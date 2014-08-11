//
//  BlurryImageViewController.h
//  Blur Image
//
//  Created by Harry Jordan on 10/08/2014.
//  Copyright (c) 2014 Inquisitive Software. All rights reserved.
//
//  Released under the MIT license: http://opensource.org/licenses/mit-license.php
//


#import <UIKit/UIKit.h>


@interface BlurryImageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
@property (weak, nonatomic) IBOutlet UISlider *repetitionSlider;

@property (weak, nonatomic) IBOutlet UILabel *repetitionNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *radiusNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectedImageSegmentedControl;

@end
