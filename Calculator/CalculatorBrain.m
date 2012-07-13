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

- (double)performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

+ (NSString *)descriptionOfProgram:(id)program
{
    return @"Implement in Assignment #2";
}

+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableNames 
{
    return [self runProgram:program];
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    return nil;
}

+ (double)popOperandOffStack:(NSMutableArray *)stack
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
            result = [self popOperandOffStack:stack] 
            + [self popOperandOffStack:stack];
        } else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffStack:stack] 
            * [self popOperandOffStack:stack];
        } else if ([@"-" isEqualToString:operation]) {
            double subtrahend = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] - subtrahend;
        } else if ([@"/" isEqualToString:operation]) {
            double divisor = [self popOperandOffStack:stack];
            if (divisor) {
                result = [self popOperandOffStack:stack] 
                            / divisor;
            }
        } else if ([@"sin" isEqualToString:operation]) {
            result = sin([self popOperandOffStack:stack]);
        } else if ([@"cos" isEqualToString:operation]) {
            result = cos([self popOperandOffStack:stack]);
        } else if ([@"sqrt" isEqualToString:operation]) {
            result = sqrt([self popOperandOffStack:stack]);
        } else if ([@"π" isEqualToString:operation]) {
            result = M_PI;
        }
    }
    
    return result;
}

/*
    if ([operation isEqualToString:@"+"]) {
        result = [self popOperand] + [self popOperand];
    } else if ([@"*" isEqualToString:operation]) {
        result = [self popOperand] * [self popOperand];
    } else if ([@"-" isEqualToString:operation]) {
        double subtrahend = [self popOperand];
        result = [self popOperand] - subtrahend;
    } else if ([@"/" isEqualToString:operation]) {
        double divisor = [self popOperand];
        if (divisor) result = [self popOperand] / divisor;
    } else if ([@"sin" isEqualToString:operation]) {
        result = sin([self popOperand]);
    } else if ([@"cos" isEqualToString:operation]) {
        result = cos([self popOperand]);
    } else if ([@"sqrt" isEqualToString:operation]) {
        result = sqrt([self popOperand]);
    } else if ([@"π" isEqualToString:operation]) {
        result = M_PI;
    }
    
*/

@end
