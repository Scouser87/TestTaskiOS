//
//  MyCell.h
//  TestTaskiOD
//
//  Created by Sergei Makarov on 24.04.15.
//  Copyright (c) 2015 Sergei Makarov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *Title;
@property (nonatomic, weak) IBOutlet UILabel *Subtitle;
@property (nonatomic, weak) IBOutlet UIImageView *Photo;
@end
