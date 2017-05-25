//
//  Crypt.h
//  ISS
//
//  Created by Anshuman Dahale on 3/16/17.
//  Copyright © 2017 Digvijay Joshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

@interface Crypt : NSObject

+ (NSData *)aes128Data:(NSData *)dataIn
             operation:(CCOperation)operation  // kCC Encrypt, Decrypt
                   key:(NSData *)key
               options:(CCOptions)options      // kCCOption PKCS7Padding, ECBMode,
                    iv:(NSData *)iv
                 error:(NSError **)error;
                 
+ (NSData *)dataFromHexString:(NSString *)hexString;

@end
