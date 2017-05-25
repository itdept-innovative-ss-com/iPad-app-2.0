//
//  SlipEnocding.h
//  ISS
//
//  Created by Anshuman Dahale on 3/13/17.
//  Copyright © 2017 Digvijay Joshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SlipEnocding : NSObject

- (NSData *) SLIPEncodeData:(NSData *)data;
- (NSData *) SLIPDecodeData:(NSData *)data;

@end
