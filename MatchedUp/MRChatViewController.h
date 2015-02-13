//
//  MRChatViewController.h
//  MatchedUp
//
//  Created by Mark Rabins on 8/16/14.
//  Copyright (c) 2014 edu.self.edu. All rights reserved.
//

#import "JSMessagesViewController.h"

@interface MRChatViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate>

@property (strong, nonatomic) PFObject *chatRoom;

@end