//
//  AESKeyViewController.m
//  ISS
//
//  Created by Anshuman Dahale on 3/16/17.
//  Copyright © 2017 Digvijay Joshi. All rights reserved.
//

#import "AESKeyViewController.h"
#import "ApplicationManager.h"
#import "Constants.h"

@interface AESKeyViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation AESKeyViewController


#pragma mark - IBAction
- (IBAction)doneButton_TouchUpInside:(id)sender {
    
    NSArray *words = [_textView.text componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *newKey = [words componentsJoinedByString:@""];
    
    if(_keyType == Encryption_Key_Type_AES) {
        [[NSUserDefaults standardUserDefaults] setValue:newKey forKey:kUserDefaultsAESKey];
    }
    else if (_keyType == Encryption_Key_Type_IV) {
        [[NSUserDefaults standardUserDefaults] setValue:newKey forKey:kUserDefaultsIVKey];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //3746A0A333656E2A45154567ED5F665B
    
    if(_keyType == Encryption_Key_Type_AES) {
        
        self.title = @"AES  Key";
        _textView.text = [ApplicationManager sharedInstance].aesKey;
    }
    else if (_keyType == Encryption_Key_Type_IV) {
        
        self.title = @"IV Key";
        _textView.text = [ApplicationManager sharedInstance].ivKey;
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    [_textView resignFirstResponder];
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
