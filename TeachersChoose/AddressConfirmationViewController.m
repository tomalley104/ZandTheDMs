//
//  AddressConfirmationViewController.m
//  TeachersChoose
//
//  Created by Tom OMalley on 4/9/15.
//  Copyright (c) 2015 ZandTheDMs. All rights reserved.
//

#import "AddressConfirmationViewController.h"
#import "ContainerViewController.h"
#import "FISDonorsChooseProposal.h"
#import <FAKIonIcons.h>

@interface AddressConfirmationViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *editAddressButton;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;



@property (weak, nonatomic) IBOutlet UILabel *teacherNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *schoolNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityStateZipLabel;

@end

@implementation AddressConfirmationViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    
//    self.proposal = ((ContainerViewController *) self.parentViewController.parentViewController).proposal;

    self.inputTextField.delegate = self;
    
    self.editAddressButton.layer.cornerRadius = 10;
    self.nextButton.layer.cornerRadius = 10;
    self.proposal = ((ContainerViewController*)self.parentViewController.parentViewController).proposal;
    
    
    [self setupHomeButton];
    [self setupKeyboardDismissalOnTouch];
}

-(void)setProposal:(FISDonorsChooseProposal *)proposal
{
    self.teacherNameLabel.text = proposal.teacherName;
    self.schoolNameLabel.text = proposal.schoolName;
    self.addressLabel.text = @"2101 N Indiana Ave";
    self.cityStateZipLabel.text = [NSString stringWithFormat:@"%@, %@ %@", proposal.city, proposal.state, proposal.zip];

}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}


-(void) setupKeyboardDismissalOnTouch
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self.inputTextField
                                   action:@selector(resignFirstResponder)];
    
    [self.view addGestureRecognizer:tap];
}

#pragma mark - Edit Address Button

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ContainerViewController*containerVC = (ContainerViewController*)self.parentViewController.parentViewController;
    
    containerVC.proposal.completionInfo[@"specialInstructions"] = self.inputTextField.text;
}

-(void) presentAlert
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Contact Us" message:@"Changing your address requires confirmation by our data provider. Please contact us at DonorsChoose.org." preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [alertController addAction: okayAction];
    
    [self presentViewController:alertController animated:YES completion:nil];

}

#pragma mark - Home Button

- (void)setupHomeButton {
	UIImage *homeIcon = [[FAKIonIcons iosHomeIconWithSize:30] imageWithSize:CGSizeMake(30, 30)];
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:homeIcon style:UIBarButtonItemStylePlain target:self action:@selector(homeButtonTapped)]];
}

- (void)homeButtonTapped {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Return To Dashboard" message:@"Your progress from this page will not be saved." preferredStyle:UIAlertControllerStyleAlert];
	UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
	    [self dismissViewControllerAnimated:YES completion:nil];
	}];
	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

	[alertController addAction:cancelAction];
	[alertController addAction:okAction];

	[self presentViewController:alertController animated:YES completion:nil];
}



@end
