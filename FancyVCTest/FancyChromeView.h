//
//  FancyChromeView.h
//  FancyVCTest
//
//  Created by Johannes Weiß on 4/23/12.
//  Copyright (c) 2012 factis research GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FancyChromeView : UIView {
    CGGradientRef _savedGradient;
    
    UILabel *titleLabel;
}

@property (nonatomic, readonly, retain) UILabel *titleLabel;

@end
