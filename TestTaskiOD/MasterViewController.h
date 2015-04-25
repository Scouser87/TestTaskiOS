//
//  MasterViewController.h
//  TestTaskiOD
//
//  Created by Sergei Makarov on 24.04.15.
//  Copyright (c) 2015 Sergei Makarov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;
@class SecondViewController;

@interface MasterViewController : UITableViewController <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    NSString *databasePath;
    NSMutableString* imagesPath;
    BOOL loadingInProcess;
}
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) SecondViewController *secondViewController;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

-(void)loadMoreRows;
+(int)getNumRecords;
@end

