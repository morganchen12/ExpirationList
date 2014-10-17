//
//  EXLModel.h
//  ExpirationList
//
//  Created by Morgan Chen on 10/9/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIImage;
@protocol TesseractDelegate;
@protocol UIImagePickerControllerDelegate;
@protocol UINavigationControllerDelegate;

@interface EXLModel : NSObject

+(NSSet *)itemsFromOCROutput:(NSString *)ocrOutput;
+(void)openCameraFromViewController:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)viewController;

+(NSString *)target:(id<TesseractDelegate>)target recognizeImageWithTesseract:(UIImage *)image;

@end
