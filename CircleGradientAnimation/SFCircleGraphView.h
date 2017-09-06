//
//  SFCircleGraphView.h
//  CircleGradientAnimation
//
//  Created by Ryan Bigger on 6/17/14.
//  Copyright © 2017 Ryan Bigger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFCircleGraphView : UIView

@property (assign, nonatomic) BOOL didAnimateGraph;
@property (assign, nonatomic) CGFloat percentage;
@property (strong, nonatomic) NSString *graphTitle;

- (void)animateGraph;
- (void)changePercentage:(CGFloat)percentage animated:(BOOL)animated;
- (void)changePercentage:(CGFloat)percentage animated:(BOOL)animated completion:(void(^)())completion;
- (void)clearGraph;

@end
