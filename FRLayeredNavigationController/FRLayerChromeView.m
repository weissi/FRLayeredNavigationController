/*
 * This file is part of FRLayeredNavigationController.
 *
 * Copyright (c) 2012-2014, Johannes Weiß <weiss@tux4u.de>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * The name of the author may not be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/* Standard Library */

/* Local Imports */
#import "FRLayerChromeView.h"
#import "Utils.h"
#import "FRNavigationBar.h"
#import "FRiOSVersion.h"

@interface FRLayerChromeView () {
    UIView *_savedBackgroundView;
}

@property (nonatomic, readonly, strong) UIView *savedBackgroundView;
@property (nonatomic, assign, readonly) BOOL iOS7OrNewer;

@end

@implementation FRLayerChromeView

- (id)initWithFrame:(CGRect)frame titleView:(UIView *)titleView title:(NSString *)titleText yOffset:(CGFloat)yOffset
{
    self = [super initWithFrame:frame];
    if (self) {
        _savedGradient = nil;
        self.backgroundColor = [UIColor clearColor];

        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        _toolbar.clipsToBounds = YES;
        [_toolbar setBackgroundImage:[Utils transparentImage]
                  forToolbarPosition:UIToolbarPositionAny
                          barMetrics:UIBarMetricsDefault];
        [self addSubview:_toolbar];

        _title = titleText;
        _yOffset = yOffset;
        _iOS7OrNewer = [FRiOSVersion isIOS7OrNewer];

        if (titleView == nil) {
            UILabel *titleLabel = [[UILabel alloc] init];
            const NSDictionary *titleTextAttrs = [[FRNavigationBar appearance] titleTextAttributes];

            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.text = titleText;
            titleLabel.textAlignment = UITextAlignmentCenter;


            titleLabel.font = titleTextAttrs[UITextAttributeFont];

            titleLabel.textColor = titleTextAttrs[UITextAttributeTextColor];

            titleLabel.shadowColor = titleTextAttrs[UITextAttributeTextShadowColor];

            if (titleTextAttrs[UITextAttributeTextShadowOffset]){
                titleLabel.shadowOffset = [titleTextAttrs[UITextAttributeTextShadowOffset] CGSizeValue];
            }

            self.titleView = titleLabel;
        } else {
            self.titleView = titleView;
        }
        [self addSubview:self.titleView];
        [self manageToolbar];
    }
    return self;
}

- (void)dealloc
{
    CGGradientRelease(self->_savedGradient);
    self->_savedGradient = NULL;
}

- (void)manageToolbar
{
    UIBarButtonItem *flexibleSpace =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                      target:nil
                                                      action:nil];

    if (self.leftBarButtonItem && self.rightBarButtonItem) {
        [self.toolbar setItems:@[_leftBarButtonItem, flexibleSpace, _rightBarButtonItem]];
    } else if (self.leftBarButtonItem) {
        [self.toolbar setItems:@[_leftBarButtonItem]];
    } else if (self.rightBarButtonItem) {
        [self.toolbar setItems:@[flexibleSpace, _rightBarButtonItem]];
    }

    [self setNeedsLayout];
}

- (void)setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem
{
    _leftBarButtonItem = leftBarButtonItem;
    [self manageToolbar];
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem
{
    _rightBarButtonItem = rightBarButtonItem;
    [self manageToolbar];
}

- (void)setTitle:(NSString *)aTitle
{
    if ([self.titleView isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)self.titleView;
        label.text = aTitle;
        self->_title = aTitle;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat barButtonItemsSpace = (self.leftBarButtonItem!=nil?48:0) + (self.rightBarButtonItem!=nil?48:0);

    self.toolbar.frame = CGRectMake(0,
                                    self.yOffset,
                                    CGRectGetWidth(self.bounds),
                                    CGRectGetHeight(self.bounds)-self.yOffset);

    CGRect headerMiddleFrame = CGRectMake(10 + (barButtonItemsSpace/2),
                                          0,
                                          CGRectGetWidth(self.bounds)-20-barButtonItemsSpace,
                                          CGRectGetHeight(self.bounds)-self.yOffset);

    CGSize titleFittingSize = [self.titleView sizeThatFits:headerMiddleFrame.size];
    CGRect titleFrame = CGRectMake(0 /* irrelevant, will be overriden by centering it */,
                                   MAX((headerMiddleFrame.size.height - titleFittingSize.height)/2,
                                       headerMiddleFrame.origin.y),
                                   MIN(titleFittingSize.width, headerMiddleFrame.size.width),
                                   MIN(titleFittingSize.height, headerMiddleFrame.size.height));

    self.titleView.frame = titleFrame;
    self.titleView.center = self.center;
    self.titleView.frame = CGRectMake(CGRectGetMinX(self.titleView.frame),
                                      CGRectGetMinY(self.titleView.frame)+(self.yOffset/2),
                                      CGRectGetWidth(self.titleView.frame),
                                      CGRectGetHeight(self.titleView.frame));
}

- (CGGradientRef)gradientIOS6AndOlder
{
    if (NULL == _savedGradient) {
        CGFloat colors[12] = {
            244.0f/255.0f, 245.0f/255.0f, 247.0f/255.0f, 1.0,
            223.0f/255.0f, 225.0f/255.0f, 230.0f/255.0f, 1.0,
            167.0f/244.0f, 171.0f/255.0f, 184.0f/255.0f, 1.0,
        };
        CGFloat locations[3] = { 0.05f, 0.45f, 0.95f };

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

        _savedGradient = CGGradientCreateWithColorComponents(colorSpace,
                                                             colors,
                                                             locations,
                                                             3);

        CGColorSpaceRelease(colorSpace);
    }

    return _savedGradient;
}

- (CGGradientRef)gradientIOS7AndNewer
{
    if (NULL == _savedGradient) {
        CGFloat colors[12] = {
            248.0f/255.0f, 248.0f/255.0f, 248.0f/255.0f, 0.97f,
            248.0f/255.0f, 248.0f/255.0f, 248.0f/255.0f, 0.97f,
            248.0f/255.0f, 248.0f/255.0f, 248.0f/255.0f, 0.97f,
        };
        CGFloat locations[3] = { 0.05f, 0.45f, 0.95f };

        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

        _savedGradient = CGGradientCreateWithColorComponents(colorSpace,
                                                             colors,
                                                             locations,
                                                             3);

        CGColorSpaceRelease(colorSpace);
    }

    return _savedGradient;
}

- (UIView *)savedBackgroundView
{
    if (!_savedBackgroundView && [[FRNavigationBar appearance] backgroundImage] ){
        _savedBackgroundView = [[UIImageView alloc] initWithImage:[[FRNavigationBar appearance] backgroundImage]];
        _savedBackgroundView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        _savedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }

    return _savedBackgroundView;
}

- (void)drawRectIO6AndOlder:(__unused CGRect)rect
{
    if (self.savedBackgroundView && self.savedBackgroundView.superview == nil) {
        [self insertSubview:self.savedBackgroundView atIndex:0];
    } else {
        CGContextRef ctx = UIGraphicsGetCurrentContext();

        UIBezierPath *path =
            [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                  byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                        cornerRadii:CGSizeMake(10, 10)];
        [path addClip];

        CGPoint start = CGPointMake(CGRectGetMidX(self.bounds), 0);
        CGPoint end = CGPointMake(CGRectGetMidX(self.bounds),
                                  CGRectGetMaxY(self.bounds));

        CGGradientRef gradient = [self gradientIOS6AndOlder];

        CGContextDrawLinearGradient(ctx, gradient, start, end, 0);
    }
}

- (void)drawRectIO7AndNewer:(__unused CGRect)rect
{
    if (self.savedBackgroundView && self.savedBackgroundView.superview == nil) {
        [self insertSubview:self.savedBackgroundView atIndex:0];
    } else {
        CGContextRef ctx = UIGraphicsGetCurrentContext();

        CGPoint start = CGPointMake(CGRectGetMidX(self.bounds), 0);
        CGPoint end = CGPointMake(CGRectGetMidX(self.bounds),
                                  CGRectGetMaxY(self.bounds));

        CGGradientRef gradient = [self gradientIOS7AndNewer];

        CGContextDrawLinearGradient(ctx, gradient, start, end, 0);
    }
}

- (void)drawRect:(CGRect)rect
{
    if (self.iOS7OrNewer) {
        [self drawRectIO7AndNewer:rect];
    } else {
        [self drawRectIO6AndOlder:rect];
    }
}


@end
