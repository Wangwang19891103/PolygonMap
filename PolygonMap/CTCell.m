//
//  CTCell.m
//  Test
//
//  Created by Wang on 9/17/16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import "CTCell.h"

@implementation CTCell

- (instancetype)initWithCenter:(CGPoint)center radius:(CGFloat)radius {
    self = [super init];
    if (self) {
        _center = center;
        _radius = radius;
        
        [self loadPoints];
    }
    return self;
}

- (void)loadPoints {
    _points = [NSMutableArray arrayWithCapacity:0];
    
    // Draw the polygon
    for (int i = 0; i < 6; i ++) {
        CGFloat radian = M_PI / 2 + i * 2 * M_PI / 6;
        CGPoint cgPoint = CGPointMake(self.center.x + self.radius * cos(radian), self.center.y - self.radius * sin(radian));
        
        CTCellPoint* cellPoint = [[CTCellPoint alloc] initWithCGPoint:cgPoint];
        
        [_points addObject:cellPoint];
    }
}

@end
