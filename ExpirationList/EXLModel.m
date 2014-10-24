//
//  EXLModel.m
//  ExpirationList
//
//  Created by Morgan Chen on 10/9/14.
//  Copyright (c) 2014 Morgan Chen. All rights reserved.
//

#import "EXLModel.h"
#import <UIKit/UIKit.h>
#import "UIImage+Filters.h"
#import <TesseractOCR/TesseractOCR.h>
#import <GPUImage/GPUImageFramework.h>

@implementation EXLModel

#pragma mark - String Processing

+(NSSet *)itemsFromOCROutput:(NSString *)ocrOutput {
    //break text into an array of individual lines
    NSMutableArray *lines = [[ocrOutput componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]] mutableCopy];
    
    //loop through lines, treating each line as an array of whitespace separated words
    //first loop removes noise
    
    for(int i = 0; i < [lines count]; i++) {
        if([self lineIsBeginningOfItemList:lines[i]]){
            [lines removeObjectsInRange:NSMakeRange(0, i)];
            break;
        }
    }
    for(int i = 0; i < [lines count]; i++) {
        NSMutableArray *words = [[lines[i] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
        
        for(int j = 0; j < [words count]; j++){
            //words of length 2 or less are almost never useful, e.g. '20 oz'
            if([words[j] length] < 3){
                [words removeObjectAtIndex:j];
                j--;
            }
            
            //words containing '.' are prices or noise and can be removed
            else if([words[j] rangeOfString:@"."].location != NSNotFound) {
                [words removeObjectAtIndex:j];
                j--;
            }
            
            //words that are all numbers are not useful and can be removed
            else if([self stringIsProbablyEntirelyNumbers:words[j]]) {
                [words removeObjectAtIndex:j];
                j--;
            }
        }
        //write over line with new line
        [lines replaceObjectAtIndex:i withObject:[words componentsJoinedByString:@" "]];
        
        //delete everything below SUBTOTAL, this marks the end of the list of food items
        if([self stringProbablyDoesContainSubtotal:lines[i]]){
            [lines removeObjectsInRange:NSMakeRange(i, [lines count]-i)];
            break;
        }
        NSLog(@"%@", [words componentsJoinedByString:@" "]);
        
        //extremely short lines are likely to be noise
        if([lines[i] length] < 3){
            [lines removeObjectAtIndex:i];
            i--;
        }
    }
#ifdef DEBUG
//    NSLog(@"%@", [lines componentsJoinedByString:@"\n"]);
#endif
    return [NSSet setWithArray:lines];
}

#pragma mark - UIImagePickerControllerDelegate
//check if camera available before calling this method
+(void)openCameraFromViewController:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)viewController {
    UIImagePickerController *imgPicker = [UIImagePickerController new];
    imgPicker.delegate = viewController;
    
    imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [(UIViewController *)viewController presentViewController:imgPicker animated:YES completion:nil];
}

#pragma mark - TesseractDelegate

//perform on background thread
+(NSString *)target:(id<TesseractDelegate>)target recognizeImageWithTesseract:(UIImage *)image {
    
    // process image
//    UIImage *imageToTest = [image binaryImageFromAdaptiveThresholdingWithAreaRadius:15 andConstant:3];
    GPUImageAdaptiveThresholdFilter *filter = [[GPUImageAdaptiveThresholdFilter alloc] init];
    UIImage *imageToRead = [filter imageByFilteringImage:image];
    
    // run OCR on processed image
    Tesseract *tesseract = [[Tesseract alloc] initWithLanguage:@"eng"];
    [tesseract setVariableValue:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz." forKey:@"tessedit_char_whitelist"];
    tesseract.delegate = target;
    [tesseract setImage:imageToRead];
    [tesseract recognize];
    NSLog(@"%@", tesseract.recognizedText);
    return tesseract.recognizedText;
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract {
    //    NSLog(@"progress: %d", tesseract.progress);
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

#pragma mark - Helper Methods

+(BOOL)stringProbablyDoesContainSubtotal:(NSString *)string {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"S[A-Za-z0-9]BT[A-Za-z0-9]T[A-Za-z0-9]L" options:0 error:&error];
    return [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])] > 0;
}

+(BOOL)stringIsProbablyEntirelyNumbers:(NSString *)string {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[0-9]{2,}" options:0 error:&error];
    return [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])] > 0;
}

+(BOOL)lineIsBeginningOfItemList:(NSString *)line {
    NSMutableArray *words = [[line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
    
    for(int j = 0; j < [words count]; j++){
        //words of length 2 or less are almost never useful, e.g. '20 oz'
        if([words[j] length] < 3){
            [words removeObjectAtIndex:j];
            j--;
        }
    }
    
    if([words count] == 0) {
        return NO;
    }
    
    NSString *firstWord = words[0];
    NSString *lastWord = words[[words count]-1];
    
    if([self stringIsProbablyEntirelyNumbers:firstWord]) {
        return NO;
    }
    
    if(![self stringIsProbablyEntirelyNumbers:lastWord]) {
        return NO;
    }
    
    // check if first word contains a period; words with periods are likely to be prices
    if([firstWord rangeOfString:@"."].location != NSNotFound) {
        return NO;
    }
    
    // check if last word contains a period, e.g. "3.25"
    if([lastWord rangeOfString:@"."].location == NSNotFound) {
        return NO;
    }
    
    return YES;
}

@end
