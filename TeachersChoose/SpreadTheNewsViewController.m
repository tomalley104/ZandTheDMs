//
//  GoodNewsViewController.m
//  TeachersChoose
//
//  Created by Tom OMalley on 4/16/15.
//  Copyright (c) 2015 ZandTheDMs. All rights reserved.
//

#import "SpreadTheNewsViewController.h"

static NSString* TEXTVIEW_PLACEHOLDER = @"Tap here to begin your message";

@interface SpreadTheNewsViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *saveMessageButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation SpreadTheNewsViewController

- (void)viewDidLoad {
    self.textView.delegate = self;
    self.saveMessageButton.layer.cornerRadius = 10;
    [self setupKeyboardDismissalOnTouch];
    [self createInputAccessoryView];
    [super viewDidLoad];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    [self presentAlert];
}

-(void) setupKeyboardDismissalOnTouch
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

-(void) dismissKeyboard
{
    [self.textView resignFirstResponder];
}


#pragma mark - UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:TEXTVIEW_PLACEHOLDER])
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
        textView.textAlignment = NSTextAlignmentLeft;
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = TEXTVIEW_PLACEHOLDER;
        textView.textColor = [UIColor lightGrayColor];
        textView.textAlignment = NSTextAlignmentCenter;
    }
}

-(void) textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] > 3) {
        self.saveMessageButton.enabled = YES;
        self.saveMessageButton.backgroundColor = [UIColor colorWithRed:0.106 green:0.761 blue:0.106 alpha:1.000];
    }
    else {
        self.saveMessageButton.enabled = NO;
        self.saveMessageButton.backgroundColor = [UIColor lightGrayColor];
    }
}

-(void) presentAlert
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Brief Thank You Message" message:@"This note will be publicly viewable on your project page and cannot be changed.\n\nFor safety purposes DO NOT include your name, school name, location, etc." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [alertController addAction: okayAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void) createInputAccessoryView
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self.textView action:@selector(resignFirstResponder)];

    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    toolbar.items = @[flexibleSpace, doneButton];

    self.textView.inputAccessoryView = toolbar;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
