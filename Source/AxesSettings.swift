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
    var axisSize: AxisSize { get }
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

struct AxisSize {
    let width: Float
    let length: Float
    let depth: Float
}

struct LocalAxesSettings: AxesSettings {
    var axisSize: AxisSize {
        return AxisSize(width: 0.01, length: length, depth: 0.01)
    }
    
    var geometry: SCNGeometry {
        return SCNBox(width: CGFloat(axisSize.width),
                      height: CGFloat(axisSize.length),
                      length: CGFloat(axisSize.depth),
                      chamferRadius: 0.0)
    }
    
    var name: String = CoordinateSystem.local
    var colors: AxesColors = AxesColors(x: .red, y: .green, z: .blue)
    var transform: SCNMatrix4 = SCNMatrix4Identity
    
    private let length: Float
    
    init(axisLength: Float) {
        self.length = axisLength
    }
}

struct PivotAxesSettings: AxesSettings {
    var axisSize: AxisSize {
        return AxisSize(width: 0.005, length: length, depth: 0.001)
    }
    
    var geometry: SCNGeometry {
        return SCNBox(width: CGFloat(axisSize.width),
                      height: CGFloat(axisSize.length),
                      length: CGFloat(axisSize.depth),
                      chamferRadius: 0.0)
    }
    
    var name: String = CoordinateSystem.pivot
    var colors: AxesColors = AxesColors(x: .magenta, y: .yellow, z: .cyan)
    var transform: SCNMatrix4 {
        return pivotTransform
    }
    
    private let length: Float
    private let pivotTransform: SCNMatrix4
    
    init(axisLength: Float, pivotTransform: SCNMatrix4) {
        self.length = axisLength
        self.pivotTransform = pivotTransform
    }
}

struct AxesSettignsProvider {
    static func makeLocalAxesSettings(for node: SCNNode, customAxisLength: Float? = nil) -> AxesSettings {
        let length = customAxisLength ?? node.lengthOfTheGreatestSideOfBoundingBox
        return LocalAxesSettings(axisLength: length)
    }

    static func makePivotAxesSettings(for node: SCNNode, customAxisLength: Float? = nil) -> AxesSettings {
        let length = customAxisLength ?? (node.lengthOfTheGreatestSideOfBoundingBox * 1.5)
        return PivotAxesSettings(axisLength: length, pivotTransform: node.pivot)
    }
}
