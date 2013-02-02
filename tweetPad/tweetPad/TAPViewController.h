//
//  TAPViewController.h
//  tweetPad
//
//  Created by Todd Pickell on 1/31/13.
//  Copyright (c) 2013 Todd Pickell. All rights reserved.
//


#import <UIKit/UIKit.h>

//TAPViewController inherits from UIViewController
@interface TAPViewController : UIViewController

//instance method returning IBAction and takes an id object locally called sender
- (IBAction)handleTweetButtonTapped:(id)sender;


@end
