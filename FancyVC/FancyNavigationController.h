//
//  FancyNavigationController.h
//  FancyVCTest
//
//  Created by Johannes Weiß on 4/20/12.
//  Copyright (c) 2012 factis research GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FancyNavigationItem.h"

@interface FancyNavigationController : UIViewController {
    NSMutableArray *viewControllers;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController;

- (void)popViewControllerAnimated:(BOOL)animated;

- (void)popToRootViewControllerAnimated:(BOOL)animated;

- (void)popToViewController:(UIViewController *)vc animated:(BOOL)animated;

- (void)pushViewController:(UIViewController *)viewController
                 inFrontOf:(UIViewController *)anchorViewController
              maximumWidth:(BOOL)maxWidth
                  animated:(BOOL)animated;

- (void)pushViewController:(UIViewController *)viewController
                 inFrontOf:(UIViewController *)anchorViewController
              maximumWidth:(BOOL)maxWidth
                  animated:(BOOL)animated
             configuration:(void (^)(FancyNavigationItem *item))configuration;


@property (nonatomic, readonly, retain) NSArray *viewControllers;

@end
