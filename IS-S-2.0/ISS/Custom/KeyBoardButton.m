//
//  CustomButton.m
//  KeyBoardTest
//
//  Created by Anshuman Dahale on 5/20/16.
//  Copyright © 2016 Silicus. All rights reserved.
//

#import "KeyBoardButton.h"
#import "Constants.h"
#import "KeyboardViewController.h"
#import "ApplicationManager.h"

#define BUTTON_POPUP_FACTOR 44

@class KeyboardViewController;
@interface KeyBoardButton ()

@property (nonatomic, strong) UIColor *originalBackGroundColor;
@property (nonatomic) CGRect originalFrame;
@property (nonatomic) BOOL buttonTouched;

@end

@implementation KeyBoardButton

- (void) resetToOriginalBackgroundColor {
    
    _originalBackGroundColor = ([ApplicationManager sharedInstance].isDarkMode) ? [UIColor darkGrayColor] : [UIColor whiteColor];
//    _touchDownColor = (_originalBackGroundColor == [UIColor whiteColor]) ? [UIColor darkGrayColor] : [UIColor whiteColor];
    self.backgroundColor = _originalBackGroundColor;
}

- (void) updateTheme {
    
    if(self.keyTheme == Key_Theme_White) {
        
        if([ApplicationManager sharedInstance].isDarkMode) {
            self.backgroundColor = [UIColor darkGrayColor];
            [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else {
            self.backgroundColor = [UIColor whiteColor];
            [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
}

- (void) updateBackGroundColor {
    
    if(self.keyTheme == Key_Theme_White) {
        if([ApplicationManager sharedInstance].isDarkMode) {
            _originalBackGroundColor = [UIColor darkGrayColor];
        }
        else {
            _originalBackGroundColor = [UIColor whiteColor];
        }
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect {
    
    if(!_originalBackGroundColor) {
        
        //Set the original background color
        _originalBackGroundColor = self.backgroundColor;
        
        // Add actions to the button
        [self   addTarget:self
                action:@selector(button_OtherTouchEvents:)
                forControlEvents:
                                    UIControlEventTouchDragOutside  |
                                    UIControlEventTouchDragExit     |
                                    UIControlEventTouchCancel
        ];
        
        //add observer to listen updation of button theme
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBackGroundColor) name:kNotificationSettingsChanged object:nil];
        
        
        [self addTarget:self action:@selector(button_TouchDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(button_TouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
        if(self.keyTheme == Key_Theme_White) {
            
            if([ApplicationManager sharedInstance].isDarkMode) {
                self.backgroundColor = [UIColor darkGrayColor];
                [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
                [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            else {
                self.backgroundColor = [UIColor whiteColor];
                [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
        }
        
        self.keyState = Key_State_Default;
        
        if([self.keyName isEqualToString:@"KEY_DIRECT"] || [self.keyName isEqualToString:@"KEY_VTF"]) {
            
            NSString *imageName = ([self.keyName isEqualToString:@"KEY_DIRECT"] ? @"d" : @"v");
            [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        }
    }
}

// Pressed down the button
- (void) button_TouchDown:(id)sender {
    
    [self touchDownAction];
}


- (void) touchDownAction {
    
//    NSLog(@"TouchDownAction");
    
    if(self.keyTheme == Key_Theme_White) {
        [self setBackgroundColor:(_originalBackGroundColor == [UIColor whiteColor]) ? [UIColor darkGrayColor] : [UIColor whiteColor]];
    }
    else {
        [self setBackgroundColor:[UIColor darkGrayColor]];
    }
    
    if([self.keyName isEqualToString:@"KEY_DIRECT"] || [self.keyName isEqualToString:@"KEY_VTF"]) {
        
        NSString *imageName = ([self.keyName isEqualToString:@"KEY_DIRECT"] ? @"d-white" : @"v-white");
        [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
    }
    _originalFrame = self.frame;
    [UIView animateWithDuration:0.0 animations:^{
        
        
        [self setFrame:CGRectMake(  _originalFrame.origin.x,
                                    _originalFrame.origin.y - BUTTON_POPUP_FACTOR,
                                    _originalFrame.size.width,
                                    _originalFrame.size.height)];
    }];
}

// Released after pressed down
- (void) button_TouchUpInside:(id)sender {
    
    _buttonTouched = NO;
//    NSLog(@"TouchUpInside");
    [self setBackgroundColor:(self.keyState == Key_State_Default) ? _originalBackGroundColor : kHighlitedKeyColor];
    if([self.keyName isEqualToString:@"KEY_DIRECT"] || [self.keyName isEqualToString:@"KEY_VTF"]) {
        NSString *imageName = ([self.keyName isEqualToString:@"KEY_DIRECT"] ? @"d" : @"v");
        [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    if([_delegate respondsToSelector:@selector(userPressedKey:)]) {
        
        [_delegate userPressedKey:self];
    }
    [UIView animateWithDuration:0.0 animations:^{
        [self setFrame:_originalFrame];
    }];
}



- (void) button_OtherTouchEvents:(id)sender {
    
    _buttonTouched = NO;
    NSLog(@"button_OtherTouchEvents");
    [self setBackgroundColor:(self.keyState == Key_State_Default) ? _originalBackGroundColor : kHighlitedKeyColor];
    if([self.keyName isEqualToString:@"KEY_DIRECT"] || [self.keyName isEqualToString:@"KEY_VTF"]) {
        
        NSString *imageName = ([self.keyName isEqualToString:@"KEY_DIRECT"] ? @"d" : @"v");
        [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    [UIView animateWithDuration:0.0 animations:^{
        [self setFrame:_originalFrame];
    }];
}

@end
