//
//  UIImage+Filters.h
//  Tesseract OCR iOS
//
//  Created by Daniele on 31/07/14.
//  Copyright (c) 2014 Daniele Galiotto - www.g8production.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Filters)

/* Return a copy of self with all pixels set to gray by averaging the RGB values of each pixel.
 */
-(UIImage *)blackAndWhite;


/* Return a grayscale copy of self with weighted RGB averages.
 */
-(UIImage *)grayScale;


/* Turns image into binary image, calculating values for pixels on CPU using dispatch_apply.
 * Do not use.
 */
-(UIImage *)binaryImageFromAdaptiveThresholdingWithAreaRadius:(int)radius andConstant:(int)constant;


/* Scale an image to a fixed size for OCR reading.
 */
-(UIImage *)normalizeSize;

@end
