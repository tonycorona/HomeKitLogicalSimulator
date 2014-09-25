//
//  OTIHAPCore.h
//  HomeKitBridge
//
//  Created by Khaos Tian on 7/18/14.
//  Copyright (c) 2014 Oltica. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HAKAccessory;

@interface OTIHAPCore : NSObject

- (id)initAsBridge:(BOOL)isBridge;
- (HAKAccessory *)addAccessory:(HAKAccessory *)accessory;
- (HAKAccessory *)getAccessoryWithSerialNumber:(NSString *)serialNumber;
- (NSString *)password;

@end
