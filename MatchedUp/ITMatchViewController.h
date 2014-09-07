//
//  ITMatchViewController.h
//  MatchedUp
//
//  Created by yousheng chang on 9/6/14.
//  Copyright (c) 2014 InfoTech Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ITMatchViewControllerDelegate <NSObject>

-(void)presentMatchesViewController;

@end

@interface ITMatchViewController : UIViewController

@property (strong, nonatomic) UIImage *matchedUserImage;
@property (weak) id <ITMatchViewControllerDelegate> delegate;
@end
