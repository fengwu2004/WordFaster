//
//  WordCell.h
//  WordFaster
//
//  Created by ky on 8/29/16.
//  Copyright © 2016 yellfun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Word.h"

@interface WordCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *ibEn;

@property (nonatomic, retain) IBOutlet UILabel *ibRead;

@property (nonatomic, retain) IBOutlet UILabel *ibCh;

@property (nonatomic, retain) Word *word;

@end
