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


@interface veryFirstViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@end

@implementation veryFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.datastore=[FISDonorsChooseDatastore sharedDataStore];
    

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
        //        [self dismissViewControllerAnimated:YES completion:nil];
        
        // tell the datastore to grab the current users proposals
        [self.datastore getSearchResultsWithTeacherId:[PFUser currentUser][@"teacherId"] andCompletion:^(BOOL completion) {
            
            for (FISDonorsChooseProposal *eachProposal in self.datastore.loggedInTeacherProposals){
                NSLog(@"%@",eachProposal.title);
            }
            [self dismissViewControllerAnimated:YES completion:nil];
            [self transitionToHomePage];
        }];
        
    }


    //DAMON
//    } else {
//        PFUser *loggedInUser = [PFUser currentUser];
//        NSString *currentTeacherId = loggedInUser[@"teacherId"];
//        
//        [self.datastore getSearchResultsWithTeacherId:currentTeacherId andCompletion:^(BOOL completion) {
//            
//            //May need to insert API stuff here to update proposals on parse
//            if(completion) {
//                
//                for (FISDonorsChooseProposal *eachProposal in self.datastore.loggedInTeacherProposals) {
//                    [FISParseAPI getProposalObjectIdForProposalId:eachProposal.proposalId andCompletionBlock:^(NSString *objId) {
//                        eachProposal.parseObjectId=objId;
//                        [FISParseAPI getDonationsListForProposalWithObjectId:eachProposal.parseObjectId  andCompletionBlock:^(NSArray *parseDonationsList) {
//                            eachProposal.donations=[parseDonationsList mutableCopy];
//                            
//                        }];
//                        
//                        
//                    }];
//                    
//                }
//                
//            } else {
//                NSLog(@"No active proposals");
//            }
//        }];
//        
//        
//    }
//    
    // COOPER/TOM
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
                [FISParseAPI getProposalObjectIdForProposalId:eachProposal.proposalId andCompletionBlock:^(NSString *objId) {
                    eachProposal.parseObjectId=objId;
                    [FISParseAPI getDonationsListForProposalWithObjectId:eachProposal.parseObjectId  andCompletionBlock:^(NSArray *parseDonationsObjectIdList) {
                        for (NSDictionary *eachDonationObject in parseDonationsObjectIdList) {
                            
                            [FISParseAPI getDonationforDonationWithObjectId:eachDonationObject[@"objectId"] andCompletionBlock:^(NSDictionary * donationDict) {
                                FISDonation *newDonation = [FISDonation donationFromDictionary:donationDict];
                                newDonation.donationObjectId = eachDonationObject[@"objectId"];
                                [eachProposal.donations addObject:newDonation];
                                
                            }];
                        }
                    }];
                }];
                
            }
            
        } else {
            NSLog(@"No active proposals");
        }
        //DAMON
         [self dismissViewControllerAnimated:YES completion:nil];
        
        // FISDonorsChooseProposal *testProposal = self.datastore.loggedInTeacherProposals[0];
        
        // COOPER
         [self transitionToHomePage];
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
        
        NSUInteger r=arc4random_uniform(50);
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
                    [FISParseAPI getDonationsListForProposalWithObjectId:eachProposal.parseObjectId  andCompletionBlock:^(NSArray *parseDonationsObjectIdList) {
                        for (NSDictionary *eachDonationObject in parseDonationsObjectIdList) {
                            
                            [FISParseAPI getDonationforDonationWithObjectId:eachDonationObject[@"objectId"] andCompletionBlock:^(NSDictionary * donationDict) {
                    
                                FISDonation *newDonation = [FISDonation donationFromDictionary:donationDict];
                                newDonation.donationObjectId = eachDonationObject[@"objectId"];
                                [eachProposal.donations addObject:newDonation];
                            }];
                        }
                    }];
                }];
            }
            [self dismissViewControllerAnimated:YES completion:nil];

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
    
    [self presentViewController:homePageVC animated:YES completion:nil];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selected row: %ld", indexPath.row);
    
    // make the tab bar controller
    DetailsTabBarController *tabBarController = [[DetailsTabBarController alloc] init];
    
    //static for now
    tabBarController.navigationItem.title = @"The Power of Print";
    // move to it (all the child VCs are setup in viewDidLoad of DetailsTabBarController)
    [self.navigationController showViewController: tabBarController sender:nil];
    
    //    [self.navigationController pushViewController:tabBarController animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end