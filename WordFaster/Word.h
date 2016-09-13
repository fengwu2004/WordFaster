//
//  MyWord.h
//  WordFaster
//
//  Created by ky on 8/29/16.
//  Copyright © 2016 yellfun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@interface Word : JSONModel

@property (nonatomic, copy) NSString<Optional> *en;
@property (nonatomic, copy) NSString<Optional> *ch;
@property (nonatomic, copy) NSString<Optional> *read;

@end
