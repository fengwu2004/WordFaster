//
//  GCGiftCollectCell.m
//  CollectiveView
//
//  Created by user on 15/12/15.
//  Copyright © 2015年 user. All rights reserved.
//

#import "GCGiftCollectCell.h"

@implementation GCGiftCollectCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setWordFileName:(NSString *)wordFileName {
    
    self.wordFileName = wordFileName;
    
    [_ibLabel setText:wordFileName];
}

@end
