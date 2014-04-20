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

/* Local Imports */
#import "FRDLog.h"
#import "FRLayerController.h"
#import "FRLayerChromeView.h"
#import "FRLayeredNavigationItem+Protected.h"
#import "FRiOSVersion.h"

@interface FRLayerController ()

@property (nonatomic, readwrite, strong) UIViewController *contentViewController;
@property (nonatomic, readwrite, strong) FRLayeredNavigationItem *layeredNavigationItem;
@property (nonatomic, readwrite) BOOL maximumWidth;

@property (nonatomic, strong) FRLayerChromeView *chromeView;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, weak) UIView *contentView;

@property (nonatomic, assign, readonly) BOOL isIOS7OrNewer;

@end

@implementation FRLayerController

#pragma mark - init/dealloc

- (id)initWithContentViewController:(UIViewController *)vc maximumWidth:(BOOL)maxWidth
{
    if ((self = [super init])) {
        _layeredNavigationItem = [[FRLayeredNavigationItem alloc] init];
        _layeredNavigationItem.layerController = self;
        _contentViewController = vc;
        _isIOS7OrNewer = [FRiOSVersion isIOS7OrNewer];
        [_contentViewController addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
        _maximumWidth = maxWidth;
    }

    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(__unused id)object
                        change:(NSDictionary *)change
                       context:(__unused void *)context
{
    if ([keyPath isEqualToString:@"title"]) {
        self.chromeView.title = change[@"new"];
    }
}

- (void)dealloc
{
    self.layeredNavigationItem.layerController = nil;
    [_contentViewController removeObserver:self forKeyPath:@"title"];
}

#pragma mark - internal methods

- (CGFloat)layerChromeHeight
{
    return self.isIOS7OrNewer ? 64 : 44;
}

- (CGFloat)layerChromeOffset
{
    return self.isIOS7OrNewer ? 20 : 0;
}

- (void)doViewLayout
{
    CGRect contentFrame = CGRectZero;
    CGRect borderFrame = CGRectZero;
    const CGFloat borderSpacing = self.layeredNavigationItem.hasBorder ? 1 : 0;

    if (self.layeredNavigationItem.hasChrome) {
        CGRect chromeFrame = CGRectMake(0,
                                        0,
                                        CGRectGetWidth(self.view.bounds),
                                        [self layerChromeHeight]);
        borderFrame = CGRectMake(0,
                                 [self layerChromeHeight],
                                 CGRectGetWidth(self.view.bounds),
                                 CGRectGetHeight(self.view.bounds)-[self layerChromeHeight]);
        contentFrame = CGRectMake(borderSpacing,
                                  [self layerChromeHeight] + borderSpacing,
                                  CGRectGetWidth(self.view.bounds)-(2*borderSpacing),
                                  CGRectGetHeight(self.view.bounds)-[self layerChromeHeight]-(2*borderSpacing));
        self.chromeView.frame = chromeFrame;
    } else {
        borderFrame = CGRectMake(0,
                                 0,
                                 CGRectGetWidth(self.view.bounds),
                                 CGRectGetHeight(self.view.bounds));
        contentFrame = CGRectMake(borderSpacing,
                                  borderSpacing,
                                  CGRectGetWidth(self.view.bounds)-(2*borderSpacing),
                                  CGRectGetHeight(self.view.bounds)-(2*borderSpacing));
    }

    if (self.layeredNavigationItem.hasBorder) {
        self.borderView.frame = borderFrame;
    }
    if (self.layeredNavigationItem.autosizeContent) {
        self.contentView.frame = contentFrame;
    }
}


#pragma mark - UIViewController interface methods

- (void)loadView
{
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor clearColor];

    const FRLayeredNavigationItem *navItem = self.layeredNavigationItem;

    if (navItem.hasBorder) {
        self.borderView = [[UIView alloc] init];
        self.borderView.backgroundColor = [UIColor clearColor];
        self.borderView.layer.borderWidth = 1;
        self.borderView.layer.borderColor = [UIColor colorWithWhite:236.0f/255.0f alpha:1].CGColor;
        [self.view addSubview:self.borderView];
    }

    if (self.layeredNavigationItem.hasChrome) {
        self.chromeView = [[FRLayerChromeView alloc] initWithFrame:CGRectZero
                                                         titleView:navItem.titleView
                                                             title:navItem.title == nil ?
                           self.contentViewController.title : navItem.title
                                                           yOffset:[self layerChromeOffset]];

        [self.view addSubview:self.chromeView];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(__unused UIInterfaceOrientation)interfaceOrientation
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

@end
