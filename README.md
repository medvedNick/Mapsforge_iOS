Mapsforge_iOS
=============

Annotations
=============
In the original Mapsforge library for iOS by medvednick <medvednick@yandex.ru>, a mistake in the mercator projection caused an issue while showing offline maps at a high ground resolution.

Rebased the project to the current development-Tree of the Mapbox-IOS-SDK for much better performance, new Annotation system and general error correction (https://github.com/mapbox/mapbox-ios-sdk).

Added AES256 encryption support for map files.

In this fork, the mercator projection error is fixed and a very minimalistic theme was applied.
 
If you have questions regarding the changes, feel free to contagt me via email (stephan@contagt.com).

Major thanks to medvednick for his expansive work on this port!


Original Readme
=============

This is Objective-C analog for some part of Mapsforge library for Android, which you can find there: http://code.google.com/p/mapsforge/ 

MapsforgeReader allows iOS applications to read compact .map files with vector maps. There is an example, which should be working without any settings.

This example is a simple view controller with modified RouteMe mapView on it. It consists of sub projects, and these ones have been changed or made by me:

1. MapsforgeReader. It parses .map file into primitives. This is almost copy-paste from Android's sources, but in obj-c, converted by me with help of java2objc tool (http://code.google.com/p/java2objc/). Note: the way to improve parser is to use j2objc (https://code.google.com/p/j2objc/) instead.

2. OpenStreetPad. This is project from here https://github.com/beelsebob/OpenStreetPad with some changes. I took CoreGraphics renderer from that project.

3. RouteMe. I made some changes like asynchronous tile loading and changing data source and renderer to my ones.

Another sub projects like Proj4 or sqlite were not changed, but I added them to make example project run without additional job.

Note: the last changes of Mapsforge_iOS  had beed done in summer 2012, and some things can be changed.

Feel free to contact me with any questions: medvednick@yandex.ru.