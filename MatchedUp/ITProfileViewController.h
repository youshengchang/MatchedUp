//
//  ITProfileViewController.h
//  MatchedUp
//
//  Created by yousheng chang on 9/5/14.
//  Copyright (c) 2014 InfoTech Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ITProfileViewControllerDelegate <NSObject>

-(void)didPressLike;
-(void)didPressDislike;

@end
@interface ITProfileViewController : UIViewController

@property (strong, nonatomic)PFObject *photo;
@property (weak, nonatomic) id <ITProfileViewControllerDelegate> delegate;

@end
