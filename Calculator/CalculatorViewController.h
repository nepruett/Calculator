//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Nathan Pruett on 6/30/12.
//  Copyright (c) 2012 LMN Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalculatorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *input;
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *variableDisplay;
@end
