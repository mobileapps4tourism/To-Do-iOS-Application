//
//  NotesViewController.m
//  To-Do
//
//  Created by Mats Sandvoll on 28.10.13.
//  Copyright (c) 2013 Mats Sandvoll. All rights reserved.
//

#import "NotesViewController.h"

@interface NotesViewController ()

@end

@implementation NotesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    self.dbManager = [[DBManager alloc]init];
    [self.dbManager setDbPath];
    self.notes = [self.dbManager getNotesByTask:self.task];
    
    self.title = self.task.name;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight) style:UITableViewStylePlain];
    self.tableView.rowHeight = 50;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    if (self.canEdit==YES) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = self.notes.count;
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
    if (indexPath.row < self.notes.count ) {
        cell.textLabel.text = [[self.notes objectAtIndex:indexPath.row] description];
    } else {
        self.noteField = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, cell.bounds.size.width, cell.bounds.size.height)];
        self.noteField.placeholder = @"Add New Note";
        if ([cell.contentView.subviews count]==0){
            [cell.contentView addSubview:self.noteField];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.notes.count ) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleInsert;
    }
}

-(void)setEditing:(BOOL)editing animated:(BOOL) animated {
    if(editing != self.editing ) {
        [super setEditing:editing animated:animated];
        [self.tableView setEditing:editing animated:animated];
        NSArray *indexes =[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.notes.count inSection:0]];
        if (editing == YES ) {
            [self.tableView insertRowsAtIndexPaths:indexes
                                  withRowAnimation:UITableViewRowAnimationLeft];
        } else {
            [self.tableView deleteRowsAtIndexPaths:indexes
                                  withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle) editing
 forRowAtIndexPath:(NSIndexPath *)indexPath {
    LogManager *logMan = [[LogManager alloc]init];
    if(editing == UITableViewCellEditingStyleDelete ) {
        [self.dbManager deleteNote:[self.notes objectAtIndex:indexPath.row]];
        [logMan writeToLog:DeleteNote:[self.notes objectAtIndex:indexPath.row]];
        
        [self.notes removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationLeft];
    }else{
        Note *newNote = [[Note alloc]init];
        newNote.description = self.noteField.text;
        newNote.taskID = self.task.taskID;
        newNote.externalTaskID = self.task.externalTaskID;
        newNote.noteID = [self.dbManager insertNote:newNote];
        [logMan writeToLog:CreateNote :newNote];
        
        self.notes = [self.dbManager getNotesByTask:self.task];
        [self.tableView reloadData];
    }
}

//Extra Functions

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
