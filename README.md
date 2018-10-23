# ![CovertOps Logo](logo-covertops.png)

[![CI Status](https://img.shields.io/travis/patricklynch/CovertOps.svg?style=flat)](https://travis-ci.org/patricklynch/CovertOps)
[![Version](https://img.shields.io/cocoapods/v/CovertOps.svg?style=flat)](https://cocoapods.org/pods/CovertOps)
[![License](https://img.shields.io/cocoapods/l/CovertOps.svg?style=flat)](https://cocoapods.org/pods/CovertOps)
![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)
[![Platform](https://img.shields.io/cocoapods/p/CovertOps.svg?style=flat)](https://cocoapods.org/pods/CovertOps)
[![Language](https://img.shields.io/badge/swift-4.2-orange.svg)](https://developer.apple.com/swift)

`CovertOps` uses the `Operation` and `OperationQueue` classes from Apple's _Foundation_ framework to provide flexible, concise and easy control over robust application behaviors that are often difficult to achieve.  This includes precise timing, mutual exclusivity, observation, thread safety, sequencing, throttling, asynchronous behavior and dependency management.

Apple's operation classes are simple and powerful but were designed decades ago in Objective-C.  This framework adds many wrappers and convenience methods for a modern, functional-inspired Swift syntax that is much faster and easier to use.  There's also a handlful of utlity operations that solve common problems and some new features added to the behavior of operations that will make your own custom subclasses much more powerful.

If you're interesting in using CoreData as well, check out [`CovertOpsData`](https://github.com/patricklynch/CovertOpsData), an extension of `CovertOps` that provides an easy, powerful and thread-safe implementation of a CoreData stack using operations to read and write from a persistent store.

## Resources
For a better unstanding of operations and the principles upon which the framework are based, see below:
- [Operation](https://developer.apple.com/documentation/foundation/operation) Apple Docs
- [OperationQueue](https://developer.apple.com/documentation/foundation/operationqueue) Apple Docs
- [Advanced NSOperations](https://developer.apple.com/videos/play/wwdc2015/226/) from WWDC 2015 by Dave Delong

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

To install using CocoaPods, add the following to your project Podfile:
```ruby
pod 'CovertOps'
```
To install using Carthage, add the following to your project Cartfile:
```ruby
github "patricklynch/CovertOps"
```

## Author

Patrick Lynch: pdlynch@gmail.com

## License

`CovertOps` is available under the MIT license. See the LICENSE file for more info.
