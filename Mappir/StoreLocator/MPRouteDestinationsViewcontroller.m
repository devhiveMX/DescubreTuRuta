//
//  MPAddingLocationsViewcontroller.m
//  Mappir
//
//  Created by Leonardo Cid on 12/10/14.
//  Copyright (c) 2014 Devhive. All rights reserved.
//

#import "MPRouteDestinationsViewcontroller.h"
#import "MPDestinationTableViewCell.h"

@interface MPRouteDestinationsViewcontroller ()
@property IBOutlet UITableView *tableView;

@end

@implementation MPRouteDestinationsViewcontroller

- (void)viewDidLoad {
    [super viewDidLoad];
    destinationsArray = [NSMutableArray arrayWithObjects:@"",@"", nil];
    [self.tableView setDataSource:self];
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
        }
        destinationCell.alphabeticLabel.text = [NSString stringWithFormat:@"%c", (int)('A' + indexPath.row)];
        NSLog(@"IndexPath: %@", indexPath);
        if (indexPath.row == 0) {
            [destinationCell configure:TypeOrigin];
        } else if (indexPath.row == [destinationsArray count] - 1) {
            [destinationCell configure:TypeDestination];
        } else {
            [destinationCell configure:TypeMiddle];
        }
    } else {
        
    }
    
    return cell;
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

@end
