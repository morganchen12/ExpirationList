//
//  EXLModel.m
//  ExpirationList
//
//  Created by Morgan Chen on 10/9/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import "EXLModel.h"

@implementation EXLModel

+(NSArray *)itemsFromOCROutput:(NSString *)ocrOutput {
    NSMutableArray *lines = [[ocrOutput componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]] mutableCopy];
    for(int i = 0; i < [lines count]; i++){
        NSMutableArray *words = [[lines[i] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
        for(int j = 0; j < [words count]; j++){
            if([words[j] length] < 3){
                [words removeObjectAtIndex:j];
                j--;
            }
            else if([words[j] rangeOfString:@"."].location != NSNotFound) {
                [words removeObjectAtIndex:j];
                j--;
            }
            else if([self stringIsProbablyEntirelyNumbers:words[j]]) {
                [words removeObjectAtIndex:j];
                j--;
            }
        }
        [lines replaceObjectAtIndex:i withObject:[words componentsJoinedByString:@" "]];
        if([self stringProbablyDoesContainSubtotal:lines[i]]){
            [lines removeObjectsInRange:NSMakeRange(i, [lines count]-i-1)];
            break;
        }
        if([lines[i] length] < 4){
            [lines removeObjectAtIndex:i];
            i--;
        }
    }
    NSLog(@"%@", [lines componentsJoinedByString:@"\n"]);
    return lines;
}

+(BOOL)stringProbablyDoesContainSubtotal:(NSString *)string {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"S[A-Za-z0-9]BT[A-Za-z0-9]T[A-Za-z0-9]L" options:0 error:&error];
    return [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])] > 0;
}

+(BOOL)stringIsProbablyEntirelyNumbers:(NSString *)string {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+" options:0 error:&error];
    return [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])] > 0;
}

@end
