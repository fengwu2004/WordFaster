//
//  WordListVCTL.h
//  WordFaster
//
//  Created by ky on 8/29/16.
//  Copyright © 2016 yellfun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WordListVCTL : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSArray *words;

@end
