Cat2Cat (Catalog to Category)
=========
----
`Cat2Cat` exists to help solve the typo problem with UIImage's `imageNamed:` method.

Without `Cat2Cat`, you can be left wondering where your background image named `backgroundImage` is, only to discover that you've set up a `[UIImage imageNamed:@"backrgoundImage"];` call by accident.

With the advent of the Asset Catalog in Xcode 5, there was a huge step in the right direction - images ceased to be tied to their filenames, and it became straightforward to centralize your image assets.

That nasty typo problem, however, still persisted. Until now.

`Cat2Cat` goes through provided Asset Catalog files and writes out their contents to a **UIImage+AssetCatalog** or **NSImage+AssetCatalog** category - each `.imageset` within an asset catalog will get its own method to call it, prefixed by `ac_` to indicate the method is from the asset catalog and to help prevent any namespace collisions.

After running `Cat2Cat` and adding the category or categories it produces, instead of calling `[UIImage imageNamed:@"backgroundImage"]`, you can now call `[UIImage ac_backgroundImage]` ensuring that you're always going to get the image you think you're getting, and giving you the benefit of autocomplete when you're trying to remember what in the hell you named that icon.

`Cat2Cat` is compatible with Xcode 5 projects which can leverage Asset Catalogs (i.e., iOS 6 and above).

##Usage
----

*Note: You should not use Cat2Cat as a Git Submodule due to issues with how submodules handle the test filenames which include accents. If you wish to keep an eye on versions through dependency management instead of manually, please use our CocoaPod, which does not contain any of the test projects.*

###Using a Pre-Compiled Binary And A Build Script
The current compiled binary can be downloaded from [the releases page](../../releases).

```
usage: Cat2Cat [options]
    -p, --base-path             Base path used for interpreting the asset catalogs and output directory
    -a, --asset-catalog         Asset catalog(s)
    -m, --method-name-prefix    Prefix for category method names. Optional; default is "ac".
    -o, --output-dir            Output directory

        --objc                  Output Objective-C category or categories
        --swift                 Output Swift class extension(s)

        --ios                   Output for iOS (UIImage)
        --osx                   Output for OS X (NSImage)

    -h, --help                  Show this message
```

Examples:

```
Cat2Cat --base-path="/Users/YourName/Desktop/YourProjectFolder" --asset-catalog="Resources/Images.xcassets" --asset-catalog="Resources/Media.xcassets" --output-dir="Categories" --objc --ios --osx
```

```
Cat2Cat --swift --ios \
	--base-path="/Users/YourName/Desktop/YourProjectFolder" \
	--asset-catalog="Resources/*.xcassets" \
    --method-name-prefix="xyz" \
	--output-dir="Categories"
```

Please see the [iOS Example App](SampleiOSApp)'s `Cat2Cat` aggregate build target for the appropriate run script for iOS only, and the [Mac Example App](SampleMacApp)'s `Cat2Cat` aggregate build target for the appropriate run script for Mac only. 

###Directly from Xcode

Download the zip of this repo using the handy link at the right. Open the .xcodeproj, select the default build scheme, then select Edit Scheme...

In the Arguments section, add five (or more) Arguments Passed On Launch to the build scheme:

- The base directory for both asset catalogs and the generated categories/extensions (e.g., the path to your project):  
  ```
  --base-path="/Users/YourName/Desktop/YourProjectFolder"
  ```
- The path within your project to your asset catalog, without a preceding slash (add multiple times if you have multiple asset catalogs):  
  ```
  --asset-catalog="Resources/Images.xcassets"
  ```  
  ```
  --asset-catalog="Resources/Media.xcassets"
  ```
- The prefix for the category method names. If not specified, the default is `ac`. Must be at least 2 characters, and conform to valid method naming rules:
  ```
  --method-name-prefix="xyz"
  ```
- The path within your project where you wish to have your Category written out to, without a preceding slash:  
  ```
  --output-dir="Categories"
  ```
- A flag(s) indicating whether to generate Objective-C category/categories or Swift class extensions or both:  
  ```
  --objc
  ```  
  ```
  --swift
  ```
- A flag(s) indicating whether to generate for iOS (`UIImage`) or OS X (`NSImage`) or both:  
  ```
  --ios
  ```  
  ```
  --osx
  ```

After you've added your launch arguments, build and run the application. Your new category or categories should be output to the file path you've provided.

##Notes
----
* Any image name containing invalid method name characters (anything other than a-z,A-Z,0-9, and an underscore) in the Asset Catalog will have those characters replaced in the method signature with underscores. For example while "AssetName" would become `ac_AssetName`, "Asset Name" will become `ac_Asset_Name`. 

* Relatedly, characters in image names with accents or other decorations will generally have the letter without the accent then an underscore. For example , an image named "Fiancée Photo" in your asset catalog will be become `ac_Fiance_e_Photo`.

* The first time you run this application, you will need to drag the category files into your project in order for your project to see the files. On subsequent runs, you will be able to see the changes immediately since Xcode already knows about them.

* Any time after the first time you run `Cat2Cat`, it completely replaces the contents of the files rather than only updating what's changed. Therefore, you should not make any manual changes to these files.

* If you have more than one image with the same name, either in the same asset catalog or in different asset catalogs, you will get a "Duplicate Declaration of Method" warning from the compiler when you attempt to compile the project which is using `UIImage+AssetCatalog` or `NSImage+AssetCatalog`. 

* [XcodeAutoBasher](https://github.com/vokal/XcodeAutoBasher) can be used to automatically run a script to use Cat2Cat whenever you change anything within an asset catalog.

##Limitations
----
* `.launchimage`, `.iconset` and `.appiconset` folders are not supported on iOS, since they are not directly supported by `UIImage`'s `imageNamed:` scheme. If you need to use your app icon or launch image in your application, please add it as a standard `.imageset`. 

* `.iconset` and `.appiconset` *do* return images on OS X, but they appear to be of a single size. Would love to hear more from Mac developers about whether this would be the expected behavior if you wanted to access your App Icon. Support has been added for what does get returned for now. 


##Contributors
----
* [Ellen Shapiro](https://github.com/designatednerd)
* [Bryan Luby](https://github.com/bryanluby)
* [Isaac Greenspan](https://github.com/vokal-isaac)