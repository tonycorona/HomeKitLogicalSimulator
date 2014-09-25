//
//  Thermostat.m
//  HomeKitLogicalSimulator
//
//  Created by Khaos Tian on 8/21/14.
//  Copyright (c) 2014 Oltica. All rights reserved.
//

#import "Thermostat.h"
#import "OTIHAPCore.h"
#import "HAKAccessory.h"
#import "HAKAccessoryInformationService.h"
#import "HAKCharacteristic.h"
#import "HAKNameCharacteristic.h"
#import "HAKSerialNumberCharacteristic.h"
#import "HAKManufacturerCharacteristic.h"
#import "HAKModelCharacteristic.h"
#import "HAKThermostatService.h"
#import "HAKCoolingThresholdTemperatureCharacteristic.h"
#import "HAKHeatingThresholdTemperatureCharacteristic.h"
#import "HAKTargetRelativeHumidityCharacteristic.h"
#import "HAKCurrentRelativeHumidityCharacteristic.h"
#import "HAKTemperatureUnitsCharacteristic.h"
#import "HAKTargetTemperatureCharacteristic.h"
#import "HAKCurrentTemperatureCharacteristic.h"
#import "HAKTargetHeatingCoolingModeCharacteristic.h"
#import "HAKCurrentHeatingCoolingModeCharacteristic.h"

@interface Thermostat () {
    OTIHAPCore *_accessoryCore;
    
    HAKAccessory *_thermostatAccessory;
    
    HAKCoolingThresholdTemperatureCharacteristic *_coolingThresholdTemperatureCharacteristic;
    HAKHeatingThresholdTemperatureCharacteristic *_heatingThresholdTemperatureCharacteristic;
    HAKTargetRelativeHumidityCharacteristic      *_targetRelativeHumidityCharacteristic;
    HAKCurrentRelativeHumidityCharacteristic     *_currentRelativeHumidityCharacteristic;
    HAKTemperatureUnitsCharacteristic            *_temperatureUnitsCharacteristic;
    HAKTargetTemperatureCharacteristic           *_targetTemperatureCharacteristic;
    HAKCurrentTemperatureCharacteristic          *_currentTemperatureCharacteristic;
    HAKTargetHeatingCoolingModeCharacteristic    *_targetHeatingCoolingModeCharacteristic;
    HAKCurrentHeatingCoolingModeCharacteristic   *_currentHeatingCoolingModeCharacteristic;
}

@end

@implementation Thermostat

- (id)initWithSerialNumber:(NSString *)serialNumber Core:(OTIHAPCore *)core {
    self = [super init];
    if (self) {
        _accessoryCore = core;
        
        _thermostatAccessory = [self createThermostatAccessoryWithSerialNumber:serialNumber];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(characteristicDidUpdateValueNotification:) name:@"HAKCharacteristicDidUpdateValueNotification" object:nil];
    }
    return self;
}

- (void)characteristicDidUpdateValueNotification:(NSNotification *)aNote {
    HAKCharacteristic *characteristic = aNote.object;
    if ([characteristic.service.accessory isEqual:_thermostatAccessory]) {
        if (characteristic == _targetHeatingCoolingModeCharacteristic) {
            NSLog(@"Heating Cooling mode change:%i",_targetHeatingCoolingModeCharacteristic.targetHeatingCoolingMode);
            switch (_targetHeatingCoolingModeCharacteristic.targetHeatingCoolingMode) {
                case 0:
                    _currentHeatingCoolingModeCharacteristic.currentHeatingCoolingMode = 0;
                    break;
                    
                case 1:
                    _currentHeatingCoolingModeCharacteristic.currentHeatingCoolingMode = 1;
                    break;
                    
                case 2:
                    _currentHeatingCoolingModeCharacteristic.currentHeatingCoolingMode = 2;
                    break;
                    
                case 3:
                    _currentHeatingCoolingModeCharacteristic.currentHeatingCoolingMode = 2;
                    
                default:
                    break;
            }
        }
    }
}

- (HAKAccessory *)createThermostatAccessoryWithSerialNumber:(NSString *)serialNumber {
    NSLog(@"Init Accessory With Serial Number:%@",serialNumber);
    HAKAccessory *thermostat = [_accessoryCore getAccessoryWithSerialNumber:serialNumber];
    
    if (thermostat != nil) {
        for (HAKService *service in thermostat.services) {
            if ([service isKindOfClass:[HAKThermostatService class]]) {
                HAKThermostatService *ts = (HAKThermostatService *)service;
                _coolingThresholdTemperatureCharacteristic = ts.coolingThresholdTemperatureCharacteristic;
                _heatingThresholdTemperatureCharacteristic = ts.heatingThresholdTemperatureCharacteristic;
                _targetRelativeHumidityCharacteristic = ts.targetRelativeHumidityCharacteristic;
                _currentRelativeHumidityCharacteristic = ts.currentRelativeHumidityCharacteristic;
                _temperatureUnitsCharacteristic = ts.temperatureUnitsCharacteristic;
                _targetTemperatureCharacteristic = ts.targetTemperatureCharacteristic;
                _currentTemperatureCharacteristic = ts.currentTemperatureCharacteristic;
                _targetHeatingCoolingModeCharacteristic = ts.targetHeatingCoolingModeCharacteristic;
                _currentHeatingCoolingModeCharacteristic = ts.currentHeatingCoolingModeCharacteristic;
            }
        }
    } else {
        thermostat = [[HAKAccessory alloc]init];
        
        HAKAccessoryInformationService *infoService = [[HAKAccessoryInformationService alloc] init];
        infoService.nameCharacteristic.name = @"Thermostat";
        infoService.serialNumberCharacteristic.serialNumber = serialNumber.copy;
        infoService.manufacturerCharacteristic.manufacturer = @"Oltica";
        infoService.modelCharacteristic.model = @"Thermostat 1";
        
        thermostat.accessoryInformationService = infoService;
        [thermostat addService:infoService];
        [thermostat addService:[self setupThermostatService]];
    }
    
    return thermostat;
}

- (HAKThermostatService *)setupThermostatService {
    HAKThermostatService *service = [[HAKThermostatService alloc] init];
    
    service.coolingThresholdTemperatureCharacteristic = [[HAKCoolingThresholdTemperatureCharacteristic alloc] init];
    _coolingThresholdTemperatureCharacteristic = service.coolingThresholdTemperatureCharacteristic;
    
    service.heatingThresholdTemperatureCharacteristic = [[HAKHeatingThresholdTemperatureCharacteristic alloc] init];
    _heatingThresholdTemperatureCharacteristic = service.heatingThresholdTemperatureCharacteristic;
    
    service.nameCharacteristic = [[HAKNameCharacteristic alloc] init];
    service.nameCharacteristic.name = @"Thermostat Service";
    
    service.targetRelativeHumidityCharacteristic = [[HAKTargetRelativeHumidityCharacteristic alloc] init];
    _targetRelativeHumidityCharacteristic = service.targetRelativeHumidityCharacteristic;
    
    service.currentRelativeHumidityCharacteristic = [[HAKCurrentRelativeHumidityCharacteristic alloc] init];
    _currentRelativeHumidityCharacteristic = service.currentRelativeHumidityCharacteristic;
    
    _temperatureUnitsCharacteristic = service.temperatureUnitsCharacteristic;
    _targetTemperatureCharacteristic = service.targetTemperatureCharacteristic;
    _currentTemperatureCharacteristic = service.currentTemperatureCharacteristic;
    _targetHeatingCoolingModeCharacteristic = service.targetHeatingCoolingModeCharacteristic;
    _currentHeatingCoolingModeCharacteristic = service.currentHeatingCoolingModeCharacteristic;
    
    
    return service;
}

- (HAKAccessory *)accessory {
    return _thermostatAccessory;
}

@end
