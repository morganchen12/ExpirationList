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
            if([words[j] length] < 4){
                [words removeObjectAtIndex:j];
                j--;
            } else if([words[j] rangeOfString:@"."].location != NSNotFound){
                [words removeObjectAtIndex:j];
                j--;
            }
            [lines replaceObjectAtIndex:i withObject:[words componentsJoinedByString:@" "]];
        }
    }
    NSLog(@"%@", [lines componentsJoinedByString:@"\n"]);
    return @[];
}

@end
