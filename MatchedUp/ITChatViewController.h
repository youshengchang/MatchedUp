//
//  ITChatViewController.h
//  MatchedUp
//
//  Created by yousheng chang on 9/6/14.
//  Copyright (c) 2014 InfoTech Inc. All rights reserved.
//

#import "JSMessagesViewController.h"

@interface ITChatViewController : JSMessagesViewController<JSMessagesViewDataSource, JSMessagesViewDelegate>

@property (strong, nonatomic) PFObject *chatRoom;

@end
