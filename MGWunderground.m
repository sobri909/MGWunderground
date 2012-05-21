//
// Created by Matt Greenfield on 2/02/12.
// Copyright Big Paua 2012. All rights reserved.
//

#import "MGWunderground.h"

#define LOC_CACHE_AGE (60.0 * 60 * 1)
#define MIN_CACHE_AGE (60.0 * 10)
#define FEATURES       @"conditions/astronomy"
#define API_KEY        @"[your API key]"

@interface MGWunderground ()

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSURLConnection *request;
@property (nonatomic, retain) NSMutableData *weatherData;
@property (nonatomic, retain) NSMutableArray *callbacks;
@property (nonatomic, retain) NSMutableArray *errorCallbacks;

@end

@implementation MGWunderground

static MGWunderground *singleton;

@synthesize locationManager, userLocation, request, callbacks, errorCallbacks;
@synthesize weatherData, latestReport, locationUsable, internetUsable, errorInfo;

+ (void)initialize {
    singleton = [[MGWunderground alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
        self.locationUsable = YES;
        self.internetUsable = YES;
        self.callbacks = [NSMutableArray arrayWithCapacity:1];
        self.errorCallbacks = [NSMutableArray arrayWithCapacity:1];
        self.locationManager = [[CLLocationManager alloc] init];
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        locationManager.delegate = self;
        [locationManager startUpdatingLocation];
    }
    return self;
}

+ (MGWunderground *)singleton {
    return singleton;
}

- (BOOL)usable {
    return locationUsable && internetUsable;
}

#pragma mark - Location

- (CLLocation *)userLocation {
    if (!userLocation || [userLocation.timestamp timeIntervalSinceNow]
        < -LOC_CACHE_AGE) {
        [locationManager startUpdatingLocation];
    }
    return userLocation;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if (!userLocation || newLocation.horizontalAccuracy <= 1000) {
        self.userLocation = newLocation;
    }
    if (userLocation.horizontalAccuracy <= 1000) {
        [locationManager stopUpdatingLocation];
    }
    self.locationUsable = YES;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        [locationManager stopUpdatingLocation];
        self.errorInfo = @"Access to Location Services denied.";
    } else if (error.code == kCLErrorLocationUnknown) {
        self.errorInfo = @"Location could not be determined.";
    } else {
        self.errorInfo = error.localizedDescription;
    }
    NSLog(@"error:%@", errorInfo);
    self.locationUsable = NO;
}

#pragma mark - Report fetching

- (void)maxAge:(NSTimeInterval)age fetchReport:(WeatherReportCallback)_callback
       onError:(WeatherErrorCallback)errorCallback {
    if (errorCallback) {
        [errorCallbacks addObject:[errorCallback copy]];
    }

    // deal with no location
    if (!self.userLocation) {
        if (locationUsable) {
            dispatch_time_t
                    delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC);
            dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
                [self maxAge:age fetchReport:_callback onError:nil];
            });
        } else {
            [locationManager startUpdatingLocation];
        }
        while ([errorCallbacks count]) {
            WeatherErrorCallback callback = [errorCallbacks lastObject];
            callback();
            [errorCallbacks removeObject:callback];
        }
        return;
    }

    // latest report is fressshhh
    NSTimeInterval maxAge = MAX(age, MIN_CACHE_AGE);
    if (self.latestReport && latestReport.age < maxAge) {
        _callback(latestReport);
        return;
    }

    // need a new report
    [callbacks addObject:[_callback copy]];

    // already a request underway
    if (request) {
        return;
    }

    // new request
    NSString *url = [NSString
            stringWithFormat:@"http://api.wunderground.com/api/%@/%@/q/%f,%f.json",
                             API_KEY, FEATURES,
                             userLocation.coordinate.latitude,
                             userLocation.coordinate.longitude];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
            cachePolicy:NSURLRequestUseProtocolCachePolicy
            timeoutInterval:60.0];
    self.request = [NSURLConnection connectionWithRequest:req delegate:self];
    self.weatherData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    NSLog(@"%@", error.localizedDescription);
    self.request = nil;
    self.internetUsable = NO;
    self.errorInfo = error.localizedDescription;
    while ([errorCallbacks count]) {
        WeatherErrorCallback callback = [errorCallbacks lastObject];
        callback();
        [errorCallbacks removeObject:callback];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [weatherData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.request = nil;
    self.internetUsable = YES;

    NSDictionary *response = [NSJSONSerialization
            JSONObjectWithData:weatherData options:0 error:nil];
    self.latestReport = [MGWundergroundReport fromResponse:response];

    // tell everyone who asked
    while ([callbacks count]) {
        WeatherReportCallback callback = [callbacks lastObject];
        callback(latestReport);
        [callbacks removeObject:callback];
    }
}

#pragma mark - Exit

- (void)dealloc {
    [locationManager stopUpdatingLocation];
}

@end
