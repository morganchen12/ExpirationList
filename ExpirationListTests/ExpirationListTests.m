//
//  ExpirationListTests.m
//  ExpirationListTests
//
//  Created by Morgan Chen on 9/26/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "EXLModel.h"
#import "UIImage+Filters.h"

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

- (void)testItemStringScanner {
    // This is an example of a functional test case.
    NSString *testInput = @"foo\n\nbar baz 4.00\n       \n\n\n\n";
    NSSet *results = [EXLModel itemsFromOCROutput:testInput];
    XCTAssert([results containsObject:@"foo"], @"Expected bare text line");
    XCTAssert(![results containsObject:@""], @"Should not contain any empty lines");
    NSUInteger idx = [[results allObjects] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0;
    }];
    XCTAssert(idx == NSNotFound, @"Should not contain any lines that trim to zero length");
}

- (void)testItemStringScannerFull {
    NSString *testInput = @"SUBTOTRL 46.04\nTax 1 7.000 X 0.26\n. TOTHL 46.30\nDEBIT TENO 46.30\nCHRNGE DUE 0.00\n";
    NSSet *results = [EXLModel itemsFromOCROutput:testInput];
//    XCTAssert([results containsObject:@"foo"], @"Expected bare text line");
    XCTAssert(![results containsObject:@""], @"Should not contain any empty lines");
    NSUInteger idx = [[results allObjects] indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0;
    }];
    XCTAssert(idx == NSNotFound, @"Should not contain any lines that trim to zero length");
}

-(void)testImageProcessing {
    UIImage *testImage = [UIImage imageNamed:@"receipt3"];
    testImage = [testImage binaryImageFromAdaptiveThresholdingWithAreaRadius:150 andConstant:10];
    XCTAssert(!(testImage), @"Test is for benchmark only");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
