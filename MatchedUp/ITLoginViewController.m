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
            [self performSegueWithIdentifier:@"loginToTabBarSegue" sender:self];
            
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
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc]initWithCapacity:8];
            if(userDictionary[@"name"]){
                userProfile[@"name"] = userDictionary[@"name"];
                
            }
            if(userDictionary[@"first_name"]){
                userProfile[@"first_name"] = userDictionary[@"first_name"];
            }
            if(userDictionary[@"location"][@"name"]){
                userProfile[@"location"] = userDictionary[@"location"][@"name"];
            }
            if(userDictionary[@"gender"]){
                userProfile[@"gender"] = userDictionary[@"gender"];
            }
            if(userDictionary[@"birthday"]){
                userProfile[@"birthday"] = userDictionary[@"birthday"];
            }
            if(userDictionary[@"interested_in"]){
                userProfile[@"interested_in"] = userDictionary[@"interested_in"];
            }
            [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            [[PFUser currentUser] saveInBackground];
        }
        else{
            
            NSLog(@"Error in facebook request %@", error);
        }
    }];
}
@end
