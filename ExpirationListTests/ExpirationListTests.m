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
    NSString *degenerate = @"";
    NSString *testString1 = @"kitten";
    NSString *testString2 = @"sitting";
    NSString *testString3 = @"mitten";
    NSString *testString4 = @"Sunday";
    NSString *testString5 = @"Saturday";
    
    int test1 = [testString1 distanceToWord:testString2];
    int test2 = [testString1 distanceToWord:testString3];
    int test3 = [testString4 distanceToWord:testString5];
    int test4 = [degenerate distanceToWord:testString1];
    int test5 = [testString1 distanceToWord:degenerate];
    int test6 = [testString1 distanceToWord:testString1];
    
    XCTAssert(test1 == 3, @"Expected 3 edit difference, found %d", test1);
    XCTAssert(test2 == 1, @"Expected 1 edit difference, found %d", test2);
    XCTAssert(test3 == 3, @"Expected 3 edit difference, found %d", test3);
    XCTAssert(test4 == 6, @"Expected 6 edit difference, found %d", test4);
    XCTAssert(test5 == 6, @"Expected 6 edit difference, found %d", test5);
    XCTAssert(test6 == 0, @"Expected 0 edit difference, found %d", test6);
}

/*
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
*/

@end
