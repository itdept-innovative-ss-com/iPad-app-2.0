//
//  ISSTests.m
//  ISSTests
//
//  Created by Anshuman Dahale on 3/9/17.
//  Copyright © 2017 Digvijay Joshi. All rights reserved.
//

#import <XCTest/XCTest.h>
//#import "BluetoothManager.h"
#import "Utility.h"
#import "SlipEnocding.h"
#import "NSString+Conversion.h"
#import "NSData+AES.h"
#import "Constants.h"
#import "Crypt.h"

@interface ISSTests : XCTestCase

@end

@implementation ISSTests

#pragma mark - 

- (void) testAESEncoding {
    
    
    unsigned char message[5];
    message[0] = 0xFD;
    message[1] = 49;//[@"0x31" hexToInteger];
    message[2] = 1;
    message[3] = 0;
    message[4] = ~ (message[0] + message[1] + message[2] + message[3]) + 1;
    NSData *data = [NSData dataWithBytes:(const void*) message length:sizeof(message)];
    
//    const char constChar[5] = {message[0], message[1], message [2], message [3], message[4]};
//    NSString *messageString = [NSString stringWithCString:constChar encoding:NSASCIIStringEncoding];
//    NSData *messageStringData = [messageString dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"Message String Data: %@", messageStringData);
    
//    NSData *stringData = [@"fd310100d1" dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"Data: %@\nString Data:%@", data, stringData);
    
    NSData *encrypteData = [data AES128EncryptedDataWithKey:@"3746A0A333656E2A45154567ED5F665B" iv:kAESIvKey];
    NSLog(@"%@", encrypteData);
}


- (void) testWithCrypt {
    
    unsigned char message[5];
    message[0] = 0xFD;
    message[1] = 49;//[@"0x31" hexToInteger];
    message[2] = 1;
    message[3] = 0;
    message[4] = ~ (message[0] + message[1] + message[2] + message[3]) + 1;
    NSData *data = [NSData dataWithBytes:(const void*) message length:sizeof(message)];
    
    
//    NSData *dataHexString = [Crypt dataFromHexString:@"EA010B23CDA9B16F0001020304050607"];
//    NSData *keyHex  = [Crypt dataFromHexString:@"000102030405060708090A0B0C0D0E0F"];
//    NSData *ivHex   = [Crypt dataFromHexString:@"00102030405060708090A0B0C0D0E0F0"];

    
        NSData *keyHex  = [Crypt dataFromHexString:@"3746A0A333656E2A45154567ED5F665B"];
        NSData *ivHex   = [Crypt dataFromHexString:@"00102030405060708090A0B0C0D0E0F0"];


    
    NSError *error;
    NSData *encryptedPacket = [Crypt aes128Data:data operation:kCCEncrypt key:keyHex options:kCCOptionPKCS7Padding iv:ivHex error:&error];
    NSLog(@"Crypt encrypted pkt: %@", encryptedPacket);
}


- (void) testRadioSettingsTest {
    
//    BluetoothManager *ble = [[BluetoothManager alloc] init];
//    [ble writeRadioFrequency:@[@"0x30", @"0x31"]];
}

- (void) testRadioHex {
    
    Utility *utility = [[Utility alloc] init];
//    [utility getKeyCodesForNumericString:@"118"];
    [utility getKeyCodesForString:@"ASDF"];
}


- (void) testSlipEncoding {
    
//    static unsigned char message[5];
//    NSString *hexValue = @"0x41";
//    message[0] = 0xFD;
//    message[1] = [hexValue hexToInteger]; //(unsigned int)[hexValue UTF8String];
//    message[2] = 1;//state; // for CCD keycode, zero otherwise, one for the highlight color (green) on the keyboard
//    message[3] = 0; // for CCD keycode, zero otherwise
//    message[4] = ~ (message[0] + message[1] + message[2] + message[3]) + 1;
//    
//    NSInteger messageSize = sizeof(message);
//    NSData *data = [NSData dataWithBytes:(const void*) message length:messageSize];
//    NSLog(@"Data Sent: %@", data);
//    
//    NSString *key = [NSString stringWithFormat:@"%@%@", kAESPlainKey, kAESSaltKey];
//    NSData *aesEncrypted = [data AES128EncryptedDataWithKey:key iv:kAESSaltKey];
//    
//    SlipEnocding *slip = [[SlipEnocding alloc] init];
//    [slip SLIPEncodeData:aesEncrypted];
}


#pragma mark - Default Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
