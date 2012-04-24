//
//  FancyNavigationController.m
//  FancyVCTest
//
//  Created by Johannes Weiß on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
    [self.view addGestureRecognizer:panGR];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"steel" ofType:@"png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:path]];
}

- (void)handleGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    NSInteger firstIdx = [self->viewControllers count] - 1;
    NSInteger secondIdx = firstIdx - 1;
    BOOL moveFirstView = firstIdx > 0;
    BOOL moveSecondView = secondIdx > 0;
    UIViewController *firstVC;
    UIViewController *secondVC;

    if (moveFirstView) {
         firstVC = [self->viewControllers objectAtIndex:firstIdx];
    } else {
        firstVC = nil;
    }
    
    if (moveSecondView) {
        secondVC = [self->viewControllers objectAtIndex:secondIdx];
    } else {
        secondVC = nil;
    }
    
    UIView *firstView = firstVC.view;
    UIView *secondView = secondVC.view;
    
    if (!moveFirstView && !moveSecondView) {
        return;
    }

    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStatePossible: {
            //NSLog(@"UIGestureRecognizerStatePossible");
            break;
        }
            
        case UIGestureRecognizerStateBegan: {
            //NSLog(@"UIGestureRecognizerStateBegan");
            self.savedFirstFrame = firstView.frame;
            self.savedSecondFrame = secondView.frame;
            self.firstAndSecondBound = NO;
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            //NSLog(@"UIGestureRecognizerStateChanged, vel=%f", [gestureRecognizer velocityInView:firstView].x);

            CGPoint trans = [gestureRecognizer translationInView:firstView];
            float speedFactor = (firstView.frame.origin.x > self.savedFirstFrame.origin.x ? 1 : 0.5);
            
            CGPoint ff = CGPointMake(firstView.frame.origin.x + trans.x*speedFactor, firstView.frame.origin.y);
            firstView.frame = CGRectMake(ff.x, ff.y, firstView.frame.size.width, firstView.frame.size.height);
                        
            if (self.firstAndSecondBound) {
                CGPoint fs = CGPointMake(secondView.frame.origin.x + trans.x*speedFactor, secondView.frame.origin.y);
                secondView.frame = CGRectMake(fs.x, fs.y, secondView.frame.size.width, secondView.frame.size.height);
            }
            
            if (firstView.frame.origin.x > secondView.frame.origin.x + secondView.frame.size.width) {
                self.firstAndSecondBound = YES;
                
                CGRect newSecondFrame = CGRectMake(ff.x - secondView.frame.size.width, secondView.frame.origin.y, secondView.frame.size.width, secondView.frame.size.height);
                secondView.frame = newSecondFrame;
            }
            if (secondView.frame.origin.x < self.savedSecondFrame.origin.x) {
                self.firstAndSecondBound = NO;
            }
            [gestureRecognizer setTranslation:CGPointZero inView:firstView];
            
            if (([gestureRecognizer locationInView:self.view].x > (self.view.bounds.size.width - 100)) ||
                (firstView.frame.origin.x > (self.view.bounds.size.width - 100))) {
                firstView.layer.opacity = 0.4;
            } else {
                firstView.layer.opacity = 1;
            }
            break;
        }
            
        case UIGestureRecognizerStateEnded: {
            BOOL poppedFirst = NO;
            //NSLog(@"UIGestureRecognizerStateEnded");
            
            if (([gestureRecognizer locationInView:self.view].x > (self.view.bounds.size.width - 100)) ||
                (firstView.frame.origin.x > (self.view.bounds.size.width - 100))) {
                [self popViewController];
                poppedFirst = YES;
            }
            
            [UIView animateWithDuration:0.5
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 if (!poppedFirst) {
                                     firstView.frame = self.savedFirstFrame;
                                 }
                                 secondView.frame = self.savedSecondFrame;
                             }
                             completion:^(BOOL finished) {
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
    // Release any retained subviews of the main view.
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
    for (UIViewController *vc in self->viewControllers) {
        CGRect oldFrame = vc.view.frame;
        CGRect newFrame = CGRectMake(oldFrame.origin.x,
                                     oldFrame.origin.y,
                                     oldFrame.size.width,
                                     self.view.bounds.size.height);
        vc.view.frame = newFrame;
    }
    return;
}

- (void)pushViewController:(UIViewController *)contentViewController behind:(UIViewController *)anchorViewController animated:(BOOL)animated {
    NSLog(@"MASTER parent: %@", [self.parentViewController description]);
    UIViewController *viewController = [[FancyChromeController alloc]
                                        initWithContentViewController:contentViewController];
    
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
    
    CGRect startFrame = CGRectMake(1000, 0, 400, self.view.frame.size.height);
    
    CGRect newFrame = CGRectMake(100*vcCount,
                                 0,
                                 400,
                                 self.view.bounds.size.height);

    
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
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         viewController.view.frame = newFrame;
                     }
                     completion:^(BOOL finished) {
                     }];     
}

@synthesize viewControllers;
@synthesize savedFirstFrame;
@synthesize savedSecondFrame;
@synthesize firstAndSecondBound;

@end
