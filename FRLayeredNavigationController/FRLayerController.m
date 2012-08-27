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

#import "FRDLog.h"
#import "FRLayerController.h"
#import "FRLayerChromeView.h"
#import "FRLayeredNavigationItem+Protected.h"

#import <QuartzCore/QuartzCore.h>

#define FRLayerChromeHeight ((CGFloat)44)

@interface FRLayerController ()

@property (nonatomic, readwrite, strong) UIViewController *contentViewController;
@property (nonatomic, readwrite, strong) FRLayeredNavigationItem *layeredNavigationItem;
@property (nonatomic, readwrite) BOOL maximumWidth;

@property (nonatomic, strong) FRLayerChromeView *chromeView;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, weak) UIView *contentView;

@end

@implementation FRLayerController

#pragma mark - init/dealloc

- (id)initWithContentViewController:(UIViewController *)vc maximumWidth:(BOOL)maxWidth
{
    if ((self = [super init])) {
        _layeredNavigationItem = [[FRLayeredNavigationItem alloc] init];
        _layeredNavigationItem.layerController = self;
        _contentViewController = vc;
        [_contentViewController addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
        _maximumWidth = maxWidth;
    }

    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"title"]) {
        self.chromeView.title = [change objectForKey:@"new"];
    }
}

- (void)dealloc
{
    self.layeredNavigationItem.layerController = nil;
    [_contentViewController removeObserver:self forKeyPath:@"title"];
}

#pragma mark - internal methods

- (void)doViewLayout
{
    CGRect contentFrame = CGRectZero;

    if (self.layeredNavigationItem.hasChrome) {
        CGRect chromeFrame = CGRectMake(0,
                                        0,
                                        CGRectGetWidth(self.view.bounds),
                                        FRLayerChromeHeight);
        CGRect borderFrame = CGRectMake(0,
                                        FRLayerChromeHeight,
                                        CGRectGetWidth(self.view.bounds),
                                        CGRectGetHeight(self.view.bounds)-FRLayerChromeHeight);
        contentFrame = CGRectMake(1,
                                  FRLayerChromeHeight + 1,
                                  CGRectGetWidth(self.view.bounds)-2,
                                  CGRectGetHeight(self.view.bounds)-FRLayerChromeHeight-2);
        self.borderView.frame = borderFrame;
        self.chromeView.frame = chromeFrame;
    } else {
        contentFrame = CGRectMake(0,
                                  0,
                                  CGRectGetWidth(self.view.bounds),
                                  CGRectGetHeight(self.view.bounds));
    }


    self.contentView.frame = contentFrame;
}


#pragma mark - UIViewController interface methods

- (void)loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor clearColor];

    const FRLayeredNavigationItem *navItem = self.layeredNavigationItem;

    if (self.layeredNavigationItem.hasChrome) {
        self.chromeView = [[FRLayerChromeView alloc] initWithFrame:CGRectZero
                                                         titleView:navItem.titleView
                                                             title:navItem.title == nil ?
                           self.contentViewController.title : navItem.title];

        self.borderView = [[UIView alloc] init];
        self.borderView.backgroundColor = [UIColor colorWithWhite:236.0f/255.0f alpha:1];

        [self.view addSubview:self.chromeView];
        [self.view addSubview:self.borderView];
    }

    if (self.contentView == nil && self.contentViewController.parentViewController == self) {
        /* when loaded again after a low memory view removal */
        self.contentView = self.contentViewController.view;
    }

    if (self.contentView != nil) {
        [self.view addSubview:self.contentView];
    }
}

- (void)viewWillLayoutSubviews
{
    if (self.layeredNavigationItem.displayShadow) {
        self.view.layer.shadowRadius = 10.0;
        self.view.layer.shadowOffset = CGSizeMake(-2.0, -3.0);
        self.view.layer.shadowOpacity = 0.5;
        self.view.layer.shadowColor = [UIColor blackColor].CGColor;
        self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    }

    [self doViewLayout];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    FRDLOG(@"FRLayerController (%@): viewDidUnload", self);

    self.borderView = nil;
    self.chromeView = nil;
    self.contentView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];

    if (parent != nil) {
        /* will shortly attach to parent */
        [self addChildViewController:self.contentViewController];

        self.contentView = self.contentViewController.view;
        [self.view addSubview:self.contentView];
    } else {
        /* will shortly detach from parent view controller */
        [self.contentViewController willMoveToParentViewController:nil];

        [self.contentView removeFromSuperview];
        self.contentView = nil;
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];

    if (parent != nil) {
        /* just attached to parent view controller */
        [self.contentViewController didMoveToParentViewController:self];
    } else {
        /* did just detach */
        [self.contentViewController removeFromParentViewController];
    }
}

@synthesize contentViewController = _contentViewController;
@synthesize maximumWidth = _maximumWidth;
@synthesize borderView = _borderView;
@synthesize chromeView = _chromeView;
@synthesize layeredNavigationItem = _layeredNavigationItem;
@synthesize contentView = _contentView;

@end
