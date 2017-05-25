//
//  SettingsViewController.h
//  ISS
//
//  Created by Anshuman Dahale on 2/24/17.
//  Copyright © 2017 Digvijay Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvertColorsTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UISwitch *invertSwitch;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end


@interface SettingsViewController : UIViewController

@end
