//
//  HomeViewController.m
//  ISS
//
//  Created by Anshuman Dahale on 2/21/17.
//  Copyright © 2017 Digvijay Joshi. All rights reserved.
//

#import "HomeViewController.h"
#import "RadioView.h"
#import "SettingsViewController.h"
#import "KeyBoardButton.h"

#import "Constants.h"

#import "ApplicationManager.h"
#import "BluetoothManager.h"
#import "KeyHexConverter.h"
#import "Utility.h"


@interface HomeViewController () <ReadResponseDelegate, KeyBoardButtonDelegate>

@property IBOutlet UIView *centerView, *tabContainerView;

@property (nonatomic, strong) SettingsViewController *settingsViewController;
@property (nonatomic, strong) Utility *utility;
@property (nonatomic, strong) KeyHexConverter *keyHexConverter;
@property (nonatomic, strong) BluetoothManager *bluetoothManager;
@property (nonatomic, strong) NSMutableArray *allKeys, *clickedButtons;

@property (weak, nonatomic) IBOutlet UIView *fltPlanContainerView;
@property (weak, nonatomic) IBOutlet UIView *tspContainerView;
@property (weak, nonatomic) IBOutlet UIView *radioContainerView;
@property (weak, nonatomic) IBOutlet UIView *keyboardContainerView;

@property (nonatomic, strong) IBOutlet UIView *topView, *bottomView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *mfdModeLabelPortrait, *mfdModeLabelLandscape, *modelNameLabel;

@property (nonatomic, strong) IBOutlet UIButton *settingsButton;
@property (nonatomic)         BOOL hasRotatedOnce;

//@property (nonatomic, strong) KeyboardViewController *keyboardViewControllerRef;

@end

@implementation HomeViewController


#pragma mark - Gestures Detected
- (void) leftGestureDetected {
    
    if(_segmentedControl.selectedSegmentIndex != (_segmentedControl.numberOfSegments - 1)) {
        [_segmentedControl setSelectedSegmentIndex:(_segmentedControl.selectedSegmentIndex + 1)];
        [_segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void) rightGestureDetected {
    
    if(_segmentedControl.selectedSegmentIndex > 0) {
        
        [_segmentedControl setSelectedSegmentIndex:(_segmentedControl.selectedSegmentIndex - 1)];
        [_segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

#pragma mark -
- (void) settingsIconRotateBackToOriginal {
    
    [UIView animateWithDuration:0.5 animations:^{
        _settingsButton.transform = CGAffineTransformMakeRotation(-M_PI/4);
    }];
}


- (void) updateThemeAsPerSettings {
    
    if([ApplicationManager sharedInstance].isDarkMode) {
        
        [self.view setBackgroundColor:[UIColor blackColor]];
        [_settingsButton setImage:[UIImage imageNamed:@"setting-white-small"] forState:UIControlStateNormal];
        
        [_mfdModeLabelPortrait setBackgroundColor:[UIColor blackColor]];
        [_mfdModeLabelPortrait setTextColor:[UIColor whiteColor]];
        
        [_mfdModeLabelLandscape setBackgroundColor:[UIColor blackColor]];
        [_mfdModeLabelLandscape setTextColor:[UIColor whiteColor]];
        
        [_modelNameLabel setTextColor:[UIColor whiteColor]];
    }
    else {
        
        [self.view setBackgroundColor:kLightBackgroundColor];
        [_settingsButton setImage:[UIImage imageNamed:@"setting-black-small"] forState:UIControlStateNormal];
        
        [_mfdModeLabelPortrait setBackgroundColor:kLightBackgroundColor];
        [_mfdModeLabelPortrait setTextColor:[UIColor blackColor]];
        
        [_mfdModeLabelLandscape setBackgroundColor:kLightBackgroundColor];
        [_mfdModeLabelLandscape setTextColor:[UIColor blackColor]];
        
        [_modelNameLabel setTextColor:[UIColor blackColor]];
    }
}

- (void) changeStateTo:(Key_State)state forKeysInArray:(NSArray *)keysArray {
    
    for(KeyBoardButton *aKey in keysArray) {
        
        aKey.keyState = state;
        
        if(aKey.keyState == Key_State_Default) {
            
            [aKey updateTheme];
            [_clickedButtons removeObject:aKey];
        }
        else /*if(aKey.keyState == Key_State_Highlighted)*/ {
            
            [aKey setBackgroundColor:kHighlitedKeyColor];
            if(![_clickedButtons containsObject:aKey]) {
                [_clickedButtons addObject:aKey];
            }
        }
    }
}


- (void) orientationChanged:(NSNotification *)notification {
   
//   [self updateAllKeysArray];
   
   float delay = _hasRotatedOnce ? 0.0 : 1.0;
   
   [self    performSelector:@selector(markButttonsAsClickedAfterOrientationChange)
            withObject:nil
            afterDelay:delay];
    
    _hasRotatedOnce = YES;
}

- (void) markButttonsAsClickedAfterOrientationChange {
    
    //NSLog(@"In markButttonsAsClickedAfterOrientationChange");
    NSArray *copyOfClickedButtons = [[NSArray alloc] initWithArray:_clickedButtons];
    for(KeyBoardButton *clickedButton in copyOfClickedButtons) {
       
       NSArray *matchingKeysArray = [_utility getMatchingButtonsForKeyName:clickedButton.keyName inArray:_allKeys];
       [self changeStateTo:Key_State_Highlighted forKeysInArray:matchingKeysArray];
   }
}



#pragma mark - KeyBoardButton Delegate
- (void) userPressedKey:(KeyBoardButton *)pressedKey {
    
    NSString *valueOfPressedKey =    [_keyHexConverter  getValueForKey:pressedKey.keyName
                                                        category:pressedKey.keyCategory];
    Key_State state = pressedKey.keyState;
    
    if(_bluetoothManager.isConnected) {
     
           [_bluetoothManager writeToPeripheralValue:valueOfPressedKey forState:(Key_State)state withSuccessBlock:^(NSError *error, BOOL success) {
            
        }];
    }
}

#pragma mark - BLE

- (void) readValueKeyHex:(NSString *)keyHex forState:(Key_State)keyState {
    
    if(keyHex) {
    
        NSArray *matchingKeyNameArray = [_keyHexConverter getKeyForHexValue:keyHex];
        if([matchingKeyNameArray count]) {
            
            NSString *keyName = [matchingKeyNameArray objectAtIndex:0];
            NSArray *keys = [_utility getMatchingButtonsForKeyName:keyName inArray:_allKeys];
            [self changeStateTo:keyState forKeysInArray:keys];
        }
    }
    
    NSLog(@"Read Value for Key");
}

- (void) setupBLEConnection {

    _bluetoothManager = [BluetoothManager sharedInstance];
    _bluetoothManager.homeReadDelegate = self;
    
    [_bluetoothManager connectWithResponseBlock:^(NSError *error, NSString *peripheralName) {
        
        // If the peripheral is connected, show its name on the label
        // If not, a blank string is sent by BluetoothManager
        _modelNameLabel.text = peripheralName;
        [ApplicationManager sharedInstance].deviceName = peripheralName;
        if(error) {
            
        }
    }];
}


#pragma mark - IBActions

- (IBAction)settingsButton_TouchUpInside:(id)sender {
    
    [UIView animateWithDuration:0.5 animations:^{
       _settingsButton.transform = CGAffineTransformMakeRotation(M_PI/4);
       [self performSegueWithIdentifier:@"segueToSettingsViewController" sender:self];
    }];
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    
    UISegmentedControl *senderControl = (UISegmentedControl *)sender;
    
    _fltPlanContainerView.hidden        = YES;
    _tspContainerView.hidden            = YES;
    _radioContainerView.hidden          = YES;
    _keyboardContainerView.hidden       = YES;
    
    switch (senderControl.selectedSegmentIndex) {
        case 0:
            _keyboardContainerView.hidden = NO;
            break;
        case 1:
            _radioContainerView.hidden = NO;
            break;
        case 2:
            _tspContainerView.hidden = NO;
            break;
        case 3:
            _fltPlanContainerView.hidden = NO;
            break;
        default:
            break;
    }
}


#pragma mark - View Lyfecycle

- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self updateThemeAsPerSettings];
    [self setupBLEConnection];
    
    _utility = [[Utility alloc] init];
    _allKeys = [[NSMutableArray alloc] init];
    _keyHexConverter = [[KeyHexConverter alloc] init];
    
    [_utility getAllButtonsFromView:_topView withComplitionBlock:^(NSArray *keysArray) {
        if([keysArray count]) {
            _allKeys = [NSMutableArray arrayWithArray:keysArray];
            NSLog(@"All Keys Count: %d", _allKeys.count);
        }
    }];
    
    _utility = [[Utility alloc] init];
    [_utility getAllButtonsFromView:_bottomView withComplitionBlock:^(NSArray *keysArray) {
        
        if([keysArray count]) {
            
            [_allKeys addObjectsFromArray:keysArray];
            NSLog(@"All Keys Count: %d", _allKeys.count);
        }
    }];
    
    
    //Set only KeyboardView visible and others hidden
    _keyboardContainerView.hidden       = NO;
    
    _fltPlanContainerView.hidden        = YES;
    _tspContainerView.hidden            = YES;
    _radioContainerView.hidden          = YES;
    
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]   addObserver:self
                                            selector:@selector(settingsButton_TouchUpInside:)
                                            name:kNotificationSettingsClicked
                                            object:nil];
    
    [[NSNotificationCenter defaultCenter]   addObserver:self
                                            selector:@selector(settingsIconRotateBackToOriginal)
                                            name:kNotificationSettingsViewClosed
                                            object:nil];
    
    [[NSNotificationCenter defaultCenter]   addObserver:self
                                            selector:@selector(updateThemeAsPerSettings)
                                            name:kNotificationSettingsChanged
                                            object:nil];
    
    [[NSNotificationCenter defaultCenter]   addObserver:self
                                            selector:@selector(orientationChanged:)
                                            name:UIDeviceOrientationDidChangeNotification
                                            object:nil];
    
    [[NSNotificationCenter defaultCenter]   addObserver:self
                                            selector:@selector(leftGestureDetected)
                                            name:kNotificationLeftGesture
                                            object:nil];
    
    [[NSNotificationCenter defaultCenter]   addObserver:self
                                            selector:@selector(rightGestureDetected)
                                            name:kNotificationRightGesture
                                            object:nil];
}




@end
