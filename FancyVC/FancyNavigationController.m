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

#import "FancyNavigationController.h"
#import "FancyChromeController.h"
#import "UIViewController+FancyNavigationController.h"

#import <QuartzCore/QuartzCore.h>

#define kFancyNavigationControllerStandardDistance ((float)64)
#define kFancyNavigationControllerStandardWidth ((float)400)

@interface FancyNavigationController ()

@property (nonatomic, readwrite, retain) UIPanGestureRecognizer *panGR;

@end

@implementation FancyNavigationController

#pragma mark - Initialization/dealloc
- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    return [self initWithRootViewController:rootViewController configuration:^(FancyNavigationItem *item) {
        /* nothing */
    }];
}
    
    - (id)initWithRootViewController:(UIViewController *)rootViewController
configuration:(void (^)(FancyNavigationItem *item))configuration
    {
    self = [super init];
    if (self) {
        FancyChromeController *fancyRC = [[FancyChromeController alloc] initWithContentViewController:rootViewController leaf:NO];
        self->viewControllers = [[NSMutableArray alloc] initWithObjects:fancyRC, nil];
        fancyRC.fancyNavigationItem.nextItemDistance = kFancyNavigationControllerStandardDistance;
        fancyRC.fancyNavigationItem.width = kFancyNavigationControllerStandardWidth;
        fancyRC.fancyNavigationItem.hasChrome = NO;
        configuration(fancyRC.fancyNavigationItem);
    }
    return self;    
}

- (void)dealloc {
    self.panGR.delegate = nil;
}


#pragma mark - UIViewController interface

- (void)loadView
{
    NSAssert([self->viewControllers count] == 1, @"This is a bug, more than one ViewController present! Go on and implement more sophisticated view loading/unloading...");
    UIViewController *rootViewController = [self->viewControllers objectAtIndex:0];
    [self addChildViewController:rootViewController];
    
    self.view = [[UIView alloc] init];
    CGRect rootViewFrame = CGRectMake(0, 0, rootViewController.fancyNavigationItem.width, self.view.bounds.size.height);
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
    for (FancyChromeController *vc in self->viewControllers) {
        CGRect f = vc.view.frame;
        f.origin = vc.fancyNavigationItem.currentViewPosition;
        
        if (vc.leaf) {
            f.size.width = self.view.bounds.size.width - vc.fancyNavigationItem.initialViewPosition.x;
            vc.fancyNavigationItem.width = f.size.width;
        }
        
        f.size.height = self.view.bounds.size.height;
        
        vc.view.frame = f;
    }
    return;
}

- (void)viewWillUnload
{
    NSAssert([self->viewControllers count] == 1, @"This is a bug, more than one ViewController present! Go on and implement more sophisticated view loading/unloading...");
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
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStatePossible: {
            //NSLog(@"UIGestureRecognizerStatePossible");
            break;
        }
            
        case UIGestureRecognizerStateBegan: {
            //NSLog(@"UIGestureRecognizerStateBegan");
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            //NSLog(@"UIGestureRecognizerStateChanged, vel=%f", [gestureRecognizer velocityInView:firstView].x);
            
            const NSInteger startVcIdx = [self->viewControllers count]-1;
            const UIViewController *startVc = [self->viewControllers objectAtIndex:startVcIdx];
            
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

+ (void)viewController:(FancyChromeController *)vc xTranslation:(CGFloat)origXTranslation bounded:(BOOL)bounded {
    CGRect f = vc.view.frame;
    CGFloat xTranslation;
    const CGPoint initPos = vc.fancyNavigationItem.initialViewPosition;
    
    if (f.origin.x < initPos.x && origXTranslation < 0) {
        /* if view already left from left bound and still moving left, half moving speed */
        xTranslation = origXTranslation / 2;
    } else {
        xTranslation = origXTranslation;
    }
    
    if (f.origin.x + xTranslation < initPos.x) {
        if (bounded) {
            f.origin.x = initPos.x;
            if (xTranslation > 0) {
                f.origin.x += xTranslation;
            }
            vc.fancyNavigationItem.currentViewPosition = f.origin;
            vc.view.frame = f;
            return;
        } else {
            f.origin.x += xTranslation;
            vc.fancyNavigationItem.currentViewPosition = initPos;
            vc.view.frame = f;
        }
    } else {
        f.origin.x += xTranslation;
        vc.fancyNavigationItem.currentViewPosition = f.origin;
        vc.view.frame = f;
        return;
    }
}

- (void)viewControllersToSnappingPointsExpand:(BOOL)expand {
    FancyChromeController *last = nil;
    CGFloat xTranslation = 0;
    
    for (FancyChromeController *vc in self->viewControllers) {
        const CGPoint myPos = vc.view.frame.origin;
        const CGPoint myInitPos = vc.fancyNavigationItem.initialViewPosition;
        
        const CGFloat curDiff = myPos.x - last.view.frame.origin.x;
        const CGFloat initDiff = myInitPos.x - last.fancyNavigationItem.initialViewPosition.x;
        const CGFloat maxDiff = last.view.frame.size.width;
        
        if (xTranslation == 0 && (curDiff != initDiff && curDiff != maxDiff)) {
            if (expand) {
                xTranslation = maxDiff - curDiff;
            } else {
                xTranslation = initDiff - curDiff;
            }
        }
        [FancyNavigationController viewController:vc xTranslation:xTranslation bounded:YES];
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
    
    FancyChromeController *me = [self.viewControllers objectAtIndex:myIndex];
    const FancyChromeController *parent = parentIndex < 0 ? nil : [self.viewControllers objectAtIndex:myIndex+1];
    
    const CGPoint myPos = me.fancyNavigationItem.currentViewPosition;
    const CGPoint parentPos = parent.fancyNavigationItem.currentViewPosition;
    const CGPoint myInitPos = me.fancyNavigationItem.initialViewPosition;
    const CGPoint parentInitPos = parent.fancyNavigationItem.initialViewPosition;
    const CGFloat myWidth = me.view.frame.size.width;
    const CGPoint myOldPos = myPos;
    
    CGPoint myNewPos = myPos;
    
    CGFloat xTranslation = 0;
    BOOL bounded = YES; //parentIndex >= 0;
    
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
    
    [FancyNavigationController viewController:me xTranslation:xTranslation bounded:bounded];
    
    UIView *touchedView = [g.view hitTest:[g locationInView:g.view] withEvent:nil];
    
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
    
    for (FancyChromeController *vc in self->viewControllers) {
        const CGFloat initX = vc.fancyNavigationItem.initialViewPosition.x;
        const CGFloat currentX = vc.fancyNavigationItem.currentViewPosition.x;
        
        if (initX < currentX + xTranslation) {
            xTranslation += initX - (currentX + xTranslation);
        }
        
        if (abs(xTranslation) >= pointsWanted) {
            break;
        }
    }
    
    for (FancyChromeController *vc in self->viewControllers) {
        if (vc == [self->viewControllers lastObject]) {
            break;
        }
        [FancyNavigationController viewController:vc xTranslation:xTranslation bounded:YES];
    }
    return abs(xTranslation);
}


#pragma mark - Public API

- (void)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *vc = [self->viewControllers lastObject];
    
    if ([self->viewControllers count] == 1) {
        /* don't remove root view controller */
        return;
    }
    
    [vc willMoveToParentViewController:nil];
    [self->viewControllers removeObject:vc];
    
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

    while ((currentVc = [self->viewControllers lastObject])) {
        if (([currentVc class] == [FancyChromeController class] &&
             ((FancyChromeController*)currentVc).contentViewController == vc) ||
            ([currentVc class] != [FancyChromeController class] &&
             currentVc == vc)) {
                break;
            }
        
        if ([self->viewControllers count] == 1) {
            /* don't remove root view controller */
            return;
        }
        
        [self popViewControllerAnimated:animated];
    }
}

- (void)popToRootViewControllerAnimated:(BOOL)animated
{
    [self popToViewController:[self->viewControllers objectAtIndex:0] animated:animated];
}

- (void)pushViewController:(UIViewController *)contentViewController
                 inFrontOf:(UIViewController *)anchorViewController
              maximumWidth:(BOOL)maxWidth
                  animated:(BOOL)animated
             configuration:(void (^)(FancyNavigationItem *item))configuration
{
    FancyChromeController *newVC = [[FancyChromeController alloc]
                                                   initWithContentViewController:contentViewController leaf:maxWidth];
    const FancyNavigationItem *navItem = newVC.fancyNavigationItem;
    const FancyNavigationItem *parentNavItem = anchorViewController.fancyNavigationItem;
    
    [self popToViewController:anchorViewController animated:animated];
    
    CGFloat anchorInitX = anchorViewController.fancyNavigationItem.initialViewPosition.x;
    CGFloat anchorCurrentX = anchorViewController.fancyNavigationItem.currentViewPosition.x;
    CGFloat anchorWidth = anchorViewController.view.frame.size.width;
    CGFloat initX = anchorInitX + (parentNavItem.nextItemDistance > 0 ? parentNavItem.nextItemDistance :
                                                                            kFancyNavigationControllerStandardDistance);
    
    navItem.initialViewPosition = CGPointMake(initX, 0);
    navItem.currentViewPosition = CGPointMake(anchorCurrentX + anchorWidth, 0);
    navItem.titleView = nil;
    navItem.title = nil;
    navItem.hasChrome = YES;
    
    configuration(newVC.fancyNavigationItem);
    
    CGFloat width;
    if (navItem.width > 0) {
        width = navItem.width;
    } else {
        width = newVC.leaf ? self.view.bounds.size.width - initX : kFancyNavigationControllerStandardWidth;
    }
    
    CGRect newFrame = CGRectMake(newVC.fancyNavigationItem.currentViewPosition.x,
                                 newVC.fancyNavigationItem.currentViewPosition.y,
                                 width,
                                 self.view.bounds.size.height);
    CGRect startFrame = CGRectMake(MAX(1024, newFrame.origin.x),
                                   0,
                                   newFrame.size.width,
                                   newFrame.size.height);
    

    [self->viewControllers addObject:newVC];
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
                         newVC.fancyNavigationItem.currentViewPosition = newVC.view.frame.origin;

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
               configuration:^(FancyNavigationItem *item) {
               }];
}

#pragma mark - properties

@synthesize viewControllers;
@synthesize panGR;

@end
