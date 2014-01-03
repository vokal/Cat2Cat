ImageNamer
=========
----
ImageNamer exists to help solve the typo problem with UIImage's imageNamed method. Without ImageNamer, you can be left wondering where your background image named `backgroundImage` is, only to discover that you've set up a `[UIImage imageNamed:@"backrgoundImage"];` call by accident. 

With the advent of the Asset Catalog in Xcode 5, there was a huge step in the right direction - images ceased to be tied to their filenames, and it became straightforward to centralize your image assets.

That nasty typo problem, however, still persisted. Until now. 

ImageNamer goes through an AssetCatalog file and writes out its contents to a **UIImage+AssetCatalog\_YourCatalogName** category - each `.imageset` within an asset catalog will get its own method to call it, prefixed by ac_ to indicate the method is from the asset catalog and to help prevent any namespace collisions. 

After running ImageNamer and adding the category or categories it produces, instead of calling `[UIImage imageNamed:@"backgroundImage"]`, you can now call `[UIImage ac_backgroundImage]` ensuring that you're always going to get the image you think you're getting, and giving you the benefit of autocomplete when you're trying to remember what in the hell you named that icon.  

Note: Any image name containing spaces will have those spaces replaced in the method signature with underscores. 

ImageNamer is compatible with Xcode 5 projects targeting iOS 7 and above.*

\** - possibly also iOS 6, still need to investigate.*

##Usage
----
To use image namer, download the zip of this repo using the handy link at the right. Open the .xcodeproj, select the default build scheme, then select Edit Scheme...

In the Arguments section, add three Arguments Passed On Launch to the build scheme, in this order:

1. The path to your project. (e.g. /Users/YourName/Desktop/YourProjectFolder)
2. The path within your project to your asset catalog, without a preceding slash. (e.g. Resources/Images.xcassets)
3. The path within your project where you wish to have your Category written out to, without a preceding slash. (e.g. Categories).

After you've added your launch arguments, build and run the application. Your new category should be output to the file path you've provided.

The first time you run this application, you will need to drag the category files into your project in order for your project to see the files. On subsequent runs, 


##Limitations
----
* Asset catalogs cannot be combined into a single category yet.
* Does not automatically detect potential name collisions with other asset catalogs (Name collisions within an asset catalog will show up as a warning about a redefinition of a method)
* .appiconset and .launchimage folders are not supported at the moment - trying to definitively nail down whether they are supported by apple at all in the imageNamed scheme. 
* Currently nukes the existing files entirely before creating the new files rather than just replacing changes.
* Requires Xcode to run (though I suppose if you have need of this, you've most likely already got Xcode). 

##Contributors
----
* [Ellen Shapiro](http://github.com/designatednerd)