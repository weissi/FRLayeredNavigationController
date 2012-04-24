//
//  FancyChromeController.m
//  FancyVCTest
//
//  Created by Johannes Weiß on 4/23/12.
//  Copyright (c) 2012 factis research GmbH. All rights reserved.
//

#import "FancyChromeController.h"

#import "FancyChromeView.h"

#import <QuartzCore/QuartzCore.h>

@interface FancyChromeController ()

@property (nonatomic, readwrite, retain) UIViewController *contentViewController;
@property (nonatomic, readwrite, assign) BOOL leaf;

@property (nonatomic, retain) FancyChromeView *chromeView;
@property (nonatomic, retain) UIView *borderView;
@property (nonatomic, retain) UIView *contentView;

@end

@implementation FancyChromeController

- (id)initWithContentViewController:(UIViewController *)aContentViewController leaf:(BOOL)isLeaf {
    if ((self = [super init])) {
        self.contentViewController = aContentViewController;
        self.leaf = isLeaf;
    }
    assert(self.parentViewController == nil);
    
    
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated {
    self.view.layer.shadowRadius = 10.0;
    self.view.layer.shadowOffset = CGSizeMake(-2.0, -3.0);
    self.view.layer.shadowOpacity = 0.5;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        /* will be REMOVED from a container controller */
        [self.contentViewController willMoveToParentViewController:nil];
        [self.contentViewController removeFromParentViewController];
    } else {
        /* will be added to a container controller */
        [self addChildViewController:self.contentViewController];
    }
}

- (void)doViewLayout {
    CGRect chromeFrame = CGRectMake(0,
                                    0,
                                    self.view.bounds.size.width,
                                    100);
    CGRect borderFrame = CGRectMake(0,
                                    100,
                                    self.view.bounds.size.width,
                                    self.view.bounds.size.height-100);
    CGRect contentFrame = CGRectMake(1,
                                     101,
                                     self.view.bounds.size.width-2,
                                     self.view.bounds.size.height-102);
    
    self.borderView.frame = borderFrame;
    self.chromeView.frame = chromeFrame;
    self.contentView.frame = contentFrame;
}

- (void)viewWillLayoutSubviews {
    [self doViewLayout];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (parent != nil) {
        assert(self.parentViewController == parent);
        
        self.contentView = self.contentViewController.view;
        
        self.chromeView = [[FancyChromeView alloc] init];
        
        self.borderView = [[UIView alloc] init];
        self.borderView.backgroundColor = [UIColor colorWithWhite:236.0f/255.0f alpha:1];
        
        [self.view addSubview:self.chromeView];
        [self.view addSubview:self.borderView];
        [self.view addSubview:self.contentView];
        
        self.chromeView.titleLabel.text = self.contentViewController.title;
        
        [self doViewLayout];
        
        [self.contentViewController didMoveToParentViewController:self];   
    } else {
        [self.contentView removeFromSuperview];
        [self.chromeView removeFromSuperview];
        [self.borderView removeFromSuperview];
        
        self.contentView = nil;
        self.borderView = nil;
        self.chromeView = nil;
        
        self.contentViewController = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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

@synthesize contentViewController;
@synthesize leaf;
@synthesize borderView;
@synthesize contentView;
@synthesize chromeView;

@end
