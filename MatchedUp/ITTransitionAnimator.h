//
//  ITTransitionAnimator.h
//  MatchedUp
//
//  Created by yousheng chang on 9/12/14.
//  Copyright (c) 2014 InfoTech Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITTransitionAnimator : NSObject<UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;

@end
