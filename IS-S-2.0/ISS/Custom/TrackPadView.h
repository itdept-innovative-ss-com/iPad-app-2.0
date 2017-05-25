//
//  TrackPadView.h
//  KeyBoardTest
//
//  Created by Anshuman Dahale on 5/20/16.
//  Copyright © 2016 Silicus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol TouchCoordinatesDelegate <NSObject>
- (void) userTouchedOnPoint:(CGPoint)touchPoint;
@end

@interface TrackPadView : UIView

@property(nonatomic) id<TouchCoordinatesDelegate> touchDelegate;
@property(nonatomic) BOOL hideCoordinatesLabel;
@property(nonatomic) BOOL hideUserTrial;
@property(nonatomic) BOOL hideGrid;

@end
