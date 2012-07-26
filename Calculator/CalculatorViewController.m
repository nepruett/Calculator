//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Nathan Pruett on 6/30/12.
//  Copyright (c) 2012 LMN Solutions, Inc. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *testVariableValues;
@end

@implementation CalculatorViewController
@synthesize input;
@synthesize display;
@synthesize userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize testVariableValues = _variables;

- (CalculatorBrain *)brain
{
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (NSDictionary *)variables
{
    if (!_variables) _variables = [[NSDictionary alloc] init];
    return _variables;
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSRange range = [self.display.text rangeOfString:@"."];
    BOOL alreadyHasDecimalPoint = NO;
    if (range.location != NSNotFound) {
        alreadyHasDecimalPoint = YES;
    } else {
        alreadyHasDecimalPoint = NO;
    }
    NSString *digit = [sender currentTitle];
    if ([@"." isEqualToString:digit] && alreadyHasDecimalPoint ) {
        return;
    }
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
    self.input.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

- (IBAction)variablePressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *variableName = [sender currentTitle];
    [self.brain pushVariable:variableName];
    self.input.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    
}

-(IBAction)clearPressed {
    [self.brain clear];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.display.text = @"";
    self.input.text = @"";
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.input.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *operation = [sender currentTitle];
    [self.brain performOperation:operation];
    double result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    self.input.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

- (void)viewDidUnload {
    [self setInput:nil];
    [super viewDidUnload];
}
@end
