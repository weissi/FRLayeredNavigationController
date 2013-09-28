/*
 * This file is part of FRLayeredNavigationController.
 *
 * Copyright (c) 2012, 2013, Johannes Weiß <weiss@tux4u.de>
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

#import "SampleContentViewController.h"

#import "FRLayeredNavigation.h"

@interface SampleContentViewController ()

@property (nonatomic, readwrite, strong) UIImageView *imageView;
@property (nonatomic, readwrite, strong) UIScrollView *scrollView;

@end

@implementation SampleContentViewController

- (void)hooray
{
    NSLog(@"hooray");
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(UIView *) viewForZoomingInScrollView:(__unused UIScrollView *)inScroll {
    return self.imageView;
}

- (void)loadView
{
    self.view = [[UIView alloc] init];

    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"mandel" ofType:@"jpg"];
    UIImage *img = [UIImage imageWithContentsOfFile:path];
    self.imageView = [[UIImageView alloc] initWithImage:img];

    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.maximumZoomScale = 10;
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.backgroundColor = [UIColor blueColor];
    self.scrollView.clipsToBounds = YES;
    self.scrollView.delegate = self;
    [self.scrollView addSubview:self.imageView];
    self.scrollView.zoomScale = .37;

    [self.view addSubview:self.scrollView];

    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(10, 10, 400, 40)];
    [self.view addSubview:slider];
}

- (void)viewWillLayoutSubviews {
    _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)viewWillAppear:(__unused BOOL)animated
{
    self.layeredNavigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                                    initWithImage:[UIImage imageNamed:@"back.png"]
                                                    style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(hooray)];
    self.layeredNavigationItem.leftBarButtonItem.style = UIBarButtonItemStyleBordered;
    self.layeredNavigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                     initWithImage:[UIImage imageNamed:@"back.png"]
                                                     style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(hooray)];
    self.layeredNavigationItem.rightBarButtonItem.style = UIBarButtonItemStyleBordered;
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        self.scrollView.delegate = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.scrollView.delegate = nil;
    self.scrollView = nil;
    self.imageView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(__unused UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)indexDidChangeForSegmentedControl:(__unused UISegmentedControl *)sc
{
    NSLog(@"SC changed");
}

@end
