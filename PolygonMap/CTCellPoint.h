//
//  CTCellPoint.h
//  Test
//
//  Created by Wang on 9/17/16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTCellPoint : NSObject

@property (nonatomic, readonly) CGFloat x;
@property (nonatomic, readonly) CGFloat y;

- (instancetype)initWithCGPoint:(CGPoint)point;

- (CGPoint)cgPoint;

@end
