//
//  ExpirationTableViewController.m
//  ExpirationList
//
//  Created by Morgan Chen on 9/26/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import "ExpirationTableViewController.h"
#import "AddItemTableViewController.h"
#import "Expirable.h"
#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "EXLModel.h"

@interface ExpirationTableViewController ()

@property (strong, nonatomic) NSMutableArray *expirables;
@property (strong, nonatomic) NSMutableDictionary *expirablesByDate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (strong, nonatomic, readonly) NSArray *keys;
@property (strong, nonatomic, readwrite) NSMutableArray *keySubset;

@end

@implementation ExpirationTableViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _keys = @[@"Today", @"Yesterday", @"Past week", @"Past 2 weeks", @"Past month", @"Past 6 months", @"Older"];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    if([self.expirables count]==0){
        // first-time user experience
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.keySubset = [self.keys mutableCopy];
    self.expirables = [[[CoreDataHelper sharedHelper] getExpirables] mutableCopy];
    if(self.expirables.count) {
        self.expirablesByDate = [self dictionaryForArrayOfItems];
    }
    [self sanitize];
    [self.tableView reloadData];
}

#pragma mark - Table view data source / UITableViewDataSource

-(NSMutableDictionary *)dictionaryForArrayOfItems {
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:[self.keys count]];
    for(int i = 0; i < [self.keys count]; i++) {
        values[i] = [[NSMutableArray alloc] init];
    }
    
    for(Expirable *item in self.expirables) {
        int daysOld = [self daysSinceDate:item.purchaseDate];
        
        if(daysOld == 0) {
            [values[0] addObject:item];
        }
        else if(daysOld == 1) {
            [values[1] addObject:item];
        }
        else if(daysOld <= 7) {
            [values[2] addObject:item];
        }
        else if(daysOld <= 14) {
            [values[3] addObject:item];
        }
        else if(daysOld <= 30) {
            [values[4] addObject:item];
        }
        else if(daysOld <= 182) {
            [values[5] addObject:item];
        }
        else {
            [values[6] addObject:item];
        }
    }
    return [[NSMutableDictionary alloc] initWithObjects:values forKeys:self.keys];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.expirablesByDate[self.keySubset[section]] count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.keySubset[section];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.keySubset count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExpirableCell" forIndexPath:indexPath];
    Expirable *item = [self.expirablesByDate[self.keySubset[[indexPath section]]] objectAtIndex:[indexPath row]];
    NSString *name = item.name;
    cell.textLabel.text = name;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSDate *purchaseDate = item.purchaseDate;
    int days = [self daysSinceDate:purchaseDate];
    NSString *subTextString = [NSString stringWithFormat:@"  %d days old - Added %@", days, [dateFormatter stringFromDate:purchaseDate]];
    
    cell.detailTextLabel.text = subTextString;
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [[CoreDataHelper sharedHelper] deleteExpirable:self.expirables[indexPath.row]];
        NSString *key = self.keySubset[[indexPath section]];
        [self.expirables removeObject:self.expirablesByDate[key][[indexPath row]]];
        self.expirablesByDate = [self dictionaryForArrayOfItems];
        [self sanitize];
        if([[self.expirablesByDate objectForKey:key] count]) {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else {
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (IBAction)openCamera:(id)sender {
    if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
        [EXLModel openCameraFromViewController:self];
    }
    else {
        NSLog(@"No rear camera available");
        //notify user somehow
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"ShowItemsAfterImagePicker" sender:image];
    }];
}

#pragma mark - Helper Methods

- (void)sortElements {
    [self.expirables sortUsingComparator:^NSComparisonResult(Expirable *obj1, Expirable *obj2) {
        return [obj1.purchaseDate compare:obj2.purchaseDate];
    }];
    [self.tableView reloadData];
}

-(int)daysSinceDate:(NSDate *)date {
    double timeSinceNow = [date timeIntervalSinceNow]*-1;
    return (timeSinceNow / 86400);
}

-(void)sanitize {
    for(int i = 0; i < [self.keySubset count]; i++) {
        NSString *key = self.keySubset[i];
        if([self.expirablesByDate[key] count] == 0) {
            [self.keySubset removeObjectAtIndex:i];
            [self.expirablesByDate removeObjectForKey:key];
            break;
        }
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ShowItemsAfterImagePicker"]) {
        AddItemTableViewController *destination = (AddItemTableViewController *)[segue destinationViewController];
        [destination processImage:(UIImage *)sender];
    }
}


@end
