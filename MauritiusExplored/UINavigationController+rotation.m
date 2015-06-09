//
//  UINavigationController+rotation.m
//  MauritiusExplored
//
//  Created by Niranjan Ravichandran on 09/06/15.
//  Copyright (c) 2015 Adavers. All rights reserved.
//

#import "UINavigationController+rotation.h"

@implementation UINavigationController (rotation)

- (BOOL) shouldAutorotate
{
    return [[self topViewController] shouldAutorotate];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return [[self topViewController] supportedInterfaceOrientations];
}

@end
