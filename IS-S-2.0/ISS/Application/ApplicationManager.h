//
//  ApplicationManager.h
//  ISS
//
//  Created by Anshuman Dahale on 5/26/16.
//  Copyright © 2016 Digvijay Joshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//@class KeyboardViewController;

@interface ApplicationManager : NSObject

@property (nonatomic, strong) UIViewController *keyBoardViewController;
@property (nonatomic) BOOL isDarkMode;
@property (nonatomic, strong) NSString *aesKey, *ivKey, *deviceName;
@property (nonatomic, strong) NSString *comSpacing, *navSpacing, *adfSpacing;

+ (ApplicationManager *) sharedInstance;

@end
