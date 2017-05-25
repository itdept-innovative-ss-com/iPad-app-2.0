//
//  CustomButton.h
//  KeyBoardTest
//
//  Created by Anshuman Dahale on 5/20/16.
//  Copyright © 2016 Silicus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Enums.h"

@class KeyBoardButton;

@protocol KeyBoardButtonDelegate <NSObject>

@optional

- (void) userPressedKey:(KeyBoardButton *)pressedKey;

@end

@interface KeyBoardButton : UIButton

@property (nonatomic, strong)   NSString *keyName;
@property (nonatomic)           Key_Category keyCategory;
@property (nonatomic)           Key_State keyState;
@property (nonatomic)           Key_Theme keyTheme;
@property (nonatomic, strong)   IBOutlet id<KeyBoardButtonDelegate>delegate;

- (void) resetToOriginalBackgroundColor;
- (void) updateTheme;

@end
