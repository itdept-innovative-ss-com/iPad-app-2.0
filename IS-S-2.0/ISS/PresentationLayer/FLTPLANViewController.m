//
//  FLTPLANViewController.m
//  ISS
//
//  Created by Anshuman Dahale on 2/23/17.
//  Copyright © 2017 Digvijay Joshi. All rights reserved.
//

#import "FLTPLANViewController.h"
#import "Constants.h"
#import "Utility.h"
#import "BluetoothManager.h"
#import "KeyBoardButton.h"
#import "Enums.h"
#import "ApplicationManager.h"


@interface FLTPLANViewController () <KeyBoardButtonDelegate, ReadResponseDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *flightPlanTextView;
@property (nonatomic, strong) IBOutlet UIButton *settingsButton;
@property (nonatomic, strong) Utility *utility;
@property (nonatomic, strong) BluetoothManager *bluetoothManager;
@property (nonatomic, strong) NSMutableArray *allKeys;
@property (nonatomic, strong) IBOutlet UIView *keyBoardContainerView;
@property (nonatomic, strong) id<UIKeyInput> keyInputDelegate;

@end

@implementation FLTPLANViewController




#pragma mark -

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    UITextInputAssistantItem* item = [textView inputAssistantItem];
    item.leadingBarButtonGroups = @[];  
    item.trailingBarButtonGroups = @[];
    item.allowsHidingShortcuts = YES;
    
    return YES;
}


#pragma mark - 

- (void) updateColorForAllKeys {
    
    if([ApplicationManager sharedInstance].isDarkMode) {
    
        [_settingsButton setImage:[UIImage imageNamed:@"setting-white"] forState:UIControlStateNormal];
        _flightPlanTextView.backgroundColor = [UIColor darkGrayColor];
        _flightPlanTextView.textColor = [UIColor whiteColor];
    }
    else {
        [_settingsButton setImage:[UIImage imageNamed:@"setting-black"] forState:UIControlStateNormal];
        _flightPlanTextView.backgroundColor = [UIColor whiteColor];
        _flightPlanTextView.textColor = [UIColor blackColor];
    }

    [self changeKeyColorsForKeysInArray:_allKeys];
}

- (void) changeKeyColorsForKeysInArray:(NSArray *)keysArray {
    
    for(KeyBoardButton *aKey in keysArray) {
        
        NSLog(@"Changing color for: %@", aKey.keyName);
        //Set the delegate to self
        aKey.delegate = self;
        
        if(aKey.keyTheme == Key_Theme_White) {
            
            if([ApplicationManager sharedInstance].isDarkMode) {
                aKey.backgroundColor = [UIColor darkGrayColor];
                [aKey setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
                [aKey setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            else {
                aKey.backgroundColor = [UIColor whiteColor];
                [aKey setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [aKey setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
        }
    }
}

#pragma mark - BLE Delegate
- (void) readValueKeyHex:(NSString *)keyHex forState:(Key_State)keyState {
    
}

#pragma mark - KeyBoardButtonDelegate

- (void) userPressedKey:(KeyBoardButton *)pressedKey {
    
    //Alpha numeric key pressed
    if(pressedKey.keyCategory == Key_Category_Alphabet || pressedKey.keyCategory == Key_Category_Numeric) {
        
        [_keyInputDelegate insertText:pressedKey.titleLabel.text];
    }
    else if (pressedKey.keyCategory == Key_Category_KeyBoard_Functional) {
        
        //CLR key pressed
        if([pressedKey.keyName isEqualToString:@"KEY_CLR"]) {
            
            [_keyInputDelegate deleteBackward];
        }
        
        //Enter Key pressed
        else if ([pressedKey.keyName isEqualToString:@"KEY_ENTER"]) {
            
            [_keyInputDelegate insertText:@"\n"];
        }
        else if ([pressedKey.keyName isEqualToString:@"KEY_SP"]) {
            
            [_keyInputDelegate insertText:@" "];
        }
        
        else {
            [_keyInputDelegate insertText:pressedKey.titleLabel.text];
        }
    }
}




#pragma mark - IBActions

- (IBAction)pasteButton_TouchUpInside:(id)sender {
    
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    _flightPlanTextView.text = [pasteBoard.string uppercaseString];
}

- (IBAction)sendButton_TouchUpInside:(id)sender {
    
    NSArray *hexArray = [_utility getKeyCodesForString:_flightPlanTextView.text];
    [_bluetoothManager writeFltPlnInput:hexArray withSuccessBlock:^(NSError *error, BOOL success) {
        
    }];
}

- (IBAction)settingsButton_TouchUpInside:(id)sender {
    
    [UIView animateWithDuration:0.5 animations:^{
        
        _settingsButton.transform = CGAffineTransformMakeRotation(M_PI/4);
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSettingsClicked object:nil];
    }];
}

- (void) settingsIconRotateBackToOriginal {
    
    [UIView animateWithDuration:0.5 animations:^{
        _settingsButton.transform = CGAffineTransformMakeRotation(-M_PI/4);
    }];
}

#pragma mark - Gesture recognizer

- (void) rightSwipeGestureDetected {
    
    NSLog(@"User swiped right");
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRightGesture object:nil];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeGestureDetected)];
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    
    UIView *inputView = [[UIView alloc] init];
    [inputView setFrame:CGRectMake(0, 0, 1, 1)];
    inputView.backgroundColor = [UIColor clearColor];
    _flightPlanTextView.inputView = inputView;
    
    UIView *inputAccView = [[UIView alloc] init];
    [inputAccView setFrame:CGRectMake(0, 0, 1, 1)];
    inputAccView.backgroundColor = [UIColor clearColor];
    _flightPlanTextView.inputAccessoryView = inputAccView;
    
    _utility = [[Utility alloc] init];
    _allKeys = [[NSMutableArray alloc] init];
    _bluetoothManager = [BluetoothManager sharedInstance];
    _bluetoothManager.fltPlanReadDelegate = self;
    _keyInputDelegate = _flightPlanTextView;
    
//    [_flightPlanTextView becomeFirstResponder];
    
    [_utility getAllButtonsFromView:_keyBoardContainerView withComplitionBlock:^(NSArray *keysArray) {
        
        _allKeys = [NSMutableArray arrayWithArray:keysArray];
        [self updateColorForAllKeys];
    }];
    
    
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(updateColorForAllKeys)
        name:kNotificationSettingsChanged
        object:nil];
    
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(settingsIconRotateBackToOriginal)
        name:kNotificationSettingsViewClosed
        object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
