/*
 * AppController.j
 * GithubIssues
 *
 * Created by Randy Luecke on April 14, 2011.
 * Copyright 2011, RCLConcepts, LLC All rights reserved.
 */

/*!
    The account view shows the login status of the user
*/

var octocatImage = nil;

@implementation ISAccountView : CPView
{
    @outlet CPImageView avatarView;
    @outlet CPTextField accountNameField;
    @outlet CPTextField loggedInAsField;
    @outlet CPButton    loginButton;

    @outlet CPPopUpButton detailsButton;
}

- (void)awakeFromCib
{
    var buttonPattern = [CPColor colorWithPatternImage:resourcesImage("loginbutton.png", 58, 21)],
        buttonPatternActive = [CPColor colorWithPatternImage:resourcesImage("loginbutton-active.png", 58, 21)];

    octocatImage = resourcesImage("octocat32.png", 32, 32);

    [loginButton setValue:buttonPattern forThemeAttribute:"bezel-color" inState:CPThemeStateNormal];
    [loginButton setValue:buttonPatternActive forThemeAttribute:"bezel-color" inState:CPThemeStateHighlighted];
    [loginButton setValue:[CPColor colorWithRed:218/255 green:225/255 blue:229/255 alpha:1.0] forThemeAttribute:@"text-color" inState:CPThemeStateNormal];
    [loginButton setValue:[CPColor colorWithRed:0 green:0 blue:0 alpha:.35] forThemeAttribute:@"text-shadow-color" inState:CPThemeStateNormal];
    [loginButton setValue:CGSizeMake(0,-1) forThemeAttribute:@"text-shadow-offset" inState:CPThemeStateNormal];

    // FIX ME: it'd be nice to get NIB2Cib to do this for us...
    [loginButton setFrameSize:CGSizeMake(58, 21)];
    [loginButton setTitle:"Login"];


    [accountNameField setValue:[CPColor colorWithRed:1 green:1 blue:1 alpha:.3] forThemeAttribute:@"text-shadow-color" inState:CPThemeStateNormal];
    [accountNameField setValue:CGSizeMake(0,1) forThemeAttribute:@"text-shadow-offset" inState:CPThemeStateNormal];

    // In order to add a proper shadow we need to make the frame 1px taller
    var size = [accountNameField frameSize];
    size.height += 1;
    [accountNameField setFrameSize:size];


    [loggedInAsField setValue:[CPColor colorWithRed:1 green:1 blue:1 alpha:.3] forThemeAttribute:@"text-shadow-color" inState:CPThemeStateNormal];
    [loggedInAsField setValue:CGSizeMake(0,1) forThemeAttribute:@"text-shadow-offset" inState:CPThemeStateNormal];

    var size = [loggedInAsField frameSize];
    size.height += 2;
    [loggedInAsField setFrameSize:size];

    [avatarView setBackgroundColor:[CPColor colorWithPatternImage:resourcesImage("userViewImageBackground-large.png", 44, 44)]];

    [[CPNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(loginStatusDidChange:) 
                                                 name:CPUserSessionManagerStatusDidChangeNotification 
                                               object:nil];

    [detailsButton setFrameSize:CGSizeMake(10,10)];
    [detailsButton setValue:[CPColor colorWithPatternImage:resourcesImage("FIXME_arrowdown.png", 10, 10)] forThemeAttribute:"bezel-color"];

    [self loginStatusDidChange:nil];

}

- (@action)addOwnRepos:(id)sender
{
    var controller = [ISGithubAPIController sharedController];

    [controller loadAllReposForUser:[controller username] callback:function(aRepo, aRequest){
        [[[CPApp delegate] reposController] addRepository:aRepo select:NO];
    }];
}

- (@action)toggleLogin:(id)sender
{
    [[ISGithubAPIController sharedController] toggleAuthentication:sender];
}

- (void)loginStatusDidChange:(CPNotification)aNote
{
    var githubController = [ISGithubAPIController sharedController],
        isLoggedIn = [githubController isAuthenticated];
    
    if (isLoggedIn)
    {
        [loggedInAsField setStringValue:"Logged in as"];
        [accountNameField setStringValue:[githubController username]];
        [accountNameField sizeToFit];

        [avatarView setImage:[githubController userThumbnailImage]];
        [loginButton setTitle:"Logout"];

        var frame = [accountNameField frame];

        [detailsButton setFrameOrigin:CGPointMake(CGRectGetMaxX(frame) + 2, CGRectGetMinY(frame) + 2)];
        [detailsButton setHidden:NO];

        var defaults = [CPUserDefaults standardUserDefaults];
        [defaults setObject:[githubController username] forKey:"username"];
        [defaults setObject:[githubController password] forKey:"password"];
    }
    else
    {
        [detailsButton setHidden:YES];
        [loggedInAsField setStringValue:"Not logged in"];
        [accountNameField setStringValue:""];
        [avatarView setImage:octocatImage];

        [loginButton setTitle:"Login"];
    }
}

@end
