//
//  CTOverlayView.h
//  Test
//
//  Created by Wang on 9/17/16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface CTOverlayView : UIView

@property (nonatomic, readonly) NSInteger highlightCellIndex;

@property (nonatomic, readonly) CGFloat radius;

@property (strong, nonatomic) ViewController* controller;

@property (strong, nonatomic) NSMutableArray* cells;

- (void)redrawWithRadius:(CGFloat)radius;

- (void)highlightCellOfIndex:(NSInteger)cellIndex;

- (NSInteger)getCellIndexWithUserPoint:(CGPoint)userPoint;

@end
