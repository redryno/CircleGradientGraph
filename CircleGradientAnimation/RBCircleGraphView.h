//
//  RBCircleGraphView.h
//  CircleGradientAnimation
//
//  Created by Ryan Bigger on 6/17/14.
//  Copyright © 2017 Ryan Bigger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RBCircleGraphView : UIView

@property (assign, nonatomic) CGFloat percentage;

- (void)animate;
- (void)changePercentage:(CGFloat)percentage animated:(BOOL)animated;
- (void)clear;

@end
