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
    
    func addDebugAxes(to node: SCNNode, recursively: Bool = false) {
        guard !node.isDebugAxes else { return }
        
        removeDebuggingForNode(node)
        
        let localAxes = AxesHelper.makeAxes(with: LocalAxesSettings.make(for: node))
        node.addChildNode(localAxes)
        
        let pivotAxes: SCNNode
        if SCNMatrix4IsIdentity(node.pivot) {
            pivotAxes = AxesHelper.makeAxes(with: PivotAxesSettings.make(for: node))
        } else {
            let overlappingNode = AxesHelper.findTheGreatestOverlappingNode(for: node)
            pivotAxes = AxesHelper.makeAxes(with: PivotAxesSettings.make(for: node, overlappingNode: overlappingNode))
        }
        node.addChildNode(pivotAxes)
        
        nodeObserverHelper.addObserver(to: node)
        
        if recursively {
            node.childNodes.forEach { addDebugAxes(to: $0, recursively: true) }
        }
    }
    
    func removeDebugAxes(from node: SCNNode, recursively: Bool = false) {
        removeDebuggingForNode(node)
        
        if recursively {
            node.childNodes.forEach { removeDebugAxes(from: $0, recursively: true) }
        }
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


//MARK: SCNNodeObserverHelperDelegate
extension SCNNodeVisualDebugger: SCNNodeObserverHelperDelegate {
    
    func nodeObserverHelperDelegate(_ helper: SCNNodeObserverHelper, didNodePivotChange node: SCNNode) {
        guard let pivotAxes = node.pivotAxes else {
            return
        }
        pivotAxes.transform = node.pivot
        AxesHelper.updatePivotAxesIfNeeded(for: node)
    }
}
