FRLayeredNavigationController
=============================

FRLayeredNavigationController, an iOS container view controller with an API
similar to UINavigationController. Influenced by the UI of the Twitter and
Soundcloud iPad apps, the user will think of a stack of paper and has similar
interaction options.

Official Project Home: https://github.com/weissi/FRLayeredNavigationController

See below for documentation and instructions (including a screencast) on how
to add FRLayeredNavigationController to your project.

If you have further questions, feel free to [mail me](mailto:weiss@tux4u.de)!

[![Flattr this git repo](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=JohannesWeiss&url=https://github.com/weissi/FRLayeredNavigationController&title=FRLayeredNavigationController&language=&tags=github&category=software)

©2012, [Johannes Weiß](mailto:weiss@tux4u.de) for
[factis research GmbH](http://www.factisresearch.com).


Documentation
=============

 - [The API Documentation](http://weissi.github.com/FRLayeredNavigationController/docs/html/index.html)
 - [Blog Post](http://factisresearch.blogspot.de/2012/06/uis-for-hierachical-ipad-apps.html)
 - [EuroCopa Demo Project](https://github.com/weissi/EuroCopaInfo)


Features
========

 - The [API](http://weissi.github.com/FRLayeredNavigationController/docs/html/index.html)
   feels very natural to iOS developers since it's very similar to the API of
   `UINavigationController`
 - FRLayeredNavigationController uses ARC (automatic reference counting) but you
   can use it in your legacy projects without ARC, too
 - Low memory conditions and rotation are handled correctly with
   FRLayeredNavigationController
 - FRLayeredNavigationController works on the iPad, the iPhone and iPod touch
   but the UI concept is best on the iPad since the big screen
 - You can easily install FRLayeredNavigationController using
   [CocoaPods](http://cocoapods.org/) or manually (screencast and instructions
   below)
 - Correctly handles `view.frame` and `view.bounds` and has therefore no
   problems with `view.transform` (such as rotations) as you can see on this
   [screenshot](https://github.com/weissi/FRLayeredNavigationController/raw/master/FRLayeredNavigationControllerRotation.png).
 - *App Store* compatible (uses only Public API and was already approved by
   Apple)


License
=======
It's all open source but you can use it in your commercial product free of
charge. FRLayeredNavigationController is licensed under the terms of the
Modified BSD License.


Demo Videos
===========
 - http://youtu.be/v_tXD_mL05E
 - http://youtu.be/q66HX2td_uc


Screenshots
===========
[![](https://github.com/weissi/FRLayeredNavigationController/raw/master/FRLayeredNavigationControllerScreenshot1.png)](https://github.com/weissi/FRLayeredNavigationController/raw/master/FRLayeredNavigationControllerScreenshot1.png)
[![](https://github.com/weissi/FRLayeredNavigationController/raw/master/FRLayeredNavigationControllerScreenshot2.png)](https://github.com/weissi/FRLayeredNavigationController/raw/master/FRLayeredNavigationControllerScreenshot2.png)


Known Users
===========

###[RecordBox](http://myrecordbox.com) ([App Store](http://itunes.apple.com/us/app/recordbox/id480534869?mt=8))###
[![](http://a4.mzstatic.com/us/r1000/093/Purple/v4/50/61/93/50619376-7243-bf68-2192-d11bc8687106/mza_4403044630314584279.175x175-75.jpg)](http://myrecordbox.com)

###[Checkpad MED](http://www.lohmann-birkner.de/lohmann/wDeutsch/HP_Checkpad/Index.php?navanchor=11610074)###
[![](http://www.lohmann-birkner.de/lohmann/wMedia/headlogos/lub_hcc.gif)](http://www.lohmann-birkner.de/lohmann/wEnglish/HP_Checkpad/index.php?navanchor=13510008)


Adding FRLayeredNavigationController to your project
====================================================

FRLayeredNavigationController is compiled as static libraries. It use Xcode's
"dependent project" facilities. If you're familiar with
[CocoaPods](http://cocoapods.org/) use that, just add the `dependency
'FRLayeredNavigationController'` to your `Podfile`.

Here is how:  **Estimated time:** 5 minutes.

There's also a screencast which shows how to add
FRLayeredNavigationController to a project and how to switch from
UINavigationController to FRLayeredNavigationController:
http://youtu.be/k9bFAYtoenw .

1. Clone the FRLayeredNavigationController git repository: `git clone
   git@github.com:weissi/FRLayeredNavigationController.git`.  Make sure you
   store the repository in a permanent place because Xcode will need to reference
   the files every time you compile your project.

2. Locate the "FRLayeredNavigationController.xcodeproj" file under
   "`FRLayeredNavigationController`". Drag
   FRLayeredNavigationController.xcodeproj and drop it onto the root of your Xcode
   project's "Groups and Files"  sidebar.

3. Now you need to link the FRLayeredNavigationController static libraries to
   your project. Add `libFRLayeredNavigationController.a` to the `Link Binary
   With Libraries` section of your project's Build phases.

4. Finally, we need to tell your project where to find the
   FRLayeredNavigationController headers.  Open your "Project Settings" and go
   to the "Build" tab. Look for "Header Search Paths" and double-click it.  Add the
   relative path from your project's directory to the
   "FRLayeredNavigationController/" directory.

5. While you are in Project Settings, go to "Other Linker Flags" under the
   "Linker" section, and add "`-ObjC`", "`-fobjc-arc`" and "`-all_load`" to the
   list of flags.

6. You're ready to go.
   Just `#import "FRLayeredNavigationController/FRLayeredNavigation.h"`
   anywhere you want to use FRLayeredNavigationController in your project.

If you want to, you can install [appledoc](http://gentlebytes.com/appledoc/)
and type `appledoc .` in FRLayeredNavigationController's root directory to
install the API documentation in Xcode.
