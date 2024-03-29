//
//  ITSettingsViewController.m
//  MatchedUp
//
//  Created by yousheng chang on 9/2/14.
//  Copyright (c) 2014 InfoTech Inc. All rights reserved.
//

#import "ITSettingsViewController.h"

@interface ITSettingsViewController ()
@property (strong, nonatomic) IBOutlet UISlider *ageSlider;
@property (strong, nonatomic) IBOutlet UISwitch *manSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *womenSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *singleSwitch;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;

@property (strong, nonatomic) IBOutlet UIButton *editProfileButton;

@property (strong, nonatomic) IBOutlet UIButton *logoutButton;
@end

@implementation ITSettingsViewController

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
    self.ageSlider.value = [[NSUserDefaults standardUserDefaults] integerForKey:kITAgeMaxKey];
    self.manSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kITMenEnabledKey];
    self.womenSwitch.on = [[NSUserDefaults standardUserDefaults]boolForKey:kITWomenEnabledKey];
    self.singleSwitch.on = [[NSUserDefaults standardUserDefaults]boolForKey:kITSingleEnabledKey];
    
    [self.ageSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.manSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.womenSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.singleSwitch addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    self.ageLabel.text = [NSString stringWithFormat:@"%i", (int)self.ageSlider.value];
    
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

#pragma mark IB Actions
- (IBAction)logoutButtonPressed:(UIButton *)sender {
    [PFUser logOut];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}
- (IBAction)editProfileButtonPressed:(UIButton *)sender {
}

#pragma mark helper method
-(void)valueChanged:(id)sender
{
    if(sender == self.ageSlider){
        [[NSUserDefaults standardUserDefaults]setInteger:(int)self.ageSlider.value forKey:kITAgeMaxKey];
        self.ageLabel.text = [NSString stringWithFormat:@"%i", (int)self.ageSlider.value];
        
    }else if(sender == self.manSwitch){
        [[NSUserDefaults standardUserDefaults]setBool:self.manSwitch.isOn forKey:kITMenEnabledKey];
        
    }else if(sender == self.womenSwitch){
        [[NSUserDefaults standardUserDefaults]setBool:self.womenSwitch.isOn forKey:kITWomenEnabledKey];
        
    }else if(sender == self.singleSwitch){
        [[NSUserDefaults standardUserDefaults]setBool:self.singleSwitch.isOn forKey:kITSingleEnabledKey];
        
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
    
}
@end
