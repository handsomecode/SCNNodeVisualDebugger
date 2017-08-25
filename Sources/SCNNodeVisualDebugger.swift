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
    
    fileprivate lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 2
        return tapGestureRecognizer
    }()
    
    private lazy var nodeObserverHelper: SCNNodeObserverHelper = {
        let helper = SCNNodeObserverHelperProvider.make()
        helper.delegate = self
        return helper
    }()
    
    private override init() {
        super.init()
    }
    
    deinit {
        nodeObserverHelper.removeAllObservers()
    }
    
    func debugAxes(node: SCNNode, recursively: Bool = false) {
        guard !node.isDebugAxes else { return }
        
        removeDebuggingForNode(node)
        
        let localAxes = generateAxesFromSettings(AxesSettignsProvider.makeLocalAxesSettings(for: node))
        node.addChildNode(localAxes)
        
        let pivotAxes: SCNNode
        if SCNMatrix4IsIdentity(node.pivot) {
            pivotAxes = generateAxesFromSettings(AxesSettignsProvider.makePivotAxesSettings(for: node))
        } else {
            let lengthOfBoundingBoxSide = findTheGreatestOverlappingNode(for: node)?.lengthOfTheGreatestSideOfBoundingBox
            let axesSettings = AxesSettignsProvider.makePivotAxesSettings(for: node, customAxisLength: lengthOfBoundingBoxSide)
            pivotAxes = generateAxesFromSettings(axesSettings)
        }
        node.addChildNode(pivotAxes)
        
        nodeObserverHelper.addObserver(to: node)
        
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
    
    fileprivate func generateAxesFromSettings(_ settings: AxesSettings) -> SCNNode {
        
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

    private func removeDebuggingForNode(_ node: SCNNode) {
        if let existingLocalAxes = node.childNode(withName: CoordinateSystem.local, recursively: false) {
            existingLocalAxes.removeFromParentNode()
        }
        
        if let exsitingPivotAxes = node.childNode(withName: CoordinateSystem.pivot, recursively: false) {
            exsitingPivotAxes.removeFromParentNode()
        }
        
        nodeObserverHelper.removeObserver(from: node)
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
    fileprivate func handleDoubleTap(_ gestureRecognize: UIGestureRecognizer) {
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
    
    fileprivate func updatePivotAxesIfNeeded(for node: SCNNode) {
        guard let overlappingNode = findTheGreatestOverlappingNode(for: node) else { return }
        let lengthOfBoundingBoxSide = overlappingNode.lengthOfTheGreatestSideOfBoundingBox
        if lengthOfBoundingBoxSide > node.lengthOfTheGreatestSideOfBoundingBox {
            let axesSettings = AxesSettignsProvider.makePivotAxesSettings(for: node, customAxisLength: lengthOfBoundingBoxSide)
            let pivotAxes = generateAxesFromSettings(axesSettings)
            guard let pivotAxesOfNode = node.pivotAxes else {
                fatalError("Pivot axes must exist")
            }
            node.replaceChildNode(pivotAxesOfNode, with: pivotAxes)
        }
    }
    
    fileprivate func findTheGreatestOverlappingNode(for node: SCNNode) -> SCNNode? {
        let worldPosition = node.convertPosition(node.position, to: nil)
        let rootNode = findRootNode(from: node)
        let hitTestResult = rootNode.hitTestWithSegment(from: SCNVector3(worldPosition.x, worldPosition.y, -100),
                                                        to: SCNVector3(worldPosition.x, worldPosition.y, 100),
                                                        options: nil)
        guard !hitTestResult.isEmpty else { return nil }
        let overlappingNodes = hitTestResult.map { $0.node }
        let theGreatestNode = overlappingNodes.max { $0.lengthOfTheGreatestSideOfBoundingBox < $1.lengthOfTheGreatestSideOfBoundingBox }
        return theGreatestNode
    }
    
    private func findRootNode(from node: SCNNode) -> SCNNode {
        var rootNode: SCNNode = node
        while let parent = rootNode.parent {
            rootNode = parent
        }
        return rootNode
    }
}


//MARK: SCNNodeObserverHelperDelegate
extension SCNNodeVisualDebugger: SCNNodeObserverHelperDelegate {
    
    func nodeObserverHelperDelegate(_ helper: SCNNodeObserverHelper, didNodePivotChange node: SCNNode) {
        guard let pivotAxes = node.pivotAxes else {
            return
        }
        pivotAxes.transform = node.pivot
        updatePivotAxesIfNeeded(for: node)
    }
}
