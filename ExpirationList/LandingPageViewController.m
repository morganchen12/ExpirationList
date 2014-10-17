//
//  LandingPageViewController.m
//  ExpirationList
//
//  Created by Morgan Chen on 10/17/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import "LandingPageViewController.h"
#import "EXLModel.h"
#import "UIImage+Filters.h"
#import "CoreDataHelper.h"

@interface LandingPageViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LandingPageViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.activityIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.activityIndicator startAnimating];
            });
            
            //process image
            UIImage *binaryImage = [image binaryImageFromAdaptiveThresholdingWithAreaRadius:12 andConstant:2];
            NSString *rawOutput = [EXLModel target:self recognizeImageWithTesseract:binaryImage];
            NSArray *outputNames = [[EXLModel itemsFromOCROutput:rawOutput] allObjects];
            
            //save everything using current date
            for(NSString *name in outputNames) {
                [CoreDataHelper insertExpirableWithName:name date:[NSDate date]];
            }
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
            });
        });
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
