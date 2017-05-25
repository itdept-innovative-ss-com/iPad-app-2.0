//
//  RadioViewController.m
//  ISS
//
//  Created by Anshuman Dahale on 2/22/17.
//  Copyright © 2017 Digvijay Joshi. All rights reserved.
//

#import "RadioViewController.h"
#import "ApplicationManager.h"
#import "Utility.h"
#import "Enums.h"
#import "Constants.h"
#import "BluetoothManager.h"
#import "SMVerticalSegmentedControl.h"
#import "KeyHexConverter.h"
#import "FrequencyParameters.h"

#define AdfMin2 2180.0
#define AdfMax2 2189.0


@interface RadioViewController () <ReadResponseDelegate>

@property (nonatomic, strong) FrequencyParameters *com1Freq;
@property (nonatomic, strong) FrequencyParameters *com2Freq;
@property (nonatomic, strong) FrequencyParameters *nav1Freq;
@property (nonatomic, strong) FrequencyParameters *nav2Freq;
@property (nonatomic, strong) FrequencyParameters *adfFreq;

@property (nonatomic) NSInteger selectedFreq;

@property (nonatomic, strong) Utility *utility;
@property (nonatomic, strong) BluetoothManager *bluetoothManager;
@property (nonatomic, strong) KeyHexConverter *keyHexConverter;

@property (nonatomic, strong) NSMutableArray *allKeys;
@property (nonatomic, strong) NSMutableArray *frequencyArray;

@property (nonatomic, strong) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UILabel *frequencyLabel, *comFreqLabel, *mhzLabel;
@property (strong, nonatomic) IBOutlet UIView *frequencySelectionView;
@property (nonatomic, strong) SMVerticalSegmentedControl *freqSegmentControl;

@end

@implementation RadioViewController

#pragma mark - IBActions
- (IBAction)settingsButton_TouchUpInside:(id)sender {
    
    [UIView animateWithDuration:0.5 animations:^{
        
        _settingsButton.transform = CGAffineTransformMakeRotation(M_PI/4);
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSettingsClicked object:nil];
    }];
}

- (void) segmentControl_ValueChanged:(NSInteger)selectedSegmentIndex {
    
    _selectedFreq = selectedSegmentIndex;
    FrequencyParameters *frequencyParameter = [_frequencyArray objectAtIndex:_selectedFreq];
    NSString *freq = frequencyParameter.value;
    _frequencyLabel.text = freq;
    
    //ASF has 2 ranges
    if(selectedSegmentIndex == 4) {
        
        //ADF sends signals in KHz so change the label
        _mhzLabel.text = @"KHz";
        
        NSInteger freqInt = [freq integerValue];
        NSInteger fPMin = [frequencyParameter.min integerValue];
        NSInteger fPMax = [frequencyParameter.max integerValue];
        _frequencyLabel.backgroundColor = ((fPMin >=freqInt <= fPMax) && (AdfMin2 >= freqInt <= AdfMax2)) ? [UIColor darkGrayColor] : [UIColor redColor];
    }
    else {
        
        _mhzLabel.text = @"MHz";
        _frequencyLabel.backgroundColor = (freq.length > 0 && ([freq integerValue] < [frequencyParameter.min integerValue] || [freq integerValue] > [frequencyParameter.max integerValue])) ? [UIColor redColor] : [UIColor darkGrayColor];
    }
}

- (IBAction)numericButton_TouchUpInside:(id)sender {
    
}

- (IBAction)sendButton_TouchUpInside:(id)sender {
    
    FrequencyParameters *frequencyParameter = [_frequencyArray objectAtIndex:_selectedFreq];
    
    // Multiply the values with 1000 as these are in MHz and spacing is in KHz
    double value         = [_frequencyLabel.text doubleValue] * 1000;
    int spacing          = [frequencyParameter.spacing integerValue];
    double lowerLimit    = [frequencyParameter.min doubleValue] * 1000;
    double upperLimit    = [frequencyParameter.max doubleValue] * 1000;
    
    
    //ADF Freq has 2 ranges to check
    if(_selectedFreq == 4) {
    
        int freqInt = [_frequencyLabel.text doubleValue];
        double fPMin = [frequencyParameter.min doubleValue];
        double fPMax = [frequencyParameter.max doubleValue];
        
        //its in a valid range
        if(fPMin >=freqInt <= fPMax) {
            
            int remainder = freqInt % spacing;
            
            if(remainder < spacing/2) {
                freqInt = ((freqInt - remainder) < lowerLimit) ? lowerLimit : (freqInt - remainder);
            }
            else {
                freqInt = ((freqInt - remainder + spacing) > upperLimit ? upperLimit : (freqInt - remainder + spacing));
            }
        }
        else if (AdfMin2 >= freqInt <= AdfMax2) {
            
            int remainder = freqInt % spacing;
            
            if(remainder < spacing/2) {
                freqInt = ((freqInt - remainder) < AdfMin2) ? AdfMin2 : (freqInt - remainder);
            }
            else {
                freqInt = ((freqInt - remainder + spacing) > AdfMax2 ? AdfMax2 : (freqInt - remainder + spacing));
            }
        }
        value = freqInt;
    }

    else if(lowerLimit >= value <= upperLimit) {

        int remainder = (int)value % spacing;
        
        if(remainder < spacing/2) {
            value = ((value - remainder) < lowerLimit) ? lowerLimit : (value - remainder);
        }
        else {
            value = ((value - remainder + spacing) > upperLimit ? upperLimit : (value - remainder + spacing));
        }
        //convert the value back to MHz
        value = value / 1000;
    }
    
    NSString *adjustedValue = [NSString stringWithFormat:@"%.3f", value];
    _frequencyLabel.text = adjustedValue;
    [self setFrequency:adjustedValue forSegment:_selectedFreq];
    
    NSArray *keyHexArray = [_utility getKeyCodesForNumericString:adjustedValue];
    [_bluetoothManager writeRadioFrequency:keyHexArray forFrequencyType:_selectedFreq];
}


- (void) getCorrectedFreqForFreq:(double )value min:(double)min max:(double)max spacing:(double)spacing {
    
    
}


#pragma mark - BLE Delegate
- (void) readValueKeyHex:(NSString *)keyHex forState:(Key_State)keyState {
    
}


- (void) settingsIconRotateBackToOriginal {
    
    [UIView animateWithDuration:0.5 animations:^{
        _settingsButton.transform = CGAffineTransformMakeRotation(-M_PI/4);
    }];
}


#pragma mark - Helper

- (void) setFrequency:(NSString *)freq forSegment:(NSInteger)type {

    FrequencyParameters *frequencyParameter = [_frequencyArray objectAtIndex:type];
    frequencyParameter.value = freq;
    _frequencyLabel.text = freq;
    
    //ASF has 2 ranges
    if(type == 4) {
        
        NSInteger freqInt = [freq integerValue];
        NSInteger fPMin = [frequencyParameter.min integerValue];
        NSInteger fPMax = [frequencyParameter.max integerValue];
        _frequencyLabel.backgroundColor = (((freqInt<fPMin)||(freqInt>fPMax)) && ( (freqInt<AdfMin2) || (freqInt>AdfMax2) )) ? [UIColor redColor] : [UIColor darkGrayColor];
    }
    else {
        _frequencyLabel.backgroundColor = (freq.length > 0 && ([freq integerValue] < [frequencyParameter.min integerValue] || [freq integerValue] > [frequencyParameter.max integerValue])) ? [UIColor redColor] : [UIColor darkGrayColor];
    }
}


- (void) updateColorForAllKeys {

    if([ApplicationManager sharedInstance].isDarkMode) {
        
        _comFreqLabel.textColor = [UIColor whiteColor];
        _mhzLabel.textColor = [UIColor whiteColor];
        _frequencyLabel.textColor = [UIColor whiteColor];
        [_settingsButton setImage:[UIImage imageNamed:@"setting-white"] forState:UIControlStateNormal];
        _frequencySelectionView.layer.borderColor = [[UIColor whiteColor] CGColor];
        _freqSegmentControl.textColor = [UIColor whiteColor];
    }
    else {
        _comFreqLabel.textColor = [UIColor blackColor];
        _mhzLabel.textColor = [UIColor blackColor];
        _frequencyLabel.textColor = [UIColor blackColor];
        [_settingsButton setImage:[UIImage imageNamed:@"setting-black"] forState:UIControlStateNormal];
        _frequencySelectionView.layer.borderColor = [[UIColor blackColor] CGColor];
        _freqSegmentControl.textColor = [UIColor blackColor];
    }
    [_freqSegmentControl setNeedsDisplay];
    [self changeKeyColorsForKeysInArray:_allKeys];
}


- (void) changeKeyColorsForKeysInArray:(NSArray *)keysArray {
    
    for(KeyBoardButton *aKey in keysArray) {
        
        NSLog(@"Changing color for: %@", aKey.keyName);
        //Set the delegate to self
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


#pragma mark - UI Placement
- (void) placeVerticalSegment {
    
    _freqSegmentControl = [[SMVerticalSegmentedControl alloc] initWithSectionTitles:@[@"COM1", @"COM2", @"NAV1", @"NAV2", @"ADF"]];
    [_freqSegmentControl setFrame:CGRectMake(   0,
                                                0,
                                                _frequencySelectionView.frame.size.width,
                                                _frequencySelectionView.frame.size.height)];
    
    _freqSegmentControl.selectionIndicatorThickness = 0;
    _freqSegmentControl.selectionStyle = SMVerticalSegmentedControlSelectionStyleBox;
    _freqSegmentControl.selectionIndicatorColor = [UIColor lightGrayColor];
    _freqSegmentControl.selectionBoxBorderWidth = 2;
    _freqSegmentControl.selectionBoxBackgroundColorAlpha = 0.5;
    _freqSegmentControl.textFont = [UIFont systemFontOfSize:20];
    _freqSegmentControl.textAlignment = SMVerticalSegmentedControlTextAlignmentCenter;
    _freqSegmentControl.selectionBoxBorderColorAlpha = 0.7;
    _freqSegmentControl.backgroundColor = [UIColor clearColor];
    
    __block RadioViewController *selfRefrence = self;
    _freqSegmentControl.indexChangeBlock = ^(NSInteger selectedSegmentIndex) {
        
        [selfRefrence segmentControl_ValueChanged:selectedSegmentIndex];
    };
    
    [_frequencySelectionView addSubview:_freqSegmentControl];
}



#pragma mark - KeyBoardButtonDelegate

- (void) userPressedKey:(KeyBoardButton *)pressedKey {
    
    NSLog(@"User pressed: %@", pressedKey.keyName);
    if(pressedKey.keyCategory == Key_Category_Numeric) {
        
        if(_frequencyLabel.text.length < 7) {
            
            //If the user pressed decimal point, check if a decimal already exists. If yes then return
            if([pressedKey.keyName isEqualToString:@"."]) {
                if([_frequencyLabel.text containsString:@"."]) {
                    return;
                }
            }
            _frequencyLabel.text = [_frequencyLabel.text stringByAppendingString:pressedKey.keyName];
            [self setFrequency:_frequencyLabel.text forSegment:_selectedFreq];
        }
    }
    
    else if(pressedKey.keyCategory == Key_Category_KeyBoard_Functional) {
        
        [self volumeKeyPressed:pressedKey];
    }
    
    else {
        if([pressedKey.keyName isEqualToString:@"DELETE"]) {
            
            if(_frequencyLabel.text.length > 0) {
                NSString *frequency = [_frequencyLabel.text substringToIndex:_frequencyLabel.text.length-1];
                _frequencyLabel.text = frequency;
                [self setFrequency:_frequencyLabel.text forSegment:_selectedFreq];
            }
        }
    }
}


- (void) volumeKeyPressed:(KeyBoardButton *)key {
    
    NSString *keyValue = [_keyHexConverter getValueForKey:key.keyName
    category:key.keyCategory];
    
    Key_State state = ([key.keyName isEqualToString:@"KEY_VOL_UP"]) ? Key_State_Highlighted : Key_State_Default;
    
    [_bluetoothManager writeToPeripheralValue:keyValue forState:state withSuccessBlock:^(NSError *error, BOOL success) {
        
    }];
}


- (void) frequenciesSetUp {
    
    _com1Freq           = [[FrequencyParameters alloc] init];
    _com1Freq.min       = @"118";
    _com1Freq.max       = @"136";
    _com1Freq.value     = @"";
    _com1Freq.spacing   = [ApplicationManager sharedInstance].comSpacing;
    
    _com2Freq           = [[FrequencyParameters alloc] init];
    _com2Freq.min       = @"118";
    _com2Freq.max       = @"136";
    _com2Freq.value     = @"";
    _com2Freq.spacing   = [ApplicationManager sharedInstance].comSpacing;
    
    _nav1Freq           = [[FrequencyParameters alloc] init];
    _nav1Freq.min       = @"108";
    _nav1Freq.max       = @"117.95";
    _nav1Freq.value     = @"";
    _nav1Freq.spacing   = [ApplicationManager sharedInstance].navSpacing;
    
    _nav2Freq           = [[FrequencyParameters alloc] init];
    _nav2Freq.min       = @"108";
    _nav2Freq.max       = @"117.95";
    _nav2Freq.value     = @"";
    _nav2Freq.spacing   = [ApplicationManager sharedInstance].navSpacing;
    
    _adfFreq            = [[FrequencyParameters alloc] init];
    _adfFreq.min        = @"190";
    _adfFreq.max        = @"1799";
    _adfFreq.value      = @"";
    _adfFreq.spacing    = [ApplicationManager sharedInstance].navSpacing;
}

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
    
    
    [self placeVerticalSegment];
    
    [self frequenciesSetUp];
    
    _frequencyArray = [NSMutableArray arrayWithArray:@[_com1Freq, _com2Freq, _nav1Freq, _nav2Freq, _adfFreq]];
    _allKeys                = [[NSMutableArray alloc] init];
    _utility                = [[Utility alloc] init];
    _keyHexConverter        = [[KeyHexConverter alloc] init];
    _bluetoothManager       = [BluetoothManager sharedInstance];
    
    _bluetoothManager.radioReadDelegate = self;
    
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
