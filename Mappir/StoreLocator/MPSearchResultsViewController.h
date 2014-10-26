//
//  MPSearchResultsViewController.h
//  Mappir
//
//  Created by Leonardo Cid on 18/10/14.
//  Copyright (c) 2014 Devhive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPSearchResult.h"
@protocol MPSearchResultsDataSource <NSObject>
- (NSInteger)numberOfResults;
- (MPSearchResult*)resultForIndex:(NSInteger)index;
@end

@protocol MPSearchResultsDelegate <NSObject>
- (void)resultSelected:(NSInteger)index;
@end

@interface MPSearchResultsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<MPSearchResultsDataSource> dataSource;
@property (nonatomic, weak) id<MPSearchResultsDelegate> delegate;
@property (nonatomic) BOOL loadingOnStart;

- (void)refreshResults;

@end
