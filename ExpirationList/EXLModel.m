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
#import "TextCheckerHelper.h"

@implementation EXLModel

#pragma mark - String Processing

+(NSSet *)itemsFromOCROutput:(NSString *)ocrOutput {
    // break text into an array of individual lines
    NSMutableArray *lines = [[ocrOutput componentsSeparatedByString:@"\n"] mutableCopy];
    
    for(int i = 0; i < [lines count]; i++) {
        
        // delete empty lines
        if([[lines[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            [lines removeObjectAtIndex:i];
            i--;
            continue;
        }
        
        // break lines into array of individual whitespace-separated words
        NSMutableArray *words = [[lines[i] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
        
        // if word length is 2 or less, word is most likely not useful or noise
        for(int j = 0; j < [words count]; j++) {
            if([words[j] length] < 3) {
                [words removeObjectAtIndex:j];
                j--;
            }
        }
        
        // check if the last word of a line is a price
        if([words count] > 0) {
            NSString *lastWord = words[[words count]-1];
            if([lastWord rangeOfString:@"."].location == NSNotFound ||
               ![self stringIsProbablyEntirelyNumbers:lastWord]) {
                
                // if not a price, delete the line
                [lines removeObjectAtIndex:i];
                i--;
                continue;
            }
        }
        
        // if line is now empty, delete the line and continue
        if(![words count]) {
            [lines removeObjectAtIndex:i];
            i--;
            continue;
        }
    }
    
    for(int i = 0; i < [lines count]; i++) {
        // break lines into array of individual whitespace-separated words
        NSMutableArray *words = [[lines[i] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] mutableCopy];
        
        // remove numbers and prices
        for(int j = 0; j < [words count]; j++) {
            if([self stringIsProbablyEntirelyNumbers:words[j]] || [words[j] length] < 3) {
                [words removeObjectAtIndex:j];
                j--;
            }
        }
        
        // autocorrect words in line
        UITextChecker *textChecker = [TextCheckerHelper sharedHelper].textChecker;
        for(int j = 0; j < [words count]; j++) {
            if([textChecker rangeOfMisspelledWordInString:words[j]
                                                    range:NSMakeRange(0, [words[j] length])
                                               startingAt:0
                                                     wrap:NO
                                                 language:@"en-US"].location != NSNotFound) {
                
                NSArray *suggestions = [textChecker guessesForWordRange:NSMakeRange(0, [words[j] length])
                                                               inString:words[j]
                                                               language:@"en_US"];
                
                // only correct word if guess is found
                if([suggestions count] > 0) {
                    words[j] = suggestions[0];
                }
                else {
                    [words removeObjectAtIndex:j];
                    j--;
                }
            }
        }
        
        // remove lines if empty, otherwise overwrite line
        if(![words count]) {
            [lines removeObjectAtIndex:i];
            i--;
            continue;
        }
        else {
            lines[i] = [[words componentsJoinedByString:@" "] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        
        // remove non-items
        if([[lines[i] uppercaseString] isEqualToString:@"SUB TOTAL"] ||
           [[lines[i] uppercaseString] isEqualToString:@"SUBTOTAL"] ||
           [[lines[i] uppercaseString] isEqualToString:@"TOTAL"] ||
           [[lines[i] uppercaseString] isEqualToString:@"TAX"]) {
            [lines removeObjectAtIndex:i];
            i--;
            continue;
        }
    }
    return [NSSet setWithArray:lines];
}

#pragma mark - UIImagePickerControllerDelegate

// check if camera available before calling this method
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
//    GPUImageAdaptiveThresholdFilter *filter = [[GPUImageAdaptiveThresholdFilter alloc] init];
//    UIImage *imageToRead = [filter imageByFilteringImage:image];
    
    // run OCR on processed image
    Tesseract *tesseract = [[Tesseract alloc] initWithLanguage:@"eng"];
    [tesseract setVariableValue:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz." forKey:@"tessedit_char_whitelist"];
    tesseract.delegate = target;
    [tesseract setImage:[image normalizeSize]];
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
