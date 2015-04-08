//
//  ViewController.m
//  TeachersChoose
//
//  Created by Damon Skinner on 4/1/15.
//  Copyright (c) 2015 ZandTheDMs. All rights reserved.
//

#import "veryFirstViewController.h"
#import <Parse/Parse.h>
#import "LogInViewController.h"
#import "SignUpViewController.h"
#import "FISDonorsChooseProposal.h"
#import <AFNetworking.h>
#import "FISParseAPI.h"
#import "FISDonation.h"
#import "DetailsTabBarController.h"
#import "UIColor+DonorsChooseColors.h"

@interface veryFirstViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@end

@implementation veryFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.datastore=[FISDonorsChooseDatastore sharedDataStore];
    self.view.backgroundColor=[UIColor DonorsChooseOrange];

    [self.view removeConstraints:self.view.constraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![PFUser currentUser]) { // No user logged in
 
        // Create the log in view controller
        PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
        [logInViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Create the sign up view controller
        PFSignUpViewController *signUpViewController = [[PFSignUpViewController alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log  in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    } else {

        
        // tell the datastore to grab the current users proposals
        if([self.datastore.loggedInTeacherProposals count]<1){
            PFUser *loggedInUser = [PFUser currentUser];
            [FISParseAPI getTeacherIdForObjectId:loggedInUser.objectId andCompletionBlock:^(NSString *teacherId) {
                
                [self.datastore getSearchResultsWithTeacherId:teacherId andCompletion:^(BOOL completion) {
                    
                    for (FISDonorsChooseProposal *eachProposal in self.datastore.loggedInTeacherProposals){
                        [self.datastore getDonationsListForProposalId:eachProposal.proposalId andCompletion:^(BOOL completion) {
                            
                        }];
                    }
                    [self.datastore getTeacherProfileWithTeacherId:teacherId andCompletion:^(BOOL completion) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                        [self transitionToHomePage];
                    }];
                    
                }];
            }];
            
        }
    }
}

- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {

    PFUser *currentUser = user;
    NSString *currentTeacherId = currentUser[@"teacherId"];
    
    [self.datastore getSearchResultsWithTeacherId:currentTeacherId andCompletion:^(BOOL completion) {

        //May need to insert API stuff here to update proposals on parse
        if(completion) {
            
            for (FISDonorsChooseProposal *eachProposal in self.datastore.loggedInTeacherProposals) {
                [self.datastore getDonationsListForProposalId:eachProposal.proposalId andCompletion:^(BOOL completion) {
                    
                }];
            }
            
        } else {
            NSLog(@"No active proposals");
        }
        [self.datastore getTeacherProfileWithTeacherId:currentTeacherId andCompletion:^(BOOL completion) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [self transitionToHomePage];
        }];
    }];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {

    PFUser *currentUser = user;
    NSInteger maxSearchResults=50;
    NSDictionary *params = @{@"location":@"NY",@"max":[NSString stringWithFormat:@"%ld",maxSearchResults]};
    [self.datastore getSearchResultsWithParams:params andCompletion:^(BOOL completion) {
        
        NSUInteger r=arc4random_uniform([self.datastore.donorsChooseSearchResults count]);
        FISDonorsChooseProposal *randomProposal = self.datastore.donorsChooseSearchResults[r];
        NSString *randomTeacherId = randomProposal.teacherId;

        [self.datastore getSearchResultsWithTeacherId:randomTeacherId andCompletion:^(BOOL completion) {
            
            [FISParseAPI addRandomTeacherId:randomTeacherId toNewUserWithObjectId:currentUser.objectId currentUserSessionToken:currentUser.sessionToken andCompletionBlock:^(void) {
            }];

            for (FISDonorsChooseProposal *eachProposal in self.datastore.loggedInTeacherProposals){
                
                [FISParseAPI createProposalWithId:eachProposal.proposalId withTeacherObjectId:currentUser.objectId andCompletionBlock:^(NSDictionary *responseObject){

                    eachProposal.parseObjectId=responseObject[@"objectId"];
                    
                    [FISParseAPI addProposalObjectId:eachProposal.parseObjectId toNewUserWithObjectId:currentUser.objectId currentUserSessionToken:currentUser.sessionToken andCompletionBlock:^{
                    }];
                    [self.datastore getDonationsListForProposalId:eachProposal.proposalId andCompletion:^(BOOL completion) {
                        
                    }];
                }];
            }
            [self.datastore getTeacherProfileWithTeacherId:randomTeacherId andCompletion:^(BOOL completion) {
                [self dismissViewControllerAnimated:YES completion:nil];
                [self transitionToHomePage];
            }];
        }];
    }];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

-(void) transitionToHomePage {
    veryFirstViewController *homePageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"homePage"];
    UINavigationController *newNavController = [[UINavigationController alloc]init];
    
    [newNavController addChildViewController:homePageVC];
    
    
    [self presentViewController:newNavController animated:YES completion:nil];
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
