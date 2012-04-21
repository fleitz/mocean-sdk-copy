//
//  MASTSAdvancedTable.m
//  AdMobileSamples
//
//  Created by Jason Dickert on 4/18/12.
//  Copyright (c) 2012 mOcean Mobile. All rights reserved.
//

#import "MASTSAdvancedTable.h"
#import "MASTAdView.h"


@interface MASTSAdvancedTable ()
@property (nonatomic, retain) MASTSAdConfigController* adConfigController;
@end

@implementation MASTSAdvancedTable

@synthesize adConfigController;

- (void)dealloc
{
    self.adConfigController.delegate = nil;
    self.adConfigController = nil;
    
    [super dealloc];
}

- (id)init
{
    self = [self initWithStyle:UITableViewStylePlain];
    if (self)
    {
        
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.adConfigController = [[MASTSAdConfigController new] autorelease];
        self.adConfigController.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.tableHeaderView = self.adConfigController.view;
    
    self.adConfigController.site = 19829;
    self.adConfigController.zone = 102238;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.row > 0) && (indexPath.row % 5 == 0))
        return 50;
    
    return 44;
}

static NSString *CellIdentifier = @"Cell";
static NSString *AdCellIdentifier = @"AdCell";
static NSInteger AdViewTag = 123;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* cellId = CellIdentifier;
    
    if ((indexPath.row > 0) && (indexPath.row % 5 == 0))
        cellId = AdCellIdentifier;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:cellId] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (cellId == AdCellIdentifier)
        {
            CGRect frame = CGRectMake(0, 0, tableView.bounds.size.width, 50);
            MASTAdView* adView = [[[MASTAdView alloc] initWithFrame:frame] autorelease];
            adView.backgroundColor = [UIColor darkGrayColor];
            adView.showPreviousAdOnError = YES;
            adView.autoCollapse = NO;
            adView.tag = AdViewTag;
            [cell.contentView addSubview:adView];
        }
    }
    
    if (cellId == CellIdentifier)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    }
    else
    {
        MASTAdView* adView = (MASTAdView*)[cell.contentView viewWithTag:AdViewTag];
        adView.site = self.adConfigController.site;
        adView.zone = self.adConfigController.zone;
        [adView update];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark -

- (void)updateAdWithConfig:(MASTSAdConfigController *)configController
{
    NSArray* cells = [self.tableView visibleCells];
    
    for (UITableViewCell* cell in cells)
    {
        if (cell.reuseIdentifier == AdCellIdentifier)
        {
            MASTAdView* adView = (MASTAdView*)[cell.contentView viewWithTag:AdViewTag];
            
            adView.site = configController.site;
            adView.zone = configController.zone;
            [adView update];
        }
    }
}

@end
