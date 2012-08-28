/*
 * This file is part of FRLayeredNavigationController.
 *
 * Copyright (c) 2012, Apurva Mehta <apurva.1618@gmail.com>
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



#import <UIKit/UIKit.h>

/**
 * It’s a bar, typically displayed at the top of the screen, containing the view
 * controller's title and optionally some buttons or other views.
 */
@interface FRNavigationBar : NSObject<UIAppearance>

/**
 * Returns an object which can be used to set global styles for the FRNavigationBar.
 */
+(FRNavigationBar *) appearance;


/**
 * Returns an object which can be used set the style of an FRNavigationBar when embedded within other appearance
 * containers.
 *
 * @param ContainerClass A nil-terminated list of appearance container classes.
 * @param ... A nil-terminated list of appearance container classes.
 */
+(FRNavigationBar *) appearanceWhenContainedIn: (Class <UIAppearanceContainer>)ContainerClass,...;

/**
 * The default background image of all FRNavigationBars in the application. If none is specified,
 * the default gray gradient of the iPad is used.
 */
@property (nonatomic, strong) UIImage *backgroundImage;


/**
 * The default text attributes for FRNavigationBar titles.
 * Defaults to the etched dark gray look that is default on iPad navigation bars.
 */
@property (nonatomic, copy) NSDictionary *titleTextAttributes;


@end
