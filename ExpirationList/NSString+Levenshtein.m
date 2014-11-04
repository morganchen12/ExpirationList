//
//  NSString+Levenshtein.m
//  ExpirationList
//
//  Created by Morgan Chen on 10/31/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import "NSString+Levenshtein.h"

@implementation NSString (filters)

-(int)distanceToWord:(NSString *)word {
    return [NSString distanceBetweenString:self andString:word];
}

+(int)distanceBetweenString:(NSString *)stringA andString:(NSString *)stringB {
    
    // degenerate cases
    if([stringA isEqualToString:stringB]) return 0;
    if([stringA length] == 0) return (int)[stringB length];
    if([stringB length] == 0) return (int)[stringA length];
    
    // create two rows of matrix of edit distances
    int length = (int)stringB.length;
    int *previousRow = malloc((length+1) * sizeof(int));
    int *currentRow = malloc((length+1) * sizeof(int));
    
    // initialize previous row as edit distance for empty stringA
    for(int i = 0; i < [stringB length]; i++) {
        previousRow[i] = i;
    }
    
    for(int i = 0; i < [stringA length]; i++) {
        // calculate currentRow distances from previousRow
        // first element of currentRow is matrix[i+1][0]
        // edit distance is delete (i+1) chars from stringA to match stringB
        currentRow[0] = i+1;
        
        // use formula to fill in the rest of the row
        for(int j = 0; j < [stringB length]; j++) {
            int cost = ([stringA characterAtIndex:i] == [stringB characterAtIndex:j]) ? 0 : 1;
            currentRow[j+1] = minimum3(currentRow[j] + 1,
                                       previousRow[j+1] + 1,
                                       previousRow[j] + cost);
        }
        
        // take deep copy of current row to previous row for next iteration
        for(int j = 0; j < [stringB length]; j++) {
            previousRow[j] = currentRow[j];
        }
    }
    
    int returnValue = currentRow[length];
    free(previousRow);
    free(currentRow);
    
    return returnValue;
}

-(NSString *)closestWordInSet:(NSSet *)set {

    NSString *returnWord;
    int distance = -1;
    for(NSString *word in set) {
        int tempDistance = [self distanceToWord:word];
        if(distance < 0 || tempDistance < distance) {
            distance = tempDistance;
            returnWord = word;
        }
    }
    return returnWord;
}

static int minimum3(int a, int b, int c) {
    return MIN(a, MIN(b, c));
}

@end
