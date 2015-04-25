//
//  SecondViewController.m
//  TestTaskiOD
//
//  Created by Sergei Makarov on 25.04.15.
//  Copyright (c) 2015 Sergei Makarov. All rights reserved.
//

#import "SecondViewController.h"
#import "MasterViewController.h"

@implementation SecondViewController

@synthesize masterController = _masterController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.menuCaption setText:[NSString stringWithFormat:@"Прочитано записей: %d", [MasterViewController getNumRecords]]];
    if (self.masterController != nil)
    {
        self.backButton.hidden = true;
    }
}

- (IBAction)tappedCloseModal:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)closeApplication:(id)sender {
    exit(0);
}

@end
