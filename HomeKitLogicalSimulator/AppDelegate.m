//
//  AppDelegate.m
//  HomeKitLogicalSimulator
//
//  Created by Khaos Tian on 8/21/14.
//  Copyright (c) 2014 Oltica. All rights reserved.
//

#import "AppDelegate.h"
#import "OTIHAPCore.h"
#import "GarageDoorOpener.h"
#import "Thermostat.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) OTIHAPCore *accessoryCore;
@property (strong, nonatomic) GarageDoorOpener *doorOpener;
@property (strong, nonatomic) Thermostat *thermostat;

@end

@implementation AppDelegate
            
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _accessoryCore = [[OTIHAPCore alloc]initAsBridge:YES];
    
    _doorOpener = [[GarageDoorOpener alloc] initWithSerialNumber:@"B0107469FA37" Core:_accessoryCore];
    NSLog(@"Opener:%@",_doorOpener);
    
    [_accessoryCore addAccessory:[_doorOpener accessory]];
    
    _thermostat = [[Thermostat alloc] initWithSerialNumber:@"E1E46A9C0345" Core:_accessoryCore];
    NSLog(@"Thermostat:%@",_thermostat);
    
    [_accessoryCore addAccessory:[_thermostat accessory]];

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
