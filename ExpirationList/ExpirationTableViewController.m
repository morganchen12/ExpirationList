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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;

@end

@implementation ExpirationTableViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];
    if([self.expirables count]==0){
        
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.expirables = [[[CoreDataHelper sharedHelper] getExpirables] mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - Table view data source / UITableViewDataSource

-(NSDictionary *)dictionaryForArrayOfItems {
    [self sortElements];
    NSArray *keys = @[@"Today", @"Yesterday", @"1 week ago", @"2 weeks ago", @"1 month ago", @"6 months ago", @"Older"];
    NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:[keys count]];

    int valueIndex = 0;
    int lastIndex = -1;
    for(int keyIndex = 0; keyIndex < [keys count]; keyIndex++) {
        NSDate *purchaseDate = [self.expirables[valueIndex] purchaseDate];
        int days = [self daysSinceDate:purchaseDate];
        
        switch (keyIndex) {
            case 0: {
                // Today
                
                while(valueIndex < [self.expirables count]) {
                    if(!(days == 0)) {
                        NSRange range = NSMakeRange(lastIndex+1, (valueIndex+1) - lastIndex);
                        lastIndex = valueIndex;
                        [objects addObject:[self.expirables subarrayWithRange:range]];
                        break;
                    }
                    valueIndex++;
                }
                break;
            }
            case 1: {
                // Yesterday
                
                while(valueIndex < [self.expirables count]) {
                    if(!(days == 1)) {
                        NSRange range = NSMakeRange(lastIndex+1, (valueIndex+1) - lastIndex);
                        lastIndex = valueIndex;
                        [objects addObject:[self.expirables subarrayWithRange:range]];
                        break;
                    }
                    valueIndex++;
                }
            }
            case 2: {
                // 1 week ago
                
                while(valueIndex < [self.expirables count]) {
                    if(!(days > 1 && days < 7)) {
                        NSRange range = NSMakeRange(lastIndex+1, (valueIndex+1) - lastIndex);
                        lastIndex = valueIndex;
                        [objects addObject:[self.expirables subarrayWithRange:range]];
                        break;
                    }
                    valueIndex++;
                }
            }
            case 3: {
                // 2 weeks ago
                
                while(valueIndex < [self.expirables count]) {
                    if(!(days > 7 && days <= 14)) {
                        NSRange range = NSMakeRange(lastIndex+1, (valueIndex+1) - lastIndex);
                        lastIndex = valueIndex;
                        [objects addObject:[self.expirables subarrayWithRange:range]];
                        break;
                    }
                    valueIndex++;
                }
            }
            case 4: {
                // 1 month ago
                
                while(valueIndex < [self.expirables count]) {
                    if(!(days > 14 && days <= 30)) {
                        NSRange range = NSMakeRange(lastIndex+1, (valueIndex+1) - lastIndex);
                        lastIndex = valueIndex;
                        [objects addObject:[self.expirables subarrayWithRange:range]];
                        break;
                    }
                    valueIndex++;
                }
            }
            case 5: {
                // 6 months ago
                
                while(valueIndex < [self.expirables count]) {
                    if(!(days > 30 && days <= 182)) {
                        NSRange range = NSMakeRange(lastIndex+1, (valueIndex+1) - lastIndex);
                        lastIndex = valueIndex;
                        [objects addObject:[self.expirables subarrayWithRange:range]];
                        break;
                    }
                    valueIndex++;
                }
            }
            default: {
                // older than 6 months
                
                while(valueIndex < [self.expirables count]) {
                    if(!(days > 182)) {
                        NSRange range = NSMakeRange(lastIndex+1, (valueIndex+1) - lastIndex);
                        lastIndex = valueIndex;
                        [objects addObject:[self.expirables subarrayWithRange:range]];
                        break;
                    }
                    valueIndex++;
                }
            }
        }
    }
    return [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
}

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
    int days = [self daysSinceDate:purchaseDate];
    NSString *subTextString = [NSString stringWithFormat:@"  %d days old - Added %@", days, [dateFormatter stringFromDate:purchaseDate]];
    
    cell.detailTextLabel.text = subTextString;
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete){
        [[CoreDataHelper sharedHelper] deleteExpirable:self.expirables[indexPath.row]];
        [self.expirables removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
