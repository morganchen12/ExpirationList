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

@property(nonatomic, retain, readonly) dispatch_queue_t coreDataQueue;

@end

@implementation CoreDataHelper

-(instancetype)init {
    if(self = [super init]) {
        _coreDataQueue = dispatch_queue_create("com.expirationList.coreDataQueue", DISPATCH_QUEUE_SERIAL);
        _sharedMOC = ((AppDelegate *)([UIApplication sharedApplication].delegate)).managedObjectContext;
    }
    return self;
}

+(CoreDataHelper *)sharedHelper {
    static CoreDataHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[CoreDataHelper alloc] init];
    });
    return helper;
}

-(NSArray *)getExpirables{
    __block NSArray *queryResult;
    
    dispatch_sync(self.coreDataQueue, ^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Expirable" inManagedObjectContext:self.sharedMOC];
        [request setEntity:entityDescription];
        
        NSError *error;
        queryResult = [self.sharedMOC executeFetchRequest:request error:&error];
        if(error){
            NSLog(@"%@", [error localizedDescription]);
        }
    });
    return queryResult;
}

-(void)insertExpirablesWithNames:(NSArray *)names completion:(void (^)(void))completion {
    [self insertExpirablesWithNames:names date:[NSDate date] completion:completion];
}

-(void)insertExpirablesWithNames:(NSArray *)names date:(NSDate *)date completion:(void (^)(void))completion {
    dispatch_async(self.coreDataQueue, ^{
        for(NSString *name in names){
            Expirable *newExpirable = (Expirable *)[NSEntityDescription insertNewObjectForEntityForName:@"Expirable" inManagedObjectContext:self.sharedMOC];
            newExpirable.name = name;
            newExpirable.purchaseDate = date;
        }
        if(completion) {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
    });
}

-(void)insertExpirableWithName:(NSString *)name date:(NSDate *)date completion:(void (^)(void))completion {
    dispatch_async(self.coreDataQueue, ^{
        Expirable *newExpirable = (Expirable *)[NSEntityDescription insertNewObjectForEntityForName:@"Expirable" inManagedObjectContext:self.sharedMOC];
        newExpirable.name = name;
        newExpirable.purchaseDate = date;
        NSAssert([name length] > 0, @"Name must be valid!");
        if(completion) {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
    });
}

-(void)deleteExpirable:(Expirable *)expirable {
    dispatch_async(self.coreDataQueue, ^{
        [[CoreDataHelper sharedHelper].sharedMOC deleteObject:expirable];
    });
}

-(void)save {
    dispatch_async(self.coreDataQueue, ^{
        NSError *error;
        if(![self.sharedMOC save:&error]) {
            NSLog(@"%@", error);
        }
    });
}


@end
