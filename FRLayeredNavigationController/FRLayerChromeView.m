/*
 * This file is part of FRLayeredNavigationController.
 *
 * Copyright (c) 2012, Johannes Weiß <weiss@tux4u.de>
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

#import "FRLayerChromeView.h"
#import "Utils.h"
#import "FRNavigationBar.h"

@interface FRLayerChromeView ()
@property (nonatomic, readonly, strong) UIView *savedBackgroundView;

@end

@implementation FRLayerChromeView
@synthesize savedBackgroundView = _savedBackgroundView;
@synthesize title = _title;

- (id)initWithFrame:(CGRect)frame titleView:(UIView *)titleView title:(NSString *)titleText
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

        self.title = titleText;

        if (titleView == nil) {
            UILabel *titleLabel = [[UILabel alloc] init];
            const NSDictionary *titleTextAttrs = [[FRNavigationBar appearance] titleTextAttributes];

            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.text = titleText;
            titleLabel.textAlignment = UITextAlignmentCenter;


            titleLabel.font = [titleTextAttrs objectForKey:UITextAttributeFont];

            titleLabel.textColor = [titleTextAttrs objectForKey:UITextAttributeTextColor];

            titleLabel.shadowColor = [titleTextAttrs objectForKey:UITextAttributeTextShadowColor];

            if ([titleTextAttrs objectForKey:UITextAttributeTextShadowOffset]){
                titleLabel.shadowOffset = [[titleTextAttrs objectForKey:UITextAttributeTextShadowOffset] CGSizeValue];
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

    if (self.leftBarButtonItem != nil && self.rightBarButtonItem != nil) {
        [self.toolbar setItems:[NSArray arrayWithObjects:_leftBarButtonItem, flexibleSpace, _rightBarButtonItem, nil]];
    } else if(self.leftBarButtonItem != nil && self.rightBarButtonItem == nil) {
        [self.toolbar setItems:[NSArray arrayWithObject:_leftBarButtonItem]];
    } else {
        [self.toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, _rightBarButtonItem, nil]];
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

    CGFloat barButtonItemsSpace = (self.leftBarButtonItem!=nil?44:0) + (self.rightBarButtonItem!=nil?44:0);

    self.toolbar.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));

    CGRect headerMiddleFrame = CGRectMake(10 + (barButtonItemsSpace/2),
                                          0,
                                          CGRectGetWidth(self.bounds)-20-barButtonItemsSpace,
                                          CGRectGetHeight(self.bounds));

    CGSize titleFittingSize = [self.titleView sizeThatFits:headerMiddleFrame.size];
    CGRect titleFrame = CGRectMake(MAX((headerMiddleFrame.size.width - titleFittingSize.width)/2,
                                       headerMiddleFrame.origin.x),
                                   MAX((headerMiddleFrame.size.height - titleFittingSize.height)/2,
                                       headerMiddleFrame.origin.y),
                                   MIN(titleFittingSize.width, headerMiddleFrame.size.width),
                                   MIN(titleFittingSize.height, headerMiddleFrame.size.height));

    self.titleView.frame = titleFrame;
}

- (CGGradientRef)gradient
{
    if (NULL == _savedGradient) {
        CGFloat colors[12] = {
            244.0/255.0, 245.0/255.0, 247.0/255.0, 1.0,
            223.0/255.0, 225.0/255.0, 230.0/255.0, 1.0,
            167.0/244.0, 171.0/255.0, 184.0/255.0, 1.0,
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

- (void)drawRect:(CGRect)rect
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

        CGGradientRef gradient = [self gradient];

        CGContextDrawLinearGradient(ctx, gradient, start, end, 0);
    }
}

@synthesize leftBarButtonItem = _leftBarButtonItem;
@synthesize rightBarButtonItem = _rightBarButtonItem;
@synthesize toolbar = _toolbar;
@synthesize titleView = _titleView;

@end
