//
//  RadioSettingViewController.m
//  ISS
//
//  Created by Anshuman Dahale on 2/28/17.
//  Copyright © 2017 Digvijay Joshi. All rights reserved.
//

#import "RadioSettingViewController.h"
#import "RadioSettingsTableViewCell.h"
#import "FrequencyParameters.h"
#import "ApplicationManager.h"

@interface RadioSettingViewController () <RadioSettingTableCellProtocol>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) FrequencyParameters *comFreq, *navFreq, *adfFreq;
@property (nonatomic, strong) NSArray *frequencies;
@property (nonatomic, strong) UITextField *editingTextField;

@end

@implementation RadioSettingViewController

#pragma mark - RadioSettingTableCellProtocol
- (void) editingTextFieldRefrence:(UITextField *)textField {
    
    _editingTextField = textField;
}


#pragma mark - Table View DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSArray *sectionTitles = @[@"Spacing"];
    return [sectionTitles objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RadioSettingsTableViewCell *cell = (RadioSettingsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"radioCellIdentifier"];
    NSArray *nameLabelTitles = @[@"COM Frequency", @"NAV Frequency", @"ADF Frequency"];
    cell.nameLabel.text = [nameLabelTitles objectAtIndex:indexPath.row];
    
    //COM Frequency section
    
    if(indexPath.row == 0) {
        cell.frequencyParameter = _comFreq;
        cell.valueTextField.text = _comFreq.spacing;
    }
    if(indexPath.row == 1) {
        cell.frequencyParameter = _navFreq;
        cell.valueTextField.text = _navFreq.spacing;
    }
    if(indexPath.row == 2) {
        cell.frequencyParameter = _adfFreq;
        cell.valueTextField.text = _adfFreq.spacing;
    }
    return cell;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *comSpacing = [ApplicationManager sharedInstance].comSpacing;
    NSString *navSpacing = [ApplicationManager sharedInstance].navSpacing;
    NSString *adfSpacing = [ApplicationManager sharedInstance].adfSpacing;
    
    
    _comFreq = [[FrequencyParameters alloc] init];
    _comFreq.min = @"118.000";
    _comFreq.max = @"136.000";
    _comFreq.spacing = comSpacing;
    
    _navFreq = [[FrequencyParameters alloc] init];
    _navFreq.min = @"108.000";
    _navFreq.max = @"117.95";
    _navFreq.spacing = navSpacing;
    
    _adfFreq = [[FrequencyParameters alloc] init];
    _adfFreq.min = @"190";
    _adfFreq.max = @"1799";
    _adfFreq.spacing = adfSpacing;
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [_editingTextField resignFirstResponder];
    
    [ApplicationManager sharedInstance].comSpacing = _comFreq.spacing;
    [ApplicationManager sharedInstance].navSpacing = _navFreq.spacing;
    [ApplicationManager sharedInstance].adfSpacing = _adfFreq.spacing;
    
    [super viewWillDisappear:animated];
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
