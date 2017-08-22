//
//  GameViewController.swift
//  SceneKitSample
//
//  Created by Andrey Arzhannikov on 18.08.17.
//  Copyright © 2017 Handsome. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SCNNodeVisualDebugger

class GameViewController: UIViewController {
    
    let scene = SCNScene(named: "art.scnassets/ship.scn")!
    lazy var earthNode: SCNNode = {
        guard let earth = scene.rootNode.childNode(withName: "Earth", recursively: true) else {
            preconditionFailure("Earth node not found")
        }
        return earth
    }()
    
//    lazy var moonWrapperNode: SCNNode = {
//        guard let earth = scene.rootNode.childNode(withName: "MoonWrapper", recursively: true) else {
//            preconditionFailure("MoonWrapper node not found")
//        }
//        return earth
//    }()
    
    lazy var moonNode: SCNNode = {
        guard let earth = scene.rootNode.childNode(withName: "Moon", recursively: true) else {
            preconditionFailure("Moon node not found")
        }
        return earth
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        earthNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 5)))
        
        moonNode.pivot = SCNMatrix4MakeTranslation(0, 0, 3)
        moonNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 5)))
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        scnView.enableDebugAxesByDoubleTap = true
        
        // add a tap gesture recognizer
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//        tapGesture.numberOfTapsRequired = 2
//        scnView.addGestureRecognizer(tapGesture)
    }
    
//    @objc
//    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
//        // retrieve the SCNView
//        let scnView = self.view as! SCNView
//
//        // check what nodes are tapped
//        let p = gestureRecognize.location(in: scnView)
//        let hitResults = scnView.hitTest(p, options: [:])
//        // check that we clicked on at least one object
//        if hitResults.count > 0 {
//            // retrieved the first clicked object
//            let result = hitResults[0]
//            if result.node.hasDebugAxes() {
//                result.node.removeDebugAxes()
//            } else {
//                result.node.addDebugAxes()
//            }
//        }
//    }
}
