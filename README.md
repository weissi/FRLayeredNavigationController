FRLayeredNavigationController
=============================

FRLayeredNavigationController, an iOS container view controller with an API
similar to UINavigationController.

Project home: https://github.com/weissi/FRLayeredNavigationController

(c)2012, Johannes Weiß <weiss@tux4u.de> for factis research GmbH
(http://www.factisresearch.com).

License
=======
LGPL 3 (see COPYING and COPYING.LESSER)

Watch the demo videos
=====================
 - http://youtu.be/v_tXD_mL05E
 - http://youtu.be/q66HX2td_uc

Adding FRLayeredNavigationController to your project
====================================================

FRLayeredNavigationController is compiled as static libraries. It use Xcode's
"dependent project" facilities.

Here is how:  **Estimated time:** 5 minutes.

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
   "FRLayeredNavigationController/FRLayeredNavigationController" directory.

5. While you are in Project Settings, go to "Other Linker Flags" under the
   "Linker" section, and add "-ObjC", "-fobjc-arc" and "-all_load" to the list
  of flags.

6. You're ready to go.  Just #import
   "FRLayeredNavigationController/FRLayeredNavigation.h" anywhere you want to
   use FRLayeredNavigationController in your project.

