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

protocol AxesSettings {
    var dimensions: AxesDimensions { get }
    var geometry: SCNGeometry { get }
    var colors: AxesColors { get }
    var name: String { get }
    var transform: SCNMatrix4 { get }
}

struct AxesColors {
    let x: UIColor
    let y: UIColor
    let z: UIColor
}

struct AxesDimensions {
    let width: CGFloat
    let length: CGFloat
    let depth: CGFloat
}

struct LocalAxesSettings: AxesSettings {
    var dimensions: AxesDimensions {
        return AxesDimensions(width: 0.01, length: length, depth: 0.01)
    }
    
    var geometry: SCNGeometry {
        return SCNBox(width: dimensions.width,
                      height: dimensions.length,
                      length: dimensions.depth,
                      chamferRadius: 0.0)
    }
    
    var name: String = CoordinateSystem.local
    var colors: AxesColors = AxesColors(x: .red, y: .green, z: .blue)
    var transform: SCNMatrix4 = SCNMatrix4Identity
    
    private let length: CGFloat
    
    init(axisLength: CGFloat) {
        self.length = axisLength
    }
}

struct PivotAxesSettings: AxesSettings {
    var dimensions: AxesDimensions {
        return AxesDimensions(width: 0.005, length: length, depth: 0.001)
    }
    
    var geometry: SCNGeometry {
        return SCNBox(width: dimensions.width,
                      height: dimensions.length,
                      length: dimensions.depth,
                      chamferRadius: 0.0)
    }
    
    var name: String = CoordinateSystem.pivot
    var colors: AxesColors = AxesColors(x: .magenta, y: .yellow, z: .cyan)
    var transform: SCNMatrix4 {
        return pivotTransform
    }
    
    private let length: CGFloat
    private let pivotTransform: SCNMatrix4
    
    init(axisLength: CGFloat, pivotTransform: SCNMatrix4) {
        self.length = axisLength
        self.pivotTransform = pivotTransform
    }
}

struct AxesSettignsFactory {
    static func makeLocalAxesSettings(for node: SCNNode, axisLength: CGFloat? = nil) -> AxesSettings {
        let length = axisLength ?? nodeMaxDimensionValue(node)
        return LocalAxesSettings(axisLength: length)
    }
    
    static func makePivotAxesSettings(for node: SCNNode, axisLength: CGFloat? = nil) -> AxesSettings {
        let length = axisLength ?? (nodeMaxDimensionValue(node) * 1.5)
        return PivotAxesSettings(axisLength: length, pivotTransform: node.pivot)
    }
    
    private static func nodeMaxDimensionValue(_ node: SCNNode) -> CGFloat {
        return CGFloat(node.geometry?.maxDimensionValue ?? node.maxDimensionValue)
    }
}
