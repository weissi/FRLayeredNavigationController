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

#import "FancyChromeController.h"

#import "FancyChromeView.h"

#import <QuartzCore/QuartzCore.h>

@interface FancyChromeController ()

@property (nonatomic, readwrite, retain) UIViewController *contentViewController;
@property (nonatomic, readwrite, retain) FancyNavigationItem *fancyNavigationItem;
@property (nonatomic, readwrite, assign) BOOL leaf;

@property (nonatomic, retain) FancyChromeView *chromeView;
@property (nonatomic, retain) UIView *borderView;
@property (nonatomic, retain) UIView *contentView;

@end

@implementation FancyChromeController

- (id)initWithContentViewController:(UIViewController *)aContentViewController leaf:(BOOL)isLeaf {
    if ((self = [super init])) {
        self.contentViewController = aContentViewController;
        self.fancyNavigationItem = [[FancyNavigationItem alloc] init];
        self.leaf = isLeaf;
    }
    assert(self.parentViewController == nil);

    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor clearColor];
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
                                    44);
    CGRect borderFrame = CGRectMake(0,
                                    44,
                                    self.view.bounds.size.width,
                                    self.view.bounds.size.height-44);
    CGRect contentFrame = CGRectMake(1,
                                     45,
                                     self.view.bounds.size.width-2,
                                     self.view.bounds.size.height-46);
    
    self.borderView.frame = borderFrame;
    self.chromeView.frame = chromeFrame;
    self.contentView.frame = contentFrame;
}

- (void)viewWillLayoutSubviews {
    self.view.layer.shadowRadius = 10.0;
    self.view.layer.shadowOffset = CGSizeMake(-2.0, -3.0);
    self.view.layer.shadowOpacity = 0.5;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;

    [self doViewLayout];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (parent != nil) {
        assert(self.parentViewController == parent);
        
        const FancyNavigationItem *navItem = self.fancyNavigationItem;
        
        self.contentView = self.contentViewController.view;
        
        self.chromeView = [[FancyChromeView alloc] initWithFrame:CGRectZero
                                                       titleView:navItem.titleView
                                                           title:navItem.title == nil ?
                           self.contentViewController.title : navItem.title];
        
        self.borderView = [[UIView alloc] init];
        self.borderView.backgroundColor = [UIColor colorWithWhite:236.0f/255.0f alpha:1];
        
        [self.view addSubview:self.chromeView];
        [self.view addSubview:self.borderView];
        [self.view addSubview:self.contentView];
        
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
    
    self.contentView = nil;
    self.borderView = nil;
    self.chromeView = nil;
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
@synthesize fancyNavigationItem;

@end
