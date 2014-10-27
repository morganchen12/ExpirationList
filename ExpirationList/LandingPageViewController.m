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
#import "ImageTestViewController.h"
#import <GPUImage/GPUImageFramework.h>

@interface LandingPageViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LandingPageViewController

#pragma mark - View Lifecycle

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
    NSLog(@"w, h: %f, %f", image.size.width, image.size.height);
    
    [self dismissViewControllerAnimated:YES completion:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.activityIndicator startAnimating];
            });
            
            // process image
            NSString *rawOutput = [EXLModel target:self recognizeImageWithTesseract:image];
            NSArray *outputNames = [[EXLModel itemsFromOCROutput:rawOutput] allObjects];
            
            // save everything using current date
            [[CoreDataHelper sharedHelper] insertExpirablesWithNames:outputNames];
            
//            GPUImageAdaptiveThresholdFilter *filter = [[GPUImageAdaptiveThresholdFilter alloc] init];
//            UIImage *binaryImage = [filter imageByFilteringImage:image];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
//                [self performSegueWithIdentifier:@"TestImage" sender:binaryImage]; //debug
            });
        });
    }];
}

#pragma mark - TesseractDelegate

-(BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract *)tesseract {
    NSLog(@"%d", tesseract.progress);
    return NO;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"TestImage"]){
        ImageTestViewController *destination = (ImageTestViewController *)[segue destinationViewController];
        destination.testImage = (UIImage *)sender;
        NSLog(@"Done");
    }
}


@end
