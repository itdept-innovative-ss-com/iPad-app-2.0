//
//  TSPViewController.m
//  ISS
//
//  Created by Anshuman Dahale on 2/23/17.
//  Copyright © 2017 Digvijay Joshi. All rights reserved.
//

#import "TSPViewController.h"
#import "Utility.h"
#import "ApplicationManager.h"
#import "KeyBoardButton.h"
#import "Constants.h"
#import "BluetoothManager.h"
#import "KeyHexConverter.h"

@interface TSPViewController () <KeyBoardButtonDelegate, ReadResponseDelegate>

@property (nonatomic, strong) Utility *utility;
@property (nonatomic, strong) BluetoothManager *bluetoothManager;
@property (nonatomic, strong) KeyHexConverter *keyHexConverter;

@property (nonatomic, strong) NSMutableArray *allKeys;
@property (nonatomic, strong) IBOutlet UILabel *frequencyLabel;
@property (nonatomic, strong) IBOutlet UIButton *settingsButton;

@end

@implementation TSPViewController

#pragma mark - IBActions
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


#pragma mark - BLE Delegate
- (void) readValueKeyHex:(NSString *)keyHex forState:(Key_State)keyState {
    
    NSArray *matchingKeysArray = [_keyHexConverter getKeyForHexValue:keyHex];
    if([matchingKeysArray count]) {
        NSString *keyName = [matchingKeysArray objectAtIndex:0];
        NSArray *matchingButtons = [_utility getMatchingButtonsForKeyName:keyName inArray:_allKeys];
        
        for(KeyBoardButton *aKey in matchingButtons) {
            
            aKey.keyState = keyState;
            [aKey updateTheme];
        }
    }
}


#pragma mark - KeyBoardButtonDelegate
- (void) userPressedKey:(KeyBoardButton *)pressedKey {
    
    // A numeric key is pressed change the frequency label text
    NSLog(@"User pressed: %@", pressedKey.keyName);
    
    if(pressedKey.keyCategory == Key_Category_Numeric) {
        
        if(_frequencyLabel.text.length < 4) {
            
            //If the user pressed decimal point, check if a decimal already exists. If yes then return
            if([pressedKey.keyName isEqualToString:@"."]) {
                if([_frequencyLabel.text containsString:@"."]) {
                    return;
                }
            }
            _frequencyLabel.text = [_frequencyLabel.text stringByAppendingString:pressedKey.keyName];
        }
    }
    
    //functional key is pressed
    else if (pressedKey.keyCategory == Key_Category_Cockpit_Functional) {
        
        [self processFunctinalKeyPress:pressedKey];
    }
    
    //delete key is pressed
    else {
        if([pressedKey.keyName isEqualToString:@"DELETE"]) {
            
            if(_frequencyLabel.text.length > 0) {
                NSString *frequency = [_frequencyLabel.text substringToIndex:_frequencyLabel.text.length-1];
                _frequencyLabel.text = frequency;
            }
        }
    }
}


- (void) processFunctinalKeyPress:(KeyBoardButton *)key {
    
    //Set XPDR
    if([key.keyName isEqualToString:@"KEY_XPDR1"]) {
        
        NSArray *keysArray = [_utility getKeyCodesForNumericString:_frequencyLabel.text];
        [_bluetoothManager writeRadioFrequency:keysArray forFrequencyType:Frequency_Type_ADF];
    }
    else {
        
        NSString *keyValue = [_keyHexConverter getValueForKey:key.keyName category:key.keyCategory];
        [_bluetoothManager writeToPeripheralValue:keyValue forState:key.keyState withSuccessBlock:^(NSError *error, BOOL success) {
            
        }];
    }
}


- (void) updateColorForAllKeys {
    
    UIImage *image = [UIImage imageNamed:[ApplicationManager sharedInstance].isDarkMode ? @"setting-white" : @"setting-black"];
    _frequencyLabel.textColor = [ApplicationManager sharedInstance].isDarkMode ? [UIColor whiteColor] : [UIColor blackColor];
    [_settingsButton setImage:image forState:UIControlStateNormal];
    [self changeKeyColorsForKeysInArray:_allKeys];
}


- (void) changeKeyColorsForKeysInArray:(NSArray *)keysArray {
    
    for(KeyBoardButton *aKey in keysArray) {
        
        NSLog(@"Changing color for: %@", aKey.keyName);
        aKey.delegate = self;
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

#pragma mark - Gesture recognizer

- (void) leftSwipeGestureDetected {
    
    NSLog(@"User swiped right");
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLeftGesture object:nil];
}

- (void) rightSwipeGestureDetected {
    
    NSLog(@"User swiped right");
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRightGesture object:nil];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeGestureDetected)];
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
    
    
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeGestureDetected)];
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    
    _allKeys                = [[NSMutableArray alloc] init];
    _utility                = [[Utility alloc] init];
    _bluetoothManager       = [BluetoothManager sharedInstance];
    _keyHexConverter        = [[KeyHexConverter alloc] init];
    
    _bluetoothManager.tspReadDelegate = self;
    
    [_utility getAllButtonsFromView:self.view withComplitionBlock:^(NSArray *keysArray) {
        _allKeys = [[NSMutableArray alloc] initWithArray:keysArray];
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
