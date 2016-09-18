//
//  StoreMgr.h
//  Lottery
//
//  Created by user on 16/2/16.
//  Copyright © 2016年 user. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Word.h"

@interface StoreMgr : NSObject

@property (nonatomic, assign) BOOL stopSave;

+ (StoreMgr*)sharedInstance;

- (void)saveWords:(NSArray*)words name:(NSString*)tableName;

- (BOOL)checkWordlistExist:(NSString*)wordlistName;

- (NSArray*)loadWords:(NSString*)file;

- (void)saveWord:(Word*)word tableName:(NSString*)tableName;

- (void)updateWord:(Word*)word tableName:(NSString*)tableName;

@end
