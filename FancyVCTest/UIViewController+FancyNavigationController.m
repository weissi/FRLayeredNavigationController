//
//  NSViewController+FancyNavigationController.m
//  FancyVCTest
//
//  Created by Johannes Weiß on 4/20/12.
//  Copyright (c) 2012 factis research GmbH. All rights reserved.
//

#import "UIViewController+FancyNavigationController.h"

@implementation UIViewController (FancyNavigationController)

- (FancyNavigationController *)fancyNavigationController {
    UIViewController *here = self;
    
    while (here != nil) {
        if([here class] == [FancyNavigationController class]) {
            return (FancyNavigationController *)here;
        }

        here = here.parentViewController;
    }
    
    return nil;
}

@end
