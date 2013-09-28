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

#import "SampleListViewController.h"
#import "SampleContentViewController.h"

#import "FRLayeredNavigation.h"

@interface SampleListViewController ()

@end

@implementation SampleListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"demo";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)hooray
{
    NSLog(@"hooray");
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(__unused UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSString *)cellText:(NSInteger)n {
    if (n < 0) {
        return @"iOS stinkt";
    } else if (n == 0) {
        return @"content (ANIMATION)";
    } else if (n == 1) {
        return @"content chromeless (NO ANIMATION)";
    } else if (n == 2) {
        return @"pop to root vc (ANIMATION)";
    } else if (n == 3) {
        return @"pop to root vc (NO ANIMATION)";
    } else if (n == 4) {
        return @"pop VC (ANIMATION)";
    } else if (n == 5) {
        return @"pop VC (NO ANIMATION)";
    } else if (n == 6) {
        return @"low mem testing: push on UINavigationController";
    } else if (n == 7) {
        return @"foo";
    } else if (n == 8) {
        return @"bar";
    } else if (n == 9) {
        return @"buz";
    } else {
        NSAssert(n >= 0, @"n negative");
        NSMutableString *s = [[NSMutableString alloc] initWithCapacity:(NSUInteger)n];
        [s appendString:@"q"];
        for (int i=7; i<n; i++) {
            [s appendString:@"u"];
        }
        [s appendString:@"x"];
        return s;
    }
}

- (NSInteger)numberOfSectionsInTableView:(__unused UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(__unused UITableView *)tableView numberOfRowsInSection:(__unused NSInteger)section
{
    return 106;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = [self cellText:indexPath.row];
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(__unused UITableView *)tableView didSelectRowAtIndexPath:(__unused NSIndexPath *)indexPath
{
    UIViewController *svc = nil;
    NSString *title = [NSString stringWithFormat:@"%@ : %@", self.title, [self cellText:indexPath.row]];

    if (indexPath.row == 0) {
        /* push a content view controller */
        svc = [[SampleContentViewController alloc] init];
        svc.title = title;
        [self.layeredNavigationController pushViewController:svc
                                                   inFrontOf:self
                                                maximumWidth:YES
                                                    animated:YES
                                               configuration:^(FRLayeredNavigationItem *item) {
                                                   UISegmentedControl *segControl = [[UISegmentedControl alloc]
                                                                                     initWithItems:@[@"foo", @"bar",
                                                                                                     @"buz"]];
                                                   segControl.segmentedControlStyle = UISegmentedControlStyleBar;
                                                   segControl.selectedSegmentIndex = 0;

                                                   [segControl addTarget:svc
                                                                  action:@selector(indexDidChangeForSegmentedControl:)
                                                        forControlEvents:UIControlEventValueChanged];

                                                   item.titleView = segControl;
                                               }];
    } else if (indexPath.row == 1) {
        /* push a content view controller */
        svc = [[SampleContentViewController alloc] init];
        svc.title = title;
        [self.layeredNavigationController pushViewController:svc
                                                   inFrontOf:self
                                                maximumWidth:YES
                                                    animated:NO
                                               configuration:^(FRLayeredNavigationItem *item) {
            item.hasChrome = NO;
        }];
    } else if (indexPath.row == 2) {
        [self.layeredNavigationController popToRootViewControllerAnimated:YES];
    } else if (indexPath.row == 3) {
        [self.layeredNavigationController popToRootViewControllerAnimated:NO];

    } else if (indexPath.row == 4) {
        [self.layeredNavigationController popViewControllerAnimated:YES];
    } else if (indexPath.row == 5) {
        [self.layeredNavigationController popViewControllerAnimated:NO];
    } else if (indexPath.row == 6) {
        UIViewController *vc = [[SampleListViewController alloc] init];
        FRLayeredNavigationController *fvc = [[FRLayeredNavigationController alloc] initWithRootViewController:vc];
        [self.navigationController pushViewController:fvc animated:YES];
    } else {
        /* list */
        svc = [[SampleListViewController alloc] init];
        svc.title = title;
        [self.layeredNavigationController pushViewController:svc inFrontOf:self maximumWidth:NO animated:YES configuration:^(FRLayeredNavigationItem *item) {
            /*
            item.width = (arc4random() % 200) + 200;
            if (indexPath.row == 6) {
                item.nextItemDistance = 2;
            } else {
                item.nextItemDistance = (arc4random() % 100) + 40;
            }
             */
            item.width = 200;
            item.nextItemDistance = 64;
            item.title = [NSString stringWithFormat:@"%@ (%f)", title, item.width];;
            return;
        }];
    }
}

@end
