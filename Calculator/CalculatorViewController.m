//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Nathan Pruett on 6/30/12.
//  Copyright (c) 2012 LMN Solutions, Inc. All rights reserved.
//
#include <stdlib.h>
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
@synthesize variableDisplay;
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
    [self updateDisplays];
}

- (IBAction)variablePressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *variableName = [sender currentTitle];
    [self.brain pushVariable:variableName];
    [self updateDisplays];
    
}

-(IBAction)clearPressed {
    [self.brain clear];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.display.text = @"";
    self.input.text = @"";
    self.variableDisplay.text = @"";
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self updateDisplays];
}

- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *operation = [sender currentTitle];
    [self.brain performOperation:operation];
    double result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    [self updateDisplays];
}

- (IBAction)testPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    NSString *testName = [sender currentTitle];
    if ([@"Test 1" isEqualToString:testName]) {
        self.testVariableValues = nil;
    } else if ([@"Test 2" isEqualToString:testName]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:5], @"x",[NSNumber numberWithFloat:24.5], @"y", nil];
    } else if ([@"Test 3" isEqualToString:testName]) {
        self.testVariableValues = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:arc4random_uniform(100)], @"x", [NSNumber numberWithInt:arc4random_uniform(100)], @"y", [NSNumber numberWithInt:arc4random_uniform(100)], @"z", nil];
    }
    double result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues];
    self.display.text = [NSString stringWithFormat:@"%g", result];
    [self updateDisplays];
}

- (void)updateDisplays {
    self.input.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    NSSet *variablesUsed = [CalculatorBrain variablesUsedInProgram:self.brain.program];
    NSString *result = @"";
    if (variablesUsed) {
        for (NSString *varName in variablesUsed) {
            NSNumber *varValue = [self.testVariableValues valueForKey:varName];
            if (varValue) {
                result = [result stringByAppendingString:[NSString stringWithFormat:@"%@ = %@ ", varName, varValue]];
            } else {
                result = [result stringByAppendingString:[NSString stringWithFormat:@"%@ = 0 ", varName]];
            }
        }
    }
    self.variableDisplay.text = result;
}

- (void)viewDidUnload {
    [self setInput:nil];
    [super viewDidUnload];
}
@end
