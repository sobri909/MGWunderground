# MGWunderground - A lightweight Wunderground report fetcher

A basic class for fetching reports from Wunderground based on the user's current location.

Reports are returned in a wrapper object giving easy access to some common fields. The raw reports are available as `NSDictionary` properties of the report object (`report.rawWeather`, `report.rawAstronomy`).

The report class defines convenience functions for converting between knots, mph, km/h, Celsius, and Fahrenheit.

## Fetch a report

```objc
MGWunderground *weather = [MGWunderground singleton];
NSTimeInterval maxReportAge = 60.0 * 60;

[weather maxAge:maxReportAge fetchReport:^(WundergroundReport *report) {
    
        NSLog(@"Weather:%@", report.weatherType);
        NSLog(@"Temperature in Celsius:%f", report.tempc);
        NSLog(@"Temperature in Fahrenheit:%f", report.tempf);
        NSLog(@"Sunrise hour:%d minute:%d", report.sunriseHour, report.sunriseMinute);

    } onError:^{

        NSLog(@"Error:%@", weather.errorInfo);
        NSLog(@"Location usable:%@", weather.locationUsable ? @"YES" : @"NO");
        NSLog(@"Internet usable:%@", weather.internetUsable ? @"YES" : @"NO");

    }];
```

## Convenience Conversion Functions

```
float mph = MPH_FROM_KN(knots);
float kmh = KMH_FROM_KN(knots);
float knots = KN_FROM_MPH(mph);
float knots = KN_FROM_KMH(kmh);
float kmh = KMH_FROM_MPH(mph);
float mph = MPH_FROM_KMH(hmh);

float fahrenheit = F_FROM_C(celsius);
float celsius = C_FROM_F(fahrenheit);
```
