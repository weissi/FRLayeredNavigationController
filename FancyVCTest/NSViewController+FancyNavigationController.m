//
//  NSViewController+FancyNavigationController.m
//  FancyVCTest
//
//  Created by Johannes Weiß on 4/20/12.
//  Copyright (c) 2012 factis research GmbH. All rights reserved.
//

#import "NSViewController+FancyNavigationController.h"

@implementation UIViewController (FancyNavigationController)

- (FancyNavigationController *)fancyNavigationController {
    UIViewController *here = self;
    
    while (here != nil) {
        NSLog(@"walking up, currently at %@", [[here class] description]);
        if([here class] == [FancyNavigationController class]) {
            return (FancyNavigationController *)here;
        }
        NSLog(@"my class: %@, parent class: %@", [[here class] description], [[self.parentViewController class] description]);
        //NSAssert(here != self.parentViewController, @"VC is parent of itself!");
        here = here.parentViewController;
    }
    
    return nil;
}

@end
