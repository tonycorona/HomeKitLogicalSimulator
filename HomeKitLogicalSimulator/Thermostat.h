//
//  Thermostat.h
//  HomeKitLogicalSimulator
//
//  Created by Khaos Tian on 8/21/14.
//  Copyright (c) 2014 Oltica. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OTIHAPCore, HAKAccessory;

@interface Thermostat : NSObject

- (id)initWithSerialNumber:(NSString *)serialNumber Core:(OTIHAPCore *)core;
- (HAKAccessory *)accessory;

@end
