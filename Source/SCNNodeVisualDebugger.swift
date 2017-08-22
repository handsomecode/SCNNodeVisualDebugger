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

import UIKit
import SceneKit

class SCNNodeVisualDebugger: NSObject {
    
    static let shared = SCNNodeVisualDebugger()
    
    var enableDebugAxesByDoubleTap: Bool = false
    
    private var observations = [SCNNode: NSKeyValueObservation]()
    
    private lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 2
        return tapGestureRecognizer
    }()
    
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
        
        let localAxes = generateAxesFromSettings(AxesSettignsFactory.makeLocalAxesSettings(for: node))
        node.addChildNode(localAxes)
        
        let pivotAxes: SCNNode
        if SCNMatrix4IsIdentity(node.pivot) {
            pivotAxes = generateAxesFromSettings(AxesSettignsFactory.makePivotAxesSettings(for: node))
        } else {
            let maxValue = maxDimensionValueOfOverlappingNodes(for: node)
            let axesSettings = AxesSettignsFactory.makePivotAxesSettings(for: node, axisLength: CGFloat(maxValue))
            pivotAxes = generateAxesFromSettings(axesSettings)
        }
        node.addChildNode(pivotAxes)
        
        let observation = node.observe(\.pivot) { node, change in
            pivotAxes.transform = node.pivot
            
            self.updatePivotAxesIfNeeded(for: node)
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
    
    private func generateAxesFromSettings(_ settings: AxesSettings) -> SCNNode {
        
        func generateAxis(color: UIColor, rotation: SCNVector4, geometry: SCNGeometry) -> SCNNode {
            let material = SCNMaterial()
            material.diffuse.contents = color
            geometry.materials = [material]
            
            let axis = SCNNode(geometry: geometry)
            let offset = Float(settings.dimensions.length * 0.5)
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


//MARK: DebuggingByDoubleTap
extension SCNNodeVisualDebugger {
    
    func addDoubleTapGestureRecognizer(to view: SCNView) {
        view.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    func removeDoubleTapGestureRecognizer(from view: SCNView) {
        view.removeGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    @objc
    private func handleDoubleTap(_ gestureRecognize: UIGestureRecognizer) {
        guard let scnView = gestureRecognize.view as? SCNView else {
            fatalError("View must be type SCNView")
        }
        
        let point = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(point, options: [:])
        if let node = hitResults.first?.node {
            if node.hasDebugAxes() {
                node.removeDebugAxes()
            } else {
                node.addDebugAxes()
            }
        }
    }
}


//MARK: Pivot Axes Helper
extension SCNNodeVisualDebugger {
    private func updatePivotAxesIfNeeded(for node: SCNNode) {
        let maxValue = maxDimensionValueOfOverlappingNodes(for: node)
        if maxValue > axisLength(for: node) {
            let axesSettings = AxesSettignsFactory.makePivotAxesSettings(for: node, axisLength: CGFloat(maxValue))
            let pivotAxes = generateAxesFromSettings(axesSettings)
            node.replaceChildNode(node.pivotAxes!, with: pivotAxes)
        }
    }
    
    private func maxDimensionValueOfOverlappingNodes(for node: SCNNode) -> Float {
        let overlappinNodes = findOverlappingNodes(for: node)!
        
        let nodeMaxDimensionValue = axisLength(for: node)
        var maxDimensionValue = nodeMaxDimensionValue
        overlappinNodes.forEach {
            if axisLength(for: $0) > maxDimensionValue {
                maxDimensionValue = axisLength(for: $0)
            }
        }
        
        return maxDimensionValue
    }
    
    func findOverlappingNodes(for node: SCNNode) -> [SCNNode]? {
        let rootNode = findRootNode(from: node)
        
        let worldPosition = node.convertPosition(node.position, to: nil)
        let hitTestResult = rootNode.hitTestWithSegment(from: SCNVector3(worldPosition.x, worldPosition.y, -100),
                                                        to: SCNVector3(worldPosition.x, worldPosition.y, 100),
                                                        options: nil)
        return hitTestResult.map { $0.node }
    }
    
    func findRootNode(from node: SCNNode) -> SCNNode {
        var rootNode: SCNNode = node
        while let parent = rootNode.parent {
            rootNode = parent
        }
        return rootNode
    }
    
    private func axisLength(for node: SCNNode) -> Float {
        return node.geometry?.maxDimensionValue ?? node.maxDimensionValue
    }
}
