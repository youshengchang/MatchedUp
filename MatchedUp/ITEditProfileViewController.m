//
//  ITEditProfileViewController.m
//  MatchedUp
//
//  Created by yousheng chang on 9/5/14.
//  Copyright (c) 2014 InfoTech Inc. All rights reserved.
//

#import "ITEditProfileViewController.h"

@interface ITEditProfileViewController ()
@property (strong, nonatomic) IBOutlet UITextView *tagLineTextView;
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;

@end

@implementation ITEditProfileViewController

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


#pragma mark - IB Actions
- (IBAction)saveBarButtonPressed:(UIBarButtonItem *)sender {
    
}


@end
