//
//  ViewController.m
//  PolygonMap
//
//  Created by Wang on 9/17/16.
//  Copyright © 2016 Wang. All rights reserved.
//

#import "ViewController.h"
@import Mapbox;


#define UsingMapbox     NO


@interface ViewController () <MGLMapViewDelegate>

@property (weak, nonatomic) IBOutlet CTOverlayView* overlayView;

@property (nonatomic) MGLMapView* mapView;
@property (nonatomic) MGLPolygon* containPolygon;
@property (strong, nonatomic) NSMutableArray* cellPolygons;

@property (nonatomic) MGLUserLocation* userLocation;
@property (nonatomic) BOOL changeLocation;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.changeLocation = NO;
    
    self.mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.showsUserLocation = YES;
    
    // Set the delegate property of our map view to self after instantiating it
    self.mapView.delegate = self;
    
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate zoomLevel:11 animated:NO];
    self.mapView.userTrackingMode = MGLUserTrackingModeFollow;
    
    [self.view addSubview:self.mapView];
    
    if (!UsingMapbox)
        [self.view bringSubviewToFront:self.overlayView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark - MGLMapView delegate

- (CGFloat)mapView:(MGLMapView *)mapView alphaForShapeAnnotation:(MGLShape *)annotation {
    //set the alpha for shape annovation to 0.5 (half opacity)
    return 1.f;
}

- (UIColor *)mapView:(MGLMapView *)mapView strokeColorForShapeAnnotation:(MGLShape *)annotation {
    //set the stroke color for shape annotationss
//    UIColor* borderColor = [UIColor brownColor];
    UIColor* borderColor = [UIColor colorWithRed:(200/255.0) green:(138/255.0) blue:(99/255.0) alpha:1];
    return borderColor;
}

- (UIColor *)mapView:(MGLMapView *)mapView fillColorForPolygonAnnotation:(MGLPolygon *)annotation {
    //Mapbox cyan fill color
    UIColor* fillColor = [UIColor clearColor];
    if (UsingMapbox) {
        if ([annotation isEqual:self.containPolygon])
            fillColor = [UIColor colorWithRed:0 green:255 blue:0 alpha:0.5];
    }
    return fillColor;
}

- (CGFloat)mapView:(MGLMapView *)mapView lineWidthForPolylineAnnotation:(MGLPolyline *)annotation {
    return 5.f;
}

- (void)mapView:(MGLMapView *)mapView didUpdateUserLocation:(MGLUserLocation *)userLocation {
    if (userLocation)
        self.userLocation = userLocation;

    MGLCoordinateSpan span;
    
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    
    CLLocationCoordinate2D location;
    location.latitude = self.userLocation.coordinate.latitude;
    location.longitude = self.userLocation.coordinate.longitude;
    
    [self highlightCell];
}

- (void)mapViewRegionIsChanging:(MGLMapView *)mapView {
    if (self.changeLocation == TRUE) {
        self.changeLocation = FALSE;
    }
    else {
//        [self.mapView removeAnnotation:self.shape];
        self.changeLocation = TRUE;
    }
    
    [self highlightCell];
}

- (void)mapView:(MGLMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    [self clearCells];
    [self createCells];
    
    [self highlightCell];
}

//- (void)mapViewWillStartLoadingMap:(MGLMapView *)mapView{
//    [mapView removeAnnotation:shape];
//}

//- (void)mapViewDidStopLocatingUser:(MGLMapView *)mapView{
//    [mapView removeAnnotation:shape];
//}


#pragma mark -
#pragma mark - Main methods

- (void)highlightCell {
    if (!self.userLocation)
        return;
    
    CGPoint userPoint = [self.mapView convertCoordinate:self.userLocation.coordinate toPointToView:self.mapView];
    NSLog(@"========> User Location is %@\n\nUser Point is %@ : %@",
          self.userLocation,
          NSStringFromCGPoint(userPoint),
          NSStringFromCGRect(self.mapView.frame));
    
    NSInteger cellIndex = [self.overlayView getCellIndexWithUserPoint:userPoint];
    
    if (UsingMapbox) {
        if (self.containPolygon)
            [self.mapView removeAnnotation:self.containPolygon];
        
        self.containPolygon = self.cellPolygons[cellIndex];
        [self.mapView addAnnotation:self.containPolygon];
    }
    else {
        [self.overlayView highlightCellOfIndex:cellIndex];
    }
}

- (void)clearCells {
    if (self.cellPolygons) {
        for (MGLPolygon* polygon in self.cellPolygons)
            [self.mapView removeAnnotation:polygon];
    }
}

- (void)createCells {
    if (!UsingMapbox)
        return;
    
    if (!self.userLocation)
        return;
    
    self.cellPolygons = [NSMutableArray arrayWithCapacity:0];
    
    // add center cell
    CGPoint center = self.view.center;
    CGFloat radius = 30.f;
    CGFloat sectionHeight = radius + radius * cos(M_PI / 3);
    CGFloat rowWidth = 2 * radius * cos(M_PI / 6);
    
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
            CTCell* cell = [[CTCell alloc] initWithCenter:center radius:radius];
            
            MGLPolygon* polygon = [self getPolygonWithCell:cell];
            [self.cellPolygons addObject:polygon];
        }
    }
    
    
    for (MGLPolygon* polygon in self.cellPolygons)
        [self.mapView addAnnotation:polygon];
}

- (MGLPolygon*)getPolygonWithCell:(CTCell*)cell {
    CLLocationCoordinate2D coordinates[] = {
        [self.mapView convertPoint:((CTCellPoint*)cell.points[0]).cgPoint toCoordinateFromView:self.overlayView],
        [self.mapView convertPoint:((CTCellPoint*)cell.points[1]).cgPoint toCoordinateFromView:self.overlayView],
        [self.mapView convertPoint:((CTCellPoint*)cell.points[2]).cgPoint toCoordinateFromView:self.overlayView],
        [self.mapView convertPoint:((CTCellPoint*)cell.points[3]).cgPoint toCoordinateFromView:self.overlayView],
        [self.mapView convertPoint:((CTCellPoint*)cell.points[4]).cgPoint toCoordinateFromView:self.overlayView],
        [self.mapView convertPoint:((CTCellPoint*)cell.points[5]).cgPoint toCoordinateFromView:self.overlayView],
        [self.mapView convertPoint:((CTCellPoint*)cell.points[0]).cgPoint toCoordinateFromView:self.overlayView]
    };
    NSUInteger numberOfCoordinates = sizeof(coordinates) / sizeof(CLLocationCoordinate2D);
    
    // Create our shape with the formatted coordinates array
    MGLPolygon* polygon = [MGLPolygon polygonWithCoordinates:coordinates count:numberOfCoordinates];
    return polygon;
}


@end
