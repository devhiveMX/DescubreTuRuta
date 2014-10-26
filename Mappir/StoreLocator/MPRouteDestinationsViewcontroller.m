//
//  MPAddingLocationsViewcontroller.m
//  Mappir
//
//  Created by Leonardo Cid on 12/10/14.
//  Copyright (c) 2014 Devhive. All rights reserved.
//

#import "MPRouteDestinationsViewcontroller.h"
#import "MPDestinationTableViewCell.h"
#import "UIPopoverController+iPhone.h"
#import "WebServices.h"
#import "MPSearchResult.h"
#import "UIImage+Extras.h"

@interface MPRouteDestinationsViewcontroller ()
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *resultsArray;
@end

@implementation MPRouteDestinationsViewcontroller

- (void)viewDidLoad {
    [super viewDidLoad];
    destinationsArray = [NSMutableArray arrayWithObjects:@"",@"", nil];
    [self.tableView setDataSource:self];
    self.resultsArray = [NSMutableArray array];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSString *identifier = indexPath.row < [tableView numberOfRowsInSection:indexPath.section] - 1? @"DestinationCell" : @"SearchCell";
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (indexPath.row < [tableView numberOfRowsInSection:indexPath.section] - 1) {
        MPDestinationTableViewCell *destinationCell = (MPDestinationTableViewCell*)cell;
        if (!destinationCell.configured) {
            [destinationCell.deleteButton addTarget:self action:@selector(deleteDestination:event:) forControlEvents:UIControlEventTouchUpInside];
            [destinationCell.swapDestinationButton addTarget:self action:@selector(addDestination:event:) forControlEvents:UIControlEventTouchUpInside];
            destinationCell.configured = YES;
            [destinationCell.destinationInfoTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        }
        destinationCell.alphabeticLabel.text = [NSString stringWithFormat:@"%c", (int)('A' + indexPath.row)];
        destinationCell.destinationInfoTextField.delegate = self;
        id item = destinationsArray[indexPath.row];
        if ([item isKindOfClass:[NSString class]]) {
            destinationCell.destinationInfoTextField.text = item;
        } else {
            MPSearchResult *result = item;
            destinationCell.destinationInfoTextField.text = result.resultName;
        }
        NSLog(@"IndexPath: %@", indexPath);
        if (indexPath.row == 0) {
            [destinationCell configure:TypeOrigin];
        } else if (indexPath.row == [destinationsArray count] - 1) {
            [destinationCell configure:TypeDestination];
        } else {
            [destinationCell configure:TypeMiddle];
        }
    } else {
        UIButton *button = (UIButton*)[cell viewWithTag:5];
        if (!button) {
            button = (UIButton*)[cell.contentView viewWithTag:5];
        }
        if (![button targetForAction:@selector(startRetrievingRoute:) withSender:button]) {
            [button addTarget:self action:@selector(startRetrievingRoute:) forControlEvents:UIControlEventTouchUpInside];
            [button setBackgroundImage:[UIImage imageFromColor:[UIColor colorWithRed:0.41 green:0.41 blue:0.41 alpha:1.0]] forState:UIControlStateDisabled];
        }
        button.enabled = canGetRoute;
    }
    
    return cell;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self.resultsArray removeAllObjects];
    MPSearchResultsViewController *resultsVC = (MPSearchResultsViewController*) [self.popover contentViewController];
    [resultsVC refreshResults];
    [self checkIfCanGetRoute];
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [destinationsArray count] + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (IBAction)addDestination:(UIButton*)button event:(UIEvent*)event{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPos = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPos];
    NSLog(@"%@", indexPath);
    if (indexPath.row == destinationsArray.count - 1 && destinationsArray.count < 6) {
        [destinationsArray addObject:@""];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (IBAction)deleteDestination:(UIButton*)button event:(UIEvent*)event{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchPos = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPos];
    [destinationsArray removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.searchTimer) {
        [self.searchTimer invalidate];
        self.searchTimer = nil;
    }
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newString.length != 0 && newString.length > 2) {
        self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(launchSearch:) userInfo:textField repeats:NO];
        UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        currentSearchFieldIndex = indexPath.row;
    }
    return YES;
}

- (void)launchSearch:(NSTimer*)timer {
    UITextField* textField = timer.userInfo;
    NSString *newString = textField.text;
    [self.resultsArray removeAllObjects];
    if (!self.popover) {
        MPSearchResultsViewController *resultsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchResultsVC"];
        resultsVC.delegate = self;
        resultsVC.dataSource = self;
        resultsVC.loadingOnStart = YES;
        self.popover = [[WEPopoverController alloc] initWithContentViewController:resultsVC];
        self.popover.delegate = self;
        [self.popover presentPopoverFromRect:[textField convertRect:textField.frame toView:self.view] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown| UIPopoverArrowDirectionUp animated:YES];
        [WebServicesManager searchWithCriteria:newString and4Square:NO andGooglePlaces:NO observer:self];
        
    } else {
        [WebServicesManager searchWithCriteria:newString and4Square:NO andGooglePlaces:NO observer:self];
    }
    self.searchTimer = nil;
}

- (void)webServicesConnectionDidFail:(NSNotification *)notification {
    [self.resultsArray removeAllObjects];
    MPSearchResultsViewController *resultsVC = (MPSearchResultsViewController*) self.popover.contentViewController;
    [resultsVC refreshResults];
}

- (void)webServicesConnectionDidFinish:(NSNotification *)notification {
    NSDictionary *resultDict = notification.userInfo[@"resultDictionary"];
    WSConnectionType type = [[[notification userInfo] objectForKey:@"type"] intValue];
    switch (type) {
        case WSConnectionTypeLocationSearch:
        {
            [self populateResults:resultDict];
            MPSearchResultsViewController *resultsVC = (MPSearchResultsViewController*) self.popover.contentViewController;
            [resultsVC refreshResults];
        }
            break;
            
        default:
            break;
    }
    
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)popoverController {
    return YES;
}

- (void)popoverControllerDidAppear:(WEPopoverController *)popoverController {
    NSLog(@"Popover appear");
}

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)popoverController {
    NSLog(@"Popover dismissed");
    self.popover = nil;
    currentSearchFieldIndex = -1;
}

- (void)populateResults:(NSDictionary *)resultsDict {
    [self.resultsArray removeAllObjects];
    NSArray *resultsArray = resultsDict[@"mappir"];
    for (NSDictionary *result in resultsArray) {
        MPSearchResult *searchResult = [[MPSearchResult alloc] initWithDictionary:result];
        [self.resultsArray addObject:searchResult];
    }
    
//    [self.resultsArray removeAllObjects];
//    NSArray *resultsArray = resultsDict[@"mappir"];
//    NSMutableDictionary *sectionDictionary = [NSMutableDictionary dictionary];
//    for (NSDictionary *result in resultsArray) {
//        MPSearchResult *searchResult = [[MPSearchResult alloc] initWithDictionary:result];
//        NSMutableArray *resultsArr = nil;
//        if (!sectionDictionary[@"typeTitle"]) {
//            sectionDictionary[@"typeTitle"] = searchResult.typeString;
//            resultsArr = [NSMutableArray array];
//            [self.resultsArray addObject:sectionDictionary];
//        }
//        
//        if (sectionDictionary[typeT])
//            
//            [resultsArr addObject:searchResult];
//        
//        
//    }
}

- (NSInteger) numberOfResults {
    return self.resultsArray.count;
}

- (NSInteger) numberOfSections {
    return 1;
}

- (void)resultSelected:(NSInteger)index {
    MPSearchResult *result = self.resultsArray[index];
    destinationsArray[currentSearchFieldIndex] = result;
    [self.popover dismissPopoverAnimated:YES];
    [self checkIfCanGetRoute];
    [self.tableView reloadData];
}

- (MPSearchResult*)resultForIndex:(NSInteger)index {
    return self.resultsArray[index];
}

- (IBAction)startRetrievingRoute:(id)sender {
    if (self.delegate) {
        [self.delegate getRouteWithDestinations:destinationsArray];
    }
}

- (void)checkIfCanGetRoute {
    for (id item in destinationsArray) {
        if (![item isKindOfClass:[MPSearchResult class]]) {
            canGetRoute = NO;
            return;
        }
        
    }
    canGetRoute = YES;
}
             
@end
