# MGWunderground - A lightweight blocks based Wunderground report fetcher

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
