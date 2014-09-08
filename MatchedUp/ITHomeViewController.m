//
//  ITHomeViewController.m
//  MatchedUp
//
//  Created by yousheng chang on 9/2/14.
//  Copyright (c) 2014 InfoTech Inc. All rights reserved.
//

#import "ITHomeViewController.h"
#import "ITTestUser.h"
#import "ITProfileViewController.h"
#import "ITMatchViewController.h"


@interface ITHomeViewController () <ITMatchViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;

@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) PFObject *photo;
@property (strong, nonatomic) NSMutableArray *activities;


@property (nonatomic) int currentPhotoIndex;
@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL isDislikedByCurrentUser;

@end

@implementation ITHomeViewController

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
    //[ITTestUser saveTestUserToParse];
    
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:kITPhotoClassKey];
    [query whereKey:kITPhotoUserKey notEqualTo:[PFUser currentUser]];
    //[query whereKey:kITPhotoUserKey equalTo:[PFUser currentUser]];
    [query includeKey:kITPhotoUserKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            self.photos = objects;
            [self queryForCurrentPhotoIndex];
        }else{
            NSLog(@"%@", error);
        }
        
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"%@", segue.identifier);
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"homeToProfileSegue"]){
        
        ITProfileViewController *profileVC = segue.destinationViewController;
        profileVC.photo = self.photo;
    }
    else if([segue.identifier isEqualToString:@"homeToMatchSegue"]){
        NSLog(@"homeToMatchSegue");
        ITMatchViewController *matchVC = segue.destinationViewController;
        matchVC.matchedUserImage = self.photoImageView.image;
        matchVC.delegate = self;
    }
}


#pragma mark - IB actions
- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender {
}

- (IBAction)settingsBarButtonItemPressed:(UIBarButtonItem *)sender {
}
- (IBAction)likeButtonPressed:(UIButton *)sender {
    [self checkLike];
    [self performSegueWithIdentifier:@"homeToMatchSegue" sender:nil];
}
- (IBAction)infoButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"homeToProfileSegue" sender:nil];
}
- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    [self checkDislike];
}

#pragma mark - Helper method
-(void)queryForCurrentPhotoIndex
{
    if([self.photos count] > 0){
        self.photo = self.photos[self.currentPhotoIndex];
        PFFile *file = self.photo[kITPhotoPictureKey];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if(!error){
                UIImage *image = [UIImage imageWithData:data];
                self.photoImageView.image = image;
                [self updateView];
            }else NSLog(@"%@", error);
        }];
        PFQuery *queryForLike = [PFQuery queryWithClassName:kITActivityClassKey];
        [queryForLike whereKey:kITActivityTypeKey equalTo:kITActivityTypeLikeKey];
        [queryForLike whereKey:kITActivityPhotoKey equalTo:self.photo];
        [queryForLike whereKey:kITActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *queryForDislike = [PFQuery queryWithClassName:kITActivityClassKey];
        [queryForDislike whereKey:kITActivityTypeKey equalTo:kITActivityTypeDislikeKey];
        [queryForDislike whereKey:kITActivityPhotoKey equalTo:self.photo];
        [queryForLike whereKey:kITActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *likeAndDislikeQuery = [PFQuery orQueryWithSubqueries:@[queryForLike, queryForDislike]];
        [likeAndDislikeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                self.activities = [objects mutableCopy];
                NSLog(@"activities count: %d", [self.activities count]);
                
                if([self.activities count] == 0){
                    self.isLikedByCurrentUser = NO;
                    self.isDislikedByCurrentUser = NO;
                }else{
                    PFObject *activity = self.activities[0];
                    NSLog(@"actvity type: %@", activity[@"type"]);
                    
                    if([activity[kITActivityTypeKey] isEqualToString:kITActivityTypeLikeKey]){
                        self.isLikedByCurrentUser = YES;
                        self.isDislikedByCurrentUser = NO;
                    }else if([activity[kITActivityTypeKey] isEqualToString:kITActivityTypeDislikeKey]){
                        self.isLikedByCurrentUser = NO;
                        self.isDislikedByCurrentUser = YES;
                    }else{
                        //Some other type of the activity
                        
                    }
                }
                self.likeButton.enabled = YES;
                self.dislikeButton.enabled = YES;
                self.infoButton.enabled = YES;
            }
        }];
    }
}

-(void)updateView
{
    self.firstNameLabel.text = self.photo[kITPhotoUserKey][kITUserProfileKey][kITUserProfileFirstNameKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", self.photo[kITPhotoUserKey][kITUserProfileKey][kITUserProfileAgeKey]];
    self.tagLineLabel.text = self.photo[kITPhotoUserKey][kITUserTagLineKey];
}

-(void)setupNextPhoto
{
    if(self.currentPhotoIndex + 1 < self.photos.count){
        self.currentPhotoIndex ++;
        [self queryForCurrentPhotoIndex];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No more user's photo to view" message:@"Check back later for more photos" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)saveLike
{
    PFObject *likeActivity = [PFObject objectWithClassName:kITActivityClassKey];
    [likeActivity setObject:kITActivityTypeLikeKey forKey:kITActivityTypeKey];
    [likeActivity setObject:[PFUser currentUser] forKey:kITActivityFromUserKey];
    [likeActivity setObject:[self.photo objectForKey:kITPhotoUserKey] forKey:kITActivityToUserKey];
    [likeActivity setObject:self.photo forKey:kITActivityPhotoKey];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = YES;
        self.isDislikedByCurrentUser = NO;
        [self.activities addObject:likeActivity];
        [self checkForPhotoUserLikes];
        [self setupNextPhoto];
    }];
}

-(void)saveDislike
{
    PFObject *dislikeActivity = [PFObject objectWithClassName:kITActivityClassKey];
    [dislikeActivity setObject:kITActivityTypeDislikeKey forKey:kITActivityTypeKey];
    [dislikeActivity setObject:[PFUser currentUser] forKey:kITActivityFromUserKey];
    [dislikeActivity setObject:[self.photo objectForKey:kITPhotoUserKey] forKey:kITActivityToUserKey];
    [dislikeActivity setObject:self.photo forKey:kITActivityPhotoKey];
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = NO;
        self.isDislikedByCurrentUser = YES;
        [self.activities addObject:dislikeActivity];
        [self setupNextPhoto];
    }];
    
}

-(void)checkLike
{
    NSLog(@"isLikedByCurrentUser: %d", self.isLikedByCurrentUser);
    NSLog(@"isDislikedByCurrentUser: %d", self.isDislikedByCurrentUser);

    if(self.isLikedByCurrentUser){
        [self setupNextPhoto];
        return;
    }else if(self.isDislikedByCurrentUser){
        for(PFObject *activity in self.activities){
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveLike];
        
    }
    else{
        [self saveLike];
    }
}

-(void)checkDislike
{
    if(self.isDislikedByCurrentUser){
        [self setupNextPhoto];
        return;
    }
    else if(self.isLikedByCurrentUser){
        for(PFObject *activity in self.activities){
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveDislike];
    }
    else{
        [self saveDislike];
    }
}

-(void)checkForPhotoUserLikes
{
    PFQuery *query = [PFQuery queryWithClassName:kITActivityClassKey];
    [query whereKey:kITActivityFromUserKey equalTo:self.photo[kITPhotoUserKey]];
    [query whereKey:kITPhotoUserKey equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if([objects count] > 0){
            [self createChatRoom];
        }
    }];
}

-(void)createChatRoom
{
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryForChatRoom whereKey:@"user1" equalTo:[PFUser currentUser]];
    [queryForChatRoom whereKey:@"user2" equalTo:self.photo[kITPhotoUserKey]];
    PFQuery *queryForChatRoomInverse = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryForChatRoomInverse whereKey:@"user1" equalTo:self.photo[kITPhotoUserKey]];
    [queryForChatRoomInverse whereKey:@"user2" equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatRoomInverse]];
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if([objects count] ==0){
            PFObject *chatroom = [PFObject objectWithClassName:@"ChatRoom"];
            [chatroom setObject:[PFUser currentUser] forKey:@"user1"];
            [chatroom setObject:self.photo[kITPhotoUserKey] forKey:@"user2"];
            [chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self performSegueWithIdentifier:@"homeToMatchSegue" sender:nil];
            }];
        }
    }];
                              
}

#pragma mark - ITMatchViewController Delegate

-(void)presentMatchesViewController
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self performSegueWithIdentifier:@"homeToMatchesSegue" sender:nil];
    }];
}
@end
