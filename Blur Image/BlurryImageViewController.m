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
#import "UIImage+BlurredImage.h"



@implementation BlurryImageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setup];
}


- (void)setup
{
	// A block to setup the slider -> label relationship
	RACSignal *(^ setupSlider)(UISlider *slider, UILabel *label, NSInteger initialValue) = ^(UISlider *slider, UILabel *label, NSInteger initialValue) {
		RACSignal *signal = [[[slider rac_newValueChannelWithNilValue:@(0)] startWith:@(initialValue)] map:^(NSNumber *value) {
			// Round the slider to the nearest whole value
			return @(round(value.doubleValue));
		}];
		
		RAC(slider, value) = signal;
		RAC(label, text) = [signal map:^id(NSNumber *number) { return [number stringValue]; }];
		return [signal distinctUntilChanged];
	};
	
	
	// Bind the sliders to their respective label
	RACSignal *radiusSignal = setupSlider(self.radiusSlider, self.radiusNumberLabel, 50);
	RACSignal *repetitionsSignal = setupSlider(self.repetitionSlider, self.repetitionNumberLabel, 3);
	
	
	// Load the image for the selected segment
	RACSignal *sharpImageSignal = [[[self.selectedImageSegmentedControl rac_newSelectedSegmentIndexChannelWithNilValue:@(0)] startWith:@(0)] map:^id(NSNumber *selectedSegmentNumber) {
		NSInteger selectedSegment = [selectedSegmentNumber integerValue];
		NSArray *availableImageURLs = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"jpg" subdirectory:@"Example Images"];
		
		if(selectedSegment < availableImageURLs.count) {
			NSURL *imageURL = [availableImageURLs objectAtIndex:selectedSegment];
			NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
			
			if(imageData) {
				return [[UIImage alloc] initWithData:imageData];
			}
		}
		
		return nil;
	}];
	
	
	// Combine the slider values and selected image, and calculate a blurred representation
	RACSignal *blurredImageSignal = [RACSignal combineLatest:@[radiusSignal, repetitionsSignal, sharpImageSignal] reduce:^(NSNumber *radiusValue, NSNumber *repetitionsValue, UIImage *sharpImage) {
		NSDate *startTime = [NSDate date];
		
		UIImage *blurredImage = [sharpImage blurredImageWithRadius:[radiusValue integerValue]
													   repetitions:[repetitionsValue integerValue]];
		
		return RACTuplePack(blurredImage, @(-[startTime timeIntervalSinceNow]));
	}];
	
	
	// Bind the resulting image to the view
	UIImageView *imageView = (UIImageView *)self.view;
	imageView.contentMode = UIViewContentModeCenter;	// Draw at 1:1
	
	RAC(imageView, image) = [blurredImageSignal map:^id(RACTuple *imageTuple) {
		return imageTuple.first;
	}];
	
	RAC(self.durationLabel, text) = [blurredImageSignal map:^id(RACTuple *imageTuple) {
		NSTimeInterval duration = [imageTuple.second floatValue];
		
		return [NSString stringWithFormat:@"Took %.3f seconds", duration];
	}];
}



@end
