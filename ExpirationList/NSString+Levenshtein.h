//
//  NSString+Levenshtein.h
//  ExpirationList
//
//  Created by Morgan Chen on 10/31/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Levenshtein)

+(int)distanceBetweenString:(NSString *)stringA andString:(NSString *)stringB;

-(int)distanceToWord:(NSString *)word;
-(NSString *)closestWordInSet:(NSSet *)set;

@end
