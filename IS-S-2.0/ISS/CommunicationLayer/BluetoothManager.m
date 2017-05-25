//
//  BluetoothManager.m
//  BluetoothTest
//
//  Created by Anshuman Dahale on 5/26/16.
//  Copyright © 2016 Silicus. All rights reserved.
//

#import "BluetoothManager.h"
#import "Constants.h"
#import "Enums.h"
#import "NSString+Conversion.h"
#import "NSData+AES.h"
#import "Crypt.h"
#import "KeyHexConverter.h"
#import "SlipEnocding.h"
#import "ApplicationManager.h"
#import <CommonCrypto/CommonCrypto.h>


#define MAX_MSG_POINTER         5
#define BLE_KEY_HEADER          0xFD


@interface BluetoothManager ()

@property (nonatomic, strong) CBCentralManager  *centralManager;
@property (nonatomic, strong) CBPeripheral      *adaFruitPeripheral;
@property (nonatomic, strong) CBCharacteristic  *txCharacteristic;
@property (nonatomic, strong) CBCharacteristic  *rxCharacteristic;

@property (nonatomic, strong) ConnectionBlock   connectionBlock;
@property (nonatomic, strong) SuccessBlock      writeSuccessBlock;

@property (nonatomic, strong) NSMutableData     *messageData;

@property (nonatomic, strong) KeyHexConverter   *keyHexConverter;
@property (nonatomic, strong) SlipEnocding      *slipEncoding;

@end


@implementation BluetoothManager


+ (BluetoothManager *) sharedInstance {
    
    static BluetoothManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[BluetoothManager alloc] init];
        sharedInstance.centralManager = [[CBCentralManager alloc] initWithDelegate:sharedInstance queue:nil];
        sharedInstance.keyHexConverter = [[KeyHexConverter alloc] init];
        sharedInstance.slipEncoding  = [[SlipEnocding alloc] init];
    });
    
    return sharedInstance;
}


//- (id) init {
//    
//    self = [super init];
//    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
//    return self;
//}

- (void) connectWithResponseBlock:(ConnectionBlock)responseBlock {

    _connectionBlock = responseBlock;
    [self startScan];
}

- (void) disconnect {
    
}

- (void) startScan {

    // Scan for all available CoreBluetooth LE devices
    NSArray *services = @[
        [CBUUID UUIDWithString:UUID_UART_SERVICES]
    ];
    [self.centralManager scanForPeripheralsWithServices:services options:nil];
}



unsigned char fifo[5];
int fifoPointer;
//BOOL headerFound;


- (void) processPacket:(NSData *)packet {
    
    NSData *data = [self getAES128DecryptedForData:packet];  // Recieved message
    NSUInteger dataLength = [data length];         // Length of the message
    
    unsigned char *dataArray = (unsigned char *)[data bytes];
    
    unsigned char checksum;
    int startNdx;
    int keycodeNdx;
    int stateNdx;
    
    for(int i=0; i<dataLength; i++) {
        
        fifo[fifoPointer] = dataArray[i];
        fifoPointer = (fifoPointer+1) % MAX_MSG_POINTER;
        checksum = 0;
        
        for (int j = 0; j < MAX_MSG_POINTER; j++) {
            checksum += fifo[j];
        }
        NSLog(@"CheckSum in recieved message: %d", checksum);
        if (0 == checksum) // possible message found
        {
            // the next byte should be start of message
            
            startNdx    = fifoPointer;
            keycodeNdx  = fifoPointer + 1;
            stateNdx    = fifoPointer + 2;
            
            if (BLE_KEY_HEADER == fifo[startNdx]) {
                // we found a message, if AND only if the keycode is valid
                //
                // Value at 1st location is the Key
                
                NSString *actualKey = [[NSString stringWithFormat:@"%2x", fifo[keycodeNdx]] uppercaseString];
                NSString *keyHex = [NSString stringWithFormat:@"0x%@", actualKey];
                
                keyHex = [keyHex stringByReplacingOccurrencesOfString:@" " withString:@"0"];
                
                // Value at the 2nd location is state of the key
                
                NSUInteger keyState = [[NSNumber numberWithUnsignedChar:fifo[stateNdx]] integerValue];
                
                NSLog(@"Found Key is: %@ with state: %lu", keyHex, (unsigned long)keyState);
                //Pass this value to the object listening to this delegate
                
                if(keyHex) {
                    
                    Key_Category category = [_keyHexConverter getCategoryForHexValue:keyHex];
                    
                    if(category >= 0) {
                        
                        switch (category) {
                                
                            case Key_Category_Alphabet:
                            case Key_Category_KeyBoard_Functional:
                            case Key_Category_Numeric:
                                if ([_keyBoardReadDelegate respondsToSelector:@selector(readValueKeyHex:forState:)]) {
                                    [_keyBoardReadDelegate readValueKeyHex:keyHex forState:keyState];
                                }
                                break;
                                
                            case Key_Category_Cockpit_Special:
                                if ([_homeReadDelegate respondsToSelector:@selector(readValueKeyHex:forState:)]) {
                                    [_homeReadDelegate readValueKeyHex:keyHex forState:keyState];
                                }
                                break;
                                
                            case Key_Category_Cockpit_Functional:
                                if ([_tspReadDelegate respondsToSelector:@selector(readValueKeyHex:forState:)]) {
                                    [_tspReadDelegate readValueKeyHex:keyHex forState:keyState];
                                }
                                break;
                                
                            default:
                                break;
                        }
                    }
                }
            }
        }
    }
}



- (void) processRead:(CBCharacteristic *)characteristic {
    
    NSData *recievedData = [characteristic value];
    
    if((recievedData != nil) && recievedData.length > 0) {
        
        NSLog(@"Recieved Data: %@", recievedData);
        unsigned char *dataArray = (unsigned char *)[recievedData bytes];
        
        //Perfect packet recieved
        if((dataArray[0] == 0xC0) && (dataArray[[recievedData length]-1] == 0xC0)) {
            NSLog(@"Its a perfect packet");
            _messageData = nil;
            [self processPacket:recievedData];
        }
        //A new packet is recieved. Discard the previous data and start over again
        else if(dataArray[0] == 0xC0) {
            NSLog(@"Its a new packet, discard the old data in message");
            _messageData = nil;
            _messageData = [[NSMutableData alloc] initWithData:recievedData];
        }
        //SLIP_END encountered, this is the end of the packet
        else if (dataArray[[recievedData length]-1] == 0xC0) {
            if(_messageData != nil) {
                NSLog(@"Its the end of a packet. FW it to process");
                [_messageData appendData:recievedData];
                NSData *deepCopy = [[NSData alloc] initWithBytes:[_messageData bytes] length:_messageData.length];
                _messageData = nil;
                [self processPacket:deepCopy];
            }
        }
        else if(_messageData != nil) {
            NSLog(@"Its a middle packet, just append it");
            [_messageData appendData:recievedData];
        }
        
    }
    
}


#pragma mark - AES Encryption

- (NSData *) getAES128EncryptedForData:(NSData *)data {
    
    NSData *keyHex  = [Crypt dataFromHexString:[ApplicationManager sharedInstance].aesKey];
    NSData *ivHex   = [Crypt dataFromHexString:[ApplicationManager sharedInstance].ivKey];
    NSError *error = nil;
    NSData *encryptedData = [Crypt aes128Data:data operation:kCCEncrypt key:keyHex options:kCCOptionPKCS7Padding iv:ivHex error:&error];

//    NSString *key = [NSString stringWithFormat:@"%@", [ApplicationManager sharedInstance].aesKey];
//    NSData *encrypteData = [data AES128EncryptedDataWithKey:key iv:kAESIvKey];
    
    NSData *slipEncodedData = [_slipEncoding SLIPEncodeData:encryptedData];
    NSLog(@"Data to write (RAW) : %@", data);
    NSLog(@"Data to write (AES) : %@", encryptedData);
    NSLog(@"Data to write (SLIP): %@", slipEncodedData);
    NSLog(@"Data Length: %lu",(unsigned long)slipEncodedData.length);
    return slipEncodedData;
}


- (NSData *) getAES128DecryptedForData:(NSData *)encryptedData {
    
    NSData *slipDecryptedData = [_slipEncoding SLIPDecodeData:encryptedData];
    NSData *keyHex  = [Crypt dataFromHexString:[ApplicationManager sharedInstance].aesKey];
    NSData *ivHex   = [Crypt dataFromHexString:[ApplicationManager sharedInstance].ivKey];
    NSError *error;
    NSData *aesDecrypted = [Crypt aes128Data:slipDecryptedData operation:kCCDecrypt key:keyHex options:kCCOptionPKCS7Padding iv:ivHex error:&error];
    NSLog(@"Data to process (AES): %@", encryptedData);
    NSLog(@"Data to process (RAW): %@", aesDecrypted);
    return aesDecrypted;
}

#pragma mark - Radio Write

- (void) writeRadioFrequency:(NSArray *)frequencyArray forFrequencyType:(Frequency_Type)freqType {
    
    //Frequency Type
    //COM1 = 1
    //COM2 = 2
    //NAV1 = 3
    //NAV2 = 4
    //ADF  = 5
    
    //TSP dont have freq type
    
    NSInteger packetLength = (freqType == Frequency_Type_ADF) ? frequencyArray.count+3 : frequencyArray.count+4;
    
    unsigned char message [packetLength];
    
    message[0] = 0xFD;      //Marks the begining of a packet
    message[1] = (freqType == Frequency_Type_ADF) ? 0x0C : 0x80;      //Constant for Radio Frequency
    
    NSInteger startFromIndex = 2;
    if(freqType != Frequency_Type_ADF) {
        message[2] = freqType;  //FrequencyType
        startFromIndex = 3;
    }
    
    for(NSInteger charId=0, pointer = startFromIndex; charId<frequencyArray.count; charId++, pointer++) {
        
        NSString *string = [frequencyArray objectAtIndex:charId];
        message[pointer] = [string hexToInteger];
    }
    
    //Calculation checksum
    unsigned char sum = message[0];
    for(int i = 1; i < packetLength-1; i++) {
        sum = sum + message[i];
    }
    sum = (~sum) + 1;
    
    //set the checksum as last bit in the array
    message[packetLength-1] = sum;
    
    NSData *data = [NSData dataWithBytes:(const void*)message length:packetLength];
    
    [self.adaFruitPeripheral    writeValue:[self getAES128EncryptedForData:data]
                                forCharacteristic:_txCharacteristic
                                type:CBCharacteristicWriteWithResponse];
}


- (void) writeFltPlnInput:(NSArray *)input withSuccessBlock:(SuccessBlock)successBlock {
    
    _writeSuccessBlock = successBlock;
    
    NSInteger packetLength = input.count + 5;
    unsigned char message [packetLength];
    message[0] = 0xFD;      //Marks the begining of a packet
    message[1] = 0x82;
    
    int msb = 0, lsb = -1;
    
    for(NSInteger charId=0, pointer = 5; charId<input.count; charId++, pointer++) {
        
//        NSString *string = [input objectAtIndex:charId];
//        message[pointer] = [string hexToInteger];
        NSString *string = [input objectAtIndex:charId];
        message[pointer] = (unsigned char)[string UTF8String];
        printf("\nMessage Pointer: %d", message[pointer]);
        
        if(message[pointer] > msb) {
            msb = message[pointer];
        }
        
        if(lsb == -1) {
            lsb = message[pointer];
        }
        
        else if(message[pointer] < lsb) {
            lsb = message[pointer];
        }
    }
    
    NSLog(@"MSB: %d", msb);
    NSLog(@"LSB: %d", lsb);
    message[3] = msb;
    message[4] = lsb;
    
    //Calculation checksum
    unsigned char sum = message[0];
    for(int i = 1; i < packetLength-1; i++) {
        sum = sum + message[i];
    }
    sum = (~sum) + 1;
    
    //set the checksum as last bit in the array
    message[packetLength-1] = sum;
    
    NSData *data = [NSData dataWithBytes:(const void*)message length:packetLength];
    
    [self.adaFruitPeripheral    writeValue:[self getAES128EncryptedForData:data]
                                forCharacteristic:_txCharacteristic
                                type:CBCharacteristicWriteWithResponse];
}


#pragma mark - KeyBoard Write

- (void) writeTrackPadCoordinates:(CGPoint)point withSuccessBlock:(SuccessBlock)successBlock {

//    NSString *keyCode = @"KEY_CCD";
    
    static unsigned char message[5];
    
    message[0] = 0xFD;
    message[1] = 0x5F;//[keyCode hexToInteger];
    message[2] = point.x;
    message[3] = point.y;
    message[4] = ~( message[0] + message[1] + message[2] + message[3]) + 1;
    
    NSInteger messageSize = sizeof(message);
    NSData *data = [NSData dataWithBytes:(const void*) message length:messageSize];
    
    [self.adaFruitPeripheral writeValue:[self getAES128EncryptedForData:data]
                            forCharacteristic:_txCharacteristic
                            type:CBCharacteristicWriteWithResponse];
}


- (void) writeToPeripheralValue:(NSString *)hexValue forState:(Key_State)state withSuccessBlock:(SuccessBlock)writeSuccessBlock {
    
    static unsigned char message[5];
    
    message[0] = 0xFD;
    message[1] = [hexValue hexToInteger]; //(unsigned int)[hexValue UTF8String];
    message[2] = 1;//state; // for CCD keycode, zero otherwise, one for the highlight color (green) on the keyboard
    message[3] = 0; // for CCD keycode, zero otherwise
    message[4] = ~ (message[0] + message[1] + message[2] + message[3]) + 1;
    
    NSInteger messageSize = sizeof(message);
    NSData *data = [NSData dataWithBytes:(const void*) message length:messageSize];
    NSLog(@"Data Sent: %@", data);
    [self.adaFruitPeripheral writeValue:[self getAES128EncryptedForData:data]
                            forCharacteristic:_txCharacteristic
                            type:CBCharacteristicWriteWithResponse];
    
    _writeSuccessBlock = writeSuccessBlock;
}


#pragma mark - CBCentralManagerDelegate
// This method is invoked after a @link readValueForCharacteristic: @/link call, or upon receipt of a notification/indication.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    if([characteristic.UUID isEqual:_rxCharacteristic.UUID]) {
        
//        NSLog(@"DidUpdateValueForCharacteristic: %@", characteristic.value);
        [self processRead:characteristic];
    }
}

// method called whenever you have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    NSLog(@"Connected to peripheral");
    // Notify the caller that the device is connected
    _connectionBlock(nil, peripheral.name);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    
    NSLog(@"Bluetooth connection terminated with error: %@", error.description);
    _isConnected = NO;
    _connectionBlock(error,@"");
    [self startScan];
}

 
// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    
    /*
    if ([localName isEqualToString:@"Adafruit Bluefruit LE"]) {
        
        NSLog(@"Found the adafruit devicer: %@", localName);
        [self.centralManager stopScan];
        self.adaFruitPeripheral = peripheral;
        peripheral.delegate = self;
        [self.centralManager connectPeripheral:peripheral options:nil];
    }*/
    
//    if(localName.length == 8) {
    
        localName = [[localName substringToIndex:3] uppercaseString];
        NSString *adaFruitDeviceName = @"Adafruit Bluefruit LE";
        adaFruitDeviceName = [[adaFruitDeviceName substringToIndex:3] uppercaseString];
        if([localName isEqualToString:@"MFD"] || [localName isEqualToString:adaFruitDeviceName]) {
            
            NSLog(@"Found the device: %@", localName);
            [self.centralManager stopScan];
            self.adaFruitPeripheral = peripheral;
            peripheral.delegate = self;
            [self.centralManager connectPeripheral:peripheral options:nil];
        }
//    }
}
 
// method called whenever the device state changes.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    NSError *error = nil;
    
    // Determine the state of the peripheral
    if ([central state] == CBCentralManagerStatePoweredOff) {
    
        NSLog(@"CoreBluetooth BLE hardware is powered off");
        error = [NSError errorWithDomain:@"CoreBluetooth BLE hardware is powered off" code:4001 userInfo:nil];
    }
    
    else if ([central state] == CBCentralManagerStatePoweredOn) {
        
        [self startScan];
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
    }
    
    else if ([central state] == CBCentralManagerStateUnauthorized) {
        
        NSLog(@"CoreBluetooth BLE state is unauthorized");
        error = [NSError errorWithDomain:@"CoreBluetooth BLE state is unauthorized" code:4002 userInfo:nil];
    }
    
    else if ([central state] == CBCentralManagerStateUnknown) {
        
        NSLog(@"CoreBluetooth BLE state is unknown");
        error = [NSError errorWithDomain:@"CoreBluetooth BLE state is unknown" code:4003 userInfo:nil];
    }
    
    else if ([central state] == CBCentralManagerStateUnsupported) {
    
        NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
        error = [NSError errorWithDomain:@"CoreBluetooth BLE hardware is unsupported on this platform" code:4004 userInfo:nil];
    }
    
    if(error) {
        _connectionBlock(error, @"");
    }
}


#pragma mark - CBPeripheralDelegate
 
// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    // Scan the device for available services
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service: %@", service.UUID);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}
 
// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    NSLog(@"");
    for(CBCharacteristic *aCharacteristic in service.characteristics) {
        
        if([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_Tx_CHARACTERISTIC]]) {
            
            _isConnected = YES;
            _txCharacteristic = aCharacteristic;
        }
        
        if([aCharacteristic.UUID isEqual:[CBUUID UUIDWithString:UUID_Rx_CHARACTERISTIC]]) {
            _rxCharacteristic = aCharacteristic;
            [self.adaFruitPeripheral readValueForCharacteristic:_rxCharacteristic];
            [self.adaFruitPeripheral setNotifyValue:YES forCharacteristic:_rxCharacteristic];
        }
        
        NSLog(@"Discovered characteristic: %@",aCharacteristic.UUID);
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
    if(error) {
        NSLog(@"Error occured while writing characteristic: %@", error.domain);
        if(_writeSuccessBlock) {
            _writeSuccessBlock(error, NO);
        }
    }
    
    else {
        NSLog(@"Wrote successfully...");
        if(_writeSuccessBlock) {
            _writeSuccessBlock(nil, YES);
        }
    }
    _writeSuccessBlock = nil;
}

@end
