//
//  MasterViewController.m
//  TestTaskiOD
//
//  Created by Sergei Makarov on 24.04.15.
//  Copyright (c) 2015 Sergei Makarov. All rights reserved.
//

#import "MasterViewController.h"
#import "SecondViewController.h"
#import "MyCell.h"
#import "CellData.h"
#import "DBManager.h"

static int s_numRcords = 0;

static NSString* s_names[] = {@"britney", @"tarja", @"alan", @"bob", @"park", @"trevis", @"lola"};
static int s_nameId = 0;

static UIInterfaceOrientation s_currentOrientation = UIInterfaceOrientationPortrait;

@interface MasterViewController ()

@property NSMutableArray *objects;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    [[DBManager getSharedInstance] createDB];
    
    self.objects = [[NSMutableArray alloc] init];
    
    imagesPath = [[NSMutableString alloc] initWithString:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]];
    [imagesPath appendString:@"/images/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagesPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:imagesPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    
    //https://itunes.apple.com/search?term=%s&entity=musicVideo
    
    self.tableView.delegate = self;
    [self loadMoreRows];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRecognizer:)];
    recognizer.direction = UISwipeGestureRecognizerDirectionRight;
    recognizer.delegate = self;
    [self.view addGestureRecognizer:recognizer];
}

- (void)swipeRecognizer:(UISwipeGestureRecognizer *)sender
{
    if (s_currentOrientation == UIInterfaceOrientationLandscapeLeft ||
        s_currentOrientation == UIInterfaceOrientationLandscapeRight)
    {
        if (sender.direction == UISwipeGestureRecognizerDirectionRight){
            NSLog(@"SWIPE");
            SecondViewController *tb = [[SecondViewController alloc] init];
            tb = [self.storyboard instantiateViewControllerWithIdentifier:@"SecondViewController"];
            
            
            CATransition *transition = [CATransition animation];
            transition.duration = .3;
            transition.type = kCATransitionMoveIn;
            transition.subtype= kCATransitionFromLeft;
            
            [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
            
            tb.masterController = self;
            
            [self.navigationController pushViewController:tb animated:NO];
        }
    }
    
}

-(void)loadMoreRows
{
    if (s_nameId < 7)
    {
        NSString *urlAsString = [NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&entity=musicVideo", s_names[s_nameId]];
        NSURL *url = [[NSURL alloc] initWithString:urlAsString];
        NSLog(@"%@", urlAsString);
        
        s_nameId++;
        loadingInProcess = YES;
        
        [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            
            [self groupsFromJSON:data];
            loadingInProcess = NO;
        }];
    }
    
}


-(NSArray *)groupsFromJSON:(NSData *)objectNotation
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        //*error = localError;
        return nil;
    }
    
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    NSArray *results = [parsedObject valueForKey:@"results"];
    NSLog(@"Count %d", results.count);
    
    for (NSDictionary *groupDic in results) {
        NSString* key = [NSString stringWithFormat:@"%@%@%@",
                         [groupDic objectForKey:@"artistName"],
                         [groupDic objectForKey:@"collectionName"],
                         [groupDic objectForKey:@"trackName"]];
        
        NSRange range = [[groupDic objectForKey:@"artworkUrl60"] rangeOfString:@"/" options:NSBackwardsSearch];
        NSString* artworkPath = [[groupDic objectForKey:@"artworkUrl60"] substringFromIndex:range.location+1];
        [[DBManager getSharedInstance] insert:key
                                 artworkUrl60:[groupDic objectForKey:@"artworkUrl60"]
                                  artworkPath:artworkPath
                                   artistName:[groupDic objectForKey:@"artistName"]
                               collectionName:[groupDic objectForKey:@"collectionName"]
                                    trackName:[groupDic objectForKey:@"trackName"]];
        
        NSString* imagePath = [NSString stringWithFormat:@"%@%@", imagesPath, artworkPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
        {
            NSURL *url = [NSURL URLWithString:[groupDic objectForKey:@"artworkUrl60"]];
            NSData *data = [NSData dataWithContentsOfURL:url];
            if (data)
            {
                UIImage *image = [UIImage imageWithData:data];
                [UIImageJPEGRepresentation(image, 1) writeToFile:imagePath
                                                      atomically:YES];
            }
        }
    }
    
    
    NSArray* array = [[DBManager getSharedInstance] getAll];
    
    s_numRcords = [array count];
    //[self.objects removeAllObjects];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        int objCount = 0;
        for (NSDictionary *groupDic in array) {
            
            objCount++;
            if (objCount < [self.objects count])
            {
                continue;
            }
            
            CellData* data = [[CellData alloc] init];
            data.Title = [groupDic objectForKey:@"artistName"];
            data.Subtitle = [NSString stringWithFormat:@"%@ - %@", [groupDic objectForKey:@"trackName"], [groupDic objectForKey:@"collectionName"]];
            data.artPath = [groupDic objectForKey:@"artworkPath"];
            
            int index = [self.objects count];
            [self.objects insertObject:data atIndex:index];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    });
    
    return groups;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        self.menuButton.hidden = YES;
    }
    else
        self.menuButton.hidden = NO;
    s_currentOrientation = toInterfaceOrientation;
}
#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell" forIndexPath:indexPath];

    CellData *object = self.objects[indexPath.row];
    cell.Title.text = object.Title;
    cell.Subtitle.text = object.Subtitle;
    
    [cell.Photo setImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@", imagesPath, object.artPath]]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    // NSLog(@"offset: %f", offset.y);
    // NSLog(@"content.height: %f", size.height);
    // NSLog(@"bounds.height: %f", bounds.size.height);
    // NSLog(@"inset.top: %f", inset.top);
    // NSLog(@"inset.bottom: %f", inset.bottom);
    // NSLog(@"pos: %f of %f", y, h);
    
    float reload_distance = 10;
    if(y > h + reload_distance)
    {
        if (!loadingInProcess)
        {
            NSLog(@"load more rows");
            [self loadMoreRows];
        }
        
    }
}

#pragma mark - static method

+(int)getNumRecords
{
    return s_numRcords;
}

@end
