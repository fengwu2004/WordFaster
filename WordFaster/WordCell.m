//
//  WordCell.m
//  WordFaster
//
//  Created by ky on 8/29/16.
//  Copyright © 2016 yellfun. All rights reserved.
//

#import "WordCell.h"

@interface WordCell()

@property (nonatomic, retain) Word *word;

@end

@implementation WordCell

- (void)awakeFromNib {
    
    [super awakeFromNib];
    // Initialization code
}

- (void)setWord:(Word *)word translate:(BOOL)showTrans {
    
    _word = word;
    
    [_ibEn setText:_word.en];
    
    if (_word.read != nil) {
        
        NSString *read = [NSString stringWithFormat:@"[%@]", _word.read];
        
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:read];
        
        [title addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, 1)];
        
        [title addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(read.length - 1, 1)];
        
        [_ibRead setAttributedText:title];
    }
    else {
        
        [_ibRead setText:@""];
    }
    
    if (showTrans) {
        
        [_ibCh setText:_word.ch];
    }
    else {
        
        [_ibCh setText:@""];
    }
}

@end
