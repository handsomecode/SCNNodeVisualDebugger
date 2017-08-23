//
//  SCNodeVisualDebuggerTests.swift
//  SCNodeVisualDebuggerTests
//
//  Created by Andrey Arzhannikov on 17.08.17.
//  Copyright © 2017 Handsome. All rights reserved.
//

import XCTest
import SceneKit

@testable import SCNNodeVisualDebugger

class SCNNodeVisualDebuggerTests: XCTestCase {
    
    var node: SCNNode!
    
    override func setUp() {
        super.setUp()
        node = SCNNode()
    }
    
    override func tearDown() {
        super.tearDown()
        node.childNodes.forEach { $0.removeFromParentNode() }
    }
    
    func testAddDebugAxesSuccess() {
        node.addDebugAxes()
        
        XCTAssertTrue(node.hasDebugAxes())
        XCTAssertEqual(node.childNodes.count, 2)
    }
    
    func testRemoveDebugAxesSuccess() {
        node.addDebugAxes()
        XCTAssertTrue(node.hasDebugAxes())
        
        node.removeDebugAxes()
        XCTAssertFalse(node.hasDebugAxes())
        XCTAssertEqual(node.childNodes.count, 0)
    }
    
    func testHasDebugAxesSuccess() {
        node.addDebugAxes()
        
        let hasLocalDebugAxis = node.childNode(withName: CoordinateSystem.local, recursively: false) != nil
        let hasPivotDebugAxis = node.childNode(withName: CoordinateSystem.pivot, recursively: false) != nil
        
        XCTAssertTrue(hasLocalDebugAxis)
        XCTAssertTrue(hasPivotDebugAxis)
    }
    
    func testLocalAndPivotTransformsAreEqualSuccesful() {
        node.addDebugAxes()
        
        guard let localNode = node.childNode(withName: CoordinateSystem.local, recursively: false),
        let pivotNode = node.childNode(withName: CoordinateSystem.pivot, recursively: false) else {
            XCTFail()
            return
        }
        let isTransformsEqual = SCNMatrix4EqualToMatrix4(localNode.transform, pivotNode.transform)
        XCTAssertTrue(isTransformsEqual)
    }
    
    func testPivotTransformIsDifferentFromLocalOneSuccesful() {
        node.addDebugAxes()
        
        guard let localNode = node.childNode(withName: CoordinateSystem.local, recursively: false),
            let pivotNode = node.childNode(withName: CoordinateSystem.pivot, recursively: false) else {
                XCTFail()
                return
        }
        
        node.pivot = SCNMatrix4MakeTranslation(10, 0, 0)
        
        let isTransformsEqual = SCNMatrix4EqualToMatrix4(localNode.transform, pivotNode.transform)
        XCTAssertFalse(isTransformsEqual)
    }
    
    func testCorrectAxesColors() {
        node.addDebugAxes()
        
        guard let localNode = node.childNode(withName: CoordinateSystem.local, recursively: false),
            let pivotNode = node.childNode(withName: CoordinateSystem.pivot, recursively: false) else {
                XCTFail()
                return
        }
        
        XCTAssertEqual(localNode.childNodes[0].colorOfMaterial, UIColor.red)
        XCTAssertEqual(localNode.childNodes[1].colorOfMaterial, UIColor.green)
        XCTAssertEqual(localNode.childNodes[2].colorOfMaterial, UIColor.blue)
        
        XCTAssertEqual(pivotNode.childNodes[0].colorOfMaterial, UIColor.magenta)
        XCTAssertEqual(pivotNode.childNodes[1].colorOfMaterial, UIColor.yellow)
        XCTAssertEqual(pivotNode.childNodes[2].colorOfMaterial, UIColor.cyan)
    }
}

//MARK: Helpers
extension SCNNode {
    var colorOfMaterial: UIColor {
        guard let color = self.geometry?.firstMaterial?.diffuse.contents as? UIColor else {
            preconditionFailure("color not found")
        }
        return color
    }
}
