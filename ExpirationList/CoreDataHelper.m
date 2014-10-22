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

@implementation CoreDataHelper

+(NSManagedObjectContext *)managedObjectContext{
    return ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
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

+(void)insertExpirablesWithNames:(NSArray *)names {
    [self insertExpirablesWithNames:names andDate:[NSDate date]];
}

+(void)insertExpirablesWithNames:(NSArray *)namesHelper andDate:(NSDate *)date {
    NSArray *names = [namesHelper copy];
    NSManagedObjectContext *context = [self managedObjectContext];
    for(NSString *name in names){
        Expirable *newExpirable = (Expirable *)[NSEntityDescription insertNewObjectForEntityForName:@"Expirable" inManagedObjectContext:context];
        newExpirable.name = name;
        newExpirable.purchaseDate = date;
    }
}

+(void)insertExpirableWithName:(NSString *)name date:(NSDate *)date {
    NSAssert([name length] > 0, @"Name must be valid!");
    Expirable *newExpirable = (Expirable *)[NSEntityDescription insertNewObjectForEntityForName:@"Expirable" inManagedObjectContext:[CoreDataHelper managedObjectContext]];
    newExpirable.name = name;
    newExpirable.purchaseDate = date;
}

+(void)save {
    [((AppDelegate *)[UIApplication sharedApplication].delegate) saveContext]; //make this better later
}

@end
