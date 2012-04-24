//
//  SampleContentViewController.m
//  FancyVCTest
//
//  Created by Johannes Weiß on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SampleContentViewController.h"

#import "FancyNavigationController.h"

@interface SampleContentViewController ()

@property (nonatomic, readwrite, retain) UIImageView *imageView;
@property (nonatomic, readwrite, retain) UIScrollView *scrollView;

@end

@implementation SampleContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)inScroll {
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
}

- (void)viewWillLayoutSubviews {
    scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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

@synthesize imageView;
@synthesize scrollView;

@end
