//
//  CLLocationManager+RACAdditions.m
//  Pods
//
//  Created by Stefano Mondino on 26/03/14.
//
//

#import "CLLocationManager+RACAdditions.h"
@interface CLLocationManager() <CLLocationManagerDelegate>
@end
@implementation CLLocationManager (RACAdditions)

static CLLocationManager* sharedManager = nil;

+ (CLLocationManager*) sharedManager {
    if (sharedManager == nil) {
        sharedManager = [[CLLocationManager alloc] init];
    }
    return sharedManager;
}

- (RACSignal*) rac_getCurrentLocation {
    return [self rac_getCurrentLocationWithAccuracy:kCLLocationAccuracyThreeKilometers];
}
- (RACSignal*) rac_getCurrentLocationWithAccuracy:(CLLocationAccuracy) accuracy {
    __weak CLLocationManager* locationManager = self;
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[[locationManager rac_signalForSelector:@selector(locationManager:didUpdateLocations:) fromProtocol:@protocol(CLLocationManagerDelegate)]
           map:^id(RACTuple* value) {
               return [value.second lastObject];
           }]
          filter:^BOOL(CLLocation* value) {
              return value.horizontalAccuracy < accuracy ;
          }]
         subscribeNext:^(CLLocation* x) {
             [subscriber sendNext:x];
             [subscriber sendCompleted];
         }];
        
        
        [[[locationManager rac_signalForSelector:@selector(locationManager:didFailWithError:) fromProtocol:@protocol(CLLocationManagerDelegate)]
          map:^id(RACTuple* value) {
              return value.second;
          }]
         subscribeNext:^(NSError* x)
         {
             [subscriber sendError:x];
         }];
        locationManager.delegate = nil;
        locationManager.delegate = locationManager;
        [locationManager startUpdatingLocation];
        return [RACDisposable disposableWithBlock:^{
            [locationManager stopUpdatingLocation];
        }];
    }];
}

- (RACSignal*) rac_monitorSignificantLocationUpdates {
    __weak CLLocationManager* locationManager = self;
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[[locationManager rac_signalForSelector:@selector(locationManager:didUpdateLocations:)fromProtocol:@protocol(CLLocationManagerDelegate)]
        map:^id(RACTuple* value) {
            return [value.second lastObject];
        }]
        subscribeNext:^(CLLocation* x) {
          [subscriber sendNext:x];
        }];
        locationManager.delegate = nil;
        locationManager.delegate = locationManager;
        [locationManager startMonitoringSignificantLocationChanges];
        return [RACDisposable disposableWithBlock:^{
            [subscriber sendCompleted];
            [locationManager stopMonitoringSignificantLocationChanges];
        }];
    }];
}

- (RACSignal*) rac_monitorEnterRegion {
    __weak CLLocationManager* locationManager = self;
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[[locationManager rac_signalForSelector:@selector(locationManager:didEnterRegion:) fromProtocol:@protocol(CLLocationManagerDelegate)]
         map:^id(RACTuple* value) {
             return value.second;
         }]
         subscribeNext:^(CLRegion* x) {
             [subscriber sendNext: x];
//             [subscriber sendCompleted];
         }];
        locationManager.delegate = nil;
        locationManager.delegate = locationManager;
        return [RACDisposable disposableWithBlock:^{
        }];
    }];
}

- (RACSignal*) rac_monitorExitRegion {
    __weak CLLocationManager* locationManager = self;
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[[locationManager rac_signalForSelector:@selector(locationManager:didExitRegion:) fromProtocol:@protocol(CLLocationManagerDelegate)]
          map:^id(RACTuple* value) {
              return value.second;
          }]
         subscribeNext:^(CLRegion* x) {
             [subscriber sendNext: x];
             //             [subscriber sendCompleted];
         }];
        locationManager.delegate = nil;
        locationManager.delegate = locationManager;
        return [RACDisposable disposableWithBlock:^{
        }];
    }];
}


@end
