//
//  TraitCollectionOverrideViewController.m
//  ISS
//
//  Created by Digvijay Joshi on 5/20/16.
//  Copyright © 2016 Digvijay Joshi. All rights reserved.
//

#import "TraitCollectionOverrideViewController.h"

@interface TraitCollectionOverrideViewController ()

@end

@implementation TraitCollectionOverrideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpReferenceSizeClasses];
}

- (void)setUpReferenceSizeClasses {
    UITraitCollection *traitCollection_hCompact = [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassCompact];
    UITraitCollection *traitCollection_vRegular = [UITraitCollection traitCollectionWithVerticalSizeClass:UIUserInterfaceSizeClassRegular];
    _traitCollection_CompactRegular = [UITraitCollection traitCollectionWithTraitsFromCollections:@[traitCollection_hCompact, traitCollection_vRegular]];

    UITraitCollection *traitCollection_hAny = [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassUnspecified];
    UITraitCollection *traitCollection_vAny = [UITraitCollection traitCollectionWithVerticalSizeClass:UIUserInterfaceSizeClassUnspecified];
    _traitCollection_AnyAny = [UITraitCollection traitCollectionWithTraitsFromCollections:@[traitCollection_hAny, traitCollection_vAny]];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _willTransitionToPortrait = self.view.frame.size.height > self.view.frame.size.width;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    _willTransitionToPortrait = size.height > size.width;
}

- (UITraitCollection *)overrideTraitCollectionForChildViewController:(UIViewController *)childViewController {
    if (CGRectGetWidth(self.view.bounds) < CGRectGetHeight(self.view.bounds)) {
        return [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassCompact];
    } else {
        return [UITraitCollection traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassRegular];
    }
}

@end
