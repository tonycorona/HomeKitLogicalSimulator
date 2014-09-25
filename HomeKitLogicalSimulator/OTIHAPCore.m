//
//  OTIHAPCore.m
//  HomeKitBridge
//
//  Created by Khaos Tian on 7/18/14.
//  Copyright (c) 2014 Oltica. All rights reserved.
//

#import "OTIHAPCore.h"

#import "HAKTransportManager.h"
#import "HAKIPTransport.h"
#import "HAKAccessory.h"

#import "HAKNameCharacteristic.h"
#import "HAKModelCharacteristic.h"
#import "HAKManufacturerCharacteristic.h"
#import "HAKSerialNumberCharacteristic.h"
#import "HAKBrightnessCharacteristic.h"
#import "HAKHueCharacteristic.h"
#import "HAKSaturationCharacteristic.h"
#import "HAKOnCharacteristic.h"

#import "HAKLightBulbService.h"


@interface OTIHAPCore (){
    BOOL        _isBridge;
}

@property (strong,nonatomic) HAKTransportManager        *transportManager;
@property (strong,nonatomic) HAKIPTransport             *bridgeTransport;
@property (strong,nonatomic) NSMutableDictionary        *accessories;

@end

@implementation OTIHAPCore

- (id)init {
    self = [super init];
    
    if (self) {
        _accessories = [NSMutableDictionary dictionary];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:[[self homeDataPath] path]])
        {
            _transportManager = [[HAKTransportManager alloc]initWithURL:[self homeDataPath]];
            for (HAKIPTransport *transport in _transportManager.transports) {
                _bridgeTransport = transport;
                if (_bridgeTransport) {
                    NSLog(@"Find Transport");
                    for (HAKAccessory *accessory in _bridgeTransport.accessories) {
                        [_accessories setObject:accessory forKey:accessory.serialNumber];
                    }
                }
            }
            NSLog(@"Restore:%@",_transportManager);
            NSLog(@"Password:%@",_bridgeTransport.password);
        }else{
            [self setupHAP];
        }
    }
    
    return self;
}

- (NSURL *)homeDataPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportDir = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    appSupportDir = [appSupportDir URLByAppendingPathComponent:@"org.oltica.HomeKitLogicalSimulator"];
    
    if ([fileManager fileExistsAtPath:[appSupportDir path]] == NO)
    {
        [fileManager createDirectoryAtPath:[appSupportDir path] withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return [appSupportDir URLByAppendingPathComponent:@"HomeData.plist"];
}

- (id)initAsBridge:(BOOL)isBridge {
    self = [self init];
    
    if (isBridge) {
        _isBridge = true;
        [self setupBridgeAccessory];
    }
    
    return self;
}

- (void)setupHAP {
    _transportManager = [HAKTransportManager transportManager];
    
    _bridgeTransport = [[HAKIPTransport alloc] init];
    _bridgeTransport.name = @"Central Bridge";
    
    [_transportManager addTransport:_bridgeTransport];
    
    [_transportManager startAllTransports];
    
    NSLog(@"Finished. Password:%@", _bridgeTransport.password);
    
    [_transportManager writeToURL:[self homeDataPath] atomically:YES];
}

- (void)setupBridgeAccessory {
    HAKAccessory *bridgeAccessory = [[HAKAccessory alloc] init];
    HAKAccessoryInformationService *infoService = [[HAKAccessoryInformationService alloc] init];
    infoService.nameCharacteristic.name = @"Central Bridge";
    infoService.serialNumberCharacteristic.serialNumber = @"9C23552110C7";
    infoService.manufacturerCharacteristic.manufacturer = @"Oltica";
    infoService.modelCharacteristic.model = @"Central Bridge Rev. 1";
    
    bridgeAccessory.accessoryInformationService = infoService;
    [bridgeAccessory addService:infoService];
    
    [self addAccessory:bridgeAccessory];
}

- (HAKAccessory *)addAccessory:(HAKAccessory *)accessory {
    NSLog(@"Add accessory:%@",accessory);
    if (!accessory) {
        return nil;
    }
    
    if (_accessories[accessory.serialNumber] != nil) {
        return _accessories[accessory.serialNumber];
    }
    
    _accessories[accessory.serialNumber] = accessory;
    
    [_bridgeTransport addAccessory:accessory];
    
    [_transportManager writeToURL:[self homeDataPath] atomically:YES];
    
    return accessory;
}

- (HAKAccessory *)getAccessoryWithSerialNumber:(NSString *)serialNumber {
    if (_accessories[serialNumber] != nil) {
        return _accessories[serialNumber];
    }
    return nil;
}

- (NSString *)password {
    return _bridgeTransport.password;
}

@end
