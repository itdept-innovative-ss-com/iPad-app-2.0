//
//  RadioSettingsTableViewCell.m
//  ISS
//
//  Created by Anshuman Dahale on 3/1/17.
//  Copyright © 2017 Digvijay Joshi. All rights reserved.
//

#import "RadioSettingsTableViewCell.h"
#import "FrequencyParameters.h"

@implementation RadioSettingsTableViewCell

#pragma mark - TextField Delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if([_textFieldDelegate respondsToSelector:@selector(editingTextFieldRefrence:)]) {
        
        [_textFieldDelegate editingTextFieldRefrence:textField];
    }
    return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSCharacterSet *allowedCharactersSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    BOOL result = [[string stringByTrimmingCharactersInSet:allowedCharactersSet] isEqualToString:@""];
    return result;
}

- (IBAction) textFieldValueChanged:(id)sender {
    
    UITextField *textField = (UITextField *)sender;
    _frequencyParameter.spacing = textField.text;
}

#pragma mark - View Lifecycle

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
