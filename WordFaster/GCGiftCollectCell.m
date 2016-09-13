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
    
    [self setBackgroundColor:[UIColor redColor]];
    
    self.layer.cornerRadius = 5;
}

- (void)setWordFileName:(NSString *)wordFileName {
    
    _wordFileName = wordFileName;
    
    [_ibLabel setText:wordFileName];
}

@end
