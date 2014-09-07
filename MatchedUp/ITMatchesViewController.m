//
//  ITMatchesViewController.m
//  MatchedUp
//
//  Created by yousheng chang on 9/6/14.
//  Copyright (c) 2014 InfoTech Inc. All rights reserved.
//

#import "ITMatchesViewController.h"
#import "ITChatViewController.h"

@interface ITMatchesViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *avaliableChatRooms;

@end

@implementation ITMatchesViewController

#pragma mark lazy instantiation
-(NSMutableArray *)avaliableChatRooms
{
    if(!_avaliableChatRooms){
        _avaliableChatRooms = [[NSMutableArray alloc]init];
        
    }
    return _avaliableChatRooms;
}

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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self updateAvaliableChatRooms];
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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ITChatViewController *chatVC = segue.destinationViewController;
    NSIndexPath *indexPath = sender;
    chatVC.chatRoom = [self.avaliableChatRooms objectAtIndex:indexPath.row];
    
}


#pragma mark Help method

-(void)updateAvaliableChatRooms
{
    
    PFQuery *query = [PFQuery queryWithClassName:@"ChatRoom"];
    [query whereKey:@"user1" equalTo:[PFUser currentUser]];
    PFQuery *queryInverse = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryInverse whereKey:@"user2" equalTo:[PFUser currentUser]];
    PFQuery *queryCombined = [PFQuery orQueryWithSubqueries:@[query, queryInverse]];
    [queryCombined includeKey:@"chat"];
    [queryCombined includeKey:@"user1"];
    [queryCombined includeKey:@"user2"];
    [queryCombined findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            [self.avaliableChatRooms removeAllObjects];
            self.avaliableChatRooms = [objects mutableCopy];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark UITableView DataSource


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.avaliableChatRooms count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *chatRoom = [self.avaliableChatRooms objectAtIndex:indexPath.row];
    PFUser *likedUser;
    PFUser *currentUser = [PFUser currentUser];
    PFUser *testUser1 = chatRoom[@"user1"];
    if([testUser1.objectId isEqual:currentUser.objectId]){
        likedUser = [chatRoom objectForKey:@"user2"];
    }else{
        likedUser = [chatRoom objectForKey:@"user1"];
    }
    cell.textLabel.text = likedUser[@"profile"][@"firstName"];
    //cell.iamgeView.image = place holder image
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    PFQuery *queryForPhoto = [[PFQuery alloc]initWithClassName:kITPhotoClassKey];
    [queryForPhoto whereKey:kITPhotoUserKey equalTo:likedUser];
    [queryForPhoto findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if([objects count] > 0){
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kITPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                cell.imageView.image = [UIImage imageWithData:data];
                cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            }];
        }
    }];
    return cell;
}

#pragma mark - UITableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"matchesToChatSegue" sender:indexPath];
    
}
@end
