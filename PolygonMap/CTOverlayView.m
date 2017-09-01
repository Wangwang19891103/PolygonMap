//
//  CTOverlayView.m
//  Test
//
//  Created by Wang on 9/17/16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import "CTOverlayView.h"

@implementation CTOverlayView

- (void)createCells {
    self.cells = [NSMutableArray arrayWithCapacity:0];
    
    // add center cell
    CGPoint center = self.center;
//    CTCell* centerCell = [[CTCell alloc] initWithCenter:center radius:_radius];
//    [self.cells addObject:centerCell];
    
    
    CGFloat sectionHeight = _radius + _radius * cos(M_PI / 3);
    CGFloat rowWidth = 2 * _radius * cos(M_PI / 6);
    
    NSInteger rowOfCenterCell = (NSInteger)((center.x - rowWidth / 2) / rowWidth + 1);
    NSInteger sectionOfCenterCell = (NSInteger)(center.y / sectionHeight + 1);
    NSInteger sectionCount = 2 * sectionOfCenterCell + 1;
    
    for (NSInteger section = 0; section < sectionCount; section ++) {
        CGFloat yPos = center.y + (section - sectionOfCenterCell) * sectionHeight;
        
        NSInteger rowCount = (NSInteger)(center.x / rowWidth + 1) * 2;
        
        BOOL equalToCenterSection = (sectionOfCenterCell - section) % 2 == 0;
        if (equalToCenterSection)
            rowCount = rowOfCenterCell * 2 + 1;
        
        for (NSInteger row = 0; row < rowCount; row ++) {
            CGFloat xPos = center.x + (row - rowOfCenterCell) * rowWidth;
            if (!equalToCenterSection) {
                xPos = (center.x + rowWidth / 2) + (row - rowCount / 2) * rowWidth;
            }
            
            CGPoint center = CGPointMake(xPos, yPos);
            CTCell* cell = [[CTCell alloc] initWithCenter:center radius:_radius];
            
            [self.cells addObject:cell];
        }
    }
}

- (void)redrawWithRadius:(CGFloat)radius {
    _radius = radius;
    
    [self setNeedsDisplay];
}

- (void)highlightCellOfIndex:(NSInteger)cellIndex {
    _highlightCellIndex = cellIndex;
    
    [self setNeedsDisplay];
}

- (NSInteger)getCellIndexWithUserPoint:(CGPoint)userPoint {
    NSInteger cellIndex = -1;
    
    for (NSInteger idx = 0; idx < self.cells.count; idx ++) {
        CTCell* cell = self.cells[idx];
        
        CGMutablePathRef path = CGPathCreateMutable();
        
        for (int i = 0; i < cell.points.count; i ++) {
            CTCellPoint* point = cell.points[i];
            if (i == 0)
                CGPathMoveToPoint(path, nil, point.x, point.y);
            else
                CGPathAddLineToPoint(path, nil, point.x, point.y);
        }
        CGPathCloseSubpath(path);
        
        if (CGPathContainsPoint(path, nil, userPoint, NO)) {
            cellIndex = idx;
            break;
        }
    }
    
    return cellIndex;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    if (_radius == 0.f)
        _radius = 30.f;
    
    
    // create cells
    [self createCells];
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor* borderColor = [UIColor colorWithRed:(200/255.0) green:(138/255.0) blue:(99/255.0) alpha:1];
    CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
    CGContextSetLineWidth(context, 1);
    
    // Draw the polygon
    for (CTCell* cell in self.cells) {
        NSArray* points = cell.points;
        
        for (NSInteger i = 0; i < points.count; i ++) {
            CTCellPoint* point = points[i];
            
            if (i == 0)
                CGContextMoveToPoint(context, point.x, point.y);
            else
                CGContextAddLineToPoint(context, point.x, point.y);
        }
        CGContextClosePath(context);
    }
    
    /*
    for (int i = 0; i < 7; i ++) {
        CGFloat radian = M_PI / 2 + i * 2 * M_PI / 6;
        CGPoint point = CGPointMake(self.center.x + self.radius * cos(radian), self.center.y - self.radius * sin(radian));
        
        if (i == 0)
            CGContextMoveToPoint(context, point.x, point.y);
        else
            CGContextAddLineToPoint(context, point.x, point.y);
    }
    */
    
    // Fill it
    CGContextSetRGBFillColor(context, (248/255.0), (222/255.0), (173/255.0), 1);
    
    // Stroke it
    CGContextStrokePath(context);
    
    
    [self highlightCell];
}

- (void)highlightCell {
    if (_highlightCellIndex < 0)
        return;
    
    CTCell* cell = self.cells[_highlightCellIndex];
    NSArray* points = cell.points;
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    
    for (NSInteger i = 0; i < points.count; i ++) {
        CTCellPoint* point = points[i];
        
        if (i == 0)
            [bezierPath moveToPoint:point.cgPoint];
        else
            [bezierPath addLineToPoint:point.cgPoint];
    }
    [bezierPath closePath];
    
    UIColor* color = [UIColor colorWithRed:0 green:255 blue:0 alpha:0.5];
    [color setStroke];
    [color setFill];
    
    bezierPath.lineWidth = 3.0;
    [bezierPath fill];
    [bezierPath stroke];
}

@end
