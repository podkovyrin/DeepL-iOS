# DeepL iOS Client

[![CI Status](https://img.shields.io/travis/podkovyrin/DeepL-iOS.svg?style=flat)](https://travis-ci.org/podkovyrin/DeepL-iOS) [![License](https://img.shields.io/badge/license-MIT-green)](https://github.com/podkovyrin/DeepL-iOS/blob/master/LICENSE) [![Platform](https://img.shields.io/badge/platform-iOS-blue)](https://github.com/podkovyrin/DeepL-iOS)

This is **not official** [DeepL](https://deepl.com) translator iOS app written in Swift.

<p align="center">
<img src="https://github.com/podkovyrin/DeepL-iOS/raw/master/_assets/deepl_main_screen.png?raw=true" alt="DeepL iOS Screenshot" height="320">
</p>

## Features
- iPhone / iPad support, multitasking
- Gracefully handles all API errors
- Built-in retry with exponential timeout on network errors
- Testable architecture
- iOS 13 Dark Mode support
- Dynamic Type support
- Accessibility optimized (VoiceOver, etc.)

## Getting Started

Just open `DeepL.xcodeproj` in Xcode.

## Requirements

- Xcode 11
- iOS 11 or later

## Notes

DeepL API auth key is not provided with the source code. The app runs in demo mode using mocked server responses. For real use, set the auth key in `AppCoordinator.swift`.

## Implementation Details

The app is written with bare minimum dependencies. In fact, only one dependency is used: [ANOperations](https://github.com/podkovyrin/ANOperations) - a *homegrown* [Advanced Operations](https://developer.apple.com/videos/wwdc/2015/?id=226) implementation integrated as a Swift Package.

App architecture is based on a Coordinator pattern ([[1]](http://khanlou.com/2015/01/the-coordinator/), [[2]](http://khanlou.com/2015/10/coordinators-redux/), [[3]](https://davedelong.com/blog/tags/a-better-mvc/)).

Despite the fact that all UI is done in code, UIViewControllers are light and free of any business logic.

## License

*DeepL iOS* is available under the MIT license. See the LICENSE file for more info.
