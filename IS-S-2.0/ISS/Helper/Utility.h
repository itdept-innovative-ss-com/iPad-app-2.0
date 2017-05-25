//
//  Utility.h
//  ISS
//
//  Created by Anshuman Dahale on 3/3/17.
//  Copyright © 2017 Digvijay Joshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^ButtonsBlock)(NSArray *keysArray);

@interface Utility : NSObject

- (void) getAllButtonsFromView:(UIView *)view withComplitionBlock:(ButtonsBlock)block;
- (NSArray *) getKeyCodesForNumericString:(NSString *)frequency;
- (NSArray *) getMatchingButtonsForKeyName:(NSString *)keyName inArray:(NSArray *)array;
- (NSArray *) getKeyCodesForString:(NSString *)string;
+ (NSString *) getBuildVersion;

@end
