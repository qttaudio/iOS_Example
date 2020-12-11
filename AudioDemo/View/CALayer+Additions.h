//
//  CALayer+Additions.h
//  AudioDemo
//
//  Created by apple on 2020/11/5.
//  Copyright © 2020 audio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface CALayer (Additions)
- (void)setBorderColorFromUIColor:(UIColor *)color;
@end

NS_ASSUME_NONNULL_END
