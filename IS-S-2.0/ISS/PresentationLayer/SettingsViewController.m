//
//  SettingsViewController.m
//  ISS
//
//  Created by Anshuman Dahale on 2/24/17.
//  Copyright © 2017 Digvijay Joshi. All rights reserved.
//

#import "SettingsViewController.h"
#import "ApplicationManager.h"
#import "Constants.h"
#import "Enums.h"
#import "AESKeyViewController.h"
#import "Utility.h"

@implementation InvertColorsTableViewCell

- (void)drawRect:(CGRect)rect {
    
    [_invertSwitch setOn:[ApplicationManager sharedInstance].isDarkMode];
}

- (IBAction) invertSwitchValueChanged:(id)sender {
    
    [[ApplicationManager sharedInstance] setIsDarkMode:_invertSwitch.isOn];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSettingsChanged object:nil];
}

@end


@interface SettingsViewController ()

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic) Encryption_Key_Type keyType;

@end

@implementation SettingsViewController


#pragma mark - Table View Data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //For inverting color cell
    if(indexPath.row == 0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"invertColorCellIdentifier"];
        return cell;
    }
    
    //For other normal cells
    if(indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normalCellIdentifier"];
        return cell;
    }
    
    //For other AES Key cell
    if(indexPath.row == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aesKeyCellIdentifier"];
        return cell;
    }
    
    //iv Key
    if(indexPath.row == 3) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ivKeyCellIdentifier"];
        return cell;
    }
    
    //Device name
    if(indexPath.row == 4) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceNameCellIdentifier"];
        cell.textLabel.text = [ApplicationManager sharedInstance].deviceName;
        return cell;
    }
    
    //Build version
    if(indexPath.row == 5) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"buildVersionCellIdentifier"];
        cell.textLabel.text = [Utility getBuildVersion];
        return cell;
    }
    return nil;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Clicked at index: %d", indexPath.row);
    if(indexPath.row == 1) {
        
        [self performSegueWithIdentifier:@"segueToRadioSettings" sender:self];
    }
    //AES Key
    else if(indexPath.row == 2) {
        
        _keyType = Encryption_Key_Type_AES;
        [self performSegueWithIdentifier:@"segueToEncryptionKeyViewController" sender:self];
    }
    //IV Key
    else if (indexPath.row == 3) {
        
        _keyType = Encryption_Key_Type_IV;
        [self performSegueWithIdentifier:@"segueToEncryptionKeyViewController" sender:self];
    }
}


- (IBAction)doneButton_TouchUpInside:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSettingsViewClosed object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)invertKeysSwitch_ValueChanged:(id)sender {
    NSLog(@"Invert key colors");
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.destinationViewController isKindOfClass:[AESKeyViewController class]]) {
        
        AESKeyViewController *viewController = segue.destinationViewController;
        viewController.keyType = _keyType;
    }
}

@end
