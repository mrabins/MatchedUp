//
//  MRProfileViewController.h
//  MatchedUp
//
//  Created by Mark Rabins on 8/13/14.
//  Copyright (c) 2014 edu.self.edu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRProfileViewControllerDelegate <NSObject>

-(void)didPressLike;
-(void)didPressDislike;

@end

@interface MRProfileViewController : UIViewController

@property (strong, nonatomic) PFObject *photo;
@property (weak, nonatomic) id delegate;


@end
