//
//  CLLocationManager+RACAdditions.h
//  Pods
//
//  Created by Stefano Mondino on 26/03/14.
//
//

#import <CoreLocation/CoreLocation.h>
#import <ReactiveCocoa.h>
@interface CLLocationManager (RACAdditions)
+ (CLLocationManager*) sharedManager;
- (RACSignal*) rac_getCurrentLocation;
- (RACSignal*) rac_getCurrentLocationWithAccuracy:(CLLocationAccuracy) accuracy;
- (RACSignal*) rac_monitorSignificantLocationUpdates;
- (RACSignal*) rac_monitorEnterRegion;
- (RACSignal*) rac_monitorExitRegion;
@end
