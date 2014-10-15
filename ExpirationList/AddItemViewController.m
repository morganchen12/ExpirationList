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
#import "EXLModel.h"

@interface AddItemViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraBarButton;

@end

@implementation AddItemViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.nameTextField.delegate = self;
    [self.activityIndicator stopAnimating];
    
}

#pragma mark - Storyboard / CoreData and helper methods

- (IBAction)saveItem:(id)sender {
    [self toggleBusyStatus:YES];
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [CoreDataHelper insertExpirableWithName:self.nameTextField.text date:self.datePicker.date];
        [CoreDataHelper save];
    });
    [self toggleBusyStatus:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveItems:(NSArray *)array {
    
    //saves everything in the array using date shown in datePicker
    [self toggleBusyStatus:YES];
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for(NSString* itemName in array){
            NSAssert([itemName length] > 0, @"Cannot add empty item to food array");
            [CoreDataHelper insertExpirableWithName:itemName date:self.datePicker.date];
        }
        [CoreDataHelper save];
    });
    [self toggleBusyStatus:NO];
}

-(void)toggleBusyStatus:(BOOL)busy { //if starting tasks, busy = YES
    if(busy){
        [self.activityIndicator startAnimating];
        self.saveButton.userInteractionEnabled = NO;
        [self.navigationBar setHidesBackButton:YES animated:YES];
        self.cameraBarButton.enabled = NO;
    }
    else {
        [self.activityIndicator stopAnimating];
        self.saveButton.userInteractionEnabled = YES;
        [self.navigationBar setHidesBackButton:NO animated:YES];
        self.cameraBarButton.enabled = YES;
    }
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - TesseractDelegate

-(void)recognizeImageWithTesseract:(UIImage *)image {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self toggleBusyStatus:YES];
        });
        
        //run OCR on image
        UIImage *imageToTest = [image binaryImageFromAdaptiveThresholdingWithAreaRadius:15 andConstant:3];
        Tesseract *tesseract = [[Tesseract alloc] initWithLanguage:@"eng"];
        [tesseract setVariableValue:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz." forKey:@"tessedit_char_whitelist"];
        tesseract.delegate = self;
        [tesseract setImage:imageToTest];
        [tesseract recognize];
        NSLog(@"%@", tesseract.recognizedText);
        NSSet *items = [EXLModel itemsFromOCROutput:tesseract.recognizedText];
        [self saveItems:[items allObjects]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self toggleBusyStatus:NO];
        });
    });
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract {
//    NSLog(@"progress: %d", tesseract.progress);
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

#pragma mark - UIImagePickerControllerDelegate

- (IBAction)openCamera:(id)sender {
    UIImagePickerController *imgPicker = [UIImagePickerController new];
    imgPicker.delegate = self;
    
    if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imgPicker animated:YES completion:nil];
    }
    else {
        NSLog(@"No rear camera, rip dreams");
        [self testTesseract];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self recognizeImageWithTesseract:image];
    }];
}

#pragma mark - Tests

-(void)testTesseract {
    [self recognizeImageWithTesseract:[UIImage imageNamed:@"receipt3.jpg"]];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if([segue.identifier isEqualToString:@"TestImage"]){
//        ImageTestViewController *destination = (ImageTestViewController *)[segue destinationViewController];
//        destination.testImage = [[UIImage imageNamed:@"receipt3.jpg"] binaryImageFromAdaptiveThresholdingWithAreaRadius:12 andConstant:6];
//    }
}


@end
