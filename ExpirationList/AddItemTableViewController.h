//
//  AddItemViewController.h
//  ExpirationList
//
//  Created by Morgan Chen on 9/28/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TesseractOCR/TesseractOCR.h>

@interface AddItemTableViewController : UITableViewController <TesseractDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

+ (id)alloc UNAVAILABLE_ATTRIBUTE;
+ (id)allocWithZone:(struct _NSZone *)zone UNAVAILABLE_ATTRIBUTE;

+ (instancetype)sharedInstance;

-(void)processImage:(UIImage *)image;

@end
