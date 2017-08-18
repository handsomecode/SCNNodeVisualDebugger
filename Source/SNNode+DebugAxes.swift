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

public extension SCNNode {
    public func addDebugAxes(recursively: Bool = false) {
        SCNNodeVisualDebugger.shared.debugAxes(node: self, recursively: recursively)
    }
    
    public func removeDebugAxes(recursively: Bool = false) {
        SCNNodeVisualDebugger.shared.undebugAxes(node: self, recursively: recursively)
    }
    
    public func hasDebugAxes() -> Bool {
        return hasLocalDebugAxes && hasPivotDebugAxes
    }
}
