# VOKEmbeddedTemplateTools

Handle a zip file of mustache templates embedded into the Mach-O executable.

[![CI Status](http://img.shields.io/travis/Isaac Greenspan/VOKEmbeddedTemplateTools.svg?style=flat)](https://travis-ci.org/Isaac Greenspan/VOKEmbeddedTemplateTools)
[![Version](https://img.shields.io/cocoapods/v/VOKEmbeddedTemplateTools.svg?style=flat)](http://cocoapods.org/pods/VOKEmbeddedTemplateTools)
[![License](https://img.shields.io/cocoapods/l/VOKEmbeddedTemplateTools.svg?style=flat)](http://cocoapods.org/pods/VOKEmbeddedTemplateTools)
[![Platform](https://img.shields.io/cocoapods/p/VOKEmbeddedTemplateTools.svg?style=flat)](http://cocoapods.org/pods/VOKEmbeddedTemplateTools)

## Usage

Includes:
- a category on NSData for getting data embedded into the Mach-O executable (embedding done via "Other Linker Flags" `-sectcreate __TEXT __your_name "some_file_name"`)
- a category on [ZipZap](https://github.com/pixelglow/zipzap)'s `ZZArchive` to load an archive from data embedded into the Mach-O executable
- a [GRMustache](https://github.com/groue/GRMustache) `GRMustacheTemplateRepository` subclass that loads its templates from a `ZZArchive`

***NOTE:*** The Mach-O executable embedded data reading doesn't seem to compile when pods are set to use frameworks.

## Installation

VOKEmbeddedTemplateTools is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "VOKEmbeddedTemplateTools"
```

## Author

Isaac Greenspan, isaac.greenspan@vokal.io

## License

VOKEmbeddedTemplateTools is available under the MIT license. See the LICENSE file for more info.
