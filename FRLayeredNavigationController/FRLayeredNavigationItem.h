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

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@class FRLayerController;

@interface FRLayeredNavigationItem : NSObject {
    @private
    CGPoint _initialViewPosition;
    CGPoint _currentViewPosition;
    NSString *_title;
    UIView *_titleView;
    CGFloat _width;
    CGFloat _nextItemDistance;
    BOOL _hasChrome;
    FRLayerController __weak * _layerController;
}

@property (nonatomic, readwrite) CGPoint initialViewPosition;
@property (nonatomic, readwrite) CGPoint currentViewPosition;
@property (nonatomic, readwrite, strong) NSString *title;
@property (nonatomic, readwrite, strong) UIView *titleView;
@property (nonatomic, readwrite) CGFloat width;
@property (nonatomic, readwrite) CGFloat nextItemDistance;
@property (nonatomic, readwrite) BOOL hasChrome;
@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

@end
