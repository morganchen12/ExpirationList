//
//  ExpirationListTests.m
//  ExpirationListTests
//
//  Created by Morgan Chen on 9/26/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
//#import "EXLModel.h"
//#import "CoreDataHelper.h"
//#import "UIImage+Filters.h"
#import "NSString+Levenshtein.h"

@interface ExpirationListTests : XCTestCase

@end

@implementation ExpirationListTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testStringMethods {
    NSString *testString1 = @"kitten";
    NSString *testString2 = @"sitting";
    NSString *testString3 = @"mitten";
    NSString *testString4 = @"Sunday";
    NSString *testString5 = @"Saturday";
    
    XCTAssert([testString1 distanceToWord:testString2] == 3, @"3 edit difference");
    XCTAssert([testString1 distanceToWord:testString3] == 1, @"1 edit difference");
    XCTAssert([testString4 distanceToWord:testString5] == 3, @"3 edit difference");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
