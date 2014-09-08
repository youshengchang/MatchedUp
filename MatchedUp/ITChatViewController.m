//
//  ITChatViewController.m
//  MatchedUp
//
//  Created by yousheng chang on 9/6/14.
//  Copyright (c) 2014 InfoTech Inc. All rights reserved.
//

#import "ITChatViewController.h"
#import "JSMessage.h"

@interface ITChatViewController ()

@property (strong, nonatomic)PFUser *withUser;
@property (strong, nonatomic)PFUser *currentUser;
@property (strong, nonatomic)NSTimer *chatsTimer;
@property (nonatomic)BOOL initialLoadComplete;
@property (strong, nonatomic)NSMutableArray *chats;



@end

@implementation ITChatViewController

-(NSMutableArray *)chats
{
    if(!_chats){
        _chats = [[NSMutableArray alloc]init];
        
    }
    return _chats;
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
    self.delegate = self;
    self.dataSource = self;
    
    [[JSBubbleView appearance]setFont:[UIFont systemFontOfSize:16.0f]];
    self.messageInputView.textView.placeHolder = @"New Message";
    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.currentUser = [PFUser currentUser];
    PFUser *testUser1 = self.chatRoom[@"user1"];
    if([testUser1.objectId isEqual:self.currentUser.objectId]){
        self.withUser = self.chatRoom[@"user2"];
    }else{
        self.withUser = self.chatRoom[@"user1"];
    }
    self.title = self.withUser[@"profile"][@"firstName"];
    self.initialLoadComplete = NO;
    
    [self checkForNewChats];
    self.chatsTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkForNewChats) userInfo:nil repeats:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.chatsTimer invalidate];
    self.chatsTimer = nil;
    
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

#pragma mark - TableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chats count];
}

#pragma mark - TableView delegate
-(void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date
{
    if(text.length != 0){
        PFObject *chat = [PFObject objectWithClassName:@"Chat"];
        [chat setObject:self.chatRoom forKey:@"chatroom"];
        [chat setObject:self.currentUser forKey:@"fromUser"];
        [chat setObject:self.withUser forKey:@"toUser"];
        [chat setObject:text forKey:@"text"];
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.chats addObject:chat];
            [JSMessageSoundEffect playMessageSentSound];
            [self.tableView reloadData];
            [self finishSend];
            [self scrollToBottomAnimated:YES];
        }];
    }
}

-(JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[@"fromUser"];
    if([testFromUser.objectId isEqual:self.currentUser.objectId]){
        return JSBubbleMessageTypeOutgoing;
    }else{
        return  JSBubbleMessageTypeIncoming;
    }
}

-(UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[@"fromUser"];
    if([testFromUser.objectId isEqual:self.currentUser.objectId]){
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleGreenColor]];
    }else{
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleLightGrayColor]];
    }
}

/*
 //It is 3.4.4 before 4.00 version

-(JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyAll;
    
}


-(JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyNone;
}

-(JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyNone;
}
*/
-(JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

#pragma mark - Messages View Delegate OPtional

-(void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if([cell messageType] == JSBubbleMessageTypeOutgoing){
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
        
    }
}

-(BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

#pragma mark - Messages View data source required

-(id<JSMessageData>)messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    JSMessage *message = [[JSMessage alloc]initWithText:chat[@"text"] sender:nil date:[NSDate date]];
    return message;
    
}

-(UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender
{
    return nil;
}

#pragma mark - Helper Method
-(void)checkForNewChats
{
    int oldChatCount = [self.chats count];
    
    PFQuery *queryForChats = [PFQuery queryWithClassName:@"Chat"];
    [queryForChats whereKey:@"chatroom" equalTo:self.chatRoom];
    [queryForChats orderByAscending:@"createdAt"];
    [queryForChats findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            if(self.initialLoadComplete == NO || oldChatCount != [objects count]){
                self.chats = [objects mutableCopy];
                [self.tableView reloadData];
                if(self.initialLoadComplete == YES){
                    [JSMessageSoundEffect playMessageReceivedSound];
                }
                self.initialLoadComplete = YES;
                [self scrollToBottomAnimated:YES];
            }
        }
    }];
                
}

@end
