//
//  MPSearchResultsViewController.h
//  Mappir
//
//  Created by Leonardo Cid on 18/10/14.
//  Copyright (c) 2014 Devhive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPSearchResult.h"

@protocol MPSearchResultsDelegate <NSObject>
- (void)resultSelected:(NSInteger)index;
- (BOOL)shouldUseSections;
@end

@interface MPSearchResultsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<MPSearchResultsDelegate> delegate;
@property (nonatomic) BOOL loadingOnStart;
@property (nonatomic, strong) NSArray *results;
@property (nonatomic) BOOL usingSections;

- (void)refreshResults:(NSArray*)results;

@end
