//
//  FancyNavigationController.h
//  FancyVCTest
//
//  Created by Johannes Weiß on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FancyNavigationController : UIViewController {
    NSMutableArray *viewControllers;
    CGRect savedFirstFrame;
    CGRect savedSecondFrame;
    BOOL firstAndSecondBound;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController;
- (void)popViewController;
- (void)pushViewController:(UIViewController *)viewController behind:(UIViewController *)anchorViewController animated:(BOOL)animated;

@property (nonatomic, readonly, retain) NSArray *viewControllers;

@end
