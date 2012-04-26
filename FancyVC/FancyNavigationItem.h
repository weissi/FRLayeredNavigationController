//
//  FancyNavigationItem.h
//  FancyVCTest
//
//  Created by Johannes Weiß on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface FancyNavigationItem : NSObject {
    CGPoint initialViewPosition;
    CGPoint currentViewPosition;
}

@property (nonatomic, readwrite, assign) CGPoint initialViewPosition;
@property (nonatomic, readwrite, assign) CGPoint currentViewPosition;

@end
