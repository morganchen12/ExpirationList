//
//  CoreDataHelper.m
//  ExpirationList
//
//  Created by Morgan Chen on 9/26/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "Expirable.h"
@import UIKit;

@interface CoreDataHelper()

@property(nonatomic, readonly) dispatch_queue_t writeQueue;
@property(nonatomic, readonly) NSManagedObjectContext *writeContext;

@end

@implementation CoreDataHelper

-(instancetype)init {
    if(self = [super init]) {
        _writeQueue = dispatch_queue_create("com.expirationList.saveQueue", DISPATCH_QUEUE_SERIAL);
        _writeContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _writeContext.parentContext = [CoreDataHelper managedObjectContext];
    }
    return self;
}

+(NSManagedObjectContext *)managedObjectContext{
    return ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
}

+(CoreDataHelper *)sharedHelper {
    static CoreDataHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[CoreDataHelper alloc] init];
    });
    return helper;
}

+(NSArray *)getExpirables{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Expirable" inManagedObjectContext:[CoreDataHelper managedObjectContext]];
    [request setEntity:entityDescription];
    
    NSError *error;
    NSArray *queryResult = [[CoreDataHelper managedObjectContext] executeFetchRequest:request error:&error];
    if(error){
        NSLog(@"%@", [error localizedDescription]);
    }
    return queryResult;
}

-(void)insertExpirablesWithNames:(NSArray *)names {
    [self insertExpirablesWithNames:names andDate:[NSDate date]];
}

-(void)insertExpirablesWithNames:(NSArray *)namesHelper andDate:(NSDate *)date {
    [self.writeContext performBlock:^{
        // insert items into context
        NSArray *names = [namesHelper copy];
        for(NSString *name in names){
            Expirable *newExpirable = (Expirable *)[NSEntityDescription insertNewObjectForEntityForName:@"Expirable" inManagedObjectContext:self.writeContext];
            newExpirable.name = name;
            newExpirable.purchaseDate = date;
        }
        
        // push to parent context
        [self saveAllContexts];
    }];
}

-(void)insertExpirableWithName:(NSString *)name date:(NSDate *)date {
    [self.writeContext performBlock:^{
        Expirable *newExpirable = (Expirable *)[NSEntityDescription insertNewObjectForEntityForName:@"Expirable" inManagedObjectContext:[CoreDataHelper managedObjectContext]];
        newExpirable.name = name;
        newExpirable.purchaseDate = date;
        NSAssert([name length] > 0, @"Name must be valid!");
        
        [self saveAllContexts];
    }];
}

-(void)save {
    NSManagedObjectContext *mainMOC = [CoreDataHelper managedObjectContext];
    NSError *error;
    if(![mainMOC save:&error]) {
        NSLog(@"%@", error);
    }
}

// call only inside writeContext performBlock block
-(void)saveAllContexts {
    NSManagedObjectContext *mainMOC = [CoreDataHelper managedObjectContext];
    
    // push writeContext to main moc
    NSError *error;
    if(![self.writeContext save:&error]){
        NSLog(@"%@", error);
    }
    
    // save parent to disk
    [mainMOC performBlock:^{
        NSError *mainMOCError;
        if(![mainMOC save:&mainMOCError]) {
            NSLog(@"%@", mainMOCError);
        }
    }];
}

@end
