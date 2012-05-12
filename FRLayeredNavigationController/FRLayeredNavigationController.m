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

#import "FRLayeredNavigationController.h"
#import "FRLayerController.h"
#import "FRLayeredNavigationItem.h"
#import "UIViewController+FRLayeredNavigationController.h"

#import <QuartzCore/QuartzCore.h>

#define kFRLayeredNavigationControllerStandardDistance ((float)64)
#define kFRLayeredNavigationControllerStandardWidth ((float)400)

@interface FRLayeredNavigationController ()

@property (nonatomic, readwrite, strong) UIPanGestureRecognizer *panGR;
@property (nonatomic, readwrite, strong) UIView *firstTouchedView;
@property (nonatomic, readwrite, strong) NSMutableArray *viewControllers;

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
        layeredRC.layeredNavigationItem.nextItemDistance = kFRLayeredNavigationControllerStandardDistance;
        layeredRC.layeredNavigationItem.width = kFRLayeredNavigationControllerStandardWidth;
        layeredRC.layeredNavigationItem.hasChrome = NO;
        configuration(layeredRC.layeredNavigationItem);
    }
    return self;    
}

- (void)dealloc {
    self.panGR.delegate = nil;
}


#pragma mark - UIViewController interface

- (void)loadView
{
    NSAssert([self.viewControllers count] == 1, @"This is a bug, more than one ViewController present! Go on and implement more sophisticated view loading/unloading...");
    UIViewController *rootViewController = [self.viewControllers objectAtIndex:0];
    [self addChildViewController:rootViewController];
    
    self.view = [[UIView alloc] init];
    CGRect rootViewFrame = CGRectMake(0, 0, rootViewController.layeredNavigationItem.width, self.view.bounds.size.height);
    rootViewController.view.frame = rootViewFrame;
    rootViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:rootViewController.view];
    [rootViewController didMoveToParentViewController:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    self.panGR.maximumNumberOfTouches = 1;
    self.panGR.delegate = self;
    [self.view addGestureRecognizer:self.panGR];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    NSLog(@"ORIENTATION");
    for (FRLayerController *vc in self.viewControllers) {
        CGRect f = vc.view.frame;
        f.origin = vc.layeredNavigationItem.currentViewPosition;
        
        if (vc.maximumWidth) {
            f.size.width = self.view.bounds.size.width - vc.layeredNavigationItem.initialViewPosition.x;
            vc.layeredNavigationItem.width = f.size.width;
        }
        
        f.size.height = self.view.bounds.size.height;
        
        vc.view.frame = f;
    }
    return;
}

- (void)viewWillUnload
{
    NSAssert([self.viewControllers count] == 1, @"This is a bug, more than one ViewController present! Go on and implement more sophisticated view loading/unloading...");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - UIGestureRecognizer delegate interface

- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *touchedView = [gestureRecognizer.view hitTest:[gestureRecognizer locationInView:gestureRecognizer.view]
                                                withEvent:nil];
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStatePossible: {
            //NSLog(@"UIGestureRecognizerStatePossible");
            break;
        }
            
        case UIGestureRecognizerStateBegan: {
            //NSLog(@"UIGestureRecognizerStateBegan");
            self.firstTouchedView = touchedView;
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            //NSLog(@"UIGestureRecognizerStateChanged, vel=%f", [gestureRecognizer velocityInView:firstView].x);
            
            const NSInteger startVcIdx = [self.viewControllers count]-1;
            const UIViewController *startVc = [self.viewControllers objectAtIndex:startVcIdx];
            
            [self moveViewControllerIndex:startVcIdx
                    withGestureRecognizer:gestureRecognizer
                          withParentIndex:-1
                       parentLastPosition:CGPointZero
                      descendentOfTouched:NO];
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

+ (void)viewController:(FRLayerController *)vc xTranslation:(CGFloat)origXTranslation bounded:(BOOL)bounded {
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
            navItem.currentViewPosition = initPos;
        } else {
            navItem.currentViewPosition = f.origin;
        }
        vc.view.frame = f;
    }
}

- (void)viewControllersToSnappingPointsExpand:(BOOL)expand {
    FRLayerController *last = nil;
    CGFloat xTranslation = 0;
    
    for (FRLayerController *vc in self.viewControllers) {
        const CGPoint myPos = vc.layeredNavigationItem.currentViewPosition;
        const CGPoint myInitPos = vc.layeredNavigationItem.initialViewPosition;
        
        const CGFloat curDiff = myPos.x - last.layeredNavigationItem.currentViewPosition.x;
        const CGFloat initDiff = myInitPos.x - last.layeredNavigationItem.initialViewPosition.x;
        const CGFloat maxDiff = last.view.frame.size.width;
        
        if (xTranslation == 0 && (CGFloatNotEqual(curDiff, initDiff) && CGFloatNotEqual(curDiff, maxDiff))) {
            if (expand) {
                xTranslation = maxDiff - curDiff;
            } else {
                xTranslation = initDiff - curDiff;
            }
        }
        [FRLayeredNavigationController viewController:vc xTranslation:xTranslation bounded:YES];
        last = vc;
    }
}

- (void)moveToSnappingPointsWithGestureRecognizer:(UIPanGestureRecognizer *)g
{
    [self viewControllersToSnappingPointsExpand:[g velocityInView:self.view].x > 0];
}

- (void)moveViewControllerIndex:(NSInteger)myIndex
          withGestureRecognizer:(UIPanGestureRecognizer *)g
                withParentIndex:(NSInteger)parentIndex
             parentLastPosition:(CGPoint)parentOldPos
            descendentOfTouched:(BOOL)descendentOfTouched
{
    if (myIndex == 0) {
        return;
    }
    
    FRLayerController *me = [self.viewControllers objectAtIndex:myIndex];
    const FRLayerController *parent = parentIndex < 0 ? nil : [self.viewControllers objectAtIndex:myIndex+1];
    
    const CGPoint myPos = me.layeredNavigationItem.currentViewPosition;
    const CGPoint parentPos = parent.layeredNavigationItem.currentViewPosition;
    const CGPoint myInitPos = me.layeredNavigationItem.initialViewPosition;
    const CGPoint parentInitPos = parent.layeredNavigationItem.initialViewPosition;
    const CGFloat myWidth = me.view.frame.size.width;
    const CGPoint myOldPos = myPos;
    
    CGPoint myNewPos = myPos;
    
    CGFloat xTranslation = 0;
    
    if (parentIndex < 0 || !descendentOfTouched) {
        xTranslation = [g translationInView:me.view].x;
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
    
    UIView *touchedView = [g.view hitTest:[g locationInView:g.view] withEvent:nil];
    
    [FRLayeredNavigationController viewController:me
                                     xTranslation:xTranslation
                                          bounded:YES];  /* ![self.firstTouchedView isDescendantOfView:me.view]]; */
    
    if (!descendentOfTouched && [touchedView isDescendantOfView:me.view]) {
        [self moveViewControllerIndex:myIndex-1
                withGestureRecognizer:g
                      withParentIndex:myIndex
                   parentLastPosition:myOldPos
                  descendentOfTouched:YES];
    } else {
        [self moveViewControllerIndex:myIndex-1
                withGestureRecognizer:g 
                      withParentIndex:myIndex
                   parentLastPosition:myOldPos
                  descendentOfTouched:descendentOfTouched];
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
    
    CGRect goAwayFrame = CGRectMake(vc.view.frame.origin.x, 1024, vc.view.frame.size.width, vc.view.frame.size.height);
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
    
    [self popToViewController:anchorViewController animated:animated];
    
    CGFloat anchorInitX = anchorViewController.layeredNavigationItem.initialViewPosition.x;
    CGFloat anchorCurrentX = anchorViewController.layeredNavigationItem.currentViewPosition.x;
    CGFloat anchorWidth = anchorViewController.view.frame.size.width;
    CGFloat initX = anchorInitX + (parentNavItem.nextItemDistance > 0 ? parentNavItem.nextItemDistance :
                                                                            kFRLayeredNavigationControllerStandardDistance);
    
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
        width = newVC.maximumWidth ? self.view.bounds.size.width - initX : kFRLayeredNavigationControllerStandardWidth;
    }
    
    CGRect newFrame = CGRectMake(newVC.layeredNavigationItem.currentViewPosition.x,
                                 newVC.layeredNavigationItem.currentViewPosition.y,
                                 width,
                                 self.view.bounds.size.height);
    CGRect startFrame = CGRectMake(MAX(1024, newFrame.origin.x),
                                   0,
                                   newFrame.size.width,
                                   newFrame.size.height);
    

    [self.viewControllers addObject:newVC];
    [self addChildViewController:newVC];
    
    [self.view addSubview:newVC.view];
    [newVC didMoveToParentViewController:self];
    
    newVC.view.frame = startFrame;
    
    [UIView animateWithDuration:animated ? 0.5 : 0
                          delay:0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         CGFloat saved = [self savePlaceWanted:newFrame.origin.x+width-self.view.bounds.size.width];
                         newVC.view.frame = CGRectMake(newFrame.origin.x - saved,
                                                                newFrame.origin.y,
                                                                newFrame.size.width,
                                                                newFrame.size.height);
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

@end
