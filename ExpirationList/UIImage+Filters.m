//
//  UIImage+Filters.m
//  Tesseract OCR iOS
//
//  Created by Daniele on 31/07/14.
//  Copyright (c) 2014 Daniele Galiotto - www.g8production.com. All rights reserved.
//

#import "UIImage+Filters.h"

@implementation UIImage (Filters)

-(UIImage *)blackAndWhite
{
    CIImage *beginImage = [CIImage imageWithCGImage:self.CGImage];

    CIImage *blackAndWhite = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, beginImage, @"inputBrightness", @0.0, @"inputContrast", @1.1, @"inputSaturation", @0.0, nil].outputImage;
    CIImage *output = [CIFilter filterWithName:@"CIExposureAdjust" keysAndValues:kCIInputImageKey, blackAndWhite, @"inputEV", @0.7, nil].outputImage;
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgiimage = [context createCGImage:output fromRect:output.extent];
    UIImage *newImage = [UIImage imageWithCGImage:cgiimage scale:0 orientation:self.imageOrientation];
    
    CGImageRelease(cgiimage);
    return newImage;
}

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

-(UIImage *)binaryImageFromAdaptiveThresholdingWithAreaRadius:(int)radius andConstant:(int)constant {
    // Do EXTREME PROCESSING!!
    UIImage *imageAsGrayScale = [self blackAndWhite];
    
    CGSize size = self.size;
    int width = size.width;
    int height = size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    //second array solely for reading pixels so results aren't affected by previously altered pixels
    uint32_t *pixelsToReadFrom = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    memset(pixelsToReadFrom, 0, width * height * sizeof(uint32_t));
    
    //create color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create contexts with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    CGContextRef contextToReadFrom = CGBitmapContextCreate(pixelsToReadFrom, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our contexts which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [imageAsGrayScale CGImage]);
    CGContextDrawImage(contextToReadFrom, CGRectMake(0, 0, width, height), [imageAsGrayScale CGImage]);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    for(int y = 0; y < height; y++) {
        
        //inner loop performs tasks on concurrent queue since write conflicts are not a problem
        dispatch_apply(width, queue, ^(size_t x) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y*width + x];
            int xMin, yMin, xMax, yMax;
            
            //set up bounds of local region to use for thresholding
            xMin = MAX(0, (int)x - radius);
            yMin = MAX(0, y - radius);
            xMax = MIN(width-1, (int)x + radius);
            yMax = MIN(height-1, y + radius);
            
            //loop through region near pixel to find average pixel value
            int average = 0;
            for(int j = yMin; j < yMax; j++){
                for(int i = xMin; i < xMax; i++){
                    uint8_t *localRGBAPixel = (uint8_t *) &pixelsToReadFrom[j*width + i];
                    average += localRGBAPixel[RED]; //all RGB values are the same after applying grayscale function; red chosen arbitrarily
                }
            }
            //average value of local pixels minus constant
            average = (int)((float) average / pow(radius*2 + 1, 2)) - constant;
            if(rgbaPixel[RED] > average){
                //pixels brighter than average are set to white (1)
                uint32_t white = 0xFF;
                rgbaPixel[RED] = white;
                rgbaPixel[BLUE] = white;
                rgbaPixel[GREEN] = white;
            } else {
                //else, set to black (0)
                uint32_t black = 0x0;
                rgbaPixel[RED] = black;
                rgbaPixel[BLUE] = black;
                rgbaPixel[GREEN] = black;
            }
        });
    }

    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGContextRelease(contextToReadFrom);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    free(pixelsToReadFrom);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image scale:0 orientation:self.imageOrientation];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}

- (UIImage *)grayScale
{
    CGSize size = [self size];
    int width = size.width;
    int height = size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
            
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image scale:0 orientation:self.imageOrientation];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}

-(UIImage *)normalizeSize {
    //normalize to height of 2000
    return [UIImage scaleImage:self toResolution:1500];
}

+ (UIImage *)scaleImage:(UIImage*)image toResolution:(int)resolution {
    CGImageRef imgRef = [image CGImage];
    float width, height;
    if(image.imageOrientation == UIImageOrientationUp ||
       image.imageOrientation == UIImageOrientationDown ||
       image.imageOrientation == UIImageOrientationUpMirrored ||
       image.imageOrientation == UIImageOrientationDownMirrored) {
        width = CGImageGetWidth(imgRef);
        height = CGImageGetHeight(imgRef);
    }
    else {
        height = CGImageGetWidth(imgRef);
        width = CGImageGetHeight(imgRef);
    }
    
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    //if already at the minimum resolution, return the orginal image, otherwise scale
    
    CGFloat ratio = resolution / MAX(width, height);
    NSLog(@"ratio, w, h: %f, %f, %f", ratio, bounds.size.width, bounds.size.height);
    
    bounds.size.width = width*ratio;
    bounds.size.height = height*ratio;

    UIGraphicsBeginImageContext(bounds.size);
    
    [image drawInRect:CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height)];
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

@end
