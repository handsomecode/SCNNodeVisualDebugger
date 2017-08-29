# SCNNodeVisualDebugger

[![Swift version](https://img.shields.io/badge/swift-3.1-orange.svg?style=flat.svg)](https://img.shields.io/badge/swift-3.0-orange.svg?style=flat.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/hexpm/l/plug.svg)](./LICENSE)

A simple tool for showing local and pivot coordinate system of [`SCNNode`](https://developer.apple.com/documentation/scenekit/scnnode?language=objc).

Initially created during experiments with ARKit + SceneKit.

![Demo](https://user-images.githubusercontent.com/8081860/29773337-bd0746f2-8c1e-11e7-9dd5-6b640d898484.gif)

### Color notation

| Coordinate System | X | Y | Z |
| --- | :---: | :---: | :---: |
| Local | ![Red](https://placehold.it/15/f00/000000?text=+) | ![Green](https://placehold.it/15/0f0/000000?text=+) | ![Blue](https://placehold.it/15/00f/000000?text=+) |
| Pivot | ![Magenta](https://placehold.it/15/f0f/000000?text=+) | ![Yellow](https://placehold.it/15/ff0/000000?text=+) | ![Cyan](https://placehold.it/15/0ff/000000?text=+) |

#### If you like this tool, please give your :star: to this repository.

# Installation

## CocoaPods
To install it through [CocoaPods](https://cocoapods.org/), add the following line to your Podfile:
```
pod 'SCNNodeVisualDebugger', :git => 'git@github.com:handsomecode/SCNNodeVisualDebugger.git'
```
Please, don't forget to run `pod update` command to update your local specs repository during migration from one version to another.

## Carthage
To install it through [Carthage](https://github.com/Carthage/Carthage), add the following line to your Cartfile:
```
github "handsomecode/SCNodeVisualDebugger"
```

# Usage

#### Importing the library to get access to API
````swift
import SCNNodeVisualDebugger
````

#### Adding debug axes to the specific node
````swift
let node: SCNNode = // provide SCNNode instance 

node.addDebugAxes()
````
If you need to add debug axes to child nodes as well you should pass a flag `recursively` as `true` as a parameter of the method. By default, `recursively` value is `false` 
````swift
node.addDebugAxes(recursively = true)
````

#### Removing debug axes from the specific node
````swift
node.removeDebugAxes()
````
If you need to remove debug axes from child nodes as well you should pass a flag `recursively` as `true` as a parameter of the method. By default, `recursively` value is `false` 
````swift
node.removeDebugAxes(recursively = true)
````
#### Checking debug axes from the specific node
````swift
if node.hasDebugAxes() {
    // some actions
}
````

#### Adding and removing debug axes to node by double tap
It can be useful to show or remove debug axes at runtime. For this purpose, you can use a double tap on a specific node. 

Set `enableDebugAxesByDoubleTap` property of `SCNView` instance to `true` to enable double tap trigger.
````swift
sceneView.enableDebugAxesByDoubleTap = true
````

#### Samples
Use [SceneKitSample](./SceneKitSample) and [ARKitSample](./ARKitSample) to see implementation details.

# Communication

- If you **need help or found a bug**, please, open an issue.
- If you **have a feature request**, open an issue.
- If you **are ready to contribute**, submit a pull request to ***develop*** branch.
- If you **like SCNNodeVisualDebugger**, please, give it a star.

You can find more details into [CONTRIBUTING](./CONTRIBUTING.md) file.

# Requirements
- iOS 9.0+
- Xcode 8.3+
- Swift 3.1+

# License
SCNNodeVisualDebugger is available under the Apache License, Version 2.0. See the [LICENSE](./LICENSE) file for more info.