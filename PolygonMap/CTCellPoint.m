//
//  CTCellPoint.m
//  Test
//
//  Created by Wang on 9/17/16.
//  Copyright © 2016 Wang. All rights reserved.
//
#import "CTCellPoint.h"

@implementation CTCellPoint

- (instancetype)initWithCGPoint:(CGPoint)point {
    self = [super init];
    if (self) {
        _x = point.x;
        _y = point.y;
    }
    return self;
}

- (CGPoint)cgPoint{
    return CGPointMake(_x, _y);
}

@end
