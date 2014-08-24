# Blur  Image
Blur Image is a category on UIImage that creates a blurry image using CPU optimised vector functions provided by Apple's Accelerate framework.

```
@interface UIImage (BlurredImage)

- (UIImage *)blurredImage;
- (UIImage *)blurredImageWithRadius:(uint32_t)radius;

@end
```

# Example App
The example app is my first foray into using ReactiveCocoa, which is fun. It's very simple.

![Example App Screenshot](https://raw.githubusercontent.com/inquisitiveSoft/Blur-Image/master/Example%20App/Example%20App%20Screenshot.png)

# License
Released under the MIT license: http://opensource.org/licenses/mit-license.php

The test app contains core source files for ReactiveCocoa (rather than adding it as a submodule) to make this project easy to check out and play around with. The ReactiveCocoa source is under a seperate License which can be found inside the ReactiveCocoa folder.