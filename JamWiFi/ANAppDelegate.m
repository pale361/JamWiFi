//
//  ANAppDelegate.m
//  JamWiFi
//
//  Created by Alex Nichol on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANAppDelegate.h"
#import "ANListView.h"

@implementation ANAppDelegate

@synthesize window = _window;
@synthesize locationManager = _locationManager;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        [_locationManager startUpdatingLocation];
    } else {
        [self showLocationDisabledAlert];
    }
    
    // Insert code here to initialize your application
    networkList = [[ANListView alloc] initWithFrame:[self.window.contentView bounds]];
    [self pushView:networkList direction:ANViewSlideDirectionForward];
    [[CarbonAppProcess currentProcess] makeFrontmost];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (void)pushView:(NSView *)view direction:(ANViewSlideDirection)direction {
    if (animating) return;
    __weak id weakSelf = self;
    NSRect oldDestFrame = activeView.bounds;
    if (direction == ANViewSlideDirectionForward) {
        oldDestFrame.origin.x = -oldDestFrame.size.width;
    } else {
        oldDestFrame.origin.x = oldDestFrame.size.width;
    }
    
    NSRect newSourceFrame = [self.window.contentView bounds];
    NSRect newDestFrame = [self.window.contentView bounds];
    
    if (direction == ANViewSlideDirectionForward) {
        newSourceFrame.origin.x = newSourceFrame.size.width;
    } else {
        newSourceFrame.origin.x = -newSourceFrame.size.width;
    }
    
    animating = YES;
    
    [view setFrame:newSourceFrame];
    [self.window.contentView addSubview:view];
    nextView = view;
    
    [[NSAnimationContext currentContext] setDuration:0.3];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [weakSelf animationComplete];
    }];
    [NSAnimationContext beginGrouping];
    [[activeView animator] setFrame:oldDestFrame];
    [[view animator] setFrame:newDestFrame];
    [NSAnimationContext endGrouping];
}

- (void)animationComplete {
    [activeView removeFromSuperview];
    animating = NO;
    activeView = nextView;
    nextView = nil;
}

- (void)showNetworkList {
    [self pushView:networkList direction:ANViewSlideDirectionBackward];
}

- (void)showLocationDisabledAlert {
    NSRunAlertPanel(@"Location Services are not enabled", @"Location services are required to scan for BSSID", @"OK", nil, nil);
}

- (void)showLocationDeniedAlert {
    NSRunAlertPanel(@"Location permission required", @"Allow location access to scan for BSSID", @"OK", nil, nil);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"Location status updated to: %d", status);
    if (status == kCLAuthorizationStatusDenied) {
        [self showLocationDeniedAlert];
    }
}

@end
