//
// Copyright © 2017 Handsome.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
/////////////////////////////////////////////////////////////////////////////

import Foundation
import SceneKit

struct AxesHelper {
    
    private init() {}
    
    static func makeAxes(with settings: AxesSettings) -> SCNNode {
        
        func generateAxis(color: UIColor, rotation: SCNVector4, geometry: SCNGeometry) -> SCNNode {
            let material = SCNMaterial()
            material.diffuse.contents = color
            geometry.materials = [material]
            
            let axis = SCNNode(geometry: geometry)
            let offset = settings.axisSize.length * 0.5
            axis.pivot = SCNMatrix4MakeTranslation(0, -offset, 0)
            axis.rotation = rotation
            return axis
        }
        
        let xGeometry = settings.geometry
        guard let yGeometry = settings.geometry.copy() as? SCNGeometry,
            let zGeometry = settings.geometry.copy() as? SCNGeometry else {
                fatalError("Geometry cannot be copied")
        }
        
        let xAxisNode = generateAxis(color: settings.colors.x,
                                     rotation: SCNVector4(0, 0, 1, -.pi * 0.5),
                                     geometry: xGeometry)
        xAxisNode.name = CoordinateSystem.Axis.x
        
        let yAxisNode = generateAxis(color: settings.colors.y,
                                     rotation: SCNVector4(0, 0, 0, 0),
                                     geometry: yGeometry)
        yAxisNode.name = CoordinateSystem.Axis.y
        
        let zAxisNode = generateAxis(color: settings.colors.z,
                                     rotation: SCNVector4(1, 0, 0, .pi * 0.5),
                                     geometry: zGeometry)
        zAxisNode.name = CoordinateSystem.Axis.z
        
        let axesCenterNode = SCNNode()
        axesCenterNode.addChildNode(xAxisNode)
        axesCenterNode.addChildNode(yAxisNode)
        axesCenterNode.addChildNode(zAxisNode)
        
        axesCenterNode.name = settings.name
        axesCenterNode.transform = settings.transform
        
        return axesCenterNode
    }
    
    static func updatePivotAxesIfNeeded(for node: SCNNode) {
        guard let overlappingNode = findTheGreatestOverlappingNode(for: node) else { return }
        let lengthOfNodeBoxSide = overlappingNode.lengthOfTheGreatestSideOfNodeBox
        if lengthOfNodeBoxSide > node.lengthOfTheGreatestSideOfNodeBox {
            let newPivotAxes = AxesHelper.makeAxes(with: PivotAxesSettings.make(for: node, overlappingNode: overlappingNode))
            guard let oldPivotAxes = node.pivotAxes else {
                fatalError("Pivot axes must exist")
            }
            node.replaceChildNode(oldPivotAxes, with: newPivotAxes)
        }
    }
    
    static func findTheGreatestOverlappingNode(for node: SCNNode) -> SCNNode? {
        let worldPosition = node.convertPosition(node.position, to: nil)
        let rootNode = findRootNode(from: node)
        let hitTestResult = rootNode.hitTestWithSegment(from: SCNVector3(worldPosition.x, worldPosition.y, -100),
                                                        to: SCNVector3(worldPosition.x, worldPosition.y, 100),
                                                        options: nil)
        guard !hitTestResult.isEmpty else { return nil }
        let overlappingNodes = hitTestResult.map { $0.node }.filter { $0 != node }
        let theGreatestNode = overlappingNodes.max { $0.lengthOfTheGreatestSideOfNodeBox < $1.lengthOfTheGreatestSideOfNodeBox }
        return theGreatestNode
    }
    
    private static func findRootNode(from node: SCNNode) -> SCNNode {
        var rootNode: SCNNode = node
        while let parent = rootNode.parent {
            rootNode = parent
        }
        return rootNode
    }
}
