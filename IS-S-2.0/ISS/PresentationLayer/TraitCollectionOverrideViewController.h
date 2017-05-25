//
//  TraitCollectionOverrideViewController.h
//  ISS
//
//  Created by Digvijay Joshi on 5/20/16.
//  Copyright © 2016 Digvijay Joshi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TraitCollectionOverrideViewController : UIViewController
{
    BOOL _willTransitionToPortrait;
    UITraitCollection *_traitCollection_CompactRegular;
    UITraitCollection *_traitCollection_AnyAny;
}
@end
