//
//  ITSecondViewController.m
//  MatchedUp
//
//  Created by yousheng chang on 8/31/14.
//  Copyright (c) 2014 InfoTech Inc. All rights reserved.
//

#import "ITSecondViewController.h"

@interface ITSecondViewController ()

@end

@implementation ITSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    PFQuery *query = [PFQuery queryWithClassName:kITPhotoClassKey];
    [query whereKey:kITPhotoUserKey equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if([objects count] >0){
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kITPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.profilePictureImageView.image = [UIImage imageWithData:data];
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
