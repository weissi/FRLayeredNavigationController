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

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@class FRLayerController;

/**
 * FRLayeredNavigationItem is used to configure one view controller layer. It is very similar to UINavigationItem .
 *
 */
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

/**
 * The view position when the layers are compacted maximally.
 */
@property (nonatomic, readonly) CGPoint initialViewPosition;

/**
 * The current view position.
 */
@property (nonatomic, readonly) CGPoint currentViewPosition;

/**
 * The navigation item’s title displayed in the center of the navigation bar.
 */
@property (nonatomic, readwrite, strong) NSString *title;

/**
 * A custom view displayed in the center of the navigation bar.
 */
@property (nonatomic, readwrite, strong) UIView *titleView;

/**
 * The layer's width in points.
 */
@property (nonatomic, readwrite) CGFloat width;

/**
 * The minimal distance (when the child layer is as far on the left as possible) to the next layer in points.
 */
@property (nonatomic, readwrite) CGFloat nextItemDistance;

/**
 * If the view controller should get decorated by some UI chrome: the navigation bar.
 */
@property (nonatomic, readwrite) BOOL hasChrome;

/**
 * A custom bar button item displayed on the left of the navigation bar.
 */
@property (nonatomic, strong) UIBarButtonItem *leftBarButtonItem;

/**
 * A custom bar button item displayed on the right of the navigation bar.
 */
@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;

@end
