//
//  BlurryImageViewController.m
//  Blur Image
//
//  Created by Harry Jordan on 10/08/2014.
//  Copyright (c) 2014 Inquisitive Software. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//


#import "BlurryImageViewController.h"

#import "ReactiveCocoa.h"
#import "UIControl+RACSignalSupportPrivate.h"

#import "UIImage+BlurredImage.h"



@implementation BlurryImageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setup];
}


- (void)setup
{
	// Bind the radius slider to its label
	NSInteger initialRadius = 50;
	
	RACSignal *radiusIsBeingChangedSignal = [[[self.radiusSlider rac_newValueChannelWithNilValue:@(0)] startWith:@(initialRadius)] map:^(NSNumber *value) {
		// Round the slider to the nearest whole value
		return @(round(value.doubleValue));
	}];
	
	// Set the slider and label to the rounded values
	RAC(self.radiusSlider, value) = radiusIsBeingChangedSignal;
	RAC(self.radiusNumberLabel, text) = [radiusIsBeingChangedSignal map:^id(NSNumber *number) { return [number stringValue]; }];
	
	
	// Uses a private category on UIControl
	// but this allows us to update the image UISlider ends editing
	// (the 'right' way would be to extend ReactiveCocoa, but this gets the job done)
	RACSignal *radiusDidChangeSignal = [[self.radiusSlider rac_channelForControlEvents:UIControlEventTouchUpInside key:@"value" nilValue:@(0)] startWith:@(initialRadius)];
	
	
	// Load the image for the currently selected segment
	RACSignal *sharpImageSignal = [[[self.selectedImageSegmentedControl rac_newSelectedSegmentIndexChannelWithNilValue:@(0)] startWith:@(0)] map:^id(NSNumber *selectedSegmentNumber) {
		return [self exampleImageAtIndex:[selectedSegmentNumber integerValue]];
	}];
	
	// Calculate a blurred image
	RACSignal *blurredImageSignal = [RACSignal combineLatest:@[radiusDidChangeSignal, sharpImageSignal] reduce:^(NSNumber *radiusValue, UIImage *sharpImage) {
		NSDate *startTime = [NSDate date];
		UIImage *blurredImage = [sharpImage blurredImageWithRadius:[radiusValue integerValue]];
		
		return RACTuplePack(blurredImage, @(-[startTime timeIntervalSinceNow]));
	}];
	
	
	UIImageView *imageView = (UIImageView *)self.view;
	imageView.contentMode = UIViewContentModeCenter;	// Draw at 1:1
	
	// Bind the resulting image to the view
	RAC(imageView, image) = [blurredImageSignal map:^id(RACTuple *imageTuple) {
		return imageTuple.first;
	}];
	
	// Bind the time it took to generate the image to a label
	RAC(self.durationLabel, text) = [blurredImageSignal map:^id(RACTuple *imageTuple) {
		NSTimeInterval duration = [imageTuple.second floatValue];
		return [NSString stringWithFormat:@"Took %.3f seconds", duration];
	}];
}


- (UIImage *)exampleImageAtIndex:(NSInteger)imageIndex
{
	NSArray *availableImageURLs = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"jpg" subdirectory:@"Example Images"];
	
	if(imageIndex < availableImageURLs.count && imageIndex >= 0) {
		NSURL *imageURL = [availableImageURLs objectAtIndex:imageIndex];
		NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
		
		if(imageData) {
			return [[UIImage alloc] initWithData:imageData];
		}
	}
	
	NSLog(@"Couldn't find example image at index: %ld", (long)imageIndex);
	return nil;
}


@end
