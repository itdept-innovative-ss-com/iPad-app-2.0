//
//  NSString+Conversion.m
//  ISS
//
//  Created by Anshuman Dahale on 6/2/16.
//  Copyright © 2016 Digvijay Joshi. All rights reserved.
//

#import "NSString+Conversion.h"

@implementation NSString (Conversion)

- (unsigned int) hexToInteger {

    unsigned int decVal = 0 ;
    NSScanner* scan = [NSScanner scannerWithString:self];
    [scan scanHexInt:&decVal];
    scan = nil;
    return decVal;
}

@end
