//
//  ITProfileViewController.m
//  MatchedUp
//
//  Created by yousheng chang on 9/5/14.
//  Copyright (c) 2014 InfoTech Inc. All rights reserved.
//

#import "ITProfileViewController.h"

@interface ITProfileViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;

@end

@implementation ITProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    PFFile *pictureFile = self.photo[kITPhotoPictureKey];
    [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.profilePictureImageView.image = [UIImage imageWithData:data];
        
    }];
    PFUser *user = self.photo[kITPhotoUserKey];
    self.locationLabel.text = user[kITUserProfileKey][kITUserProfileLocationKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", user[kITUserProfileKey][kITUserProfileAgeKey]];
    if(user[kITUserProfileKey][kITUserProfileRelationshipStatusKey] == nil){
        self.statusLabel.text = @"Single";
    }else {
        self.statusLabel.text = user[kITUserProfileKey][kITUserProfileRelationshipStatusKey];
    }
    
    self.tagLineLabel.text = user[kITUserProfileKey][kITUserTagLineKey];
    
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    self.title = user[kITUserProfileKey][kITUserProfileFirstNameKey];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark IBActions
- (IBAction)likeButtonPressed:(UIButton *)sender {
    [self.delegate didPressLike];
}

- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    [self.delegate didPressDislike];
}

@end
