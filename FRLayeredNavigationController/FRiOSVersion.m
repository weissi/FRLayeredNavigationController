//
//  FRiOSVersion.m
//  FRLayeredNavigationController
//
//  Created by Johannes Weiß on 28/09/2013.
//
//

/* Standard Library */
#import <UIKit/UIKit.h>

/* Local Imports */
#import "FRiOSVersion.h"

@implementation FRiOSVersion

+ (BOOL)isIOS7OrNewer
{
    NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];

    return [[vComp objectAtIndex:0] intValue] >= 7;
}

@end
