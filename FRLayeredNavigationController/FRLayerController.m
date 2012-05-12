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

#import "FRLayerController.h"
#import "FRLayerChromeView.h"
#import "FRLayeredNavigation.h"
#import "FRLayeredNavigationItem+Protected.h"

#import <QuartzCore/QuartzCore.h>

@interface FRLayerController ()

@property (nonatomic, readwrite, strong) UIViewController *contentViewController;
@property (nonatomic, readwrite, strong) FRLayeredNavigationItem *layeredNavigationItem;
@property (nonatomic, readwrite) BOOL maximumWidth;

@property (nonatomic, strong) FRLayerChromeView *chromeView;
@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation FRLayerController

- (id)initWithContentViewController:(UIViewController *)vc maximumWidth:(BOOL)maxWidth {
    if ((self = [super init])) {
        _layeredNavigationItem = [[FRLayeredNavigationItem alloc] init];
        _layeredNavigationItem.layerController = self;
        _contentViewController = vc;
        _maximumWidth = maxWidth;
    }
    assert(self.parentViewController == nil);

    return self;
}

- (void)dealloc
{
    self.layeredNavigationItem.layerController = nil;
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
    CGRect contentFrame = CGRectZero;
    
    if (self.layeredNavigationItem.hasChrome) {
        CGRect chromeFrame = CGRectMake(0,
                                        0,
                                        self.view.bounds.size.width,
                                        44);
        CGRect borderFrame = CGRectMake(0,
                                        44,
                                        self.view.bounds.size.width,
                                        self.view.bounds.size.height-44);
        contentFrame = CGRectMake(1,
                                  45,
                                  self.view.bounds.size.width-2,
                                  self.view.bounds.size.height-46);
        self.borderView.frame = borderFrame;
        self.chromeView.frame = chromeFrame;
    } else {
        contentFrame = CGRectMake(0,
                                         0,
                                         self.view.bounds.size.width,
                                         self.view.bounds.size.height);
    }
    
    
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
        
        const FRLayeredNavigationItem *navItem = self.layeredNavigationItem;
        
        self.contentView = self.contentViewController.view;
        
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

@synthesize contentViewController = _contentViewController;
@synthesize maximumWidth = _maximumWidth;
@synthesize borderView = _borderView;
@synthesize contentView = _contentView;
@synthesize chromeView = _chromeView;
@synthesize layeredNavigationItem = _layeredNavigationItem;

@end
