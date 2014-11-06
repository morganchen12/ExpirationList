//
//  TextCheckerHelper.h
//  ExpirationList
//
//  Created by Morgan Chen on 11/4/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UITextChecker;

@interface TextCheckerHelper : NSObject

@property (nonatomic, readonly) UITextChecker *textChecker;

/* Return a singleton instance of this class containing a UITextChecker instance.
 * Eventually this text checker will be specially configured.
 */
+(TextCheckerHelper *)sharedHelper;

@end
