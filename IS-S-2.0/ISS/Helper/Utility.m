//
//  Utility.m
//  ISS
//
//  Created by Anshuman Dahale on 3/3/17.
//  Copyright © 2017 Digvijay Joshi. All rights reserved.
//

#import "Utility.h"
#import "KeyBoardButton.h"
#import "KeyHexConverter.h"

@interface Utility ()

@property (nonatomic, strong) NSMutableArray *keys;
@property (nonatomic, strong) UIView *parentContainerView;
@property (nonatomic, strong) KeyHexConverter *keyHexConverter;

@end


@implementation Utility

- (NSArray *) getMatchingButtonsForKeyName:(NSString *)keyName inArray:(NSArray *)array {

    NSString *nameMatchingPredicateString = [NSString stringWithFormat:@"keyName == '%@'", keyName];
    NSPredicate *nameMatchPredicate = [NSPredicate predicateWithFormat:nameMatchingPredicateString];
    NSArray *matchingKeysArray = [array filteredArrayUsingPredicate:nameMatchPredicate];
    //NSLog(@"Matching Keys: %@", matchingKeysArray);
    return matchingKeysArray;
}



- (NSArray *) getKeyCodesForString:(NSString *)string {
    
    _keyHexConverter = [[KeyHexConverter alloc] init];
    NSMutableArray *charArray = [[NSMutableArray alloc] init];
    
    for(NSInteger charId = 0; charId<string.length; charId++) {
        
        NSString *charString = [string substringWithRange:NSMakeRange(charId, 1)];
        [charArray addObject:charString];
        
//        char aChar = [string characterAtIndex:charId];
//        NSString *smallCase = [[NSString stringWithFormat:@"%c", aChar] lowercaseString];
//        NSString *charString = [NSString stringWithFormat:@"KEY_%c%@", aChar, smallCase];
//        NSString *hexString = [_keyHexConverter getValueForKey:charString category:Key_Category_Alphabet];
//        if(hexString) {
//            [hexArray addObject:hexString];
//        }
    }
    return charArray;
}


+ (NSString *) getBuildVersion {
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString *buildNumber = [infoDict objectForKey:@"CFBundleVersion"];
    NSString *version = [NSString stringWithFormat:@"Build: %@ v%@", appVersion, buildNumber];
    NSLog(@"%@", version);
    return version;
}


- (NSArray *) getKeyCodesForNumericString:(NSString *)frequency {
    
    _keyHexConverter = [[KeyHexConverter alloc] init];
    NSMutableArray *hexArray = [[NSMutableArray alloc] init];
    
    for(NSInteger charId=0; charId<frequency.length; charId++) {
        
        char aChar = [frequency characterAtIndex:charId];
        NSString *charString = [NSString stringWithFormat:@"KEY_NUM%c",aChar];
        NSString *hexString;
        if([charString isEqualToString:@"KEY_NUM."]) {
            hexString = @"0x2E";
        }
        else {
            hexString = [_keyHexConverter getValueForKey:charString category:Key_Category_Numeric];
        }
        
        NSLog(@"Hex Representation: %@",hexString);
        [hexArray addObject:hexString];
    }
    return hexArray;
}


- (void) getAllButtonsFromView:(UIView *)view withComplitionBlock:(ButtonsBlock)block {
    
    if(!_parentContainerView) {
        _parentContainerView = view;
    }
    
    if(!_keys) {
        _keys = [[NSMutableArray alloc] init];
    }
    
    UIView *containerView = view;
    while([containerView isKindOfClass:[UIView class]]) {
        for(UIView *subView in [containerView subviews]) {
            
            if([subView isKindOfClass:[KeyBoardButton class]]) {
                [_keys addObject:subView];
            }
        
            else if([subView isKindOfClass:[UIView class]]) {
                
                [self getAllButtonsFromView:subView withComplitionBlock:nil];
            }
        }
        break;
    }
    NSLog(@"All Keys %d", _keys.count);
    //the final count
    if(view == _parentContainerView) {
        NSLog(@"Final count Keys %d", _keys.count);
        block(_keys);
    }
}





@end
