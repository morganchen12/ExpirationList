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

@property(nonatomic, weak, readonly) NSManagedObjectContext *sharedMOC;

+(CoreDataHelper *)sharedHelper;
-(NSArray *)getExpirables;
-(void)insertExpirableWithName:(NSString *)name date:(NSDate *)date completion:(void (^)(void))completion;
-(void)insertExpirablesWithNames:(NSArray *)names completion:(void (^)(void))completion;
-(void)insertExpirablesWithNames:(NSArray *)names date:(NSDate *)date completion:(void (^)(void))completion;
-(void)deleteExpirable:(Expirable *)expirable;
-(void)save;

@end
