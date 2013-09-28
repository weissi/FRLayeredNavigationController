//
//  FRiOSVersion.m
//  FRLayeredNavigationController
//
//  Created by Johannes Weiß on 28/09/2013.
//
//

#import <UIKit/UIKit.h>
#import "FRiOSVersion.h"

@implementation FRiOSVersion

+ (BOOL)isIOS7OrNewer
{
    NSArray *vComp = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];

    return [[vComp objectAtIndex:0] intValue] >= 7;
}

@end
