//
//  Blur_ImageTests.m
//  Blur ImageTests
//
//  Created by Harry Jordan on 10/08/2014.
//  Copyright (c) 2014 Inquisitive Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ReactiveCocoa.h"
#import "UIImage+BlurredImage.h"


@interface Blur_ImageTests : XCTestCase

@property (strong) RACSequence *originalImagesSequence;

@end

@implementation Blur_ImageTests

- (void)setUp
{
    [super setUp];
	
	NSArray *availableImageURLs = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"jpg" subdirectory:@"Example Images"];
	self.originalImagesSequence = [[availableImageURLs rac_sequence] map:^id(NSURL *imageURL) {
		NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
		
		if(imageData) {
			return [[UIImage alloc] initWithData:imageData];
		}
		
		return nil;
	}];
}


- (void)tearDown
{
	self.originalImagesSequence = nil;
	
    [super tearDown];
}

- (void)testBlurringASequenceOfImages
{
	RACSequence *blurredImageSequence =[self.originalImagesSequence map:^id(UIImage *sharpImage) {
		return [sharpImage blurredImageWithRadius:20.0];
	}];
	
	NSArray *blurredImages = [blurredImageSequence array];
	XCTAssert(blurredImages.count == 4, @"");
}

@end
