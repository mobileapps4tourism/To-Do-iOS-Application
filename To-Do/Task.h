//
//  Spots.h
//  MobileApps4Tourism
//
//  Created by Mats Sandvoll on 18.09.13.
//  Copyright (c) 2013 Mats Sandvoll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Note.h"
#import "Category1.h"

@interface Task : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *date;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSMutableArray *notes;
@property (nonatomic, retain) Category1 *category;
@property (nonatomic, retain) Note *note;

@end
