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

class SCNNodeVisualDebugger: NSObject {
    
    private enum LocalAxisSize {
        static let width: CGFloat = 0.005
        static let length: CGFloat = 0.005
    }
    
    private enum PivotAxisSize {
        static let width: CGFloat = 0.01
        static let length: CGFloat = 0.01
    }
    
    static let shared = SCNNodeVisualDebugger()
    
    private var observations = [SCNNode: NSKeyValueObservation]()
    
    private override init() {
        super.init()
    }
    
    deinit {
        observations.values.forEach { $0.invalidate() }
        observations.removeAll()
    }
    
    func debugAxes(node: SCNNode, recursively: Bool = false) {
        guard !node.isDebugAxes else { return }
        
        removeDebuggingForNode(node)
        
        let localAxes = generateLocalAxes(length: node.maxSizeValue)
        localAxes.name = CoordinateSystem.local
        node.addChildNode(localAxes)
        
        let pivotAxes = generatePivotAxes(length: node.maxSizeValue)
        pivotAxes.name = CoordinateSystem.pivot
        pivotAxes.transform = node.pivot
        node.addChildNode(pivotAxes)
        
        let observation = node.observe(\.pivot) { node, change in
            pivotAxes.transform = node.pivot
        }
        observations[node] = observation
        
        if recursively {
            node.childNodes.forEach { debugAxes(node: $0, recursively: true) }
        }
        
    }
    
    func undebugAxes(node: SCNNode, recursively: Bool = false) {
        removeDebuggingForNode(node)
        
        if recursively {
            node.childNodes.forEach { undebugAxes(node: $0, recursively: true) }
        }
    }
    
    private func generateLocalAxes(length: Float) -> SCNNode {
        let box = SCNBox(width: LocalAxisSize.width,
                         height: CGFloat(length),
                         length: LocalAxisSize.length,
                         chamferRadius: 0.0)
        return generateAxis(length: length, geometry: box)
    }
    
    private func generatePivotAxes(length: Float) -> SCNNode {
        let box = SCNBox(width: PivotAxisSize.width,
                         height: CGFloat(length),
                         length: PivotAxisSize.length,
                         chamferRadius: 0.0)
        return generateAxis(length: length, geometry: box)
    }
    
    private func generateAxis(length: Float, geometry: SCNGeometry) -> SCNNode {
        
        func generateAxis(color: UIColor, rotation: SCNVector4, geometry: SCNGeometry) -> SCNNode {
            let material = SCNMaterial()
            material.diffuse.contents = color
            geometry.materials = [material]
            
            let axis = SCNNode(geometry: geometry)
            axis.pivot = SCNMatrix4MakeTranslation(0, -length * 0.5, 0)
            axis.rotation = rotation
            return axis
        }
        
        let xGeometry = geometry
        guard let yGeometry = geometry.copy() as? SCNGeometry,
            let zGeometry = geometry.copy() as? SCNGeometry else {
                fatalError("Geometry cannot be copied")
        }
        
        let xAxisNode = generateAxis(color: .red,
                                 rotation: SCNVector4(0, 0, 1, -.pi * 0.5),
                                 geometry: xGeometry)
        let yAxisNode = generateAxis(color: .green,
                                 rotation: SCNVector4(0, 0, 0, 0),
                                 geometry: yGeometry)
        let zAxisNode = generateAxis(color: .blue,
                                 rotation: SCNVector4(1, 0, 0, .pi * 0.5),
                                 geometry: zGeometry)
        
        let axesCenterNode = SCNNode()
        axesCenterNode.addChildNode(xAxisNode)
        axesCenterNode.addChildNode(yAxisNode)
        axesCenterNode.addChildNode(zAxisNode)
        
        return axesCenterNode
    }

    private func removeDebuggingForNode(_ node: SCNNode) {
        if let existingLocalAxes = node.childNode(withName: CoordinateSystem.local, recursively: false) {
            existingLocalAxes.removeFromParentNode()
        }
        if let exsitingPivotAxes = node.childNode(withName: CoordinateSystem.pivot, recursively: false) {
            exsitingPivotAxes.removeFromParentNode()
        }
        
        if let existingObservation = observations.removeValue(forKey: node) {
            existingObservation.invalidate()
        }
    }
}
