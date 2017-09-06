//
//  SFCircleGraphView.m
//  CircleGradientAnimation
//
//  Created by Ryan Bigger on 6/17/14.
//  Copyright © 2017 Ryan Bigger. All rights reserved.
//

#import "SFCircleGraphView.h"

static const CGFloat speed = 0.03333;

@implementation SFCircleGraphView
{
    BOOL _compressedLayout;
    
    NSInteger      _percentIndex;
    CGRect         _graphRect;
    UILabel      * _labelOverall;
    UILabel      * _labelPercent;
    UILabel      * _labelSymbol;
    CAShapeLayer * _layerMask;
    CAShapeLayer * _layerShadow;
    UIView       * _viewInsideCircle;
    UIView       * _viewPathCircle;
    NSMutableArray * _percentValues;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)setup
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.frame = CGRectMake(0.0, 0.0, screenRect.size.width, screenRect.size.height - 210.0);
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    
    _compressedLayout = (screenRect.size.height < 568);
    if (_compressedLayout) {
        _graphRect = CGRectMake(57.0, 45.0, 205.0, 205.0);
    } else {
        _graphRect = CGRectMake(32.0, 66.0, 255.0, 255.0);
    }
    
    // Percentage graph
    [self percentageCircles];
    [self percentageLabels];
    [self percentageGradientView];
}

- (void)setPercentage:(CGFloat)percentage
{
    _percentage = percentage;
    
    // Change the size of the text
    NSDictionary *labelInfo = [self percentageLabelInfo];
    
    NSString *percentText = [labelInfo objectForKey:@"percentText"];
    NSDictionary *percentAttributes = [labelInfo objectForKey:@"percentAttributes"];
    CGRect rectPercent = [[labelInfo objectForKey:@"percentRect"] CGRectValue];
    
    _labelPercent.attributedText = [[NSAttributedString alloc] initWithString:percentText attributes:percentAttributes];
    _labelPercent.frame = rectPercent;
    
    NSDictionary *symbolAttributes = [labelInfo objectForKey:@"symbolAttributes"];
    CGRect rectSymbol  = [[labelInfo objectForKey:@"symbolRect"] CGRectValue];
    _labelSymbol.attributedText = [[NSAttributedString alloc] initWithString:@"%" attributes:symbolAttributes];
    _labelSymbol.frame = rectSymbol;
}

- (void)changePercentage:(CGFloat)percentage animated:(BOOL)animated
{
    if (self.didAnimateGraph == YES) {
        [self changePercentage:percentage animated:animated completion:nil];
    } else {
        self.percentage = percentage;
    }
}

- (void)changePercentage:(CGFloat)percentage animated:(BOOL)animated completion:(void(^)())completion
{
    if (animated) {
        // Change the size of the arc
        CABasicAnimation *arcAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        arcAnimation.fromValue = [NSNumber numberWithFloat:_layerMask.strokeEnd];
        arcAnimation.toValue = [NSNumber numberWithFloat:percentage];
        arcAnimation.duration = 0.3;
        
        _layerMask.strokeEnd = percentage;
        [_layerMask addAnimation:arcAnimation forKey:@"arcGradient"];
        
        _layerShadow.strokeEnd = percentage;
        [_layerShadow addAnimation:arcAnimation forKey:@"arcShadow"];
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             _labelPercent.alpha = 0.0f;
                             _labelSymbol.alpha = 0.0f;
                         } completion:^(BOOL finished) {
                             self.percentage = percentage;
                             [UIView animateWithDuration:0.2
                                                   delay:0.1
                                                 options:UIViewAnimationOptionCurveLinear
                                              animations:^{
                                                  _labelPercent.alpha = 1.0f;
                                                  _labelSymbol.alpha  = 1.0f;
                                              } completion:^(BOOL finished) {
                                                  if (completion != nil) {
                                                      completion();
                                                  }
                                              }];
                         }];
    } else {
        [CATransaction setDisableActions:YES];
        _layerMask.strokeEnd = percentage;
        _layerShadow.strokeEnd = percentage;
        [CATransaction setDisableActions:NO];
        
        self.percentage = percentage;
    }
}

#pragma mark - Add Views & Labels

- (void)percentageCircles
{
    CGFloat solidInset, dashedInset;
    if (_compressedLayout) {
        solidInset = 12.0;
        dashedInset = 33.0;
    } else {
        solidInset = 15.0;
        dashedInset = 39.0;
    }
    
    CGRect solidViewRect = CGRectInset(_graphRect, solidInset, solidInset);
    CGRect solidLayerRect = CGRectMake(0.0, 0.0, solidViewRect.size.width, solidViewRect.size.height);
    CGMutablePathRef solidPath = CGPathCreateMutable();
    CGPathAddEllipseInRect(solidPath, nil, solidLayerRect);
    
    _viewPathCircle = [[UIView alloc] initWithFrame:solidViewRect];
    _viewPathCircle.alpha = 0.0;
    [self addSubview:_viewPathCircle];
    
    CAShapeLayer *solidCircle = [CAShapeLayer layer];
    solidCircle.fillColor = [UIColor clearColor].CGColor;
    solidCircle.frame = solidLayerRect;
    solidCircle.lineWidth = 0.5f;
    solidCircle.path = solidPath;
    solidCircle.shadowOffset = CGSizeMake(0.0, 10.0);
    solidCircle.shadowOpacity = 0.2;
    solidCircle.strokeColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
    [_viewPathCircle.layer addSublayer:solidCircle];
    CGPathRelease(solidPath);
    
    // Dotted path line
    CGRect dashedViewRect = CGRectInset(_graphRect, dashedInset, dashedInset);
    CGRect dashedLayerRect = CGRectMake(0.0, 0.0, dashedViewRect.size.width, dashedViewRect.size.height);
    CGMutablePathRef dashedPath = CGPathCreateMutable();
    CGPathAddEllipseInRect(dashedPath, nil, dashedLayerRect);
    
    _viewInsideCircle = [[UIView alloc] initWithFrame:dashedViewRect];
    _viewInsideCircle.alpha = 0.0;
    [self addSubview:_viewInsideCircle];
    
    CAShapeLayer *dashedCircle = [CAShapeLayer layer];
    dashedCircle.fillColor = [UIColor clearColor].CGColor;
    dashedCircle.frame = dashedLayerRect;
    dashedCircle.lineDashPattern = @[@1, @2];
    dashedCircle.lineWidth = 0.5f;
    dashedCircle.path = dashedPath;
    dashedCircle.shadowOffset = CGSizeMake(0.0, 10.0);
    dashedCircle.shadowOpacity = 0.2;
    dashedCircle.strokeColor = UIColor.whiteColor.CGColor; // [UIColor colorWithRed:0.4118 green:0.4549 blue:0.4667 alpha:1.0000].CGColor;
    [_viewInsideCircle.layer addSublayer:dashedCircle];
    CGPathRelease(dashedPath);
}

- (NSDictionary *)percentageLabelInfo
{
    CGFloat percentTextWidth, percentFontSize, symbolFontSize;
    if (_compressedLayout) {
        percentTextWidth = 117.0;
        percentFontSize = 69.0;
        symbolFontSize = 40.0;
    } else {
        percentTextWidth = 147.0;
        percentFontSize = 87.0;
        symbolFontSize = 50.0;
    }
    
    NSDictionary *percentAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:percentFontSize weight:UIFontWeightLight],
                                        NSKernAttributeName : @1};
    NSDictionary *symbolAttributes  = @{NSFontAttributeName : [UIFont systemFontOfSize:symbolFontSize weight:UIFontWeightLight],
                                        NSKernAttributeName : @1};
    
    NSString *percentText = [NSString stringWithFormat:@"%0.0f", MIN(_percentage, 1.0) * 100.0];
    CGSize percentSize = [percentText sizeWithAttributes:percentAttributes];
    CGSize symbolSize  = [@"%" sizeWithAttributes:symbolAttributes];
    CGFloat halfTextWidth = (percentSize.width + symbolSize.width) / 2;
    
    // Add the label to display the percentage
    CGRect rectPercent = CGRectZero;
    rectPercent.size.width = percentTextWidth;
    rectPercent.size.height = percentSize.height;
    rectPercent.origin.x = (self.frame.size.width / 2) - (percentTextWidth - (percentSize.width - halfTextWidth));
    rectPercent.origin.y = floorf(CGRectGetMidY(_graphRect)) - (percentSize.height / 2) - 4.0;
    rectPercent = CGRectIntegral(rectPercent);
    
    // Add the label to display the percent symbol
    CGRect rectSymbol = CGRectZero;
    rectSymbol.size.width = symbolSize.width;
    rectSymbol.size.height = symbolSize.height;
    rectSymbol.origin.x = (self.frame.size.width / 2) + (halfTextWidth - symbolSize.width);
    rectSymbol.origin.y = floorf(CGRectGetMidY(_graphRect)) - (symbolSize.height / 2) + 6.0;
    rectSymbol = CGRectIntegral(rectSymbol);
    
    return @{@"percentText" : percentText,
             @"percentAttributes" : percentAttributes,
             @"symbolAttributes"  : symbolAttributes,
             @"percentRect" : [NSValue valueWithCGRect:rectPercent],
             @"symbolRect"  : [NSValue valueWithCGRect:rectSymbol]};
}

- (void)percentageLabels
{
    CGFloat overallFontSize, overallPosition;
    if (_compressedLayout) {
        overallFontSize = 15.0;
        overallPosition = 170.0;
    } else {
        overallFontSize = 19.0;
        overallPosition = 226.0;
    }
    
    // Add the label to display the percentage
    _labelPercent = [[UILabel alloc] init];
    _labelPercent.backgroundColor = UIColor.darkGrayColor;
    _labelPercent.alpha = 0.0;
    _labelPercent.textAlignment = NSTextAlignmentRight;
    _labelPercent.textColor = [UIColor whiteColor];
    _labelPercent.layer.anchorPoint = CGPointMake(1.0, 0.5);
    _labelPercent.layer.shadowOffset = CGSizeMake(0.0, 10.0);
    _labelPercent.layer.shadowOpacity = 0.2;
    [self addSubview:_labelPercent];
    
    // Add the label to display the percent symbol
    _labelSymbol = [[UILabel alloc] init];
    _labelSymbol.backgroundColor = UIColor.orangeColor;
    _labelSymbol.alpha = 0.0;
    _labelSymbol.textAlignment = NSTextAlignmentLeft;
    _labelSymbol.textColor = [UIColor whiteColor];
    _labelSymbol.layer.shadowOffset = CGSizeMake(0.0, 10.0);
    _labelSymbol.layer.shadowOpacity = 0.2;
    [self addSubview:_labelSymbol];
    
    // Add the label for the overall text
    NSDictionary *overallAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:overallFontSize weight:UIFontWeightLight],
                                        NSKernAttributeName : @3};
    
    _labelOverall = [[UILabel alloc] initWithFrame:CGRectMake(60.0, overallPosition, 200.0, 21.0)];
    _labelOverall.alpha = 0.0;
    _labelOverall.attributedText = [[NSAttributedString alloc] initWithString:_graphTitle attributes:overallAttributes];
    _labelOverall.textAlignment = NSTextAlignmentCenter;
    _labelOverall.textColor = [UIColor whiteColor];
    _labelOverall.layer.shadowOffset = CGSizeMake(0.0, 10.0);
    _labelOverall.layer.shadowOpacity = 0.2;
    [self addSubview:_labelOverall];
}

- (void)percentageGradientView
{
    UIView *viewContainer = [[UIView alloc] initWithFrame:_graphRect];
    [self addSubview:viewContainer];
    
    UIImage *imageCircle;
    CGFloat circleWidth;
    if (_compressedLayout) {
        imageCircle = [UIImage imageNamed:@"progress_circle_small.png"];
        circleWidth = 24.0;
    } else {
        imageCircle = [UIImage imageNamed:@"Gradient Circle"];
        circleWidth = 30.0;
    }
    CGFloat inset = (circleWidth / 2.0);
    
    CGRect aRect = CGRectMake(0.0, 0.0, _graphRect.size.width, _graphRect.size.height);
    CGPathRef aPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(aRect, inset, inset)].CGPath;
    
    _layerMask = [CAShapeLayer layer];
    _layerMask.fillColor = [UIColor clearColor].CGColor;
    _layerMask.frame = aRect;
    _layerMask.lineWidth = circleWidth;
    _layerMask.path = aPath;
    _layerMask.strokeColor = [UIColor blackColor].CGColor;
    _layerMask.strokeStart = 0.0;
    _layerMask.strokeEnd = 0.0;
    _layerMask.transform = CATransform3DMakeRotation(-M_PI_2, 0, 0, 1.0);
    
    _layerShadow = [CAShapeLayer layer];
    _layerShadow.fillColor = [UIColor clearColor].CGColor;
    _layerShadow.frame = aRect;
    _layerShadow.lineWidth = circleWidth;
    _layerShadow.path = aPath;
    _layerShadow.strokeColor = [UIColor colorWithRed:0.147020 green:0.197157 blue:0.211765 alpha:1.0].CGColor;
    _layerShadow.strokeStart = 0.0;
    _layerShadow.strokeEnd = 0.0;
    _layerShadow.shadowOpacity = 0.2;
    _layerShadow.shadowOffset = CGSizeMake(-10.0, 0.0);
    _layerShadow.transform = CATransform3DMakeRotation(-M_PI_2, 0, 0, 1.0);
    [viewContainer.layer addSublayer:_layerShadow];
    
    CALayer* layerImage = [CALayer layer];
    layerImage.contents = (id)imageCircle.CGImage;
    layerImage.frame = aRect;
    layerImage.mask = _layerMask;
    [viewContainer.layer addSublayer:layerImage];
}

#pragma mark - Animations

float EaseOutBackx(float p)
{
	float f = (1 - p);
	return 1 - (f * f * f - f * (sin(f * M_PI) * 0.35));
}

- (CAKeyframeAnimation *)animationArcToValue:(CGFloat)toValue
{
    NSUInteger KeyframeCount = 60;
    
	NSMutableArray *values = [NSMutableArray arrayWithCapacity:KeyframeCount];
	CGFloat t = 0.0;
	CGFloat dt = 1.0 / (KeyframeCount - 1);
	for (size_t frame = 0; frame < KeyframeCount; ++frame, t += dt) {
		CGFloat value = EaseOutBackx(t) * toValue;
		[values addObject:[NSNumber numberWithFloat:value]];
	}
    
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
	[animation setValues:values];
    
	return animation;
}

- (CAKeyframeAnimation *)animationView:(UIView *)view scale:(CGFloat)scale keyTime:(CGFloat)keyTime duration:(CGFloat)duration
{
    CATransform3D startingScale = CATransform3DScale(view.layer.transform, 0, 0, 0);
    CATransform3D overshootScale = CATransform3DScale(view.layer.transform, scale, scale, 1.0);
    CATransform3D endingScale = view.layer.transform;
    
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.values = @[[NSValue valueWithCATransform3D:startingScale],
                              [NSValue valueWithCATransform3D:overshootScale],
                              [NSValue valueWithCATransform3D:endingScale]];
    scaleAnimation.keyTimes = @[@0.0f, [NSNumber numberWithFloat:keyTime], @1.0f];
    scaleAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    scaleAnimation.duration = duration;
    
    return scaleAnimation;
}

- (void)animateNumbers
{
    if (_percentIndex == 0) {
        NSUInteger KeyframeCount = 12;
        _percentValues = [NSMutableArray arrayWithCapacity:KeyframeCount];
        CGFloat t = 0.0;
        CGFloat dt = 1.0 / (KeyframeCount - 1);
        for (size_t frame = 0; frame < KeyframeCount; ++frame, t += dt) {
            CGFloat value = MIN(EaseOutBackx(t) * _percentage, 1.0);
            [_percentValues addObject:[NSNumber numberWithFloat:value]];
        }
    }
    
    CGFloat percentFontSize = (_compressedLayout) ? 69.0 : 87.0;
    NSDictionary *percentAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:percentFontSize weight:UIFontWeightLight],
                                        NSKernAttributeName : @1};
    
    CGFloat display = [[_percentValues objectAtIndex:_percentIndex] floatValue] * 100.0;
    
    NSString *percentText = [NSString stringWithFormat:@"%0.0f", display];
    _labelPercent.attributedText = [[NSAttributedString alloc] initWithString:percentText attributes:percentAttributes];
    _percentIndex++;
    if (_percentIndex < _percentValues.count) {
        [self performSelector:@selector(animateNumbers) withObject:nil afterDelay:0.12];
    }
}

- (void)animateGraph
{
    if (_didAnimateGraph == NO) {
        
        // Animate path circle view
        CGFloat duration = speed * 15;
        CAKeyframeAnimation *pathAnimation = [self animationView:_viewPathCircle scale:1.04 keyTime:0.733 duration:duration];
        _viewPathCircle.alpha = 1.0;
        [_viewPathCircle.layer addAnimation:pathAnimation forKey:@"pathCircle"];
        
        // Animate inside circle view
        CGFloat delay = speed * 6;
        duration = speed * 17;
        CAKeyframeAnimation *insideAnimation = [self animationView:_viewInsideCircle scale:1.11 keyTime:0.667 duration:duration];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _viewInsideCircle.alpha = 1.0;
            [_viewInsideCircle.layer addAnimation:insideAnimation forKey:@"innerCircle"];
        });
        
        // Animate percentage arc
        delay = speed * 8;
        CAKeyframeAnimation *arcAnimation = [self animationArcToValue:_percentage];
        arcAnimation.duration = speed * 46;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _layerMask.strokeEnd = _percentage;
            [_layerMask addAnimation:arcAnimation forKey:@"arcGradient"];
            
            _layerShadow.strokeEnd = _percentage;
            [_layerShadow addAnimation:arcAnimation forKey:@"arcShadow"];
        });
        
        delay = speed * 7;
        duration = speed * 12;
        CAKeyframeAnimation *overallAnimation = [self animationView:_labelOverall scale:1.19 keyTime:0.583 duration:duration];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _labelOverall.alpha = 1.0;
            [_labelOverall.layer addAnimation:overallAnimation forKey:@"overall"];
            _percentIndex = 0;
            [self animateNumbers];
        });
        
        delay = speed * 19;
        duration = speed * 10;
        CAKeyframeAnimation *percentAnimation = [self animationView:_labelPercent scale:1.06 keyTime:0.7 duration:duration];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _labelPercent.alpha = 1.0;
            [_labelPercent.layer addAnimation:percentAnimation forKey:@"percent"];
        });
        
        delay = speed * 21;
        duration = speed * 9;
        CAKeyframeAnimation *symbolAnimation = [self animationView:_labelSymbol scale:1.11 keyTime:0.556 duration:duration];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _labelSymbol.alpha = 1.0;
            [_labelSymbol.layer addAnimation:symbolAnimation forKey:@"symbol"];
        });
    }
    _didAnimateGraph = YES;
}

#pragma mark - Reset properties

- (void)clearGraph
{
    _didAnimateGraph = NO;
    
    _viewPathCircle.alpha = 0.0;
    _viewInsideCircle.alpha = 0.0;
    _labelOverall.alpha = 0.0;
    _labelPercent.alpha = 0.0;
    _labelSymbol.alpha = 0.0;
    
    [CATransaction setDisableActions:YES];
    _layerMask.strokeEnd = 0.0;
    _layerShadow.strokeEnd = 0.0;
    [CATransaction setDisableActions:NO];
}

@end
