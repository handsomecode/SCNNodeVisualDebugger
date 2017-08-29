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

extension SCNNode {
    var isDebugAxes: Bool {
        return self.name == CoordinateSystem.local ||
            self.name == CoordinateSystem.pivot ||
            self.name == CoordinateSystem.Axis.x ||
            self.name == CoordinateSystem.Axis.y ||
            self.name == CoordinateSystem.Axis.z
    }
    
    var hasLocalDebugAxes: Bool {
        return self.childNode(withName: CoordinateSystem.local, recursively: false) != nil
    }
    
    var hasPivotDebugAxes: Bool {
        return pivotAxes != nil
    }
    
    var pivotAxes: SCNNode? {
        return self.childNode(withName: CoordinateSystem.pivot, recursively: false)
    }
    
    var lengthOfTheGreatestSideOfNodeBox: Float {
        return self.geometry?.lengthOfTheGreatestSide ?? self.lengthOfTheGreatestSide
    }
}
