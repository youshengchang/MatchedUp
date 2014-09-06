//
//  ITLoginViewController.m
//  MatchedUp
//
//  Created by yousheng chang on 8/31/14.
//  Copyright (c) 2014 InfoTech Inc. All rights reserved.
//

#import "ITLoginViewController.h"

@interface ITLoginViewController ()
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *ctivityIndicator;
@property (strong, nonatomic) NSMutableData *imageData;

@end

@implementation ITLoginViewController

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
    self.ctivityIndicator.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    if([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
        [self updateUserInformation];
        [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
    }
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

- (IBAction)loginButtonPressed:(UIButton *)sender {
    
    self.ctivityIndicator.hidden = NO;
    [self.ctivityIndicator startAnimating];
    
    NSArray *permissionArray = @[@"user_about_me", @"user_interests", @"user_relationships", @"user_birthday", @"user_location", @"user_relationship_details"];
    [PFFacebookUtils logInWithPermissions:permissionArray block:^(PFUser *user, NSError *error) {
        [self.ctivityIndicator stopAnimating];
        self.ctivityIndicator.hidden = YES;
        
        if(!user){
            if(!error){
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Login in Error" message:@"The facebook Login was cancled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            }
        }
        else{
            [self updateUserInformation];
            [self performSegueWithIdentifier:@"loginToHomeSegue" sender:self];
            
        }
    }];
    
}

#pragma mark - Helper Method
-(void)updateUserInformation
{
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSLog(@"%@", result);
        if(!error){
            NSDictionary *userDictionary = (NSDictionary *)result;
            
            //create URL
            NSString *facebookID = userDictionary[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc]initWithCapacity:8];
            if(userDictionary[@"name"]){
                userProfile[kITUserProfileNameKey] = userDictionary[@"name"];
                
            }
            if(userDictionary[@"first_name"]){
                userProfile[kITUserProfileFirstNameKey] = userDictionary[@"first_name"];
            }
            if(userDictionary[@"location"][@"name"]){
                userProfile[kITUserProfileLocationKey] = userDictionary[@"location"][@"name"];
            }
            if(userDictionary[@"gender"]){
                userProfile[kITUserProfileGenderkey] = userDictionary[@"gender"];
            }
            if(userDictionary[@"birthday"]){
                userProfile[kITUserProfileBirthdayKey] = userDictionary[@"birthday"];
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateStyle:NSDateFormatterShortStyle];
                NSDate *date = [formatter dateFromString:userDictionary[@"birthday"]];
                NSDate *now = [NSDate date];
                NSTimeInterval seconds = [now timeIntervalSinceDate:date];
                int age = seconds/31536000;
                userProfile[kITUserProfileAgeKey] = @(age);
                
            }
            if(userDictionary[@"interested_in"]){
                userProfile[kITUserProfileInterestedInKey] = userDictionary[@"interested_in"];
            }
            if(userDictionary[@"relationship_status"]){
                userProfile[kITUserProfileRelationshipStatusKey] = userDictionary[@"relationship_status"];
            }
            
            if([pictureURL absoluteString]){
                userProfile[kITUserProfilePictureURL] = [pictureURL absoluteString];
            }
            
            [[PFUser currentUser] setObject:userProfile forKey:kITUserProfileKey];
            [[PFUser currentUser] saveInBackground];
            [self requestImage];
        }
        else{
            
            NSLog(@"Error in facebook request %@", error);
        }
    }];
}

-(void)uploadPFFileToParse:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    if(!imageData){
        NSLog(@"imageData was not foundt");
        return;
    }
    PFFile *photoFile = [PFFile fileWithData:imageData];
    
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            PFObject *photo = [PFObject objectWithClassName:kITPhotoClassKey];
            [photo setObject:[PFUser currentUser] forKey:kITPhotoUserKey];
            [photo setObject:photoFile forKey:kITPhotoPictureKey];
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"Photo saved successfully");
            }];
        }
    }];
}

-(void)requestImage
{
    PFQuery *query = [PFQuery queryWithClassName:kITPhotoClassKey];
    [query whereKey:kITPhotoUserKey equalTo:[PFUser currentUser]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if(number == 0){
            PFUser *user = [PFUser currentUser];
            self.imageData = [[NSMutableData alloc]init];
            
            NSURL *profilePictureURL = [NSURL URLWithString:user[kITUserProfileKey][kITUserProfilePictureURL]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            NSURLConnection *urlConnection = [[NSURLConnection alloc]initWithRequest:urlRequest delegate:self];
            if(!urlConnection){
                NSLog(@"Failed to download the picture.");
            }
        }
        
    }];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imageData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *profileImage = [UIImage imageWithData:self.imageData];
    [self uploadPFFileToParse:profileImage];
    
}
@end
