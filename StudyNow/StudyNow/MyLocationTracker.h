//
//  MyLocationTracker.h
//  Alike
//
//  Created by Rajesh Mehta on 4/15/16.
//  Copyright © 2016 Alike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Backendless.h"

@interface MyLocationTracker : NSObject <CLLocationManagerDelegate>

@property (nonatomic) CLLocationCoordinate2D myLastLocation;
@property (nonatomic) CLLocationAccuracy myLastLocationAccuracy;


@property (nonatomic) CLLocationCoordinate2D myLocation;
@property (nonatomic) CLLocationAccuracy myLocationAccuracy;

+ (CLLocationManager *)sharedLocationManager;

@property (strong, nonatomic) GeoPoint *me;

- (void)startLocationTracking;
- (void)stopLocationTracking;
- (void)updateLocationToServer;

@property (nonatomic) NSMutableArray *myLocationArray;

@end
