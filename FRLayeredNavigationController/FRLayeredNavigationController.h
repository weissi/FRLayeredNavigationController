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

#import <UIKit/UIKit.h>

#import "Utils.h"

@class FRLayeredNavigationItem;
@class FRLayeredNavigationController;
/**
 * The FRLayeredNavigationControllerDelegate protocol is used by delegates of FRLayeredNavigationController
 * to detect actions such as views starting to move, in the process of moving, and finished moving. This allows
 * apps which have content 'underneath' the layered controller to adjust it appropriately.
 */
@protocol FRLayeredNavigationControllerDelegate <NSObject>
@optional
/**
 * Sent by the layered navigation controller when it is about to begin moving a view controller. This message
 * is only sent if the controller can be moved.
 *
 * @param layeredController The layered controller being interacted with.
 * @param controller The view controller which is about to be moved.
 */
- (void)layeredNavigationController:(FRLayeredNavigationController*)layeredController
                 willMoveController:(UIViewController*)controller;

/**
 * Sent by the layered navigation controller when it is moving a view controller. This message
 * may be sent multiple times over the course of an interaction, and so any code implemented by
 * the delegate here should be efficient.
 *
 * @param layeredController The layered controller being interacted with.
 * @param controller The view controller which is currently being moved.
 */
- (void)layeredNavigationController:(FRLayeredNavigationController*)layeredController
               movingViewController:(UIViewController*)controller;

/**
 * Sent by the layered navigation controller when it has finished moving a view controller.
 *
 * @param layeredController The layered controller being interacted with.
 * @param controller The view controller which has finished moving.
 */
- (void)layeredNavigationController:(FRLayeredNavigationController*)layeredController
                  didMoveController:(UIViewController*)controller;

@end

/**
 * The FRLayeredNavigationController class implements a container view controller that manages the navigation
 * of hierarchical content. This class is not intended for subclassing.
 *
 * The API and the usage is very similar to UINavigationController .
 */
@interface FRLayeredNavigationController : UIViewController<UIGestureRecognizerDelegate> {
    @private
    UIView * __weak _firstTouchedView;
    UIViewController * __weak _firstTouchedController;
    UIPanGestureRecognizer *_panGR;
    NSMutableArray *_layeredViewControllers;
    UIViewController * __weak _outOfBoundsViewController;
    UIView * __weak _dropNotificationView;
    id<FRLayeredNavigationControllerDelegate> __weak _delegate;
    BOOL _userInteractionEnabled;
    BOOL _dropLayersWhenPulledRight;
}

/**
 * Initializes and returns a newly created layered navigation controller.
 *
 * @param rootViewController The view controller that resides at the bottom of the navigation stack.
 */
- (id)initWithRootViewController:(UIViewController *)rootViewController;

/**
 * Initializes and returns a newly created layered navigation controller.
 * Does the same as initWithRootViewController: but has the ability to configure some parameters for the
 * root view controller.
 *
 * @param rootViewController The view controller that resides at the bottom of the navigation stack.
 * @param configuration A block object you can use to control some parameters (such as the width) for the root view
 *                      controller. The block's only parameter is an instance of FRLayeredNavigationItem .
 */
- (id)initWithRootViewController:(UIViewController *)rootViewController
                   configuration:(void (^)(FRLayeredNavigationItem *item))configuration;

/**
 * Pops the top view controller from the navigation stack and updates the display.
 *
 * @param animated Set this value to YES to animate the transition. Pass NO if you are setting up a layered navigation
 *                 controller before its view is displayed.
 */
- (void)popViewControllerAnimated:(BOOL)animated;

/**
 * Pops all the view controllers on the stack except the root view controller and updates the display.
 *
 * @param animated Set this value to YES to animate the transition. Pass NO if you are setting up a layered navigation
 *                 controller before its view is displayed.
 */
- (void)popToRootViewControllerAnimated:(BOOL)animated;

/**
 * Pops view controllers until the specified view controller is at the top of the navigation stack.
 *
 * @param vc The view controller until which to pop.
 * @param animated Set this value to YES to animate the transition. Pass NO if you are setting up a layered navigation
 *                 controller before its view is displayed.
 */
- (void)popToViewController:(UIViewController *)vc animated:(BOOL)animated;

/**
 * Pushes a view controller onto the stack on top of anchorViewController and updates the display.
 * All view controllers already on top of anchorViewController get popped automatically first.
 *
 * @param viewController The UIViewController to push on the navigation stack.
 * @param anchorViewController The UIViewController on top of which the new view controller should get pushed.
 * @param maxWidth `YES` if viewController is a content view controller and should therefore use all the remaining
 *                 screen width.
 * @param animated Set this value to YES to animate the transition. Pass NO if you are setting up a layered navigation
 *                 controller before its view is displayed.
 */
- (void)pushViewController:(UIViewController *)viewController
                 inFrontOf:(UIViewController *)anchorViewController
              maximumWidth:(BOOL)maxWidth
                  animated:(BOOL)animated;

/**
 * Pushes a view controller onto the stack on top of anchorViewController and updates the display.
 * All view controllers already on top of anchorViewController get popped automatically first.
 *
 * @param viewController The UIViewController to push on the navigation stack.
 * @param anchorViewController The UIViewController on top of which the new view controller should get pushed.
 * @param maxWidth `YES` if viewController is a content view controller and should therefore use all the remaining
 *                 screen width.
 * @param animated Set this value to YES to animate the transition. Pass NO if you are setting up a layered navigation
 *                 controller before its view is displayed.
 * @param configuration A block object you can use to control some parameters (such as the width) for the new view
 *                      controller. The block's only parameter is a newly created instance of FRLayeredNavigationItem .
 */
- (void)pushViewController:(UIViewController *)viewController
                 inFrontOf:(UIViewController *)anchorViewController
              maximumWidth:(BOOL)maxWidth
                  animated:(BOOL)animated
             configuration:(void (^)(FRLayeredNavigationItem *item))configuration;

/**
 * If user interaction on the layered navigation controller is enabled.
 */
@property (nonatomic) BOOL userInteractionEnabled;

/**
 * Returns all the UIViewController objects being managed by the FRNavigationController.
 * Note that, unlike a UINavigationController, this is a readonly property.
 */
@property (nonatomic, readonly) NSArray *viewControllers;

/**
 * Wheater to drop all layers except the root view controller when pulled far enough to the right
 */
@property (nonatomic) BOOL dropLayersWhenPulledRight;

/**
 * The view controller in the top layer. (read-only)
 */
@property(nonatomic, readonly) UIViewController *topViewController;

/**
 * The delegate for the controller.
 */
@property(nonatomic, weak) id<FRLayeredNavigationControllerDelegate> delegate;

@end
