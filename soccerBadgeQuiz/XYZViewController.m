//
//  XYZViewController.m
//  soccerBadgeQuiz
//
//  Created by Abiel Gutierrez on 9/3/12.
//  Copyright (c) 2012 ASFM. All rights reserved.
//

#import "XYZViewController.h"
#import "QuizViewViewController.h"
#import "Options.h"
#import "Unlocks.h"


@interface XYZViewController ()

@end

@implementation XYZViewController

@synthesize startGame;
@synthesize options;
@synthesize unlocks;
@synthesize bckgView;
@synthesize adBannerView;
@synthesize gameCenterManager;
@synthesize currentLeaderBoard;

-(IBAction)initiateGame:(id)sender
{    
    QuizViewViewController *quiz = [[QuizViewViewController alloc] initWithNibName:nil bundle:nil];
    [self presentModalViewController:quiz animated:NO];
}

-(IBAction) goToOptions:(id)sender
{
    Options *inst = [[Options alloc] initWithNibName:nil bundle:nil];
    [self presentModalViewController:inst animated:NO];
}

-(IBAction) goToUnlocks:(id)sender
{
    Unlocks *inst = [[Unlocks alloc] initWithNibName:nil bundle:nil];
    [self presentModalViewController:inst animated:NO];
}

//Request to rate applciation
- (void) alertView:(UIAlertView *) alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex: buttonIndex] isEqualToString:@"残忍拒绝"])
    {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"neverAsk"];
	}
    else if ([[alertView buttonTitleAtIndex: buttonIndex] isEqualToString:@"这就去吐槽"])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/id1217101850?l=zh&ls=1&mt=8"]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"neverAsk"];
    }
}

/////IAD IMPLEMENTATION//////

- (void) createAdBannerView
{
    adBannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    CGRect bannerFrame = self.adBannerView.frame;
    bannerFrame.origin.y = /*self.view.frame.size.height*/ 568;
    self.adBannerView.frame = bannerFrame;
    
    self.adBannerView.delegate = self;
    self.adBannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, nil];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self adjustBannerView];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self adjustBannerView];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
}

- (void) adjustBannerView
{
    CGRect contentViewFrame = self.view.bounds;
    CGRect adBannerFrame = self.adBannerView.frame;
    
    if([self.adBannerView isBannerLoaded])
    {
        CGSize bannerSize = [ADBannerView sizeFromBannerContentSizeIdentifier:self.adBannerView.currentContentSizeIdentifier];
        contentViewFrame.size.height = contentViewFrame.size.height - bannerSize.height;
        adBannerFrame.origin.y = contentViewFrame.size.height;
    }
    else
    {
        adBannerFrame.origin.y = contentViewFrame.size.height;
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.adBannerView.frame = adBannerFrame;
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(UIInterfaceOrientationIsPortrait(interfaceOrientation))
        self.adBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    else
        self.adBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Code for App Store rating request
    int timesLoaded = [[NSUserDefaults standardUserDefaults] integerForKey:@"timesLoaded"];
    
    int i = 1 + timesLoaded;
    [[NSUserDefaults standardUserDefaults] setInteger: i forKey: @"timesLoaded"];
     
    
    if ( ([[NSUserDefaults standardUserDefaults] integerForKey:@"timesLoaded"] % 10 == 0) && [[NSUserDefaults standardUserDefaults] boolForKey:@"neverAsk"] != YES)
    {
        UIAlertView *alertDialogue;
        
        alertDialogue = [[UIAlertView alloc]
                         initWithTitle:@"吐槽还是评价？"
                         message:@"如果玩的愉快，这就去帮我做个评价吧！吐个槽也行呀！"
                         delegate:self
                         cancelButtonTitle:@"以后再说"
                         otherButtonTitles:@"这就去吐槽", @"残忍拒绝", nil];
        
        [alertDialogue show];
    }
    
    //Choose the appropriate background image
    UIImage *bckgImage;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            bckgImage = [UIImage imageNamed:@"FirstBackground@2X.png"];
        }
        if(result.height == 568)
        {
            bckgImage = [UIImage imageNamed:@"FirstBackground-568h@2X.png"];
        }
    }
    
    bckgView.image = bckgImage;
   
    //IAD Implementation
    [self createAdBannerView];
    [self.view addSubview:self.adBannerView];
    
    
    //GameCenter Implementation - Sign in.
    self.currentLeaderBoard = kLeaderboardID;
    if ([GameCenterManager isGameCenterAvailable])
    {
        self.gameCenterManager = [[[GameCenterManager alloc] init] autorelease];
        [self.gameCenterManager setDelegate:self];
        [self.gameCenterManager authenticateLocalUser];
    } else {
        // The current device does not support Game Center.
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

@end
