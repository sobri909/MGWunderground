//
// Created by Matt Greenfield on 2/02/12.
// Copyright Big Paua 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MGWundergroundReport.h"

@class MGWundergroundReport;

typedef void (^WeatherReportCallback)(MGWundergroundReport *report);
typedef void (^WeatherErrorCallback)(void);

@interface MGWunderground : NSObject <CLLocationManagerDelegate>

@property (nonatomic, retain) MGWundergroundReport *latestReport;
@property (nonatomic, retain) CLLocation *userLocation;
@property (nonatomic, copy) NSString *errorInfo;
@property (nonatomic, assign) BOOL locationUsable;
@property (nonatomic, assign) BOOL internetUsable;

+ (MGWunderground *)singleton;

// fetch a report
- (void)maxAge:(NSTimeInterval)age fetchReport:(WeatherReportCallback)_callback
       onError:(WeatherErrorCallback)errorCallback;

// can we fetch weather?
- (BOOL)usable;

@end
