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

/* Return items from a string representing OCR output. Uses UITextChecker to autocorrect
 * misspelled words and removes prices and non-item entries. May delete everything if OCR
 * output is from a poorly-taken image.
 */
+(NSSet *)itemsFromOCROutput:(NSString *)ocrOutput;


/* Abstraction of some of the boring work necessary for opening an image picker from a view
 * controller.
 */
+(void)openCameraFromViewController:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)viewController;


/* Abstraction of some of the boring work necessary to run a UIImage through the OCR engine.
 * Currently images are not processed prior to OCR.
 */
+(NSString *)target:(id<TesseractDelegate>)target recognizeImageWithTesseract:(UIImage *)image;

@end
