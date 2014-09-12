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
#import "ITMatchesViewController.h"
#import "ITTransitionAnimator.h"


@interface ITHomeViewController () <ITMatchViewControllerDelegate, ITProfileViewControllerDelegate, UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;
@property (strong, nonatomic) IBOutlet UIView *labelContainerView;
@property (strong, nonatomic) IBOutlet UIView *buttonContainerView;

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
    [self setUpViews];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    self.photoImageView.image = nil;
    self.firstNameLabel.text = nil;
    self.ageLabel.text = nil;
    
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:kITPhotoClassKey];
    [query whereKey:kITPhotoUserKey notEqualTo:[PFUser currentUser]];
    [query includeKey:kITPhotoUserKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            self.photos = objects;
            if([self allowPhoto] == NO){
                [self setupNextPhoto];
            }else{
                 [self queryForCurrentPhotoIndex];
            }
           
        }else{
            NSLog(@"%@", error);
        }
    }];

    
}

-(void)setUpViews
{
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
    [self addShadowForView:self.buttonContainerView];
    [self addShadowForView:self.labelContainerView];
    self.photoImageView.layer.masksToBounds = YES;
}

-(void)addShadowForView:(UIView *)view
{
    view.layer.masksToBounds = NO;
    view.layer.cornerRadius = 4;
    view.layer.shadowRadius = 1;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowOpacity = 0.25;
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
        profileVC.delegate = self;
    }
    /*else if([segue.identifier isEqualToString:@"homeToMatchSegue"]){
        NSLog(@"homeToMatchSegue");
        ITMatchViewController *matchVC = segue.destinationViewController;
        matchVC.matchedUserImage = self.photoImageView.image;
        matchVC.delegate = self;
    }*/
    else if([segue.identifier isEqualToString:@"homeToMatchesSegue"]){
        NSLog(@"homeToMatchesSegue");
        
       
    }
}


#pragma mark - IB actions
- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"homeToMatchesSegue" sender:nil];
}

- (IBAction)settingsBarButtonItemPressed:(UIBarButtonItem *)sender {
}
- (IBAction)likeButtonPressed:(UIButton *)sender {
    [self checkLike];
    //[self performSegueWithIdentifier:@"homeToMatchSegue" sender:nil];
    UIStoryboard *myStoryBoard = self.storyboard;
    ITMatchViewController *matchViewController = [myStoryBoard instantiateViewControllerWithIdentifier:@"matchVC"];
    matchViewController.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:.75];
    matchViewController.transitioningDelegate = self;
    matchViewController.matchedUserImage = self.photoImageView.image;
    matchViewController.delegate = self;
    matchViewController.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:matchViewController animated:YES completion:nil];

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
}

-(void)setupNextPhoto
{
    if(self.currentPhotoIndex + 1 < self.photos.count){
        self.currentPhotoIndex ++;
        if([self allowPhoto] == NO){
            [self setupNextPhoto];
        }else{
            [self queryForCurrentPhotoIndex];
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No more user's photo to view" message:@"Check back later for more photos" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (BOOL)allowPhoto
{
    
    int maxAge = [[NSUserDefaults standardUserDefaults]integerForKey:kITAgeMaxKey];
    BOOL men = [[NSUserDefaults standardUserDefaults]boolForKey:kITMenEnabledKey];
    BOOL women = [[NSUserDefaults standardUserDefaults]boolForKey:kITWomenEnabledKey];
    BOOL single = [[NSUserDefaults standardUserDefaults]boolForKey:kITSingleEnabledKey];
    
    NSLog(@"in allowPhto(): women = %d", women);
    
    PFObject *photo = self.photos[self.currentPhotoIndex];
    PFUser *user = photo[kITPhotoUserKey];
    int userAge = [user[kITUserProfileKey][kITUserProfileAgeKey] intValue];
    NSString *gender = user[kITUserProfileKey][kITUserProfileGenderkey];
    NSString *relationshipStatus = user[kITUserProfileKey][kITUserProfileRelationshipStatusKey];
    
    NSLog(@"in allowPhoto(): gender = %@", gender);
    
    if(userAge > maxAge){
        return NO;
    }else if(men == NO && [gender isEqualToString:@"male"]){
        return NO;
    }else if(women == NO && [gender isEqualToString:@"female"]){
        return NO;
    }
    else if(single == NO && ([relationshipStatus isEqualToString:@"single"] || relationshipStatus == nil)){
        return NO;
    }else{
        return YES;
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
    [query whereKey:kITActivityToUserKey equalTo:[PFUser currentUser]];
    [query whereKey:kITActivityTypeKey equalTo:kITActivityTypeLikeKey];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if([objects count] > 0){
            [self createChatRoom];
        }
    }];
}

-(void)createChatRoom
{
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:kITChatRoomClassKey];
    [queryForChatRoom whereKey:kITChatRoomUser1Key equalTo:[PFUser currentUser]];
    [queryForChatRoom whereKey:kITChatRoomUser2Key equalTo:self.photo[kITPhotoUserKey]];
    PFQuery *queryForChatRoomInverse = [PFQuery queryWithClassName:kITChatRoomClassKey];
    [queryForChatRoomInverse whereKey:kITChatRoomUser1Key equalTo:self.photo[kITPhotoUserKey]];
    [queryForChatRoomInverse whereKey:kITChatRoomUser2Key equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatRoomInverse]];
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error){
            NSLog(@"%@", error);
        }
        else if([objects count] ==0){
            PFObject *chatroom = [PFObject objectWithClassName:kITChatRoomClassKey];
            [chatroom setObject:[PFUser currentUser] forKey:kITChatRoomUser1Key];
            [chatroom setObject:self.photo[kITPhotoUserKey] forKey:kITChatRoomUser2Key];
            [chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
               // [self performSegueWithIdentifier:@"homeToMatchSegue" sender:nil];
                /*
                UIStoryboard *myStoryBoard = self.storyboard;
                ITMatchViewController *matchViewController = [myStoryBoard instantiateViewControllerWithIdentifier:@"matchVC"];
                matchViewController.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:.75];
                matchViewController.transitioningDelegate = self;
                matchViewController.matchedUserImage = self.photoImageView.image;
                matchViewController.delegate = self;
                matchViewController.modalPresentationStyle = UIModalPresentationCustom;
                [self presentViewController:matchViewController animated:YES completion:nil];
                 */
                
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

#pragma mark - ITProfileViewController Delegate
-(void)didPressDislike
{
    [self.navigationController popViewControllerAnimated:NO];
    [self checkDislike];
}

-(void)didPressLike
{
    [self.navigationController popViewControllerAnimated:NO];
    [self checkLike];
}

#pragma mark - UIViewControllerTransitioningDelegate

-(id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    ITTransitionAnimator *animator = [[ITTransitionAnimator alloc]init];
    animator.presenting = YES;
    return animator;
    
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    ITTransitionAnimator *animator = [[ITTransitionAnimator alloc]init];
    return animator;
    
}
@end
