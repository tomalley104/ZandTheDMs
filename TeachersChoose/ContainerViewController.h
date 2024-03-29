//
//  ContainerViewController.h
//  TeachersChoose
//
//  Created by Tom OMalley on 4/15/15.
//  Copyright (c) 2015 ZandTheDMs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FISDonorsChooseProposal.h"

@class FISDonorsChooseProposal;
@interface ContainerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIProgressView *myProgressView;
@property (strong, nonatomic) FISDonorsChooseProposal *proposal;


@end
