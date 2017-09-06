//
//  RBCircleGraphView.m
//  CircleGradientAnimation
//
//  Created by Ryan Bigger on 6/17/14.
//  Copyright © 2017 Ryan Bigger. All rights reserved.
//

#import "RBCircleGraphView.h"

static const CGFloat GRAPH_DIAMETER = 280.0;
static const CGFloat GRAPH_SPEED = 0.03333;

@interface RBCircleGraphView()
{
    UIView         *_circlePathView;
    CAShapeLayer   *_maskLayer;
    NSInteger       _percentIndex;
    NSMutableArray *_percentValues;
    CAShapeLayer   *_shadowLayer;
}

@property (strong, nonatomic) IBInspectable NSString *title;
@property (weak, nonatomic) IBOutlet UILabel *symbolLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@end

@implementation RBCircleGraphView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self graphCirclePath];
    [self graphLabels];
    [self graphLayersView];
}

#pragma mark - Graph

- (void)constraintsForView:(UIView *)view diameter:(CGFloat)diameter {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:diameter]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:diameter]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
}

- (void)graphCirclePath {
    CGFloat circlePathDiameter = GRAPH_DIAMETER - 30.0;
    CGRect  circlePathRect = CGRectMake(0.0, 0.0, circlePathDiameter, circlePathDiameter);
    CGMutablePathRef circlePath = CGPathCreateMutable();
    CGPathAddEllipseInRect(circlePath, nil, circlePathRect);
    
    _circlePathView = [[UIView alloc] init];
    _circlePathView.alpha = 0.0;
    _circlePathView.translatesAutoresizingMaskIntoConstraints = false;
    [self addSubview:_circlePathView];
    [self constraintsForView:_circlePathView diameter:circlePathDiameter];
    
    CAShapeLayer *circlePathLayer = [CAShapeLayer layer];
    circlePathLayer.fillColor = [UIColor clearColor].CGColor;
    circlePathLayer.frame = circlePathRect;
    circlePathLayer.lineWidth = 0.5f;
    circlePathLayer.path = circlePath;
    circlePathLayer.shadowOffset = CGSizeMake(0.0, 10.0);
    circlePathLayer.shadowOpacity = 0.2;
    circlePathLayer.strokeColor = [UIColor colorWithWhite:0.9 alpha:1.0].CGColor;
    [_circlePathView.layer addSublayer:circlePathLayer];
    CGPathRelease(circlePath);
}

- (void)graphLabels {
    
    // Label to display the percentage value
    _valueLabel.alpha = 0.0;
    _valueLabel.layer.shadowOffset = CGSizeMake(0.0, 10.0);
    _valueLabel.layer.shadowOpacity = 0.2;
    
    // Label to display the percent symbol
    _symbolLabel.alpha = 0.0;
    _symbolLabel.layer.shadowOffset = CGSizeMake(0.0, 10.0);
    _symbolLabel.layer.shadowOpacity = 0.2;
    
    // Label to display the graph title
    _titleLabel.alpha = 0.0;
    _titleLabel.layer.shadowOffset = CGSizeMake(0.0, 10.0);
    _titleLabel.layer.shadowOpacity = 0.2;
}

- (void)graphLayersView {
    UIView *containerView = [[UIView alloc] init];
    containerView.translatesAutoresizingMaskIntoConstraints = false;
    [self addSubview:containerView];
    [self constraintsForView:containerView diameter:GRAPH_DIAMETER];
    
    UIImage *circleImage = [UIImage imageNamed:@"Gradient Circle"];
    CGFloat lineWidth = 30.0;
    CGFloat inset = (lineWidth / 2.0);
    
    CGRect layerFrame = CGRectMake(0.0, 0.0, GRAPH_DIAMETER, GRAPH_DIAMETER);
    CGPathRef layerPath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(layerFrame, inset, inset)].CGPath;
    
    _maskLayer = [CAShapeLayer layer];
    _maskLayer.fillColor = [UIColor clearColor].CGColor;
    _maskLayer.frame = layerFrame;
    _maskLayer.lineWidth = lineWidth;
    _maskLayer.path = layerPath;
    _maskLayer.strokeColor = [UIColor blackColor].CGColor;
    _maskLayer.strokeEnd = 0.0;
    _maskLayer.strokeStart = 0.0;
    _maskLayer.transform = CATransform3DMakeRotation(-M_PI_2, 0, 0, 1.0);
    
    _shadowLayer = [CAShapeLayer layer];
    _shadowLayer.fillColor = [UIColor clearColor].CGColor;
    _shadowLayer.frame = layerFrame;
    _shadowLayer.lineWidth = lineWidth;
    _shadowLayer.path = layerPath;
    _shadowLayer.strokeColor = UIColor.darkGrayColor.CGColor;
    _shadowLayer.strokeEnd = 0.0;
    _shadowLayer.strokeStart = 0.0;
    _shadowLayer.shadowOffset = CGSizeMake(-10.0, 0.0);
    _shadowLayer.shadowOpacity = 0.2;
    _shadowLayer.transform = CATransform3DMakeRotation(-M_PI_2, 0, 0, 1.0);
    [containerView.layer addSublayer:_shadowLayer];
    
    CALayer* imageLayer = [CALayer layer];
    imageLayer.contents = (id)circleImage.CGImage;
    imageLayer.frame = layerFrame;
    imageLayer.mask = _maskLayer;
    [containerView.layer addSublayer:imageLayer];
}

#pragma mark - Animations

float EaseOutBack(float p) {
    float f = (1 - p);
    return 1 - (f * f * f - f * (sin(f * M_PI) * 0.35));
}

- (CAKeyframeAnimation *)animationArcToValue:(CGFloat)toValue {
    NSUInteger KeyframeCount = 60;
    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:KeyframeCount];
    CGFloat t = 0.0;
    CGFloat dt = 1.0 / (KeyframeCount - 1);
    for (size_t frame = 0; frame < KeyframeCount; ++frame, t += dt) {
        CGFloat value = EaseOutBack(t) * toValue;
        [values addObject:[NSNumber numberWithFloat:value]];
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    [animation setValues:values];
    
    return animation;
}

- (CAKeyframeAnimation *)animationView:(UIView *)view scale:(CGFloat)scale keyTime:(CGFloat)keyTime duration:(CGFloat)duration {
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

- (void)animateNumbers {
    if (_percentIndex == 0) {
        NSUInteger KeyframeCount = 12;
        _percentValues = [NSMutableArray arrayWithCapacity:KeyframeCount];
        CGFloat t = 0.0;
        CGFloat dt = 1.0 / (KeyframeCount - 1);
        for (size_t frame = 0; frame < KeyframeCount; ++frame, t += dt) {
            CGFloat value = MIN(EaseOutBack(t) * _percentage, 1.0);
            [_percentValues addObject:[NSNumber numberWithFloat:value]];
        }
    }
    
    CGFloat display = [[_percentValues objectAtIndex:_percentIndex] floatValue] * 100.0;
    _valueLabel.text = [NSString stringWithFormat:@"%0.0f", display];
    _percentIndex++;
    if (_percentIndex < _percentValues.count) {
        [self performSelector:@selector(animateNumbers) withObject:nil afterDelay:0.12];
    }
}

- (void)animate {
    if (_circlePathView.alpha > 0) {
        // Graph is already visible
        return;
    }
    
    // Animate path circle view
    CGFloat duration = GRAPH_SPEED * 15;
    CAKeyframeAnimation *pathAnimation = [self animationView:_circlePathView scale:1.04 keyTime:0.733 duration:duration];
    _circlePathView.alpha = 1.0;
    [_circlePathView.layer addAnimation:pathAnimation forKey:@"pathCircle"];
    
    // Animate percentage arc
    CGFloat delay = GRAPH_SPEED * 8;
    CAKeyframeAnimation *arcAnimation = [self animationArcToValue:_percentage];
    arcAnimation.duration = GRAPH_SPEED * 46;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _maskLayer.strokeEnd = _percentage;
        [_maskLayer addAnimation:arcAnimation forKey:@"arcGradient"];
        
        _shadowLayer.strokeEnd = _percentage;
        [_shadowLayer addAnimation:arcAnimation forKey:@"arcShadow"];
    });
    
    delay = GRAPH_SPEED * 7;
    duration = GRAPH_SPEED * 12;
    CAKeyframeAnimation *overallAnimation = [self animationView:_titleLabel scale:1.19 keyTime:0.583 duration:duration];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _titleLabel.alpha = 1.0;
        [_titleLabel.layer addAnimation:overallAnimation forKey:@"overall"];
        _percentIndex = 0;
        [self animateNumbers];
    });
    
    delay = GRAPH_SPEED * 19;
    duration = GRAPH_SPEED * 10;
    CAKeyframeAnimation *percentAnimation = [self animationView:_valueLabel scale:1.06 keyTime:0.7 duration:duration];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _valueLabel.alpha = 1.0;
        [_valueLabel.layer addAnimation:percentAnimation forKey:@"percent"];
    });
    
    delay = GRAPH_SPEED * 21;
    duration = GRAPH_SPEED * 9;
    CAKeyframeAnimation *symbolAnimation = [self animationView:_symbolLabel scale:1.11 keyTime:0.556 duration:duration];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _symbolLabel.alpha = 1.0;
        [_symbolLabel.layer addAnimation:symbolAnimation forKey:@"symbol"];
    });
}

#pragma mark - Modify

- (void)changePercentage:(CGFloat)percentage animated:(BOOL)animated {
    if (animated) {
        // Change the size of the arc
        CABasicAnimation *arcAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        arcAnimation.fromValue = [NSNumber numberWithFloat:_maskLayer.strokeEnd];
        arcAnimation.toValue = [NSNumber numberWithFloat:percentage];
        arcAnimation.duration = 0.3;
        
        _maskLayer.strokeEnd = percentage;
        [_maskLayer addAnimation:arcAnimation forKey:@"arcGradient"];
        
        _shadowLayer.strokeEnd = percentage;
        [_shadowLayer addAnimation:arcAnimation forKey:@"arcShadow"];
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.valueLabel.alpha = 0.0f;
                             self.symbolLabel.alpha = 0.0f;
                         } completion:^(BOOL finished) {
                             
                             self.valueLabel.text = [NSString stringWithFormat:@"%0.0f", (percentage * 100.0)];
                             self.percentage = percentage;
                             
                             [UIView animateWithDuration:0.2
                                                   delay:0.1
                                                 options:UIViewAnimationOptionCurveLinear
                                              animations:^{
                                                  _valueLabel.alpha = 1.0f;
                                                  _symbolLabel.alpha  = 1.0f;
                                              } completion:nil];
                         }];
    } else {
        [CATransaction setDisableActions:YES];
        _maskLayer.strokeEnd = percentage;
        _shadowLayer.strokeEnd = percentage;
        [CATransaction setDisableActions:NO];
        
        self.percentage = percentage;
    }
}

- (void)clear {
    _circlePathView.alpha = 0.0;
    _symbolLabel.alpha = 0.0;
    _titleLabel.alpha = 0.0;
    _valueLabel.alpha = 0.0;
    
    [CATransaction setDisableActions:YES];
    _maskLayer.strokeEnd = 0.0;
    _shadowLayer.strokeEnd = 0.0;
    [CATransaction setDisableActions:NO];
}

@end
