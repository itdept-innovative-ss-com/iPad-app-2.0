//
//  TrackPadView.m
//  KeyBoardTest
//
//  Created by Anshuman Dahale on 5/20/16.
//  Copyright © 2016 Silicus. All rights reserved.
//

#import "TrackPadView.h"

@interface TrackPadView () {
    
    CGPoint lastPoint;
    BOOL mouseSwiped;
}

@property (nonatomic, strong) IBOutlet UIImageView *drawImageView;
@property (nonatomic, strong) IBOutlet UILabel *coordinateLabel;

@end


@implementation TrackPadView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    if(!_hideCoordinatesLabel) {
        
        self.coordinateLabel = [[UILabel alloc] initWithFrame:CGRectMake
                                                            (0, 0, self.frame.size.width, 10)];
        self.coordinateLabel.alpha = 0.5;
        self.coordinateLabel.font = [UIFont systemFontOfSize:10];
        self.coordinateLabel.textColor = [UIColor blackColor];
        [self addSubview:self.coordinateLabel];
    }
}


- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
//    NSLog(@"Touches began");
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self];
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    
    if(CGRectContainsPoint(self.drawImageView.frame, currentPoint)) {
        
        CGPoint simulatedPoint = [self getSimulatedCoordinatesFromPoint:currentPoint];
        //NSLog(@"(X: %f, Y: %f)", simulatedPoint.x, simulatedPoint.y);
        
        if(!_hideCoordinatesLabel) {
            self.coordinateLabel.text = [NSString stringWithFormat:@"(X:%.2f, Y:%.2f)", simulatedPoint.x, simulatedPoint.y];
            lastPoint = simulatedPoint;
        }
        if([self.touchDelegate respondsToSelector:@selector(userTouchedOnPoint:)]) {
            
            [self.touchDelegate userTouchedOnPoint:lastPoint];
        }
    }
}


- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    //NSLog(@"Touches Ended ");
//    if([self.touchDelegate respondsToSelector:@selector(userTouchedOnPoint:)]) {
//        [self.touchDelegate userTouchedOnPoint:lastPoint];
//    }
}


- (void) showPointOnLabelWithTouch:(UITouch *)touch {
    
}

- (CGPoint) getSimulatedCoordinatesFromPoint:(CGPoint)point {
    
    CGFloat y = -(point.y);
    CGFloat simulatedY = y + (self.frame.size.height / 2);
    
    CGPoint simulatedPoint = CGPointMake(point.x - self.frame.size.width / 2, simulatedY);
    
    CGFloat adjustedX = (NSInteger)(simulatedPoint.x / (self.frame.size.width/200));
    CGFloat adjustedY = (NSInteger)(simulatedPoint.y / (self.frame.size.height/200));
    
    CGPoint adjustedReturnPoint = CGPointMake(adjustedX, adjustedY);
    
    return adjustedReturnPoint;
}


@end
