//
//  KeyHexConverter.h
//  ISS
//
//  Created by Digvijay Joshi on 5/26/16.
//  Copyright © 2016 Digvijay Joshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enums.h"

@interface KeyHexConverter : NSObject

- (NSString *)getValueForKey:(NSString *)keyName category:(Key_Category)keyCategory;
- (NSArray *) getKeyForHexValue:(NSString *)hexValue;
- (int) getCategoryForHexValue:(NSString *)hexValue;

@end
