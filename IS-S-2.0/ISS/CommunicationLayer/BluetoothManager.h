//
//  BluetoothManager.h
//  BluetoothTest
//
//  Created by Anshuman Dahale on 5/26/16.
//  Copyright © 2016 Silicus. All rights reserved.
//

#import <Foundation/Foundation.h>
@import QuartzCore;
@import CoreBluetooth;

#import "Enums.h"

// Protocol
@protocol ReadResponseDelegate <NSObject>

- (void) readValueKeyHex:(NSString *)keyHex forState:(Key_State)keyState;

@end

// Blocks
typedef void(^SuccessBlock) (NSError *error, BOOL success);
typedef void(^ConnectionBlock) (NSError *error, NSString *peripheralName);

// Interface
@interface BluetoothManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

// Properties
//@property (nonatomic, strong) id<ReadResponseDelegate>readDelegate;


@property (nonatomic, strong) id<ReadResponseDelegate>homeReadDelegate;
@property (nonatomic, strong) id<ReadResponseDelegate>keyBoardReadDelegate;
@property (nonatomic, strong) id<ReadResponseDelegate>radioReadDelegate;
@property (nonatomic, strong) id<ReadResponseDelegate>tspReadDelegate;
@property (nonatomic, strong) id<ReadResponseDelegate>fltPlanReadDelegate;



@property (nonatomic) BOOL isConnected;

// Shared Instance
+ (BluetoothManager *) sharedInstance;


// Methods
- (void) connectWithResponseBlock:(ConnectionBlock)connectionResponseBlock;
- (void) disconnect;
- (void) writeToPeripheralValue:(NSString *)hexValue forState:(Key_State)state withSuccessBlock:(SuccessBlock)writeSuccessBlock;
- (void) writeTrackPadCoordinates:(CGPoint)point withSuccessBlock:(SuccessBlock)successBlock;

- (void) writeRadioFrequency:(NSArray *)frequencyArray forFrequencyType:(Frequency_Type)freqType;
- (void) writeFltPlnInput:(NSArray *)input withSuccessBlock:(SuccessBlock)successBlock;

@end
