/*     This file is part of FancyVC.
 *
 * FancyVC is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FancyVC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with FancyVC.  If not, see <http://www.gnu.org/licenses/>.
 *
 *
 *  Copyright (c) 2012, Johannes Weiß <weiss@tux4u.de> for factis research GmbH.
 */

#import "FancyChromeView.h"

@interface FancyChromeView ()

@end

@implementation FancyChromeView

-(id)initWithFrame:(CGRect)frame titleView:(UIView *)titleView title:(NSString *)titleText
{
    self = [super initWithFrame:frame];
    if (self) {
        self->_savedGradient = nil;
        self.backgroundColor = [UIColor clearColor];
        
        if (titleView == nil) {
            UILabel *titleLabel = [[UILabel alloc] init];
            
            titleLabel.textColor = [UIColor darkGrayColor];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.shadowColor = [UIColor whiteColor];
            titleLabel.font = [UIFont boldSystemFontOfSize:22];
            titleLabel.text = titleText;
            titleLabel.textAlignment = UITextAlignmentCenter;
            
            [self addSubview:titleLabel];
        } else {
            [self addSubview:titleView];
        }
    }
    return self;
}

- (void)dealloc {
    CGGradientRelease(self->_savedGradient);
    self->_savedGradient = NULL;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect titleFrameMax = CGRectMake(5,
                                   0, 
                                   self.bounds.size.width-10,
                                   self.bounds.size.height);
    UIView *titleView = [self.subviews objectAtIndex:0];

    CGSize titleFittingSize = [titleView sizeThatFits:titleFrameMax.size];
    CGRect titleFrame = CGRectMake(MAX((titleFrameMax.size.width - titleFittingSize.width)/2, titleFrameMax.origin.x),
                                   MAX((titleFrameMax.size.height - titleFittingSize.height)/2, titleFrameMax.origin.y),
                                   MIN(titleFittingSize.width, titleFrameMax.size.width),
                                   MIN(titleFittingSize.height, titleFrameMax.size.height));        
    
    titleView.frame = titleFrame;
}

- (CGGradientRef)gradient {
    if (NULL == _savedGradient) {
        CGFloat colors[6] = {
            138.0f / 255.0f, 1.0f,
            162.0f / 255.0f, 1.0f,
            236.0f / 255.0f, 1.0f
        };
        CGFloat locations[3] = { 0.05f, 0.45f, 0.95f };
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        
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

@end
