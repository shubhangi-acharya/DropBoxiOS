//
//  ViewController.h
//  MobiquityTest
//
//  Created by Shubhangi Pandya on 14/03/15.
//  Copyright (c) 2015 shubhangi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    NSString *strAddressFromLatLong;
}
- (IBAction)choosePhoto:(id)sender;

@end
