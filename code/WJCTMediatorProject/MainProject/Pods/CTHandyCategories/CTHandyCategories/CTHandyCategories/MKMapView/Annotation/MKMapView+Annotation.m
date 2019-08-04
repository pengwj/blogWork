//
//  MKMapView+Annotation.m
//  CTHandyCategories
//
//  Created by casa on 2018/4/9.
//  Copyright © 2018年 casa. All rights reserved.
//

#import "MKMapView+Annotation.h"
#import <HandyFrame/UIView+LayoutMethods.h>
#import <CoreLocation/CoreLocation.h>

@implementation MKMapView (Annotation)

- (void)ct_showAnnotation:(id<MKAnnotation>)annotation atPoint:(CGPoint)point animated:(BOOL)animated
{
    CGPoint annotationPoint = [self convertCoordinate:annotation.coordinate toPointToView:self];
    CGPoint centerPoint = CGPointMake(annotationPoint.x, annotationPoint.y + (self.ct_centerY - point.y));
    CLLocationCoordinate2D centerCoordinate = [self convertPoint:centerPoint toCoordinateFromView:self];
    [self setCenterCoordinate:centerCoordinate animated:animated];
}

- (void)ct_showRegionThatFitsAnnotations:(NSArray<id<MKAnnotation>> *)annotationList animated:(BOOL)animated
{
    if (annotationList.count == 0) {
        return;
    }
    
    if (annotationList.count == 1) {
        [self setCenterCoordinate:annotationList.firstObject.coordinate animated:YES];
    }
    
    __block CGFloat minLat = CGFLOAT_MAX;
    __block CGFloat maxLat = CGFLOAT_MIN;
    __block CGFloat minLng = CGFLOAT_MAX;
    __block CGFloat maxLng = CGFLOAT_MIN;
    
    [annotationList enumerateObjectsUsingBlock:^(id<MKAnnotation>  _Nonnull annotation, NSUInteger idx, BOOL * _Nonnull stop) {
        if (annotation.coordinate.latitude > maxLat) {
            maxLat = annotation.coordinate.latitude;
        }
        if (annotation.coordinate.latitude < minLat) {
            minLat = annotation.coordinate.latitude;
        }
        if (annotation.coordinate.longitude > maxLng) {
            maxLng = annotation.coordinate.longitude;
        }
        if (annotation.coordinate.longitude < minLng) {
            minLng = annotation.coordinate.longitude;
        }
    }];
    MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(maxLat - minLat+0.01, maxLng - minLng+0.01);
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake((minLat+maxLat)/2.0f, (minLng + maxLng)/2.0f);
    MKCoordinateRegion region = MKCoordinateRegionMake(centerCoordinate, coordinateSpan);
    MKCoordinateRegion fittedRegion = [self regionThatFits:region];
    [self setRegion:fittedRegion animated:animated];
}

@end
