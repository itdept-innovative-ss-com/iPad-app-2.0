//
//  KeyHexConverter.m
//  ISS
//
//  Created by Digvijay Joshi on 5/26/16.
//  Copyright © 2016 Digvijay Joshi. All rights reserved.
//

#import "KeyHexConverter.h"

@interface KeyHexConverter()
{
    NSDictionary *keyCategoryAlphabetData;
    NSDictionary *keyCategoryNumericData;
    NSDictionary *keyCategoryArrowData;
    NSDictionary *keyCategoryCockpitFunctionalData;
    NSDictionary *keyCategoryCockpitSpecialData;
    NSDictionary *keyCategoryKeyboardFunctionalData;
}
@end

@implementation KeyHexConverter

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
        [self fetchDataForCategory:Key_Category_Alphabet];
        [self fetchDataForCategory:Key_Category_Numeric];
        [self fetchDataForCategory:Key_Category_Arrow];
        [self fetchDataForCategory:Key_Category_KeyBoard_Functional];
        [self fetchDataForCategory:Key_Category_Cockpit_Functional];
        [self fetchDataForCategory:Key_Category_Cockpit_Special];
    }
    return self;
}

- (NSString *)getValueForKey:(NSString *)keyName category:(Key_Category)keyCategory {

    NSString *value = nil;

    [self fetchDataForCategory:keyCategory];

    value = [self valueForKey:keyName inCategory:keyCategory];

    return value;
}

- (void)fetchDataForCategory:(Key_Category)keyCategory {

    switch (keyCategory) {
        case Key_Category_Alphabet: {
            if (!keyCategoryAlphabetData) {
                keyCategoryAlphabetData = [self loadAndParseData:@"Key_Category_Alphabet"];
            }
        }
            break;

        case Key_Category_Numeric: {
            if (!keyCategoryNumericData) {
                keyCategoryNumericData = [self loadAndParseData:@"Key_Category_Numeric"];
            }
        }
            break;

        case Key_Category_Arrow: {
            if (!keyCategoryArrowData) {
                keyCategoryArrowData = [self loadAndParseData:@"Key_Category_Arrow"];
            }
        }
            break;

        case Key_Category_KeyBoard_Functional: {
            if (!keyCategoryKeyboardFunctionalData) {
                keyCategoryKeyboardFunctionalData = [self loadAndParseData:@"Key_Category_KeyBoard_Functional"];
            }
        }
            break;

        case Key_Category_Cockpit_Functional: {
            if (!keyCategoryCockpitFunctionalData) {
                keyCategoryCockpitFunctionalData = [self loadAndParseData:@"Key_Category_Cockpit_Functional"];
            }
        }
            break;

        case Key_Category_Cockpit_Special: {
            if (!keyCategoryCockpitSpecialData) {
                keyCategoryCockpitSpecialData = [self loadAndParseData:@"Key_Category_Cockpit_Special"];
            }
        }
            break;
            
        default:
            break;
    }
}

- (NSDictionary *)loadAndParseData:(NSString *)fileName {

    NSString *plistPath = [[NSBundle mainBundle] pathForResource:fileName
                                                          ofType:@"plist"];

    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:plistPath];

    //NSLog(@"Data: %@", data);
    return data;
}

-(NSString *)valueForKey:(NSString *)keyName inCategory:(Key_Category)keyCategory {
    NSString *value = nil;
    switch (keyCategory) {
        case Key_Category_Alphabet:
            value = (keyCategoryAlphabetData) ? [keyCategoryAlphabetData valueForKey:keyName] : @"";
            break;

        case Key_Category_Numeric:
            value = (keyCategoryNumericData) ? [keyCategoryNumericData valueForKey:keyName] : @"";
            break;

        case Key_Category_Arrow:
            value = (keyCategoryArrowData) ? [keyCategoryArrowData valueForKey:keyName] : @"";
            break;

        case Key_Category_KeyBoard_Functional:
            value = (keyCategoryKeyboardFunctionalData) ? [keyCategoryKeyboardFunctionalData valueForKey:keyName] : @"";
            break;

        case Key_Category_Cockpit_Functional:
            value = (keyCategoryCockpitFunctionalData) ? [keyCategoryCockpitFunctionalData valueForKey:keyName] : @"";
            break;

        case Key_Category_Cockpit_Special:
            value = (keyCategoryCockpitSpecialData) ? [keyCategoryCockpitSpecialData valueForKey:keyName] : @"";
            break;
            
        default:
            break;
    }
    return value;
}


- (NSArray *) getKeyForHexValue:(NSString *)hexValue {
    
    NSArray *keys = nil;
        
    NSArray *dictonariesArray =  @[ keyCategoryAlphabetData,
                                    keyCategoryNumericData,
                                    keyCategoryArrowData,
                                    keyCategoryCockpitFunctionalData,
                                    keyCategoryCockpitSpecialData,
                                    keyCategoryKeyboardFunctionalData];
    
    
    for(NSDictionary *aDictonary in dictonariesArray) {
        
        if([[aDictonary allKeysForObject:hexValue] count] > 0) {
        
            //NSLog(@"%@", [aDictonary allKeysForObject:hexValue]);
             keys = [[NSArray alloc] initWithArray:[aDictonary allKeysForObject:hexValue]];
             break;
         }
    }
    return keys;
}


- (int) getCategoryForHexValue:(NSString *)hexValue {
    
    NSArray *dictonariesArray =  @[ keyCategoryAlphabetData,
                                    keyCategoryNumericData,
                                    keyCategoryArrowData,
                                    keyCategoryKeyboardFunctionalData,
                                    keyCategoryCockpitFunctionalData,
                                    keyCategoryCockpitSpecialData,
                                    ];
    
    for(int i = 0; i < dictonariesArray.count; i++) {
        
        NSDictionary *aDictonary = [dictonariesArray objectAtIndex:i];
        if([[aDictonary allKeysForObject:hexValue] count] > 0) {
            return i;
        }
    }
    return -1;
}

@end
