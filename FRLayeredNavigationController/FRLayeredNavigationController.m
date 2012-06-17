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

#import "FRLayeredNavigationController.h"
#import "FRLayerController.h"
#import "FRLayeredNavigationItem.h"
#import "FRLayeredNavigationItem+Protected.h"
#import "UIViewController+FRLayeredNavigationController.h"

#import <QuartzCore/QuartzCore.h>

#define FRLayeredNavigationControllerStandardDistance ((float)64)
#define FRLayeredNavigationControllerStandardWidth ((float)400)
#define FRLayeredNavigationControllerSnappingVelocityThreshold ((float)100)

typedef enum {
    SnappingPointsMethodNearest,
    SnappingPointsMethodCompact,
    SnappingPointsMehtodExpand
} SnappingPointsMethod;

@interface FRLayeredNavigationController ()

@property (nonatomic, readwrite, strong) UIPanGestureRecognizer *panGR;
@property (nonatomic, readwrite, strong) NSMutableArray *viewControllers;
@property (nonatomic, readwrite, weak) UIViewController *outOfBoundsViewController;
@property (nonatomic, readwrite, weak) UIView *firstTouchedView;

@end

@implementation FRLayeredNavigationController

#pragma mark - Initialization/dealloc

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    return [self initWithRootViewController:rootViewController configuration:^(FRLayeredNavigationItem *item) {
        /* nothing */
    }];
}

    - (id)initWithRootViewController:(UIViewController *)rootViewController
configuration:(void (^)(FRLayeredNavigationItem *item))configuration
    {
    self = [super init];
    if (self) {
        FRLayerController *layeredRC = [[FRLayerController alloc] initWithContentViewController:rootViewController maximumWidth:NO];
        _viewControllers = [[NSMutableArray alloc] initWithObjects:layeredRC, nil];
        layeredRC.layeredNavigationItem.nextItemDistance = FRLayeredNavigationControllerStandardDistance;
        layeredRC.layeredNavigationItem.width = FRLayeredNavigationControllerStandardWidth;
        layeredRC.layeredNavigationItem.hasChrome = NO;
        configuration(layeredRC.layeredNavigationItem);
        _outOfBoundsViewController = nil;

        [self addChildViewController:layeredRC];
        [layeredRC didMoveToParentViewController:self];
    }
    return self;
}

- (void)dealloc {
    self.panGR.delegate = nil;
}


#pragma mark - UIViewController interface

- (void)loadView
{
    self.view = [[UIView alloc] init];

    for (FRLayerController *vc in self.viewControllers) {
        vc.view.frame = CGRectMake(vc.layeredNavigationItem.currentViewPosition.x,
                                   vc.layeredNavigationItem.currentViewPosition.y,
                                   vc.layeredNavigationItem.width,
                                   self.view.bounds.size.height);
        vc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:vc.view];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    self.panGR.maximumNumberOfTouches = 1;
    self.panGR.delegate = self;
    [self.view addGestureRecognizer:self.panGR];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    NSLog(@"ORIENTATION, new size: %@", NSStringFromCGSize(self.view.bounds.size));
    [super didRotateFromInterfaceOrientation:orientation];
    [self doLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self doLayout];
}

- (void)viewWillUnload
{
    self.panGR = nil;
    self.firstTouchedView = nil;
    self.outOfBoundsViewController = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    NSLog(@"FRLayeredNavigationController (%@): viewDidUnload", self);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
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
            UIView *touchedView = [gestureRecognizer.view hitTest:[gestureRecognizer locationInView:gestureRecognizer.view]
                                                        withEvent:nil];
            self.firstTouchedView = touchedView;
            break;
        }

        case UIGestureRecognizerStateChanged: {
            //NSLog(@"UIGestureRecognizerStateChanged, vel=%f", [gestureRecognizer velocityInView:firstView].x);

            const NSInteger startVcIdx = [self.viewControllers count]-1;
            const UIViewController *startVc = [self.viewControllers objectAtIndex:startVcIdx];

            [self moveViewControllersXTranslation:[gestureRecognizer translationInView:self.view].x];

            /*
            [self moveViewControllersStartIndex:startVcIdx
                    xTranslation:[gestureRecognizer translationInView:self.view].x
                          withParentIndex:-1
                       parentLastPosition:CGPointZero
                      descendentOfTouched:NO];
             */
            [gestureRecognizer setTranslation:CGPointZero inView:startVc.view];
            break;
        }

        case UIGestureRecognizerStateEnded: {
            //NSLog(@"UIGestureRecognizerStateEnded");

            [UIView animateWithDuration:0.2 animations:^{
                [self moveToSnappingPointsWithGestureRecognizer:gestureRecognizer];
            }];

            self.firstTouchedView = nil;

            break;
        }

        default:
            break;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UISlider class]]) {
        // prevent recognizing touches on the slider
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

+ (BOOL)viewController:(FRLayerController *)vc xTranslation:(CGFloat)origXTranslation bounded:(BOOL)bounded {
    BOOL didMoveOutOfBounds = NO;
    const FRLayeredNavigationItem *navItem = vc.layeredNavigationItem;
    const CGPoint initPos = navItem.initialViewPosition;

    if (bounded) {
        /* apply translation to fancy item position first and then apply to view */
        CGRect f = vc.view.frame;
        f.origin = navItem.currentViewPosition;
        f.origin.x += origXTranslation;

        if (f.origin.x <= initPos.x) {
            f.origin.x = initPos.x;
        }

        vc.view.frame = f;
        navItem.currentViewPosition = f.origin;
    } else {
        CGRect f = vc.view.frame;
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

- (void)viewControllersToSnappingPointsMethod:(SnappingPointsMethod)method {
    FRLayerController *last = nil;
    CGFloat xTranslation = 0;

    for (FRLayerController *vc in self.viewControllers) {
        const CGPoint myPos = vc.layeredNavigationItem.currentViewPosition;
        const CGPoint myInitPos = vc.layeredNavigationItem.initialViewPosition;

        const CGFloat curDiff = myPos.x - last.layeredNavigationItem.currentViewPosition.x;
        const CGFloat initDiff = myInitPos.x - last.layeredNavigationItem.initialViewPosition.x;
        const CGFloat maxDiff = last.view.bounds.size.width;

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
                case SnappingPointsMehtodExpand: {
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

    if (abs(velocity) > FRLayeredNavigationControllerSnappingVelocityThreshold) {
        if (velocity > 0) {
            method = SnappingPointsMehtodExpand;
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
    FRLayerController *rootVC = [self.viewControllers objectAtIndex:0];

    for (FRLayerController *me in [self.viewControllers reverseObjectEnumerator]) {
        if (rootVC == me) {
            break;
        }
        FRLayeredNavigationItem *meNavItem = me.layeredNavigationItem;

        const CGPoint myPos = meNavItem.currentViewPosition;
        const CGPoint myInitPos = meNavItem.initialViewPosition;
        const CGFloat myWidth = me.view.bounds.size.width;
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
            const BOOL boundedMove = !isTouchedView;

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

    for (FRLayerController *vc in self.viewControllers) {
        const CGFloat initX = vc.layeredNavigationItem.initialViewPosition.x;
        const CGFloat currentX = vc.layeredNavigationItem.currentViewPosition.x;

        if (initX < currentX + xTranslation) {
            xTranslation += initX - (currentX + xTranslation);
        }

        if (abs(xTranslation) >= pointsWanted) {
            break;
        }
    }

    for (FRLayerController *vc in self.viewControllers) {
        if (vc == [self.viewControllers lastObject]) {
            break;
        }
        [FRLayeredNavigationController viewController:vc xTranslation:xTranslation bounded:YES];
    }
    return abs(xTranslation);
}

- (void)doLayout {
    for (FRLayerController *vc in self.viewControllers) {
        CGRect f = vc.view.frame;
        if (vc.layeredNavigationItem.currentViewPosition.x < vc.layeredNavigationItem.initialViewPosition.x) {
            vc.layeredNavigationItem.currentViewPosition = vc.layeredNavigationItem.initialViewPosition;
        }
        f.origin = vc.layeredNavigationItem.currentViewPosition;

        if (vc.maximumWidth) {
            f.size.width = self.view.bounds.size.width - vc.layeredNavigationItem.initialViewPosition.x;
            vc.layeredNavigationItem.width = f.size.width;
        }

        f.size.height = self.view.bounds.size.height;

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
        CGRect temp;
        temp.size.width = fullScreenRect.size.height;
        temp.size.height = fullScreenRect.size.width;
        fullScreenRect = temp;
    }

    return fullScreenRect;
}

#pragma mark - Public API

- (void)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *vc = [self.viewControllers lastObject];

    if ([self.viewControllers count] == 1) {
        /* don't remove root view controller */
        return;
    }

    [vc willMoveToParentViewController:nil];
    [self.viewControllers removeObject:vc];

    CGRect goAwayFrame = CGRectMake(vc.view.frame.origin.x, 1024, vc.view.bounds.size.width, vc.view.bounds.size.height);
    [UIView animateWithDuration:animated ? 0.5 : 0
                          delay:0
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         vc.view.frame = goAwayFrame;
                     }
                     completion:^(BOOL finished) {
                         [vc.view removeFromSuperview];
                         [vc removeFromParentViewController];
                     }];
}

- (void)popToViewController:(UIViewController *)vc animated:(BOOL)animated
{
    UIViewController *currentVc;

    while ((currentVc = [self.viewControllers lastObject])) {
        if (([currentVc class] == [FRLayerController class] &&
             ((FRLayerController*)currentVc).contentViewController == vc) ||
            ([currentVc class] != [FRLayerController class] &&
             currentVc == vc)) {
                break;
            }

        if ([self.viewControllers count] == 1) {
            /* don't remove root view controller */
            return;
        }

        [self popViewControllerAnimated:animated];
    }
}

- (void)popToRootViewControllerAnimated:(BOOL)animated
{
    [self popToViewController:[self.viewControllers objectAtIndex:0] animated:animated];
}

- (void)pushViewController:(UIViewController *)contentViewController
                 inFrontOf:(UIViewController *)anchorViewController
              maximumWidth:(BOOL)maxWidth
                  animated:(BOOL)animated
             configuration:(void (^)(FRLayeredNavigationItem *item))configuration
{
    FRLayerController *newVC = [[FRLayerController alloc]
                                                   initWithContentViewController:contentViewController maximumWidth:maxWidth];
    const FRLayeredNavigationItem *navItem = newVC.layeredNavigationItem;
    const FRLayeredNavigationItem *parentNavItem = anchorViewController.layeredNavigationItem;
    const CGFloat overallWidth = self.view.bounds.size.width > 0 ?
                                 self.view.bounds.size.width :
                                 [self getScreenBoundsForCurrentOrientation].size.width;

    [self popToViewController:anchorViewController animated:animated];

    CGFloat anchorInitX = anchorViewController.layeredNavigationItem.initialViewPosition.x;
    CGFloat anchorCurrentX = anchorViewController.layeredNavigationItem.currentViewPosition.x;
    CGFloat anchorWidth = anchorViewController.layeredNavigationItem.width;
    CGFloat initX = anchorInitX + (parentNavItem.nextItemDistance > 0 ?
                                   parentNavItem.nextItemDistance :
                                   FRLayeredNavigationControllerStandardDistance);
    navItem.initialViewPosition = CGPointMake(initX, 0);
    navItem.currentViewPosition = CGPointMake(anchorCurrentX + anchorWidth, 0);
    navItem.titleView = nil;
    navItem.title = nil;
    navItem.hasChrome = YES;

    configuration(newVC.layeredNavigationItem);

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
                                      self.view.bounds.size.height);
    CGRect offscreenFrame = CGRectMake(MAX(1024, onscreenFrame.origin.x),
                                       0,
                                       onscreenFrame.size.width,
                                       onscreenFrame.size.height);
    newVC.view.frame = offscreenFrame;

    [self.viewControllers addObject:newVC];
    [self addChildViewController:newVC];
    [self.view addSubview:newVC.view];
    [newVC didMoveToParentViewController:self];

    [UIView animateWithDuration:animated ? 0.5 : 0
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         CGFloat saved = [self savePlaceWanted:onscreenFrame.origin.x+width-overallWidth];
                         newVC.view.frame = CGRectMake(onscreenFrame.origin.x - saved,
                                                       onscreenFrame.origin.y,
                                                       onscreenFrame.size.width,
                                                       onscreenFrame.size.height);
                         newVC.layeredNavigationItem.currentViewPosition = newVC.view.frame.origin;

                     }
                     completion:^(BOOL finished) {
                     }];
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
               configuration:^(FRLayeredNavigationItem *item) {
               }];
}

#pragma mark - properties

@synthesize viewControllers = _viewControllers;
@synthesize panGR = _panGR;
@synthesize firstTouchedView = _firstTouchedView;
@synthesize outOfBoundsViewController = _outOfBoundsViewController;

@end
