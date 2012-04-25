//
//  UIViewController+FancyNavigationController.h
//  FancyVCTest
//
//  Created by Johannes Weiß on 4/20/12.
//  Copyright (c) 2012 factis research GmbH. All rights reserved.
//

#import "FancyNavigationController.h"
#import "FancyNavigationItem.h"

@interface UIViewController (FancyNavigationController)

@property (nonatomic, readonly, retain) FancyNavigationController *fancyNavigationController;
@property (nonatomic, readonly, retain) FancyNavigationItem *fancyNavigationItem;


@end
