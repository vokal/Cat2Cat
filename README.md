Cat2Cat (Catalog to Category)
=========
----
`Cat2Cat` exists to help solve the typo problem with UIImage's `imageNamed:` method. 

Without `Cat2Cat`, you can be left wondering where your background image named `backgroundImage` is, only to discover that you've set up a `[UIImage imageNamed:@"backrgoundImage"];` call by accident. 

With the advent of the Asset Catalog in Xcode 5, there was a huge step in the right direction - images ceased to be tied to their filenames, and it became straightforward to centralize your image assets.

That nasty typo problem, however, still persisted. Until now. 

`Cat2Cat` goes through provided Asset Catalog files and writes out their contents to a **UIImage+AssetCatalog** category - each `.imageset` within an asset catalog will get its own method to call it, prefixed by `ac_` to indicate the method is from the asset catalog and to help prevent any namespace collisions. 

After running `Cat2Cat` and adding the category or categories it produces, instead of calling `[UIImage imageNamed:@"backgroundImage"]`, you can now call `[UIImage ac_backgroundImage]` ensuring that you're always going to get the image you think you're getting, and giving you the benefit of autocomplete when you're trying to remember what in the hell you named that icon.  

`Cat2Cat` is compatible with Xcode 5 projects which can leverage Asset Catalogs (i.e., iOS 6 and above).

##Usage
----
###Directly from Xcode

Download the zip of this repo using the handy link at the right. Open the .xcodeproj, select the default build scheme, then select Edit Scheme...

In the Arguments section, add three Arguments Passed On Launch to the build scheme, in this order:

1. The path to your project. (e.g. /Users/YourName/Desktop/YourProjectFolder)
2. The paths within your project to your asset catalog, without a preceding slash, separated by a pipe if there's more than one. (e.g. Resources/Images.xcassets|Resources/Media.xcassets).
3. The path within your project where you wish to have your Category written out to, without a preceding slash. (e.g. Categories).

After you've added your launch arguments, build and run the application. Your new category should be output to the file path you've provided.

###Using a Pre-Compiled Binary And A Build Script
The current compiled binary can be downloaded from [this link](SampleiOSApp/ImageNamerExample/ImageNamerExample/Utilities/Cat2Cat).

Please see the [iOS Example App](SampleiOSApp)'s `Cat2Cat` aggregate build target for the appropriate run script. 

##Notes
----
* Any image name containing spaces in the Asset Catalog will have those spaces replaced in the method signature with underscores. For example while "AssetName" would become `ac_AssetName`, "Asset Name" will become `ac_Asset_Name`. 

* The first time you run this application, you will need to drag the category files into your project in order for your project to see the files. On subsequent runs, you will be able to see the changes immediately since Xcode already knows about them.

* Any time after the first time you run `Cat2Cat`, it completely replaces the contents of the files rather than only updating what's changed. Therefore, you should not make any manual changes to these files.

* If you have more than one image with the same name, either in the same asset catalog or in different asset catalogs, you will get a "Duplicate Declaration of Method" warning from the compiler when you attempt to compile the project which is using `UIImage+AssetCatalog`. 


##Limitations
----
* Does not bail out if it detects characters which are not acceptable in method names. These will cause a build error when you attempt to compile the project which is using UIImage+AssetCatalog.

* `.iconset` and `.appiconset` folders are not supported, since they are not supported by the `imageNamed:` scheme. If you need to use your app icon in your application, add it as a standard `.imageset`. 

##Contributors
----
* [Ellen Shapiro](https://github.com/designatednerd)
* [Bryan Luby](https://github.com/bryanluby)