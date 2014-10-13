//
//  EXLModel.m
//  ExpirationList
//
//  Created by Morgan Chen on 10/9/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import "EXLModel.h"

@implementation EXLModel

+(NSSet *)itemsFromOCROutput:(NSString *)ocrOutput {
    //break text into an array of individual lines
    NSMutableArray *lines = [[ocrOutput componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]] mutableCopy];
    
    //loop through lines, treating each line as an array of whitespace separated words
    for(int i = 0; i < [lines count]; i++) {
        NSMutableArray *words = [[lines[i] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
        
        for(int j = 0; j < [words count]; j++){
            //words of length 2 or less are almost never useful, e.g. '20 oz'
            if([words[j] length] < 3){
                [words removeObjectAtIndex:j];
                j--;
            }
            
            //words containing '.' are prices or noise and can be removed
            else if([words[j] rangeOfString:@"."].location != NSNotFound) {
                [words removeObjectAtIndex:j];
                j--;
            }
            
            //words that are all numbers are not useful and can be removed
            else if([self stringIsProbablyEntirelyNumbers:words[j]]) {
                [words removeObjectAtIndex:j];
                j--;
            }
        }
        //write over line with new line
        [lines replaceObjectAtIndex:i withObject:[words componentsJoinedByString:@" "]];
        NSLog(@"%@", [words componentsJoinedByString:@" "]);
        
        //delete everything below SUBTOTAL, this marks the end of the list of food items
        if([self stringProbablyDoesContainSubtotal:lines[i]]){
            [lines removeObjectsInRange:NSMakeRange(i, [lines count]-i-1)];
            break;
        }
        
        //extremely short lines are likely to be noise
        if([lines[i] length] < 4){
            [lines removeObjectAtIndex:i];
            i--;
        }
    }
#ifdef DEBUG
//    NSLog(@"%@", [lines componentsJoinedByString:@"\n"]);
#endif
    return [NSSet setWithArray:lines];
}

+(BOOL)stringProbablyDoesContainSubtotal:(NSString *)string {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"S[A-Za-z0-9]BT[A-Za-z0-9]T[A-Za-z0-9]L" options:0 error:&error];
    return [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])] > 0;
}

+(BOOL)stringIsProbablyEntirelyNumbers:(NSString *)string {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]{2,}" options:0 error:&error];
    return [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])] > 0;
}

@end
