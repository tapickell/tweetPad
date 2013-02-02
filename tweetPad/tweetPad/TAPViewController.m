//
//  TAPViewController.m
//  tweetPad
//
//  Created by Todd Pickell on 1/31/13.
//  Copyright (c) 2013 Todd Pickell. All rights reserved.
//

#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import "TAPViewController.h"

@interface TAPViewController ()

- (void) reloadTweets;
- (void) handleTwitterData: (NSData*) data
               urlResponse: (NSHTTPURLResponse*) urlResponse
                     error: (NSError*) error;
@property (nonatomic, strong) IBOutlet UITextView *twitterTextView;

@end

@implementation TAPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleTweetButtonTapped:(id)sender
{
    NSLog(@"handleTweetButtonTapped:");
    
    NSString *textToShare = NSLocalizedString(@"I just got tweetPad to tweet for me, #pragsios", nil);
    
    NSArray *activityItems;
    activityItems = @[textToShare];
    
    NSInteger versionNumber = [[[UIDevice currentDevice] systemVersion] integerValue];
    if (versionNumber < 6) {
        //do something
        if ([TWTweetComposeViewController canSendTweet]) // #### Tweet compose view controller deprecated iOS6 release ####
        {
            TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
            [tweetSheet setInitialText:textToShare];

            [self presentModalViewController:tweetSheet animated:YES]; // #### present modal view deprecated iOS6 release ####
        }
    } else if (versionNumber >= 6) {
        
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            SLComposeViewController *tweetVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetVC setInitialText:textToShare];
            //set completion handler block for tweet view
            tweetVC.completionHandler = ^(SLComposeViewControllerResult result) {
                if (result == SLComposeViewControllerResultDone) {
                    [self dismissViewControllerAnimated:YES completion:NULL];
                    [self reloadTweets];
                }
            };
            [self presentViewController:tweetVC animated:YES completion:NULL];
        }
        
    } else {
        NSLog(@"Oops, something broke, can't tweet right now. Sorry.");
    }
}

- (void) reloadTweets
{
    NSURL *twitterAPIURL = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/user_timeline.json"];
    NSDictionary *twitterParams = @{@"screen_name" : @"myappleguy"};
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:twitterAPIURL
                                               parameters:twitterParams];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        [self handleTwitterData:responseData
                    urlResponse:urlResponse
                          error:error];
        
    }];
    
}

- (void) handleTwitterData:(NSData *)data
               urlResponse:(NSHTTPURLResponse *)urlResponse
                     error:(NSError *)error
{
    NSError *jsonError = nil;
    NSJSONSerialization *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:0
                                                                          error:&jsonError];
    NSLog(@"jsonResponse: %@", jsonResponse);
    if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *tweets = (NSArray*) jsonResponse;
            for (NSDictionary *tweetDict in tweets) {
                NSString *tweetText = [NSString stringWithFormat:@"%@ (%@)",
                                       [tweetDict valueForKey:@"text"],
                                       [tweetDict valueForKey:@"created_at"]];
                self.twitterTextView.text = [NSString stringWithFormat:@"%@%@\n\n", self.twitterTextView.text, tweetText];
            }
        });
    }
}
    
@end
