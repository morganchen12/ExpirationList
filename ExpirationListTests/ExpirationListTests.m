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
//#import "CoreDataHelper.h"
//#import "UIImage+Filters.h"

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
    NSString *input = @"TOTAL a18.00\n";
    
    NSSet *output = [EXLModel itemsFromOCROutput:input];
    
    for(NSString *item in output) {
        XCTAssert(![item isEqualToString:@"TOTAL"], @"Name must be valid!");
    }
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
