//
//  MainViewController.h
//  MobileApps4Tourism
//
//  Created by Mats Sandvoll on 18.09.13.
//  Copyright (c) 2013 Mats Sandvoll. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"
#import "ViewTaskController.h"
#import "NewTaskViewController.h"
#import "DBManager.h"
#import "LogManager.h"
#import "Manager.h"

@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NewTaskViewControllerDelegate>

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *tasks;
@property (nonatomic, retain) Task *task;
@property (nonatomic, retain) DBManager *dbManager;
@property (nonatomic, retain) Manager *manager;

@end
