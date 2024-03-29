//
//  MainViewController.m
//  MobileApps4Tourism
//
//  Created by Mats Sandvoll on 18.09.13.
//  Copyright (c) 2013 Mats Sandvoll. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    //Presistant
    self.dbManager = [[DBManager alloc]init];
    [self.dbManager initDatabase];
    self.tasks = [self.dbManager getAllTasks];
    //Not presistant
//    self.manager = [[Manager alloc]init];
//    [self.manager initManager];
//    self.tasks = [self.manager getAllTasks];
    
    
    NSLog(@"fist object %d", (int)self.tasks.count);
   
    NSLog(@"fist object %d", (int)self.tasks.count);
    
    self.title = @"To-Do";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStylePlain];
    self.tableView.rowHeight = 50;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem *syncButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(syncClicked:)] ;
    UIBarButtonItem *delButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(delClicked:)] ;
    NSMutableArray *barButtons = [[NSMutableArray alloc]init];
    [barButtons addObject:syncButton];
    [barButtons addObject:delButton];
    self.navigationItem.rightBarButtonItems = barButtons;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)reloadTableData:(NewTaskViewController *)controller{
    self.tasks = [self.dbManager getAllTasks];
    [self.tableView reloadData];
}

- (IBAction)syncClicked:(id)sender{
    //PUSH TO SERVER
    LogManager *logMan = [[LogManager alloc]init];
    if ([logMan logFileHasContent]) {
        [logMan readLog];
    }
    NSData *dataFromServer = [[NSData alloc] initWithContentsOfURL:
                              [NSURL URLWithString:@"http://demo--1.azurewebsites.net/JSON.php?f=getToDo"]];
    NSError *error;
    NSMutableArray *arrayJson = [NSJSONSerialization JSONObjectWithData:dataFromServer options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error];
    if(error){
        NSLog(@"%@", [error localizedDescription]);
    }
    else {
        [self.tasks removeAllObjects];
        [self.dbManager deleteAllTasks];
        for (NSDictionary *data in arrayJson) {
            Task *newTask = [[Task alloc] init];
            newTask.name = [data objectForKey:@"Title"];
            newTask.description = [data objectForKey:@"Description"];
            newTask.date = [data objectForKey:@"Date"];
            newTask.externalTaskID = [NSString stringWithFormat:@"%@",[data objectForKey:@"id"]].intValue;
            newTask.taskID = [self.dbManager insertTask:newTask];
        }
    }
    self.tasks = [self.dbManager getAllTasks];
    [self.tableView reloadData];
}


- (IBAction)newClicked:(id)sender {
    NewTaskViewController *newTaskView = [[NewTaskViewController alloc] init];
    newTaskView.delegate = self;
    [self.navigationController pushViewController:newTaskView animated:YES];
}

-(IBAction)delClicked:(id)sender{
    NSString *alertTitle = [[NSString alloc]initWithFormat:@"Are you sure you want to delete all tasks?"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete Tasks", nil ];
    NSLog(@"fist object %d", (int)self.tasks.count);
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self.dbManager deleteAllTasks];
        self.tasks = [self.dbManager getAllTasks];
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = self.tasks.count;
    if(self.editing) {
        count = count + 1;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    if (indexPath.row < self.tasks.count ) {
        self.task= [self.tasks objectAtIndex:indexPath.row];
        cell.textLabel.text = self.task.name;
        cell.detailTextLabel.text = self.task.description;
        cell.detailTextLabel.text = self.task.date;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.textLabel.text = @"Add New Task";
        cell.detailTextLabel.text = @"";
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ((indexPath.row < self.tasks.count) && !self.editing) {
        ViewTaskController *viewTask = [[ViewTaskController alloc] init];
        viewTask.task = [self.tasks objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:viewTask animated:YES];
    }else if ((indexPath.row == self.tasks.count) && self.editing){
        NewTaskViewController *newTaskView = [[NewTaskViewController alloc] init];
        newTaskView.delegate = self;
        [self.navigationController pushViewController:newTaskView animated:YES];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.tasks.count ) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleInsert;
    }
}

-(void)setEditing:(BOOL)editing animated:(BOOL) animated {
    if( editing != self.editing ) {
        [super setEditing:editing animated:animated];
        [self.tableView setEditing:editing animated:animated];
        NSArray *indexes = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.tasks.count inSection:0]];
        if (editing == YES ) {
            [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationLeft];
        } else {
            [self.tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle) editing
 forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editing == UITableViewCellEditingStyleDelete) {
        [self.dbManager deleteAllNotesToTask:[self.tasks objectAtIndex:indexPath.row]];
        [self.dbManager deleteTask:[self.tasks objectAtIndex:indexPath.row]];
        LogManager *logMan = [[LogManager alloc]init];
        [logMan writeToLog:DeleteTask :[self.tasks objectAtIndex:indexPath.row]];
        
        [self.tasks removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }else{
        NewTaskViewController *newTaskView = [[NewTaskViewController alloc] init];
        self.editing = NO;
        newTaskView.delegate = self;
        [self.navigationController pushViewController:newTaskView animated:YES];
    }
}


//Extra Functions

/*
//Reset memory using NSUserDefaults
- (void)resetMemory {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
}*/

/*
//Load from memory using NSUserDefalts
- (void) loadFromMemory{
    for (int i=0; i<20; i++) {
        NSString *counter = [NSString stringWithFormat:@"%d",i];
        NSString *name = @"Task";
        NSString *task = [name stringByAppendingString:counter];
        NSString *key1 = [task stringByAppendingString:@"name"];
        self.task = [[Task alloc] init];
        self.task.name = [[NSUserDefaults standardUserDefaults] objectForKey:key1];
        NSString *key2 = [task stringByAppendingString:@"date"];
        self.task.date = [[NSUserDefaults standardUserDefaults] objectForKey:key2];
        NSString *key3 = [task stringByAppendingString:@"note"];
        self.task.note = [[NSUserDefaults standardUserDefaults] objectForKey:key3];
        if ([self.task.name length]!=0){
            [self.taskArray addObject:self.task];
            NSLog(@"Loaded from memory:%@",self.task.name);
        }
    }
}*/

/*
//Save to memory using NSUserDefaults
- (void) saveToMemory{
    [self resetMemory];
    for (int i=0; i<[self.taskArray count]; i++) {
        NSString *counter = [NSString stringWithFormat:@"%d",i];
        NSString *name = @"Task";
        NSString *task = [name stringByAppendingString:counter];
        NSString *key1 = [task stringByAppendingString:@"name"];
        Task *taskObject = [self.taskArray objectAtIndex:i];
        [[NSUserDefaults standardUserDefaults] setObject:taskObject.name forKey:key1];
        NSString *key2 = [task stringByAppendingString:@"date"];
        [[NSUserDefaults standardUserDefaults] setObject:taskObject.date forKey:key2];
        NSString *key3 = [task stringByAppendingString:@"note"];
        [[NSUserDefaults standardUserDefaults] setObject:taskObject.note forKey:key3];
    }
    //Save in memory
    [[NSUserDefaults standardUserDefaults] synchronize];
    //Log all saved keys
    NSLog(@"%@", [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys]);
}*/

/*
//For table header
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UILabel *headerLabel = [[UILabel alloc]init];
    headerLabel.text = @"Task List";
    headerLabel.textColor = [UIColor blackColor];
    //headerLabel.shadowColor = [UIColor blackColor];
    headerLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;

    return headerLabel;
}*/

/*
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
*/

@end
