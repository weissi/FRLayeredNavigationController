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
#import <QuartzCore/QuartzCore.h>
#include <tgmath.h>

/* Local Imports */
#import "FRDLog.h"
#import "FRLayeredNavigationController.h"
#import "FRLayerController.h"
#import "FRLayeredNavigationItem.h"
#import "FRLayeredNavigationItem+Protected.h"
#import "UIViewController+FRLayeredNavigationController.h"

#define FRLayeredNavigationControllerStandardDistance ((float)64.0f)
#define FRLayeredNavigationControllerStandardWidth ((float)400.0f)
#define FRLayeredNavigationControllerSnappingVelocityThreshold ((float)100.0f)

typedef enum {
    SnappingPointsMethodNearest,
    SnappingPointsMethodCompact,
    SnappingPointsMethodExpand
} SnappingPointsMethod;

@interface FRLayeredNavigationController ()

@property (nonatomic, readwrite, strong) UIPanGestureRecognizer *panGR;
@property (nonatomic, readwrite, strong) NSMutableArray *layeredViewControllers;
@property (nonatomic, readwrite, weak) UIViewController *outOfBoundsViewController;
@property (nonatomic, readwrite, weak) UIView *firstTouchedView;
@property (nonatomic, weak) UIView *dropNotificationView;
@property (nonatomic, weak) UIViewController *firstTouchedController;

@end

@implementation FRLayeredNavigationController

#pragma mark - Initialization/dealloc

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    return [self initWithRootViewController:rootViewController configuration:^(__unused FRLayeredNavigationItem *item) {
        /* nothing */
    }];
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
                   configuration:(void (^)(FRLayeredNavigationItem *item))configuration
{
    self = [super init];
    if (self) {
        FRLayerController *layeredRC = [[FRLayerController alloc] initWithContentViewController:rootViewController
                                                                                   maximumWidth:NO];
        _layeredViewControllers = [[NSMutableArray alloc] initWithArray:@[layeredRC]];
        layeredRC.layeredNavigationItem.nextItemDistance = FRLayeredNavigationControllerStandardDistance;
        layeredRC.layeredNavigationItem.width = FRLayeredNavigationControllerStandardWidth;
        layeredRC.layeredNavigationItem.hasChrome = NO;
        layeredRC.layeredNavigationItem.hasBorder = NO;
        layeredRC.layeredNavigationItem.displayShadow = NO;
        configuration(layeredRC.layeredNavigationItem);
        _outOfBoundsViewController = nil;
        _userInteractionEnabled = YES;
        _dropLayersWhenPulledRight = NO;

        [self addChildViewController:layeredRC];
        [layeredRC didMoveToParentViewController:self];
    }
    return self;
}

- (void)dealloc
{
    [self detachGestureRecognizer];
}


#pragma mark - UIViewController interface

- (void)loadView
{
    self.view = [[UIView alloc] init];
    UIInterfaceOrientation currentOrientation = self.interfaceOrientation;

    for (FRLayerController *vc in self.layeredViewControllers) {
        CGFloat itemWidth = vc.layeredNavigationItem.width;
        if (currentOrientation == UIInterfaceOrientationIsLandscape(currentOrientation)) {
            itemWidth = vc.layeredNavigationItem.landscapeWidth;
        }
        vc.view.frame = CGRectMake(vc.layeredNavigationItem.currentViewPosition.x,
                                   vc.layeredNavigationItem.currentViewPosition.y,
                                   itemWidth,
                                   CGRectGetHeight(self.view.bounds));
        vc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:vc.view];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (self.userInteractionEnabled) {
        [self attachGestureRecognizer];
    }
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    FRDLOG(@"ORIENTATION, new size: %@", NSStringFromCGSize(self.view.bounds.size));
    [super didRotateFromInterfaceOrientation:orientation];
    [self doLayout];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self doLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self doLayout];
}

- (void)viewWillUnload
{
    [self detachGestureRecognizer];
    self.firstTouchedView = nil;
    self.outOfBoundsViewController = nil;

    [super viewWillUnload];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.dropNotificationView = nil;
    NSLog(@"FRLayeredNavigationController (%@): viewDidUnload", self);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(__unused UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - UIGestureRecognizer delegate interface

- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStatePossible: {
            //NSLog(@"UIGestureRecognizerStatePossible");
            break;
        }

        case UIGestureRecognizerStateBegan: {
            //NSLog(@"UIGestureRecognizerStateBegan");
            UIView *touchedView =
                [gestureRecognizer.view hitTest:[gestureRecognizer locationInView:gestureRecognizer.view]
                                      withEvent:nil];
            self.firstTouchedView = touchedView;
            for (FRLayerController *controller in [self.layeredViewControllers reverseObjectEnumerator]) {
                if ([touchedView isDescendantOfView:controller.view]) {
                    self.firstTouchedController = controller.contentViewController;
                    break;
                }
            }

            if ([self.delegate respondsToSelector:@selector(layeredNavigationController:willMoveController:)]) {
                [self.delegate layeredNavigationController:self willMoveController:self.firstTouchedController];
            }
            break;
        }

        case UIGestureRecognizerStateChanged: {
            //NSLog(@"UIGestureRecognizerStateChanged, vel=%f", [gestureRecognizer velocityInView:firstView].x);
            NSAssert([self.layeredViewControllers count] > 0, @"no layered view controllers");

            const NSUInteger startVcIdx = [self.layeredViewControllers count]-1;
            const UIViewController *startVc = [self.layeredViewControllers objectAtIndex:startVcIdx];

            [self moveViewControllersXTranslation:[gestureRecognizer translationInView:self.view].x];
            if ([self.delegate respondsToSelector:@selector(layeredNavigationController:movingViewController:)]) {
                [self.delegate layeredNavigationController:self movingViewController:self.firstTouchedController];
            }
            /*
            [self moveViewControllersStartIndex:startVcIdx
                    xTranslation:[gestureRecognizer translationInView:self.view].x
                          withParentIndex:-1
                       parentLastPosition:CGPointZero
                      descendentOfTouched:NO];
             */
            [gestureRecognizer setTranslation:CGPointZero inView:startVc.view];

            if (self.dropLayersWhenPulledRight) {
                if (self.dropNotificationView == nil) {
                    if ([self layersInDropZone]) {
                        [self showDropNotification];
                    }
                } else {
                    if (![self layersInDropZone]) {
                        [self hideDropNotification];
                    }
                }
            } else {
                [self hideDropNotification];
            }

            break;
        }

        case UIGestureRecognizerStateEnded: {
            //NSLog(@"UIGestureRecognizerStateEnded");

            [self hideDropNotification];

            if (self.dropLayersWhenPulledRight && [self layersInDropZone]) {
                [self popToRootViewControllerAnimated:FRLayeredAnimationDirectionRight];
            }

            [UIView animateWithDuration:0.2 animations:^{
                [self moveToSnappingPointsWithGestureRecognizer:gestureRecognizer];
            }
                             completion:^(__unused BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(layeredNavigationController:didMoveController:)]) {
                [self.delegate layeredNavigationController:self didMoveController:self.firstTouchedController];
            }

            self.firstTouchedView = nil;
            self.firstTouchedController = nil;
            }];

            break;
        }

        default:
            break;
    }
}

- (BOOL)gestureRecognizer:(__unused UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    /* get a static reference to the "hidden" UITableViewCellReorderControl class */
    static Class reorderControlClass = nil;
    if (reorderControlClass == nil) {
        reorderControlClass = NSClassFromString(@"UITableViewCellReorderControl");
    }

    if ([touch.view isKindOfClass:[UISlider class]] ||
        [touch.view isKindOfClass:reorderControlClass]) {
        // prevent recognizing touches on the slider / table view reorder control
        return NO;
    }
    return YES;
}

#pragma mark - internal methods

+ (void)viewControllerToInitialPosition:(FRLayerController *)vc
{
    const CGPoint initPos = vc.layeredNavigationItem.initialViewPosition;
    CGRect f = vc.view.frame;
    f.origin = initPos;
    vc.layeredNavigationItem.currentViewPosition = initPos;
    vc.view.frame = f;
}

+ (BOOL)viewController:(FRLayerController *)vc xTranslation:(CGFloat)origXTranslation bounded:(BOOL)bounded
{
    BOOL didMoveOutOfBounds = NO;
    const FRLayeredNavigationItem *navItem = vc.layeredNavigationItem;
    const CGPoint initPos = navItem.initialViewPosition;

    CGRect f = vc.view.frame;
    if (bounded) {
        /* apply translation to fancy item position first and then apply to view */
        f.origin = navItem.currentViewPosition;
        f.origin.x += origXTranslation;

        if (f.origin.x <= initPos.x) {
            f.origin.x = initPos.x;
        }

        vc.view.frame = f;
        navItem.currentViewPosition = f.origin;
    } else {
        CGFloat xTranslation;
        if (f.origin.x < initPos.x && origXTranslation < 0) {
            /* if view already left from left bound and still moving left, half moving speed */
            xTranslation = origXTranslation / 2;
        } else {
            xTranslation = origXTranslation;
        }

        f.origin.x += xTranslation;

        /* apply translation to frame first */
        if (f.origin.x <= initPos.x) {
            didMoveOutOfBounds = YES;
            navItem.currentViewPosition = initPos;
        } else {
            navItem.currentViewPosition = f.origin;
        }
        vc.view.frame = f;
    }
    return didMoveOutOfBounds;
}

- (BOOL)areViewControllersMaximallyCompressed
{
    BOOL maximalCompression = YES;

    for (FRLayerController *lvc in self.layeredViewControllers) {
        if (lvc.layeredNavigationItem.currentViewPosition.x > lvc.layeredNavigationItem.initialViewPosition.x) {
            maximalCompression = NO;
        }
    }

    return maximalCompression;
}

- (void)viewControllersToSnappingPointsMethod:(SnappingPointsMethod)method
{
    FRLayerController *last = nil;
    CGFloat xTranslation = 0;

    for (FRLayerController *vc in self.layeredViewControllers) {
        const CGPoint myPos = vc.layeredNavigationItem.currentViewPosition;
        const CGPoint myInitPos = vc.layeredNavigationItem.initialViewPosition;

        const CGFloat curDiff = myPos.x - last.layeredNavigationItem.currentViewPosition.x;
        const CGFloat initDiff = myInitPos.x - last.layeredNavigationItem.initialViewPosition.x;
        const CGFloat maxDiff = ((last.layeredNavigationItem.snappingDistance >= 0) ?
                                 last.layeredNavigationItem.snappingDistance :
                                 CGRectGetWidth(last.view.frame));

        if (xTranslation == 0 && (CGFloatNotEqual(curDiff, initDiff) && CGFloatNotEqual(curDiff, maxDiff))) {
            switch (method) {
                case SnappingPointsMethodNearest: {
                    if ((curDiff - initDiff) > (maxDiff - curDiff)) {
                        /* right snapping point is nearest */
                        xTranslation = maxDiff - curDiff;
                    } else {
                        /* left snapping point is nearest */
                        xTranslation = initDiff - curDiff;
                    }
                    break;
                }
                case SnappingPointsMethodCompact: {
                    xTranslation = initDiff - curDiff;
                    break;
                }
                case SnappingPointsMethodExpand: {
                    xTranslation = maxDiff - curDiff;
                    break;
                }
            }
        }

        [FRLayeredNavigationController viewController:vc xTranslation:xTranslation bounded:YES];
        last = vc;
    }
}

- (void)moveToSnappingPointsWithGestureRecognizer:(UIPanGestureRecognizer *)g
{
    const CGFloat velocity = [g velocityInView:self.view].x;
    SnappingPointsMethod method;

    if (fabs(velocity) > FRLayeredNavigationControllerSnappingVelocityThreshold) {
        if (velocity > 0) {
            method = SnappingPointsMethodExpand;
        } else {
            method = SnappingPointsMethodCompact;
        }
    } else {
        method = SnappingPointsMethodNearest;
    }

    [self viewControllersToSnappingPointsMethod:method];
}

- (void)moveViewControllersXTranslation:(CGFloat)xTranslationGesture
{
    FRLayeredNavigationItem *parentNavItem = nil;
    CGPoint parentOldPos = CGPointZero;
    BOOL descendentOfTouched = NO;
    FRLayerController *rootVC = [self.layeredViewControllers objectAtIndex:0];

    for (FRLayerController *me in [self.layeredViewControllers reverseObjectEnumerator]) {
        if (rootVC == me) {
            break;
        }
        FRLayeredNavigationItem *meNavItem = me.layeredNavigationItem;

        const CGPoint myPos = meNavItem.currentViewPosition;
        const CGPoint myInitPos = meNavItem.initialViewPosition;
        const CGFloat myWidth = ((meNavItem.snappingDistance >= 0) ?
                                 meNavItem.snappingDistance :
                                 CGRectGetWidth(me.view.frame));
        CGPoint myNewPos = myPos;

        const CGPoint myOldPos = myPos;
        const CGPoint parentPos = parentNavItem.currentViewPosition;
        const CGPoint parentInitPos = parentNavItem.initialViewPosition;

        CGFloat xTranslation = 0;

        if (parentNavItem == nil || !descendentOfTouched) {
            xTranslation = xTranslationGesture;
        } else {
            CGFloat newX = myPos.x;
            const CGFloat minDiff = parentInitPos.x - myInitPos.x;

            if (parentOldPos.x >= myPos.x + myWidth || parentPos.x >= myPos.x + myWidth) {
                /* if snapped to parent's right border, move with parent */
                newX = parentPos.x - myWidth;
            }

            if (parentPos.x - myNewPos.x <= minDiff) {
                /* at least minDiff difference between parent and me */
                newX = parentPos.x - minDiff;

            }

            xTranslation = newX - myPos.x;
        }

        const BOOL isTouchedView = !descendentOfTouched && [self.firstTouchedView isDescendantOfView:me.view];

        if (self.outOfBoundsViewController == nil ||
            self.outOfBoundsViewController == me ||
            xTranslationGesture < 0) {
            const BOOL boundedMove = !(isTouchedView && [self areViewControllersMaximallyCompressed]);

            /*
             * IF no view controller is out of bounds (too far on the left)
             * OR if me who is out of bounds
             * OR the translation goes to the left again
             * THEN: apply the translation
             */
            const BOOL outOfBoundsMove = [FRLayeredNavigationController viewController:me
                                                                          xTranslation:xTranslation
                                                                               bounded:boundedMove];
            if (outOfBoundsMove) {
                /* this move was out of bounds */
                self.outOfBoundsViewController = me;
            } else if(!outOfBoundsMove && self.outOfBoundsViewController == me) {
                /* I have been moved out of bounds some time ago but now I'm back in the bounds :-), so:
                 * - no one can be out of bounds now
                 * - I have to be reset to my initial position
                 * - discard the rest of the translation
                 */
                self.outOfBoundsViewController = nil;
                [FRLayeredNavigationController viewControllerToInitialPosition:me];
                break; /* this discards the rest of the translation (i.e. stops the loop) */
            }
        }

        if (isTouchedView) {
            NSAssert(!descendentOfTouched, @"cannot be descendent of touched AND touched view");
            descendentOfTouched = YES;
        }

        /* initialize next iteration */
        parentNavItem = meNavItem;
        parentOldPos = myOldPos;
    }
}

- (CGFloat)savePlaceWanted:(CGFloat)pointsWanted;
{
    CGFloat xTranslation = 0;
    if (pointsWanted <= 0) {
        return 0;
    }

    for (FRLayerController *vc in self.layeredViewControllers) {
        const CGFloat initX = vc.layeredNavigationItem.initialViewPosition.x;
        const CGFloat currentX = vc.layeredNavigationItem.currentViewPosition.x;

        if (initX < currentX + xTranslation) {
            xTranslation += initX - (currentX + xTranslation);
        }

        if (fabs(xTranslation) >= pointsWanted) {
            break;
        }
    }

    for (FRLayerController *vc in self.layeredViewControllers) {
        if (vc == [self.layeredViewControllers lastObject]) {
            break;
        }
        [FRLayeredNavigationController viewController:vc xTranslation:xTranslation bounded:YES];
    }
    return fabs(xTranslation);
}


- (void)doLayout
{
    for (FRLayerController *vc in self.layeredViewControllers) {
        CGRect f = vc.view.frame;
        if (vc.layeredNavigationItem.currentViewPosition.x < vc.layeredNavigationItem.initialViewPosition.x) {
            vc.layeredNavigationItem.currentViewPosition = vc.layeredNavigationItem.initialViewPosition;
        }
        f.origin = vc.layeredNavigationItem.currentViewPosition;

        UIInterfaceOrientation currentOrientation = vc.interfaceOrientation;
        if (vc.maximumWidth) {
            f.size.width = CGRectGetWidth(self.view.bounds) - vc.layeredNavigationItem.initialViewPosition.x;
            vc.layeredNavigationItem.width = CGRectGetWidth(f);
        } else if (UIInterfaceOrientationIsLandscape(currentOrientation)) {
            f.size.width = vc.layeredNavigationItem.landscapeWidth;
        } else if (!UIInterfaceOrientationIsLandscape(currentOrientation)) {
            f.size.width = vc.layeredNavigationItem.width;
        }

        f.size.height = CGRectGetHeight(self.view.bounds);

        vc.view.frame = f;
    }
}

- (CGRect)getScreenBoundsForCurrentOrientation
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    return [FRLayeredNavigationController getScreenBoundsForOrientation:orientation];
}

+ (CGRect)getScreenBoundsForOrientation:(UIInterfaceOrientation)orientation
{
    UIScreen *screen = [UIScreen mainScreen];
    CGRect fullScreenRect = screen.bounds; //implicitly in Portrait orientation.

    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        CGRect temp = CGRectZero;
        temp.size.width = fullScreenRect.size.height;
        temp.size.height = fullScreenRect.size.width;
        fullScreenRect = temp;
    }

    return fullScreenRect;
}

- (void)attachGestureRecognizer
{
    self.panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    self.panGR.maximumNumberOfTouches = 1;
    self.panGR.delegate = self;
    [self.view addGestureRecognizer:self.panGR];
}

- (void)detachGestureRecognizer
{
    [self.view removeGestureRecognizer:self.panGR];
    [self.panGR removeTarget:self action:NULL];
    self.panGR.delegate = nil;
    self.panGR = nil;
}

- (FRLayerController *)layerControllerOf:(UIViewController *)vc
{
    for (FRLayerController *lvc in self.layeredViewControllers) {
        if (lvc.contentViewController == vc) {
            return lvc;
        }
    }
    return nil;
}

- (BOOL)layersInDropZone
{
    if ([self.layeredViewControllers count] > 1) {
        const FRLayerController *rootVC = [self.layeredViewControllers objectAtIndex:0];
        const FRLayerController *layer1VC = [self.layeredViewControllers objectAtIndex:1];
        const FRLayeredNavigationItem *rootNI = rootVC.layeredNavigationItem;
        const FRLayeredNavigationItem *layer1NI = layer1VC.layeredNavigationItem;

        if (layer1NI.currentViewPosition.x - rootNI.currentViewPosition.x - rootNI.width > 300) {
            return YES;
        }
    }

    return NO;
}

- (void)showDropNotification
{
    const FRLayerController *rootVC = [self.layeredViewControllers objectAtIndex:0];
    const FRLayeredNavigationItem *rootNI = rootVC.layeredNavigationItem;

    UILabel *lv = [[UILabel alloc] init];
    lv.text = @"X";
    lv.backgroundColor = [UIColor clearColor];
    lv.textColor = [UIColor redColor];
    lv.frame = CGRectMake(rootNI.currentViewPosition.x + rootNI.width + 10,
                          (CGRectGetHeight(self.view.bounds)-100)/2,
                          100,
                          100);
    self.dropNotificationView = lv;
    [self.view insertSubview:self.dropNotificationView atIndex:0];
}

- (void)hideDropNotification
{
    if (self.dropNotificationView != nil) {
        [self.dropNotificationView removeFromSuperview];
        self.dropNotificationView = nil;
    }
}

#pragma mark - Public API

- (void)popViewControllerAnimated:(BOOL)animated
{
    [self popViewControllerAnimated:animated direction:FRLayeredAnimationDirectionDown];
}

- (void)popViewControllerAnimated:(BOOL)animated direction:(FRLayeredAnimationDirection)direction
{
    UIViewController *vc = [self.layeredViewControllers lastObject];

    if ([self.layeredViewControllers count] == 1) {
        /* don't remove root view controller */
        return;
    }

    [self.layeredViewControllers removeObject:vc];

    CGRect goAwayFrame = CGRectMake(CGRectGetMinX(vc.view.frame),
                                    CGRectGetMinY(vc.view.frame),
                                    CGRectGetWidth(vc.view.frame),
                                    CGRectGetHeight(vc.view.frame));

    if (animated) {
        switch (direction) {
            case FRLayeredAnimationDirectionDown:
                goAwayFrame.origin.y = 1024;
                break;
            case FRLayeredAnimationDirectionLeft:
                goAwayFrame.origin.x = -1024;
                break;
            case FRLayeredAnimationDirectionUp:
                goAwayFrame.origin.y = -1024;
                break;
            case FRLayeredAnimationDirectionRight:
                goAwayFrame.origin.x = 1024;
                break;
            default:
                break;
        }
    }

    void (^completeViewRemoval)(BOOL) = ^(__unused BOOL finished) {
        [vc willMoveToParentViewController:nil];

        [vc.view removeFromSuperview];

        [vc removeFromParentViewController];
    };

    if (animated) {
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             vc.view.frame = goAwayFrame;
                         }
                         completion:completeViewRemoval];
    } else {
        completeViewRemoval(YES);
    }
}

- (void)popToViewController:(UIViewController *)vc animated:(BOOL)animated
{
    [self popToViewController:vc animated:animated direction:FRLayeredAnimationDirectionDown];
}

- (void)popToViewController:(UIViewController *)vc
                   animated:(BOOL)animated
                  direction:(FRLayeredAnimationDirection)direction
{
    UIViewController *currentVc;

    while ((currentVc = [self.layeredViewControllers lastObject])) {
        if (([currentVc class] == [FRLayerController class] &&
             ((FRLayerController*)currentVc).contentViewController == vc) ||
            ([currentVc class] != [FRLayerController class] &&
             currentVc == vc)) {
                break;
            }

        if ([self.layeredViewControllers count] == 1) {
            /* don't remove root view controller */
            return;
        }

        [self popViewControllerAnimated:animated direction:direction];
    }
}

- (void)popToRootViewControllerAnimated:(BOOL)animated
{
    [self popToViewController:[self.layeredViewControllers objectAtIndex:0] animated:animated];
}

- (void)popToRootViewControllerAnimated:(BOOL)animated direction:(FRLayeredAnimationDirection)direction
{
    [self popToViewController:[self.layeredViewControllers objectAtIndex:0] animated:animated direction:direction];
}

- (void)pushViewController:(UIViewController *)contentViewController
                 inFrontOf:(UIViewController *)anchorViewController
              maximumWidth:(BOOL)maxWidth
                  animated:(BOOL)animated
             configuration:(void (^)(FRLayeredNavigationItem *item))configuration
                 direction:(FRLayeredAnimationDirection)direction
{
    FRLayerController *newVC =
        [[FRLayerController alloc] initWithContentViewController:contentViewController maximumWidth:maxWidth];
    const FRLayerController *parentLayerController = [self layerControllerOf:anchorViewController];

    if (parentLayerController == nil) {
        /* view controller to push on not found */
        FRWLOG(@"WARNING: View controller to push in front of ('%@') not pushed (yet), pushing on top instead.",
               anchorViewController);
        [self pushViewController:contentViewController
                       inFrontOf:((FRLayerController *)[self.layeredViewControllers lastObject]).contentViewController
                    maximumWidth:maxWidth
                        animated:animated
                   configuration:configuration
                       direction:direction];
        return;
    }

    const FRLayeredNavigationItem *navItem = newVC.layeredNavigationItem;
    const FRLayeredNavigationItem *parentNavItem = parentLayerController.layeredNavigationItem;

    if (contentViewController.parentViewController.parentViewController == self) {
        /* no animation if the new content view controller is already a child of self */
        [self popToViewController:anchorViewController animated:NO];
    } else {
        [self popToViewController:anchorViewController animated:direction];
    }

    CGFloat anchorInitX = parentNavItem.initialViewPosition.x;
    CGFloat anchorCurrentX = parentNavItem.currentViewPosition.x;
    CGFloat anchorWidth = parentNavItem.width;
    CGFloat initX = anchorInitX + ((parentNavItem.nextItemDistance >= 0) ?
                                   parentNavItem.nextItemDistance :
                                   FRLayeredNavigationControllerStandardDistance);
    navItem.initialViewPosition = CGPointMake(initX, 0);
    navItem.currentViewPosition = CGPointMake(anchorCurrentX + anchorWidth, 0);
    navItem.titleView = nil;
    navItem.title = nil;
    navItem.hasChrome = YES;
    navItem.displayShadow = YES;

    configuration(newVC.layeredNavigationItem);

    const CGFloat overallWidth = ((CGRectGetWidth(self.view.bounds) > 0) ?
                                  CGRectGetWidth(self.view.bounds) :
                                  CGRectGetWidth([self getScreenBoundsForCurrentOrientation]));

    CGFloat width;
    if (navItem.width > 0) {
        width = navItem.width;
    } else {
        width = newVC.maximumWidth ? overallWidth - initX : FRLayeredNavigationControllerStandardWidth;
        navItem.width = width;
    }

    CGRect onscreenFrame = CGRectMake(newVC.layeredNavigationItem.currentViewPosition.x,
                                      newVC.layeredNavigationItem.currentViewPosition.y,
                                      width,
                                      CGRectGetHeight(self.view.bounds));
    CGRect offscreenFrame = CGRectMake(MAX(1024, CGRectGetMinX(onscreenFrame)),
                                       0,
                                       CGRectGetWidth(onscreenFrame),
                                       CGRectGetHeight(onscreenFrame));

    if (animated) {
        switch (direction) {
            case FRLayeredAnimationDirectionDown:
                offscreenFrame.origin.y = MAX(1024, CGRectGetMinY(onscreenFrame));
                break;
            case FRLayeredAnimationDirectionLeft:
                offscreenFrame.origin.x = MIN(-1024, CGRectGetMinX(onscreenFrame));
                break;
            case FRLayeredAnimationDirectionUp:
                offscreenFrame.origin.y = MIN(-1024, CGRectGetMinY(onscreenFrame));
                break;
            case FRLayeredAnimationDirectionRight:
                offscreenFrame.origin.x = MAX(1024, CGRectGetMinX(onscreenFrame));
                break;
        }
    }

    newVC.view.frame = offscreenFrame;

    [self.layeredViewControllers addObject:newVC];
    [self addChildViewController:newVC];
    [self.view addSubview:newVC.view];

    void (^doNewFrameMove)() = ^() {
        CGFloat saved = [self savePlaceWanted:CGRectGetMinX(onscreenFrame)+width-overallWidth];
        newVC.view.frame = CGRectMake(CGRectGetMinX(onscreenFrame) - saved,
                                      CGRectGetMinY(onscreenFrame),
                                      CGRectGetWidth(onscreenFrame),
                                      CGRectGetHeight(onscreenFrame));
        newVC.layeredNavigationItem.currentViewPosition = newVC.view.frame.origin;
    };
    void (^newFrameMoveCompleted)(BOOL) = ^(__unused BOOL finished) {
        [newVC didMoveToParentViewController:self];
    };

    if (animated) {
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             doNewFrameMove();
                         }
                         completion:^(BOOL finished) {
                             newFrameMoveCompleted(finished);
                         }];
    } else {
        doNewFrameMove();
        newFrameMoveCompleted(YES);
    }
}

- (void)pushViewController:(UIViewController *)contentViewController
                 inFrontOf:(UIViewController *)anchorViewController
              maximumWidth:(BOOL)maxWidth
                  animated:(BOOL)animated
{
    [self pushViewController:contentViewController
                   inFrontOf:anchorViewController
                maximumWidth:maxWidth
                    animated:animated
               configuration:^(__unused FRLayeredNavigationItem *item) {
               }
                   direction:FRLayeredAnimationDirectionRight];
}

- (void)pushViewController:(UIViewController *)contentViewController
                 inFrontOf:(UIViewController *)anchorViewController
              maximumWidth:(BOOL)maxWidth
                  animated:(BOOL)animated
             configuration:(void (^)(FRLayeredNavigationItem *))configuration
{
    [self pushViewController:contentViewController
                   inFrontOf:anchorViewController
                maximumWidth:maxWidth
                    animated:animated
               configuration:configuration
                   direction:FRLayeredAnimationDirectionRight];
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    if (self.userInteractionEnabled != userInteractionEnabled) {
        self->_userInteractionEnabled = userInteractionEnabled;

        if (self.userInteractionEnabled) {
            [self attachGestureRecognizer];
        } else {
            [self detachGestureRecognizer];
        }
    }
}

- (NSArray *)viewControllers
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self.layeredViewControllers count]];
    [self.layeredViewControllers enumerateObjectsUsingBlock:^(id obj, __unused NSUInteger idx, __unused BOOL *stop) {
        [result addObject:((FRLayerController*)obj).contentViewController];
    }];
    return [result copy];
}

- (UIViewController *)topViewController
{
    const FRLayerController *topLayerController = [self.layeredViewControllers lastObject];
    return topLayerController.contentViewController;
}

- (void)compressViewControllers:(BOOL)animated;
{
    void (^compact)(void) = ^{
        FRLayeredNavigationItem* parentItem = nil;
        for (FRLayerController* layerController in self.layeredViewControllers) {
            FRLayeredNavigationItem* navigationItem = layerController.layeredNavigationItem;
            if (parentItem != nil) {
                CGRect f = layerController.view.frame;
                f.origin.x = parentItem.currentViewPosition.x + parentItem.nextItemDistance;
                navigationItem.currentViewPosition = f.origin;
                layerController.view.frame = f;
            }
            parentItem = navigationItem;
        }
    };

    if (animated) {
        [UIView animateWithDuration:0.5 animations:compact];
    }
    else {
        compact();
    }
}

#pragma mark - properties

@end
