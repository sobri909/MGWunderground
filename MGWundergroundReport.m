//
// Created by Matt Greenfield on 2/02/12.
// Copyright Big Paua 2012. All rights reserved.
//

#import "MGWundergroundReport.h"

@implementation MGWundergroundReport {
    NSDate *timestamp;
}

@synthesize response, rawWeather, rawAstronomy;

- (id)init {
    self = [super init];
    return self;
}

+ (MGWundergroundReport *)fromResponse:(NSDictionary *)response {
    MGWundergroundReport *report = [[MGWundergroundReport alloc] init];
    report.response = response;
    return report;
}

- (void)setResponse:(NSDictionary *)_response {
    response = _response;
    self.rawWeather = [_response objectForKey:@"current_observation"];
    self.rawAstronomy = [_response objectForKey:@"moon_phase"];
    timestamp = [NSDate date];
}

- (NSTimeInterval)age {
    NSTimeInterval
            epoch = [[rawWeather objectForKey:@"observation_epoch"] floatValue];
    NSDate *observed = [NSDate dateWithTimeIntervalSince1970:epoch];
    return -[observed timeIntervalSinceNow];
}

- (NSString *)locationString {
    NSDictionary *loc = [rawWeather objectForKey:@"observation_location"];
    return [loc objectForKey:@"full"];
}

- (CLLocationCoordinate2D)locationCoords {
    NSDictionary *loc = [rawWeather objectForKey:@"observation_location"];
    float lat = [[loc objectForKey:@"latitude"] floatValue];
    float lon = [[loc objectForKey:@"longitude"] floatValue];
    return CLLocationCoordinate2DMake(lat, lon);
}

- (NSString *)weatherType {
    NSString *weatherString = [rawWeather objectForKey:@"weather"];
    if (!weatherString || ![weatherString length]) {
        NSLog(@"falling back to 'icon'");
        weatherString = [rawWeather objectForKey:@"icon"];
    }
    return weatherString;
}

- (float)tempc {
    return [[rawWeather objectForKey:@"temp_c"] floatValue];
}

- (float)tempf {
    return [[rawWeather objectForKey:@"temp_f"] floatValue];
}

- (int)windDegrees {
    return [[rawWeather objectForKey:@"wind_degrees"] intValue];
}

- (NSString *)windDirection {
    return [rawWeather objectForKey:@"wind_dir"];
}

- (float)windKmh {
    return [[rawWeather objectForKey:@"wind_kph"] floatValue];
}

- (int)sunriseHour {
    NSDictionary *sunrise = [rawAstronomy objectForKey:@"sunrise"];
    return [[sunrise objectForKey:@"hour"] intValue];
}

- (int)sunriseMinute {
    NSDictionary *sunrise = [rawAstronomy objectForKey:@"sunrise"];
    return [[sunrise objectForKey:@"minute"] intValue];
}

- (int)sunsetHour {
    NSDictionary *sunset = [rawAstronomy objectForKey:@"sunset"];
    return [[sunset objectForKey:@"hour"] intValue];
}

- (int)sunsetMinute {
    NSDictionary *sunrise = [rawAstronomy objectForKey:@"sunset"];
    return [[sunrise objectForKey:@"minute"] intValue];
}

@end
