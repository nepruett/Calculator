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
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    NSString *result = [self popDescriptionOffStack:stack];
    id next = [stack lastObject];
    while (next) {
        NSLog(@"there are more, so adding comma...");
        result = [NSString stringWithFormat:@"%@, %@", result, [self popDescriptionOffStack:stack]];
        next = [stack lastObject];
    }
    return result;
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
    NSArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program copy];
    }
    NSMutableSet *varNames = [NSMutableSet set];
    
    for (id obj in stack) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *name = (NSString *)obj;
            if (![varNames containsObject: name] && ![[self operationNames] containsObject:name]) {
                [varNames addObject:name];
            }
        }
    }
    
    if ([varNames count] > 0) {
        return varNames;
    } else {
        return nil;
    }
}

+ (NSSet *)operationNames
{
    return [NSSet setWithObjects:@"+", @"-", @"*", @"/", @"sin", @"cos", @"sqrt", @"π", nil];
}

+ (NSSet *)functionOperationNames
{
    return [NSSet setWithObjects:@"sqrt", @"sin", @"cos", nil];
}

+ (NSSet *)inlineOperationNames
{
    return [NSSet setWithObjects:@"+", @"-", @"*", @"/", nil];
}

+ (NSSet *)highPrecedenceOperationNames 
{
    return [NSSet setWithObjects:@"*", @"/", nil];
}

+ (NSString *)popDescriptionOffStack:(NSMutableArray *) stack 
{
    NSString *result = @"";
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        NSLog(@"number = %@", topOfStack);
        result = [topOfStack stringValue];
    } else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *topOfStackString = topOfStack;
        if ([[self functionOperationNames] containsObject:topOfStackString]) {
            NSLog(@"functionOp = %@", topOfStackString);
            result = [NSString stringWithFormat:@"%@(%@)", topOfStackString, [self popDescriptionOffStack: stack]];
        } else if ([[self inlineOperationNames] containsObject:topOfStackString]) {
            NSLog(@"inlineOp = %@", topOfStackString);
            NSString *secondArg = [self popDescriptionOffStack:stack];
            NSString *firstArg = [self popDescriptionOffStack:stack];
            if ([[self highPrecedenceOperationNames] containsObject:topOfStackString]) {
                result = [NSString stringWithFormat:@"%@ %@ %@", [self putParensIfNeeded:firstArg], topOfStackString, [self putParensIfNeeded:secondArg]];
            } else {
                result = [NSString stringWithFormat:@"%@ %@ %@", firstArg, topOfStackString, secondArg];
            }
        } else {
            NSLog(@"unaryOp = %@", topOfStackString);
            result = topOfStackString;
        }
    }
    
    NSLog(@"finally returning - \"%@\"", result);
    return result;
}

+ (NSString *)putParensIfNeeded:(NSString *)arg
{
    if ([arg rangeOfString:@"+"].location == NSNotFound && 
        [arg rangeOfString:@"-"].location == NSNotFound) {
        return arg;
    } else {
        return [NSString stringWithFormat:@"(%@)", arg];
    }
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
