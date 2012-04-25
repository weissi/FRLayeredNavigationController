//
//  FancyNavigationController.m
//  FancyVCTest
//
//  Created by Johannes Weiß on 4/20/12.
//  Copyright (c) 2012 factis research GmbH. All rights reserved.
//

#import "FancyNavigationController.h"
#import "FancyChromeController.h"

#import <QuartzCore/QuartzCore.h>

@interface FancyNavigationController ()
@property (nonatomic, readwrite, assign) CGRect savedFirstFrame;
@property (nonatomic, readwrite, assign) CGRect savedSecondFrame;
@property (nonatomic, readwrite, assign) BOOL firstAndSecondBound;

@end

@implementation FancyNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super init];
    if (self) {
        self->viewControllers = [[NSMutableArray alloc] initWithObjects:rootViewController, nil];
    }
    return self;    
}

- (void)viewWillUnload {
    NSAssert([self->viewControllers count] == 1, @"This is a bug, more than one ViewController present! Go on and implement more sophisticated view loading/unloading...");
}

- (void)loadView {
    NSAssert([self->viewControllers count] == 1, @"This is a bug, more than one ViewController present! Go on and implement more sophisticated view loading/unloading...");
    UIViewController *rootViewController = [self->viewControllers objectAtIndex:0];
    [self addChildViewController:rootViewController];
    
    self.view = [[UIView alloc] init];
    CGRect rootViewFrame = CGRectMake(0, 0, 400, self.view.bounds.size.height);
    rootViewController.view.frame = rootViewFrame;
    rootViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:rootViewController.view];
    [rootViewController didMoveToParentViewController:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(handleGesture:)];
    panGR.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:panGR];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"steel" ofType:@"png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:path]];
}

- (void)fixUpWithGestureRecognizer:(UIPanGestureRecognizer *)g {
    FancyChromeController *last = nil;
    CGFloat xTranslation = 0;
    
    for (FancyChromeController *vc in self->viewControllers) {
        const CGPoint myPos = vc.view.frame.origin;
        const CGPoint myInitPos = vc.fancyNavigationItem.initialViewPosition;
        const CGSize mySize = vc.view.frame.size;
        
//        const CGPoint touchTranslation = 
        
        if (xTranslation == 0 && myPos.x != myInitPos.x) { // && myPos.x != last.view.frame.origin.x + last.view.frame.size.width) {
            //if (myPos.x < last.view.frame.origin.x + (last.view.frame.size.width/2)) {
            if ([g velocityInView:vc.view].x < 0) {
                xTranslation = myInitPos.x - myPos.x;
            } else {
                xTranslation = last.view.frame.origin.x + last.view.frame.size.width - myPos.x;
                
            }
        }
        
        vc.view.frame = CGRectMake(myPos.x + xTranslation, myPos.y, mySize.width, mySize.height);
        last = vc;
    }
}


- (void)blaWithGestureRecognizer:(UIPanGestureRecognizer *)g onViewControllerIndex:(NSInteger)myIndex withParent:(NSInteger)parentIndex parentLastPos:(CGPoint)parentOldPos {
    if (myIndex == 0) {
        return;
    }
    
    const FancyChromeController *me = [self.viewControllers objectAtIndex:myIndex];
    const FancyChromeController *parent = parentIndex < 0 ? nil : [self.viewControllers objectAtIndex:myIndex+1];
    
    const CGPoint myPos = me.view.frame.origin;
    const CGPoint parentPos = parent.view.frame.origin;
    const CGSize mySize = me.view.frame.size;
    
    const CGFloat myWidth = mySize.width;
    
    const CGPoint myOldPos = myPos;
    
    CGPoint myNewPos = myPos;
    
    if (parentIndex < 0) {
        CGPoint touchTranslation = [g translationInView:me.view];
        CGPoint translation;
        if (myPos.x + touchTranslation.x < me.fancyNavigationItem.initialViewPosition.x) {
            translation = CGPointMake(touchTranslation.x / 2, 0);
        } else {
            translation = touchTranslation;
        }
        myNewPos = CGPointMake(myPos.x + translation.x, myPos.y);
    } else {
        if (parentOldPos.x >= myPos.x) {
            myNewPos = CGPointMake(parentPos.x - myWidth, myPos.y);
            
        }
        
        if (parentPos.x >= myPos.x + myWidth) {
            // too far on the right, move, too 
            myNewPos = CGPointMake(parentPos.x - myWidth, myPos.y);
        }
        
        if (myNewPos.x < me.fancyNavigationItem.initialViewPosition.x) {
            myNewPos = me.fancyNavigationItem.initialViewPosition;
        }
    }
    
    me.view.frame = CGRectMake(myNewPos.x, myNewPos.y, mySize.width, mySize.height);
    
    [self blaWithGestureRecognizer:g onViewControllerIndex:myIndex-1 withParent:myIndex parentLastPos:myOldPos];
}

- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer {
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
            
            [self blaWithGestureRecognizer:gestureRecognizer
                     onViewControllerIndex:startVcIdx
                                withParent:-1
                             parentLastPos:CGPointZero];
            [gestureRecognizer setTranslation:CGPointZero inView:startVc.view];
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            //NSLog(@"UIGestureRecognizerStateEnded");
            [UIView animateWithDuration:0.2 animations:^{
                [self fixUpWithGestureRecognizer:gestureRecognizer];
            }];
             
            break;
        }
            
        default:
            break;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)popViewController {
    UIViewController *vc = [self->viewControllers lastObject];
    
    [vc willMoveToParentViewController:nil];
    [self->viewControllers removeObject:vc];
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];    
}

- (void)viewWillLayoutSubviews {
    NSInteger i = 0;
    for (UIViewController *vc in self->viewControllers) {
        FancyChromeController *fvc = nil;
        if ([vc class] == [FancyChromeController class]) {
            fvc = (FancyChromeController *)vc;
        }
        CGRect oldFrame = vc.view.frame;
        const CGFloat newX = fvc == nil ? 0 : fvc.fancyNavigationItem.initialViewPosition.x;
        CGRect newFrame = CGRectMake(newX,
                                     fvc == nil ? 0 : fvc.fancyNavigationItem.initialViewPosition.y,
                                     fvc.leaf ? self.view.bounds.size.width - newX : oldFrame.size.width,
                                     self.view.bounds.size.height);
        [UIView animateWithDuration:0.3 animations:^{
            vc.view.frame = newFrame;
        }];
        i++;
    }
    return;
}

- (void)pushViewController:(UIViewController *)contentViewController inFrontOf:(UIViewController *)anchorViewController leaf:(BOOL)isLeaf animated:(BOOL)animated {
    NSLog(@"MASTER parent: %@", [self.parentViewController description]);
    FancyChromeController *viewController = [[FancyChromeController alloc]
                                        initWithContentViewController:contentViewController leaf:isLeaf];
    BOOL isNewLayer = YES;
    
    {
        UIViewController *vc;
        while ((vc = [self->viewControllers lastObject])) {
            if (([vc class] == [FancyChromeController class] &&
                 ((FancyChromeController*)vc).contentViewController == anchorViewController) ||
                ([vc class] != [FancyChromeController class] &&
                 vc == anchorViewController)) {
                    break;
            }
            
            NSLog(@"Dismissing %@", [vc description]);
            [self popViewController];
            isNewLayer = NO;
        }
    }
    
    NSUInteger vcCount = [self->viewControllers count];
    NSLog(@"pushing, having %u vcs", vcCount);

    /*
    CGRect startFrame = CGRectMake(1000, 0, 400, 400);
    
    CGRect newFrame = CGRectMake(100*(1+vcCount),
                                 100*(1+vcCount),
                                 400,
                                 400);
     */
    
    CGRect startFrame = CGRectMake(1024,
                                   0,
                                   viewController.leaf ? self.view.bounds.size.width - vcCount * 44 : 400,
                                   self.view.bounds.size.height);
    
    viewController.fancyNavigationItem.initialViewPosition = CGPointMake(vcCount * 44, 0);
    
    CGRect newFrame = CGRectMake(viewController.fancyNavigationItem.initialViewPosition.x,
                                 viewController.fancyNavigationItem.initialViewPosition.y,
                                 startFrame.size.width,
                                 startFrame.size.height);
    if (!isNewLayer) {
        startFrame = newFrame;
    }

    
    [self->viewControllers addObject:viewController];
    
    NSAssert(self.parentViewController == nil, @"NavVC.parent != nil");
    NSAssert(viewController.parentViewController == nil, @"VC.parent != nil");
    NSAssert([self class] == [FancyNavigationController class], @"NavVC wrong class");
    NSAssert([viewController class] == [FancyChromeController class], @"VC wrong class");

    [self addChildViewController:viewController];
    
    viewController.view.frame = startFrame;
    
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    
    [UIView animateWithDuration:0.5
                          delay:0
                        options: isNewLayer ? UIViewAnimationCurveEaseOut : UIViewAnimationTransitionFlipFromLeft
                     animations:^{
                         viewController.view.frame = newFrame;
                     }
                     completion:^(BOOL finished) {
                     }];
    [self.view setNeedsLayout];
}

@synthesize viewControllers;
@synthesize savedFirstFrame;
@synthesize savedSecondFrame;
@synthesize firstAndSecondBound;

@end
