//
//  MPSearchResultsViewController.m
//  Mappir
//
//  Created by Leonardo Cid on 18/10/14.
//  Copyright (c) 2014 Devhive. All rights reserved.
//

#import "MPSearchResultsViewController.h"
#import "UIPopoverController+iPhone.h"
#import "WEPopoverController.h"
#import "MPResultCell.h"
#import "MPSearchResult.h"

@interface MPSearchResultsViewController ()
@property (nonatomic, strong) IBOutlet UITableView *resultsTableView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *loadingView;
@end

@implementation MPSearchResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.preferredContentSize = CGSizeMake(200, 180);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"Disappear");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (WEPopoverContainerViewProperties *)getContainerViewProperties {
    
    WEPopoverContainerViewProperties *props = [WEPopoverContainerViewProperties alloc];
    NSString *bgImageName = @"popoverBg";
    
    CGFloat bgMargin = 15.0;
    CGFloat bgCapSize = 0.0;
    CGFloat contentMargin = 4.0;
    CGSize ImageSize = CGSizeMake(30, 30);
    
    // These constants are determined by the popoverBg.png image file and are image dependent
    bgMargin = 10; // margin width of 13 pixels on all sides popoverBg.png (62 pixels wide - 36 pixel background) / 2 == 26 / 2 == 13
    bgCapSize = ImageSize.width/2;
    props.leftBgMargin = bgMargin;
    props.rightBgMargin = bgMargin;
    props.topBgMargin = bgMargin;
    props.bottomBgMargin = bgMargin;
    props.leftBgCapSize = bgCapSize;
    props.topBgCapSize = bgCapSize;
    props.bgImageName = bgImageName;
    props.leftContentMargin = contentMargin;
    props.rightContentMargin = contentMargin - 1; // Need to shift one pixel for border to look correct
    props.topContentMargin = contentMargin;
    props.bottomContentMargin = contentMargin;
    props.arrowMargin = 4.0;
    props.upArrowImageName = @"popoverArrowUp";
    props.downArrowImageName = @"popoverArrowDown";
    props.leftArrowImageName = @"popoverArrowLeft";
    props.rightArrowImageName = @"popoverArrowRight";
    return props;	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.usingSections)
    {
        NSDictionary *sectionDict = self.results[section];
        NSArray *itemsPerSection = sectionDict[@"results"];
        return [itemsPerSection count];
    }
    return [self.results count];
}

- (MPSearchResult*)itemForIndexPath:(NSIndexPath*)indexPath {
    if (self.usingSections) {
        NSDictionary *section = self.results[indexPath.section];
        NSArray *itemsPerSection = section[@"results"];
        return itemsPerSection[indexPath.row];
    }
    return self.results[indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.usingSections)
        return [self.results count];
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MPResultCell *cell = (MPResultCell*)[tableView dequeueReusableCellWithIdentifier:@"ResultCell"];
    MPSearchResult *result = [self itemForIndexPath:indexPath];
    cell.lblResultName.text = result.resultName;
    cell.lblResultType.text = result.typeString;
    return cell;
}

- (void)refreshResults:(NSArray*)data {
    self.results = data;
    
    [self.resultsTableView reloadData];
    [self.loadingView stopAnimating];
}

- (void)setLoadingOnStart:(BOOL)loadingOnStart {
    _loadingOnStart = loadingOnStart;
    if (_loadingOnStart)
    {
        [self.loadingView startAnimating];
    } else {
        [self.loadingView stopAnimating];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate) {
        [self.delegate resultSelected:indexPath.row];
    }
}

@end
