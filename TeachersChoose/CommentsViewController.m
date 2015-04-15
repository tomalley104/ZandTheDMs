//
//  CommentsViewController.m
//  TeachersChoose
//
//  Created by Damon Skinner on 4/13/15.
//  Copyright (c) 2015 ZandTheDMs. All rights reserved.
//

#import "CommentsViewController.h"
#import "FISDonorsChooseProposal.h"
#import "FISDonorsChooseDatastore.h"
#import "UIColor+DonorsChooseColors.h"
#import "UIFont+DonorsChooseFonts.h"
#import "DetailsTabBarController.h"
#import "FISDonation.h"
#import "FISConstants.h"
#import "FISInputCommentCell.h"


@interface CommentsViewController () 

@property (nonatomic, strong) FISDonorsChooseProposal *proposal;
//@property (strong, nonatomic) NSMutableDictionary *commentsDictionary;
@property (strong, nonatomic) NSMutableArray *orderedListOfDonors;
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) UISegmentedControl *mySegmentedControl;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic) NSInteger selectedDonation;

@property (nonatomic, strong) FISDonorsChooseDatastore   *datastore;

-(void) setupSegmentedControl;
-(void) prepareTableViewForResizingCells;
//-(void) populateCommentsDictionary;



@end


NSString * const INPUT_CELL_IDENTIFIER = @"inputCell";
NSString * const BASIC_CELL_IDENTIFIER = @"basicCell";

@implementation CommentsViewController

#pragma mark - View LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.proposal=((DetailsTabBarController*)self.tabBarController).selectedProposal;
    self.datastore=[FISDonorsChooseDatastore sharedDataStore];
    [self setupSegmentedControl];
    [self setupLayout];
//    [self populateCommentsDictionary];
    [self prepareTableViewForResizingCells];
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.myTableView.delegate=self;
    self.myTableView.dataSource=self;

}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"MEMORY WARNING");
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.proposal.donations count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSString *donorName = [self.commentsDictionary allKeys][section];
//    NSArray *thisDonorsComments = self.commentsDictionary[donorName];
//    return [thisDonorsComments count];
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *donorName = [self.commentsDictionary allKeys][indexPath.section];
//    NSArray *thisSetOfComments = self.commentsDictionary[donorName];
//    FISComment *thisComment = thisSetOfComments[indexPath.row];
    
    
    if (indexPath.row==1) {
        if ([((FISDonation *)self.proposal.donations[indexPath.section]).responseMessage length]<1) {
            FISInputCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:INPUT_CELL_IDENTIFIER];
            if (!cell) {
                cell = [[FISInputCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:INPUT_CELL_IDENTIFIER];
            }
            cell.CommentsViewController=self;
            //        cell.parentTableView = tableView;
            cell.placeholder = INPUT_CELL_PLACEHOLDER;
            return cell;

        } else {
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: BASIC_CELL_IDENTIFIER];
            if (!cell){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BASIC_CELL_IDENTIFIER];
            }
            [self formatCell: cell forBasicDisplaywithMessage: ((FISDonation *)self.proposal.donations[indexPath.section]).responseMessage andIndexPath:indexPath];
            return cell;
            
        }
        
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: BASIC_CELL_IDENTIFIER];
        if (!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BASIC_CELL_IDENTIFIER];
        }
        if ([((FISDonation *)self.proposal.donations[indexPath.section]).donorMessage length]>0) {
            [self formatCell: cell forBasicDisplaywithMessage: ((FISDonation *)self.proposal.donations[indexPath.section]).donorMessage andIndexPath:indexPath];
            return cell;

        } else {
            [self formatCell: cell forBasicDisplaywithMessage: [NSString stringWithFormat:@"%@ from %@ donated.",((FISDonation *)self.proposal.donations[indexPath.section]).donorName,((FISDonation *)self.proposal.donations[indexPath.section]).donorLocation] andIndexPath:indexPath];
            return cell;
        }
    }
}

#pragma mark - UITableViewDelegate

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"%@", ((FISDonation *) self.proposal.donations[section]).donorName];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    // height-less because we implement tableView:heightForFooterInSection:
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0,0, tableView.frame.size.width, 30)];
    view.backgroundColor = [UIColor DonorsChooseWhite];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50; // just seemed like a magical number
}

#pragma mark - Formatting Helpers

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        if (tableView == self.myTableView) {
            CGFloat cornerRadius = 8.f;
            cell.backgroundColor = [UIColor DonorsChooseGreyVeryLight];
            
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGRect bounds = (CGRectInset(cell.bounds, 10, 2));
//            if ([cell isKindOfClass:[FISInputCommentCell class]]) {
//                bounds = CGRectInset(((FISInputCommentCell *)cell).myTextView.bounds, 10, 2);
//            } else if ([cell isKindOfClass:[UITableViewCell class]]){
//                bounds = CGRectInset(cell.textLabel.frame, 10, 2);
//            }
            
            CGPathMoveToPoint(pathRef, nil, CGRectGetMidX(bounds), CGRectGetMinY(bounds));  //topcenter
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMinX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
            

            layer.path = pathRef;
            CFRelease(pathRef);

            layer.fillColor = [UIColor DonorsChooseOrange].CGColor;
            UIView *testView = [[UIView alloc] initWithFrame:bounds];
            [testView.layer insertSublayer:layer atIndex:0];
            testView.backgroundColor = UIColor.clearColor;
            cell.backgroundView = testView;
        }
    }
}



-(void) formatCell:(UITableViewCell*) cell forBasicDisplaywithMessage: (NSString*) comment andIndexPath: (NSIndexPath *) indexPath
{
    cell.textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = comment;
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self formatCell: cell byCommentTypeWithMessage:comment andIndexPath: indexPath];
}

-(void) formatCell: (UITableViewCell*) cell byCommentTypeWithMessage: (NSString *) comment andIndexPath: (NSIndexPath *) indexPath
{
    // !!! need to have counter-acting actions in each since cells are reusable
    if (indexPath.row==0)
    {
        cell.backgroundColor = [UIColor DonorsChooseGreyLight];
        cell.textLabel.textColor=[UIColor DonorsChooseGreyVeryLight];
        cell.textLabel.font = [UIFont fontWithName:DonorsChooseBodyBoldFont size:17];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.indentationLevel = 0;
    }
    else
    {
        cell.backgroundColor = [UIColor DonorsChooseGreyVeryLight];
        cell.textLabel.textColor=[UIColor DonorsChooseWhite];
        cell.textLabel.font = [UIFont fontWithName:DonorsChooseBodyItalicFont size:17];
        cell.textLabel.textAlignment = NSTextAlignmentRight;
        cell.indentationLevel = 3;
    }
}

#pragma mark - Initialization Helpers

-(void) setupLayout {
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text=self.proposal.title;
    self.titleLabel.font=[UIFont fontWithName:DonorsChooseTitleBoldFont size:20];
    self.titleLabel.textColor=[UIColor DonorsChooseBlack];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.textAlignment=NSTextAlignmentCenter;
    self.myTableView = [[UITableView alloc]init];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.myTableView];
    self.view.backgroundColor=[UIColor DonorsChooseWhite];
    
    
    
    [self.mySegmentedControl removeConstraints:self.mySegmentedControl.constraints];
    [self.myTableView removeConstraints:self.myTableView.constraints];
    [self.titleLabel removeConstraints:self.titleLabel.constraints];
    [self.view removeConstraints:self.view.constraints];
    
    [self.myTableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.mySegmentedControl setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.titleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *views = @{@"view":self.view,@"segmentedControl":self.mySegmentedControl,@"titleLabel":self.titleLabel,@"tableView":self.myTableView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleLabel(view)]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[segmentedControl(view)]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-65-[titleLabel(80)][segmentedControl(35)]-[tableView]-30-|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[tableView]-|" options:0 metrics:nil views:views]];
}

-(void) setupSegmentedControl
{
    self.mySegmentedControl= [[UISegmentedControl alloc] initWithItems:@[@"Awaiting Reply", @"All"]];
    self.mySegmentedControl.selectedSegmentIndex = 0;

    self.mySegmentedControl.layer.borderWidth=1;
    self.mySegmentedControl.layer.borderColor =[UIColor DonorsChooseOrange].CGColor;
    self.mySegmentedControl.tintColor=[UIColor DonorsChooseOrange];
    [self.view addSubview:self.mySegmentedControl];
}




-(void) saveDonationWithMessage:(NSString *)responseMessage andIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@ for donation: %ld",responseMessage, indexPath.section);
    [self.myTableView reloadData];
    
    [self.datastore addNewDonationResponseMessage:responseMessage forDonation:self.proposal.donations[indexPath.section] forProposal:self.proposal andCompletion:^(BOOL completion) {

        
    }];
    
}


-(void) prepareTableViewForResizingCells
{
    self.myTableView.rowHeight = UITableViewAutomaticDimension;
    self.myTableView.estimatedRowHeight = 50.0;
}

//-(void) populateCommentsDictionary
//{
//    self.commentsDictionary = [[NSMutableDictionary alloc] init];
//    
//    for(FISDonation *donation in self.proposal.donations)
//    {
//        FISComment *donorComment = [FISComment createDonorCommentFromDonation: (FISDonation*) donation];
//        FISComment *teacherResponse = [FISComment createTeacherCommentFromDonation: (FISDonation*) donation];
//        [self.commentsDictionary setObject:@[donorComment, teacherResponse] forKey: donation.donorName];
//    }
//    NSLog(@"dictionary %@", self.commentsDictionary);
//    [self.myTableView reloadData];
//}




@end