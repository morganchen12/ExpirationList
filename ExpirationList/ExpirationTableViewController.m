//
//  ExpirationTableViewController.m
//  ExpirationList
//
//  Created by Morgan Chen on 9/26/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import "ExpirationTableViewController.h"
#import "Expirable.h"
#import "AppDelegate.h"
#import "CoreDataHelper.h"

@interface ExpirationTableViewController ()

@property (strong, nonatomic) NSMutableArray *expirables;

@end

@implementation ExpirationTableViewController

#pragma mark - Initializers

#pragma message "Get rid of empty methods"

-(id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]){
        
    }
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];
    if([self.expirables count]==0){
        
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.expirables = [[CoreDataHelper getExpirables] mutableCopy];
//    NSLog(@"%lu", (unsigned long)[self.expirables count]);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.expirables count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExpirableCell" forIndexPath:indexPath];
    NSString *name = [self.expirables[indexPath.row] name];
    cell.textLabel.text = name;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSDate *purchaseDate = [self.expirables[indexPath.row] purchaseDate];
    double timeSinceNow = [purchaseDate timeIntervalSinceNow]*-1;
    int days = timeSinceNow / 86400;
    NSString *subTextString = [NSString stringWithFormat:@"  %d days old - Added %@", days, [dateFormatter stringFromDate:purchaseDate]];
    
    cell.detailTextLabel.text = subTextString;
    return cell;
}

#pragma mark - UITableViewDataSource

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [[CoreDataHelper managedObjectContext] deleteObject:self.expirables[indexPath.row]];
        [self.expirables removeObjectAtIndex:indexPath.row];
        [(AppDelegate *)[UIApplication sharedApplication].delegate saveContext];
        [self.tableView reloadData];
    }
}

#pragma mark - Helper Methods
#pragma message "Sorting can be done a little simpler, see below"
//- (void)sortElements {
//    [self.expirables sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        double age1 = [((Expirable *)obj1).purchaseDate timeIntervalSinceNow];
//        double age2 = [((Expirable *)obj2).purchaseDate timeIntervalSinceNow];
//        if(age1 < age2){
//            return NSOrderedAscending;
//        }
//        if(age1 > age2){
//            return NSOrderedDescending;
//        }
//        return NSOrderedSame;
//    }];
//    [self.tableView reloadData];
//}

- (void)sortElements {
    [self.expirables sortUsingComparator:^NSComparisonResult(Expirable *obj1, Expirable *obj2) {
        return [obj1.purchaseDate compare:obj2.purchaseDate];
    }];
    [self.tableView reloadData];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"SEGUE");
}


@end
