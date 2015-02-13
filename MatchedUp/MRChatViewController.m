//
//  MRChatViewController.m
//  MatchedUp
//
//  Created by Mark Rabins on 8/16/14.
//  Copyright (c) 2014 edu.self.edu. All rights reserved.
//

#import "MRChatViewController.h"

@interface MRChatViewController ()

@property (strong, nonatomic) PFUser *withUser;
@property (strong, nonatomic) PFUser *currentUser;

@property (strong, nonatomic) NSTimer *chatsTimer;
@property (nonatomic) BOOL initialLoadComplete;

@property (strong, nonatomic) NSMutableArray *chats;

@end

@implementation MRChatViewController

- (NSMutableArray *)chats
{
    if (!_chats){
        _chats = [[NSMutableArray alloc] init];
    }
    return _chats;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    //Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.dataSource = self;
    self.delegate = self;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[JSBubbleView appearance] setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.f]];
    self.messageInputView.textView.placeHolder = @"Enter text to find your match!";
    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.currentUser = [PFUser currentUser];
    PFUser *testUser1 = self.chatRoom[kMRChatRoomUser1Key];
    if ([testUser1.objectId isEqual:self.currentUser.objectId]){
        self.withUser = self.chatRoom[kMRChatRoomUser2Key];
    }
    else {
        self.withUser = self.chatRoom[kMRChatRoomUser1Key];
    }
    self.title = self.withUser[kMRUserProfileKey][kMRFirstNameKey];
    self.initialLoadComplete = NO;
    
    [self checkForNewChats];
    
    self.chatsTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkForNewChats) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated
{
    [self.chatsTimer invalidate];
     self.chatsTimer = nil;
    
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.chats count];
}

#pragma mark - TableView Delegate REQUIRED

- (void)didSendText:(NSString *)text
{
    if (text.length !=0){
        PFObject *chat = [PFObject objectWithClassName:kMRChatClassKey];
        [chat setObject:self.chatRoom forKey:kMRChatChatroomKey];
        [chat setObject:self.currentUser forKey:kMRChatFromUserKey];
        [chat setObject:self.withUser forKey:kMRChatToUserKey];
        [chat setObject:text forKey:kMRChatTextKey];
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.chats addObject:chat];
            [JSMessageSoundEffect playMessageSentSound];
            [self.tableView reloadData];
            [self finishSend];
            [self scrollToBottomAnimated:YES];
        }];
    }
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[kMRChatFromUserKey];
    
    if ([testFromUser.objectId isEqual:self.currentUser.objectId]) {
        return JSBubbleMessageTypeOutgoing;
    }
    else {
        return JSBubbleMessageTypeIncoming;
    }
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[kMRChatFromUserKey];
    
    if ([testFromUser.objectId isEqual:self.currentUser.objectId]){
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleBlueColor]];
    }
    else {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleLightGrayColor]];
    }
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyAll;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyNone;
}

- (JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyNone;
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

#pragma mark - Messages View Delegate OPTIONAL
- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell messageType] == JSBubbleMessageTypeOutgoing){
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
    }
}

- (BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

#pragma mark - Messages View Data Source REQUIRED

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    NSString *message = chat[kMRChatTextKey];
    return message;
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Helper Methods

- (void)checkForNewChats
{
    int oldChatCount = [self.chats count];
    
    PFQuery *queryForChats = [PFQuery queryWithClassName:kMRChatClassKey];
    [queryForChats whereKey:kMRChatChatroomKey equalTo:self.chatRoom];
    [queryForChats orderByAscending:@"createdAt"];
    [queryForChats findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
            if (self.initialLoadComplete == NO || oldChatCount != [objects count]){
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