//
//  AddItemViewController.m
//  ExpirationList
//
//  Created by Morgan Chen on 9/28/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import "AddItemViewController.h"
#import "CoreDataHelper.h"
#import "UIImage+Filters.h"
#import "ImageTestViewController.h"

@interface AddItemViewController ()
//@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation AddItemViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.nameTextField.delegate = self;
//    self.scrollView.frame = [[UIScreen mainScreen] applicationFrame];
    
}

#pragma mark - Storyboard and helper methods

- (IBAction)saveItem:(id)sender {
    [CoreDataHelper insertExpirableWithName:self.nameTextField.text date:self.datePicker.date];
    [CoreDataHelper save];
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - TesseractDelegate

-(void)recognizeImageWithTesseract:(UIImage *)image {
    //should perform in background
    UIImage *imageToTest = [image binaryImageFromAdaptiveThresholdingWithAreaRadius:15 andConstant:12];
    Tesseract *tesseract = [[Tesseract alloc] initWithLanguage:@"eng"];
    tesseract.delegate = self;
    [tesseract setImage:imageToTest];
    [tesseract recognize];
    NSLog(@"%@", tesseract.recognizedText);
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract {
    NSLog(@"progress: %d", tesseract.progress);
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

#pragma mark - UIImagePickerControllerDelegate

- (IBAction)openCamera:(id)sender {
    
}

#pragma mark - Tests

-(void)testTesseract {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self recognizeImageWithTesseract:[UIImage imageNamed:@"receipt3.jpg"]];
    });
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"TestImage"]){
        ImageTestViewController *destination = (ImageTestViewController *)[segue destinationViewController];
        destination.testImage = [[UIImage imageNamed:@"receipt3.jpg"] binaryImageFromAdaptiveThresholdingWithAreaRadius:12 andConstant:6];
    }
}


@end
