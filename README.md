FRLayeredNavigationController
=============================

FRLayeredNavigationController, an iOS container view controller with an API
similar to UINavigationController.

Official Project Home: https://github.com/weissi/FRLayeredNavigationController

See below for documentation and instructions (including a screencast) on how
to add FRLayeredNavigationController to your project.

If you have further questions, feel free to [mail me](mailto:weiss@tux4u.de)!

©2012, [Johannes Weiß](mailto:weiss@tux4u.de) for
[factis research GmbH](http://www.factisresearch.com).


Documentation
=============

 - [The API documentation](http://weissi.github.com/FRLayeredNavigationController/docs/html/index.html)
 - [my blog post](http://factisresearch.blogspot.de/2012/06/uis-for-hierachical-ipad-apps.html)
 - [EuroCopa demo project](https://github.com/weissi/EuroCopaInfo)


License
=======
It's all open source but you can use it in your commercial product free of
charge. FRLayeredNavigationController is licensed under the terms of the
Modified BSD License.


Watch the demo videos
=====================
 - http://youtu.be/v_tXD_mL05E
 - http://youtu.be/q66HX2td_uc


Screenshots
===========
[![](https://github.com/weissi/FRLayeredNavigationController/raw/master/FRLayeredNavigationControllerScreenshot1.png)](https://github.com/weissi/FRLayeredNavigationController/raw/master/FRLayeredNavigationControllerScreenshot1.png)
[![](https://github.com/weissi/FRLayeredNavigationController/raw/master/FRLayeredNavigationControllerScreenshot2.png)](https://github.com/weissi/FRLayeredNavigationController/raw/master/FRLayeredNavigationControllerScreenshot2.png)


Adding FRLayeredNavigationController to your project
====================================================

FRLayeredNavigationController is compiled as static libraries. It use Xcode's
"dependent project" facilities.

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
