//
//  UIImage+BlurredImage.m
//  Harry Jordan
//
//  Created by Harry Jordan on 09/08/2014.
//  Copyright (c) 2014 Harry Jordan, Inquisitive Software. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//


#import "UIImage+BlurredImage.h"
@import Accelerate;


@implementation UIImage (BlurredImage)


- (UIImage *)blurredImage
{
	return [self blurredImageWithRadius:125];
}


- (UIImage *)blurredImageWithRadius:(uint32_t)radius
{
	if((radius & 1) == 0) {
		radius ++;
	}
	
	if(radius > 127) {
		radius = 127;
		NSLog(@"blurredImageWithRadius: 127 seems to be the maximum kernel size for vImageTentConvolve_ARGB8888");
	} else if(radius < 1) {
		radius = 1;
		NSLog(@"-blurredImageWithRadius: Radius must be positive");
	}
	
	
	CGImageRef sourceImageRef = [self CGImage];
	
	vImage_CGImageFormat sourceImageFormat = {
		.bitsPerComponent = (uint32_t)CGImageGetBitsPerComponent(sourceImageRef),
		.bitsPerPixel = (uint32_t)CGImageGetBitsPerPixel(sourceImageRef),
		.bitmapInfo = CGImageGetBitmapInfo(sourceImageRef),
		.colorSpace = CGImageGetColorSpace(sourceImageRef),
	};
	
	vImage_Buffer inputBuffer;
	vImage_Error error = vImageBuffer_InitWithCGImage(&inputBuffer, &sourceImageFormat, NULL, sourceImageRef, kvImageNoFlags);
	
	// Prepare the input and output buffers
	CGSize imageSize = CGSizeMake(CGImageGetWidth(sourceImageRef), CGImageGetHeight(sourceImageRef));
	NSInteger bytesPerRow = CGImageGetBytesPerRow(sourceImageRef);
	void *pixelBuffer = malloc(bytesPerRow * imageSize.height);
	vImage_Buffer blurredBuffer = {pixelBuffer, imageSize.height, imageSize.width, bytesPerRow};
	error = kvImageNoError;

	// Apply the convolution the desired number of times
	// http://elynxsdk.free.fr/ext-docs/Blur/Fast_box_blur.pdf
	NSInteger numberOfRepetitions = 1;
	
	for(NSUInteger repetition = 0; repetition < numberOfRepetitions; repetition++) {
		error = vImageTentConvolve_ARGB8888(&inputBuffer, &blurredBuffer, NULL, 0, 0, radius, radius, NULL, kvImageEdgeExtend);
		
		if(error != kvImageNoError) {
			NSLog(@"Couldn't blur image due to vImage_Error: %ld", error);
			break;
		}
	}
	
	
	UIImage *destinationImage = nil;
	
	if(error == kvImageNoError) {
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef context = CGBitmapContextCreate(pixelBuffer, imageSize.width, imageSize.height, 8, bytesPerRow, colorSpace, CGImageGetBitmapInfo(sourceImageRef));
		CGImageRef destinationImageRef = CGBitmapContextCreateImage(context);
		CGContextRelease(context);
		CGColorSpaceRelease(colorSpace);
		
		destinationImage = [UIImage imageWithCGImage:destinationImageRef];
		CGImageRelease(destinationImageRef);
	}
	
	free(pixelBuffer);
	
	return destinationImage;
}



@end
