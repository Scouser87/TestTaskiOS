//
//  SecondViewController.h
//  TestTaskiOD
//
//  Created by Sergei Makarov on 25.04.15.
//  Copyright (c) 2015 Sergei Makarov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *menuCaption;

@property (weak) UIViewController* masterController;

- (IBAction)tappedCloseModal:(id)sender;
- (IBAction)closeApplication:(id)sender;
@end
