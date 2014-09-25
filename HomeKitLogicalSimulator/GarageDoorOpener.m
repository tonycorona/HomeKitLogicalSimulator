//
//  GarageDoorOpener.m
//  HomeKitLogicalSimulator
//
//  Created by Khaos Tian on 8/21/14.
//  Copyright (c) 2014 Oltica. All rights reserved.
//

#import "GarageDoorOpener.h"
#import "OTIHAPCore.h"
#import "HAKGarageDoorOpenerService.h"
#import "HAKAccessory.h"
#import "HAKAccessoryInformationService.h"
#import "HAKCharacteristic.h"
#import "HAKNameCharacteristic.h"
#import "HAKSerialNumberCharacteristic.h"
#import "HAKManufacturerCharacteristic.h"
#import "HAKModelCharacteristic.h"
#import "HAKLockMechanismCurrentStateCharacteristic.h"
#import "HAKLockMechanismTargetStateCharacteristic.h"
#import "HAKObstructionDetectedCharacteristic.h"
#import "HAKTargetDoorStateCharacteristic.h"
#import "HAKCurrentDoorStateCharacteristic.h"

@interface GarageDoorOpener () {
    OTIHAPCore *_accessoryCore;
    
    HAKAccessory *_garageDoorAccessory;
    
    HAKLockMechanismCurrentStateCharacteristic  *_lockCurrentState;
    HAKLockMechanismTargetStateCharacteristic   *_lockTargetState;
    HAKObstructionDetectedCharacteristic        *_obstructionChar;
    HAKTargetDoorStateCharacteristic            *_targetDoorState;
    HAKCurrentDoorStateCharacteristic           *_currentDoorState;
    
    BOOL                                        _isDoorOpen;
    
    NSTimer                                     *_doorTimer;
}

@end

@implementation GarageDoorOpener

- (id)initWithSerialNumber:(NSString *)serialNumber Core:(OTIHAPCore *)core {
    self = [super init];
    if (self) {
        _accessoryCore = core;
        
        _garageDoorAccessory = [self createGarageDoorAccessoryWithSerialNumber:serialNumber];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(characteristicDidUpdateValueNotification:) name:@"HAKCharacteristicDidUpdateValueNotification" object:nil];
    }
    return self;
}

- (void)characteristicDidUpdateValueNotification:(NSNotification *)aNote {
    HAKCharacteristic *characteristic = aNote.object;
    if ([characteristic.service.accessory isEqual:_garageDoorAccessory]) {
        NSLog(@"GetUpdate:%@",characteristic);
        if (characteristic == _lockTargetState) {
            NSLog(@"Lock Target State Change:%i",_lockTargetState.targetState);
            if (_targetDoorState.targetDoorState == 0) {
                _lockCurrentState.currentState = 0;
            } else {
                _lockCurrentState.currentState = 1;
            }
        }
        if (characteristic == _targetDoorState) {
            NSLog(@"Target Door State Change:%i",_targetDoorState.targetDoorState);
            if (_targetDoorState.targetDoorState == 0 && !_isDoorOpen) {
                _currentDoorState.currentDoorState = 2;
                if (_doorTimer != nil) {
                    [_doorTimer invalidate];
                    _doorTimer = nil;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    _doorTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(updateCurrentDoorState) userInfo:nil repeats:NO];
                });
            } else {
                _currentDoorState.currentDoorState = 3;
                if (_doorTimer != nil) {
                    [_doorTimer invalidate];
                    _doorTimer = nil;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    _doorTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(updateCurrentDoorState) userInfo:nil repeats:NO];
                });
            }
        }
    }
}

- (void)updateCurrentDoorState {
    NSLog(@"Timer Triggerd");
    if (_targetDoorState.targetDoorState == 1) {
        NSLog(@"Door closed");
        _currentDoorState.currentDoorState = 1;
        _isDoorOpen = NO;
    } else {
        NSLog(@"Door opened");
        _currentDoorState.currentDoorState = 0;
        _isDoorOpen = YES;
    }
}

- (HAKAccessory *)accessory {
    return _garageDoorAccessory;
}

- (HAKAccessory *)createGarageDoorAccessoryWithSerialNumber:(NSString *)serialNumber {
    NSLog(@"Init Accessory With Serial Number:%@",serialNumber);
    HAKAccessory *garageDoor = [_accessoryCore getAccessoryWithSerialNumber:serialNumber];
    
    if (garageDoor != nil) {
        for (HAKService *service in garageDoor.services) {
            if ([service isKindOfClass:[HAKGarageDoorOpenerService class]]) {
                HAKGarageDoorOpenerService *gcs = (HAKGarageDoorOpenerService *)service;
                _lockCurrentState = gcs.lockMechanismCurrentStateCharacteristic;
                _lockTargetState = gcs.lockMechanismTargetStateCharacteristic;
                _obstructionChar = gcs.obstructionDetectedCharacteristic;
                _targetDoorState = gcs.targetDoorStateCharacteristic;
                _currentDoorState = gcs.currentDoorStateCharacteristic;
                if (_currentDoorState.currentDoorState == 0) {
                    _isDoorOpen = YES;
                } else {
                    _isDoorOpen = NO;
                }
            }
        }
    } else {
        garageDoor = [[HAKAccessory alloc]init];
        
        HAKAccessoryInformationService *infoService = [[HAKAccessoryInformationService alloc] init];
        infoService.nameCharacteristic.name = @"Garage Door";
        infoService.serialNumberCharacteristic.serialNumber = serialNumber.copy;
        infoService.manufacturerCharacteristic.manufacturer = @"Oltica";
        infoService.modelCharacteristic.model = @"Opener 1";
        
        garageDoor.accessoryInformationService = infoService;
        [garageDoor addService:infoService];
        [garageDoor addService:[self setupGarageDoorService]];
    }
    
    return garageDoor;
}

- (HAKGarageDoorOpenerService *)setupGarageDoorService {
    HAKGarageDoorOpenerService *service = [[HAKGarageDoorOpenerService alloc] init];
    
    service.lockMechanismCurrentStateCharacteristic = [[HAKLockMechanismCurrentStateCharacteristic alloc] init];
    service.lockMechanismCurrentStateCharacteristic.currentState = 0;
    _lockCurrentState = service.lockMechanismCurrentStateCharacteristic;
    
    service.lockMechanismTargetStateCharacteristic = [[HAKLockMechanismTargetStateCharacteristic alloc] init];
    service.lockMechanismTargetStateCharacteristic.targetState = 0;
    _lockTargetState = service.lockMechanismTargetStateCharacteristic;
    
    service.nameCharacteristic = [[HAKNameCharacteristic alloc] init];
    service.nameCharacteristic.name = @"Garage Door Opener 1";
    
    service.obstructionDetectedCharacteristic.obstructionDetected = NO;
    _obstructionChar = service.obstructionDetectedCharacteristic;
    
    service.targetDoorStateCharacteristic.targetDoorState = 0;
    _targetDoorState = service.targetDoorStateCharacteristic;
    
    service.currentDoorStateCharacteristic.currentDoorState = 0;
    _currentDoorState = service.currentDoorStateCharacteristic;
    if (_currentDoorState.currentDoorState == 0) {
        _isDoorOpen = YES;
    } else {
        _isDoorOpen = NO;
    }
    
    return service;
}

@end
