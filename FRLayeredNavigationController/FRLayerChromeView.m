/*     This file is part of FRLayeredNavigationController.
 *
 * FRLayeredNavigationController is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FRLayeredNavigationController is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with FRLayeredNavigationController.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 *  Copyright (c) 2012, Johannes Weiß <weiss@tux4u.de> for factis research GmbH.
 */

#import "FRLayerChromeView.h"
#import "Utils.h"

@interface FRLayerChromeView ()

@end

@implementation FRLayerChromeView

-(id)initWithFrame:(CGRect)frame titleView:(UIView *)titleView title:(NSString *)titleText
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

        if (titleView == nil) {
            UILabel *titleLabel = [[UILabel alloc] init];

            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.text = titleText;
            titleLabel.textAlignment = UITextAlignmentCenter;
            titleLabel.font = [UIFont boldSystemFontOfSize:20.5];
            titleLabel.shadowColor = [UIColor whiteColor];
            titleLabel.textColor = [UIColor colorWithRed:111.0f/255.0f
                                                   green:118.0f/255.0f
                                                    blue:126.0f/255.0f
                                                   alpha:1.0f];

            self.titleView = titleLabel;
        } else {
            self.titleView = titleView;
        }
        [self addSubview:self.titleView];
        [self manageToolbar];
    }
    return self;
}

- (void)dealloc {
    CGGradientRelease(self->_savedGradient);
    self->_savedGradient = NULL;
}

- (void)manageToolbar
{
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
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

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat barButtonItemsSpace = (self.leftBarButtonItem!=nil?44:0) + (self.rightBarButtonItem!=nil?44:0);

    self.toolbar.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);

    CGRect headerMiddleFrame = CGRectMake(10 + (barButtonItemsSpace/2),
                                          0,
                                          self.bounds.size.width-20-barButtonItemsSpace,
                                          self.bounds.size.height);

    CGSize titleFittingSize = [self.titleView sizeThatFits:headerMiddleFrame.size];
    CGRect titleFrame = CGRectMake(MAX((headerMiddleFrame.size.width - titleFittingSize.width)/2,
                                       headerMiddleFrame.origin.x),
                                   MAX((headerMiddleFrame.size.height - titleFittingSize.height)/2,
                                       headerMiddleFrame.origin.y),
                                   MIN(titleFittingSize.width, headerMiddleFrame.size.width),
                                   MIN(titleFittingSize.height, headerMiddleFrame.size.height));

    self.titleView.frame = titleFrame;
}

- (CGGradientRef)gradient {
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

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                               byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    [path addClip];

    CGPoint start = CGPointMake(CGRectGetMidX(self.bounds), 0);
    CGPoint end = CGPointMake(CGRectGetMidX(self.bounds),
                              CGRectGetMaxY(self.bounds));

    CGGradientRef gradient = [self gradient];

    CGContextDrawLinearGradient(ctx, gradient, start, end, 0);
}

@synthesize leftBarButtonItem = _leftBarButtonItem;
@synthesize rightBarButtonItem = _rightBarButtonItem;
@synthesize toolbar = _toolbar;
@synthesize titleView = _titleView;

@end
