//
//  CTCell.h
//  Test
//
//  Created by Wang on 9/17/16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTCell : NSObject

@property (nonatomic, readonly) CGPoint center;
@property (nonatomic, readonly) CGFloat radius;
@property (strong, nonatomic, readonly) NSMutableArray* points;
@property (strong, nonatomic, readonly) NSMutableArray* locations;

- (instancetype)initWithCenter:(CGPoint)center radius:(CGFloat)radius;

@end
