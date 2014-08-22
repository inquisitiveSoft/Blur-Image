//
//  UIImage+BlurredImage.h
//  Harry Jordan
//
//  Created by Harry Jordan on 09/08/2014.
//  Copyright (c) 2014 Harry Jordan, Inquisitive Software. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//


#import <UIKit/UIKit.h>


@interface UIImage (BlurredImage)

- (UIImage *)blurredImage;
- (UIImage *)blurredImageWithRadius:(uint32_t)radius;

@end
