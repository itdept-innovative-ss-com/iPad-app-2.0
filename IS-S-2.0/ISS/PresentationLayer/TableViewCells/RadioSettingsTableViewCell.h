//
//  RadioSettingsTableViewCell.h
//  ISS
//
//  Created by Anshuman Dahale on 3/1/17.
//  Copyright © 2017 Digvijay Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FrequencyParameters;

@protocol RadioSettingTableCellProtocol <NSObject>

@optional
- (void) editingTextFieldRefrence:(UITextField *)textField;

@end


@interface RadioSettingsTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UITextField *valueTextField;
@property (nonatomic, strong) FrequencyParameters *frequencyParameter;
@property (nonatomic) id<RadioSettingTableCellProtocol>textFieldDelegate;

@end
