//
//  MRMatchViewController.h
//  MatchedUp
//
//  Created by Mark Rabins on 8/16/14.
//  Copyright (c) 2014 edu.self.edu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MRMatchViewControllerDelegate <NSObject>

-(void)presentMatchesViewController;

@end

@interface MRMatchViewController : UIViewController

@property (strong, nonatomic) UIImage *matchedUserImage;
@property (weak, nonatomic) id <MRMatchViewControllerDelegate> delegate;

@end
