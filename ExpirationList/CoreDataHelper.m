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

@property(nonatomic, readonly) dispatch_queue_t saveQueue;

@end

@implementation CoreDataHelper

-(instancetype)init {
    if(self = [super init]) {
        _saveQueue = dispatch_queue_create("com.expirationList.saveQueue", DISPATCH_QUEUE_SERIAL);
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
    dispatch_async(self.saveQueue, ^{
        NSArray *names = [namesHelper copy];
        NSManagedObjectContext *context = [CoreDataHelper managedObjectContext];
        for(NSString *name in names){
            Expirable *newExpirable = (Expirable *)[NSEntityDescription insertNewObjectForEntityForName:@"Expirable" inManagedObjectContext:context];
            newExpirable.name = name;
            newExpirable.purchaseDate = date;
        }
    });
}

-(void)insertExpirableWithName:(NSString *)name date:(NSDate *)date {
    dispatch_async(self.saveQueue, ^{
        Expirable *newExpirable = (Expirable *)[NSEntityDescription insertNewObjectForEntityForName:@"Expirable" inManagedObjectContext:[CoreDataHelper managedObjectContext]];
        newExpirable.name = name;
        newExpirable.purchaseDate = date;
        NSAssert([name length] > 0, @"Name must be valid!");
    });
}

-(void)save {
    dispatch_async(self.saveQueue, ^{
        [(AppDelegate *)[UIApplication sharedApplication].delegate saveContext]; //make this better later
    });
}

@end
