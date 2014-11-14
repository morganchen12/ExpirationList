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


/* Return a singleton instance of CoreDataHelper.
 */
+(CoreDataHelper *)sharedHelper;


/* Returns an array of items fetched from Core Data. Request is performed synchronously
 * on a serial background queue.
 */
-(NSArray *)getExpirables;


/* Insert item into Core Data context asynchronously on a serial background queue.
 */
-(void)insertExpirableWithName:(NSString *)name date:(NSDate *)date completion:(void (^)(void))completion;


/* Takes an array of names and creates and inserts into context an array of items using today's date.
 * Inserts are performed asynchronously on a serial background queue.
 */
-(void)insertExpirablesWithNames:(NSArray *)names completion:(void (^)(void))completion;


/* Creates items given names and dates and inserts them into context. Also performed asynchronously in background.
 */
-(void)insertExpirablesWithNames:(NSArray *)names date:(NSDate *)date completion:(void (^)(void))completion;


/* Remove an item from context asynchronously.
 */
-(void)deleteExpirable:(Expirable *)expirable;


/* Save asynchronously.
 */
-(void)save;


/* Save synchronously or asynchronously based on parameter.
 */
-(void)saveSync:(BOOL)sync;

@end
