//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Nathan Pruett on 6/30/12.
//  Copyright (c) 2012 LMN Solutions, Inc. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()

@property (nonatomic, strong) NSMutableArray *programStack;

@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *)programStack
{
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (id)program 
{
    return [self.programStack copy];
}

- (void)clear
{
    [self.programStack removeAllObjects];
}

- (void)pushOperand:(double)operand
{
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.programStack addObject:operandObject];
}

- (void)pushVariable:(NSString *)variableName
{
    [self.programStack addObject:variableName];
}

- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program copy];
    }
    return [self popDescriptionOffStack:stack];
}

+ (double)runProgram:(id)program
{
    return [self runProgram:program usingVariableValues:[[NSDictionary alloc] init]];
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variables
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack usingVariableValues: variables];
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    return nil;
}

+ (NSString *)popDescriptionOffStack:(NSArray *) stack 
{
    NSString *result = @"";
    
    for (id obj in stack) {
        NSString *objString;
        if ([obj isKindOfClass:[NSNumber class]]) {
            objString = [obj stringValue];
        } 
        else if ([obj isKindOfClass:[NSString class]])
        {
            objString = obj;
        }
        result = [result stringByAppendingString:objString];
        result = [result stringByAppendingString:@" "];
    }
    
    return result;
}

+ (double)popOperandOffStack:(NSMutableArray *)stack
         usingVariableValues:(NSDictionary*)variables
{
    double result = 0;
    
    // pop operand off stack
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        return [topOfStack doubleValue];
    } 
    else if ([topOfStack isKindOfClass:[NSString class]])
    {
        // if operation, need to recursively evaluate
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffStack:stack usingVariableValues:variables] 
            + [self popOperandOffStack:stack usingVariableValues:variables];
        } else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffStack:stack usingVariableValues:variables] 
            * [self popOperandOffStack:stack usingVariableValues:variables];
        } else if ([@"-" isEqualToString:operation]) {
            double subtrahend = [self popOperandOffStack:stack usingVariableValues:variables];
            result = [self popOperandOffStack:stack usingVariableValues:variables] - subtrahend;
        } else if ([@"/" isEqualToString:operation]) {
            double divisor = [self popOperandOffStack:stack usingVariableValues:variables];
            if (divisor) {
                result = [self popOperandOffStack:stack usingVariableValues:variables] 
                            / divisor;
            }
        } else if ([@"sin" isEqualToString:operation]) {
            result = sin([self popOperandOffStack:stack usingVariableValues:variables]);
        } else if ([@"cos" isEqualToString:operation]) {
            result = cos([self popOperandOffStack:stack usingVariableValues:variables]);
        } else if ([@"sqrt" isEqualToString:operation]) {
            result = sqrt([self popOperandOffStack:stack usingVariableValues:variables]);
        } else if ([@"π" isEqualToString:operation]) {
            result = M_PI;
        } else {
            // is a variable
            NSString *varName = operation;
            result = 0;
            if ([[variables allKeys] containsObject:varName]) {
                NSNumber *varValue = (NSNumber *)[variables objectForKey:varName];
                result = [varValue floatValue];
            }
            
        }
    }
    
    return result;
}

@end
