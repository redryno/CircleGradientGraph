//
//  ViewController.m
//  CircleGradientAnimation
//
//  Created by Ryan Bigger on 9/5/17.
//  Copyright © 2017 Ryan Bigger. All rights reserved.
//

#import "ViewController.h"
#import "RBCircleGraphView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet RBCircleGraphView * circleGraphOverall;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.circleGraphOverall setPercentage:0.62];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.circleGraphOverall animate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapGraphView:(id)sender {
    CGFloat percentage = self.circleGraphOverall.percentage;
    if (percentage < 0.9) {
        [self.circleGraphOverall changePercentage:percentage + 0.1 animated:YES];
    } else if (percentage < 1.0) {
        [self.circleGraphOverall changePercentage:1.0 animated:YES];
    } else {
        [self.circleGraphOverall clear];
        [self.circleGraphOverall setPercentage:0.62];
        [self.circleGraphOverall animate];
    }
}

@end
