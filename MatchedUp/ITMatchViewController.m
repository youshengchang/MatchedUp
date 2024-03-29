//
//  ITMatchViewController.m
//  MatchedUp
//
//  Created by yousheng chang on 9/6/14.
//  Copyright (c) 2014 InfoTech Inc. All rights reserved.
//

#import "ITMatchViewController.h"

@interface ITMatchViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *matchedUserImageView;
@property (strong, nonatomic) IBOutlet UIImageView *currentUserImageView;
@property (strong, nonatomic) IBOutlet UIButton *viewChatsButton;
@property (strong, nonatomic) IBOutlet UIButton *keepSearchingButton;

@end

@implementation ITMatchViewController

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
    NSLog(@"matchedUserImage = %@", self.matchedUserImage);
    PFQuery *query = [PFQuery queryWithClassName:kITPhotoClassKey];
    [query whereKey:kITPhotoUserKey equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if([objects count] >0){
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kITPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.currentUserImageView.image = [UIImage imageWithData:data];
                self.matchedUserImageView.image = self.matchedUserImage;
            }];
        }
    }];
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

#pragma mark - IBActions

- (IBAction)viewChatsButtonPressed:(UIButton *)sender {
    
    [self.delegate presentMatchesViewController];
    
}

- (IBAction)keepSearchingButtonPressed:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
