//
//  AddItemViewController.m
//  ExpirationList
//
//  Created by Morgan Chen on 9/28/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import "AddItemTableViewController.h"
#import "AddItemTableViewCell.h"
#import "AddItemTextField.h"
#import "CoreDataHelper.h"
#import "UIImage+Filters.h"
#import "EXLModel.h"
#import "SVProgressHUD.h"

@interface AddItemTableViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (strong, nonatomic, readonly) NSArray *items;

@end

@implementation AddItemTableViewController {
    NSMutableArray *_items;
}

static AddItemTableViewController *sharedController = nil;

+ (instancetype)sharedInstance
{
    return sharedController;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _items = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        _items = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    return self;
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder {

    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        sharedController = self;
    });
    
    return sharedController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = NO;
    self.datePicker.datePickerMode = UIDatePickerModeDate;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_items removeAllObjects];
    [_items addObject:@""];
    self.datePicker.maximumDate = [NSDate date];
    self.datePicker.date = [NSDate date];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Table view data source / UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddItemTableViewCell *cell = (AddItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AddItemCell" forIndexPath:indexPath];
    cell.textField.text = self.items[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        if([indexPath row] == [self.items count]-1) {
            return;
        }
        @synchronized(self) {
            [_items removeObjectAtIndex:indexPath.row];
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange:)
                                                 name:@"UITextFieldTextDidChangeNotification"
                                               object:textField];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)textFieldDidChange:(NSNotification *)notification {
    AddItemTextField *textField = notification.object;
    AddItemTableViewCell *cell = textField.cell;
    
    long index = [self.tableView indexPathForCell:cell].row;
    
    @synchronized(self) {
        _items[index] = textField.text;
        if(index >= [self.items count]-1) {
            [_items addObject:@""];
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self.tableView reloadData];
    return NO;
}

#pragma mark - Storyboard / CoreData

- (IBAction)saveItems:(id)sender {
    NSMutableArray *snapshot;
    
    @synchronized(self) {
        snapshot = [self.items mutableCopy];
    }
    
    for(int i = 0; i < [snapshot count]; i++) {
        BOOL isInvalidName = [[snapshot[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""];
        if(isInvalidName) {
            [snapshot removeObjectAtIndex:i];
            i--;
        }
    }
    [[CoreDataHelper sharedHelper] insertExpirablesWithNames:snapshot date:self.datePicker.date completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - TesseractDelegate

-(BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract *)tesseract {
    return NO;
}

-(void)processImage:(UIImage *)image {
    [SVProgressHUD showWithStatus:@"Reading Image..." maskType:SVProgressHUDMaskTypeBlack];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *raw = [EXLModel target:self recognizeImageWithTesseract:image];
        NSSet *output = [EXLModel itemsFromOCROutput:raw];
        @synchronized(self) {
            [_items setArray:[output allObjects]];
            [_items addObject:@""];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        });
    });
}

@end
