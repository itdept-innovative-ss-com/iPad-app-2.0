//
//  Constants.h
//  ISS
//
//  Created by Anshuman Dahale on 5/26/16.
//  Copyright © 2016 Digvijay Joshi. All rights reserved.
//

#ifndef Constants_h
#define Constants_h


//AES Encryption:
//#define kAESPlainKey    @"3746A0A333656E2A45154567ED5F665B"
#define kAESSaltKey     @""//@"212A08B86D7E061D"
//#define kAESIvKey       @"93F1E5D61F17E48F0669E2DF1DF5EA0C"


#define kKeyBoardButtonPressedNotificationName @"keyBoardButtonPressedNotification"
#define kHighlitedKeyColor  [UIColor greenColor]
#define kDarkModeKeyColor   [UIColor darkGrayColor]
#define kLightModeKeyColor  [UIColor whiteColor]
#define kLightBackgroundColor  [UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:205.0/255.0 alpha:1.0]


//MARK: Bluetooth Service Codes

#define UUID_UART_SERVICES                      @"6e400001-b5a3-f393-e0a9-e50e24dcca9e"
#define UUID_Tx_CHARACTERISTIC                  @"6e400002-b5a3-f393-e0a9-e50e24dcca9e"
#define UUID_Rx_CHARACTERISTIC                  @"6e400003-b5a3-f393-e0a9-e50e24dcca9e"

#define UUID_DEVICE_INFO                        @"180A"
#define UUID_HARDWARE_REVISION                  @"2A27"
#define UUID_MANUFACTURER_NAME                  @"2A29"
#define UUID_MODEL_NUMBER                       @"2A24"
#define UUID_FIRMWARE_REVISION                  @"2A26"
#define UUID_SOFTWARE_REVISION                  @"2A28"
#define UUID_SERIAL_NUMBER                      @"2A25"
#define UUID_SYSTEM_ID                          @"2A23"

#define UUID_DFU_SERVICE_ID                     @"00001530-1212-efde-1523-785feabcd123"
#define UUID_MODEL_NUMBER_CHARACTERISTIC        @"00002A24-0000-1000-8000-00805F9B34FB"
#define UUID_MANUFACTURER_NAME_CHARACTERISTIC   @"00002A29-0000-1000-8000-00805F9B34FB"
#define UUID_SOFTWARE_REVISION_CHARACTERISTIC   @"00002A28-0000-1000-8000-00805F9B34FB"
#define UUID_FIRMWARE_REVISION_CHARACTERISTIC   @"00002A26-0000-1000-8000-00805F9B34FB"
#define UUID_DFU_CONTROL_POINT_CHARACTERISTIC   @"00001531-1212-EFDE-1523-785FEABCD123"
#define UUID_DFU_PACKET_CHARACTERISTIC          @"00001532-1212-EFDE-1523-785FEABCD123"
#define UUID_DFU_VERSION_CHARACTERISTIC         @"00001534-1212-EFDE-1523-785FEABCD123"


//Settings
#define kUserDefaultsAESKey                     @"aesKey"
#define kUserDefaultsIVKey                      @"ivKey"
#define kUserDefaultsComSpacing                 @"comSpacingKey"
#define kUserDefaultsNAVSpacing                 @"navSpacingKey"
#define kUserDefaultsADFSpacing                 @"adfSpacingKey"


#define kIsDarkModeDefaultsKey                  @"darkModeUserDefaultsKey"
#define kNotificationSettingsChanged            @"invertKeysColorNotificationName"
#define kNotificationSettingsClicked            @"notificationSettingsButtonClicked"
#define kNotificationSettingsViewClosed         @"notificationSettingsViewClosed"

#define kNotificationRightGesture               @"userMadeRightSwipe"
#define kNotificationLeftGesture                @"userMadeLeftSwipe"

#endif /* Constants_h */
