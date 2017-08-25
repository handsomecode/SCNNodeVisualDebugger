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
import ARKit
import SCNNodeVisualDebugger

class DemoViewController: UIViewController {

    @IBOutlet private var sceneView: ARSCNView!
    
    private let scene = SCNScene(named: "art.scnassets/demo.scn")!
    private lazy var earthNode: SCNNode = self.scene.rootNode.childNode(withName: "Earth", recursively: true)!
    private lazy var moonNode: SCNNode = self.scene.rootNode.childNode(withName: "Moon", recursively: true)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Allows the user to manipulate the camera
        sceneView.allowsCameraControl = true
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Enable debugging on specific node by double tap by that
        sceneView.enableDebugAxesByDoubleTap = true
        
        // Earth rotation animation
        earthNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 5)))
        
        // Move Moon node to orbit
        moonNode.pivot = SCNMatrix4MakeTranslation(0, 0, 3)
        
        // Moon rotation animation
        moonNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 5)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    private func switchDebugging(on node: SCNNode) {
        //check if the node has debug axes
        if node.hasDebugAxes() {
            node.removeDebugAxes()
        } else {
            node.addDebugAxes()
        }
    }
}
