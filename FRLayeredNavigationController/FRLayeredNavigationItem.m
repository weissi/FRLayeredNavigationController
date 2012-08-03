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

#import "FRLayeredNavigationItem+Protected.h"
#import "FRLayerController+Protected.h"
#import "FRLayerController.h"
#import "FRLayerChromeView.h"

@interface FRLayeredNavigationItem ()

@property (nonatomic, readwrite, weak) FRLayerController *layerController;
@property (nonatomic, readwrite) CGPoint initialViewPosition;
@property (nonatomic, readwrite) CGPoint currentViewPosition;

@end

@implementation FRLayeredNavigationItem

- (id)init
{
    if ((self = [super init])) {
        self->_width = -1;
        self->_nextItemDistance = -1;
        self->_hasChrome = YES;
        self->_displayShadow = YES;
    }

    return self;
}

- (void)setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem
{
    self.layerController.chromeView.leftBarButtonItem = leftBarButtonItem;
}

- (UIBarButtonItem *)leftBarButtonItem
{
    return self.layerController.chromeView.leftBarButtonItem;
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem
{
    self.layerController.chromeView.rightBarButtonItem = rightBarButtonItem;
}

- (UIBarButtonItem *)rightBarButtonItem
{
    return self.layerController.chromeView.rightBarButtonItem;
}


@synthesize initialViewPosition = _initialViewPosition;
@synthesize currentViewPosition = _currentViewPosition;
@synthesize title = _title;
@synthesize titleView = _titleView;
@synthesize width = _width;
@synthesize nextItemDistance = _nextItemDistance;
@synthesize hasChrome = _hasChrome;
@synthesize displayShadow = _displayShadow;
@synthesize layerController = _layerController;

@end
