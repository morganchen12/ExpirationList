//
//  TextCheckerHelper.m
//  ExpirationList
//
//  Created by Morgan Chen on 11/4/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import "TextCheckerHelper.h"
@import UIKit;

@implementation TextCheckerHelper

-(instancetype)init {
    if(self = [super init]) {
        _textChecker = [[UITextChecker alloc] init];
    }
    return self;
}

+(TextCheckerHelper *)sharedHelper {
    static TextCheckerHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[TextCheckerHelper alloc] init];
    });
    return helper;
}

@end
