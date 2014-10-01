//
//  CoreDataHelper.h
//  ExpirationList
//
//  Created by Morgan Chen on 9/26/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Expirable;
@class NSManagedObjectContext;

@interface CoreDataHelper : NSObject

+(NSManagedObjectContext *)managedObjectContext;
+(NSArray *)getExpirables;
+(void)insertExpirableWithName:(NSString *)name date:(NSDate *)date;
+(void)save;

@end
