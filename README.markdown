# MGWunderground - A lightweight Wunderground report fetcher

A very simple class that fetches a report from Wunderground based on the user's current location.

Reports are returned in a wrapper class giving easy access to some common fields. The raw report NSDictionaries are available as properties of this class (report.rawWeather, report.rawAstronomy).

The report wrapper class defines convenience functions for converting between knots, mph, km/h, Celsius, and Fahrenheit.

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
