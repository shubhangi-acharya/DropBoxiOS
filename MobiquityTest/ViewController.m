//
//  ViewController.m
//  MobiquityTest
//
//  Created by Shubhangi Pandya on 14/03/15.
//  Copyright (c) 2015 shubhangi. All rights reserved.
//

#import "ViewController.h"
#import "Dropbox.h"
#import "DBFile.h"
#import "Connection.h"
#import "ErrorFactory.h"
#import "PhotoCell.h"
NSString * const KEY_LOCATION = @"Location";
NSString * const KEY_JSON_ERROR_CODE = @"code";
NSString * const KEY_JSON_ERROR_MSG = @"message";
NSString * const KEY_JSON_FIELD_ERRORS = @"fieldErrors";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSURLSessionTaskDelegate>
@property (nonatomic, strong) NSURLSessionUploadTask *uploadTask;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIView *uploadView;
@property (weak, nonatomic) IBOutlet UIImageView *imgThumb;
@property (weak, nonatomic) UIButton *btnUpload;
@property (weak, nonatomic) IBOutlet UITableView *tblList;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (nonatomic, strong) NSArray *photoThumbnails;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation ViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // 1
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        // 2
        [config setHTTPAdditionalHeaders:@{@"Authorization": [Dropbox apiAuthorizationHeader]}];
        
        // 3
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    // Do any additional setup after loading the view, typically from a nib.

    [super viewDidLoad];
    [self getImages];
    _uploadView.hidden = YES;
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)getImages
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *photoDir = [NSString stringWithFormat:@"https://api.dropbox.com/1/metadata/auto/%@/photos?list=true",appFolder];
    
    NSURL *url = [NSURL URLWithString:photoDir];
    
    [[_session dataTaskWithURL:url completionHandler:^(NSData
                                                       *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSHTTPURLResponse *httpResp =
            (NSHTTPURLResponse*) response;
            if (httpResp.statusCode == 200) {
                
                NSError *jsonError;
                NSArray *filesJSON = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:NSJSONReadingAllowFragments
                                      error:&jsonError];
                filesJSON = [filesJSON valueForKey:@"contents"];
                NSMutableArray *dbFiles =
                [[NSMutableArray alloc] init];
                
                if (!jsonError) {
                    for (NSDictionary *fileMetadata in
                         filesJSON) {
                        DBFile *file = [[DBFile alloc]
                                        initWithJSONData:fileMetadata];
                        [dbFiles addObject:file];
                    }
                    
                    [dbFiles sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        return [obj1 compare:obj2];
                    }];
                    
                    _photoThumbnails = dbFiles;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                        [self.tblList reloadData];
                    });
                }
            } else {
                // HANDLE BAD RESPONSE //
            }
        } else {
            // ALWAYS HANDLE ERRORS :-] //
        }
    }] resume];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.photoThumbnails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"PhotoCell";
    PhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    DBFile *photo = _photoThumbnails[indexPath.row];
    cell.tag = indexPath.row;
    if (!photo.thumbNail) {
        // only download if we are moving
        if (self.tblList.dragging == NO && self.tblList.decelerating == NO)
        {
            if(photo.thumbExists) {
                
                 NSString *urlString = [NSString stringWithFormat:@"https://api-content.dropbox.com/1/thumbnails/auto/%@?size=xl",photo.path];
                
                NSString *encodedUrl = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSURL *url = [NSURL URLWithString:encodedUrl];
                NSLog(@" url %@",url);
                
                //GET THUMBNAILS //
                cell.fileName.text = [self fileName:photo.path];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
                NSURLSessionDataTask *dataTask = [_session dataTaskWithURL:url
                                                         completionHandler:^(NSData *data, NSURLResponse *response,
                                                                             NSError *error) {
                                                             if (!error) {
                                                                 UIImage *image = [[UIImage alloc] initWithData:data];
                                                                 photo.thumbNail = image;
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                                     cell.thumbnailImage.image = photo.thumbNail;
                                                                 });
                                                             } else {
                                                                 //ERROR //
                                                             }
                                                         }];
                [dataTask resume];
                
            }
        }
        
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = (PhotoCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    self.imgThumb.image = cell.thumbnailImage.image;
    self.lblLocation.text = cell.fileName.text;
    
}

- (NSString *)fileName :(NSString *)path {
    NSArray *arr = [path componentsSeparatedByString:@"/"];
    NSString *file = [arr objectAtIndex:3];
    NSArray *arrName = [file componentsSeparatedByString:@"_"];
    file = [arrName objectAtIndex:0];

    return file;
}


- (IBAction)choosePhoto:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = NO;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate methods
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self uploadImage:image];
}

// stop upload
- (IBAction)cancelUpload:(id)sender {
    if (_uploadTask.state == NSURLSessionTaskStateRunning) {
        [_uploadTask cancel];
    }
}

- (void)uploadImage:(UIImage*)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    
    // 1
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPMaximumConnectionsPerHost = 1;
    [config setHTTPAdditionalHeaders:@{@"Authorization": [Dropbox apiAuthorizationHeader]}];
    
    // 2
    NSURLSession *upLoadSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    // for now just create a random file name, dropbox will handle it if we overwrite a file and create a new name..
    
    NSURL *urlWithParams = [Dropbox createPhotoUploadURL];
    
    NSString *urlWithName = [NSString stringWithFormat:@"%@%@_%i.jpg",urlWithParams,strAddressFromLatLong,arc4random() % 1000];
    NSURL *url = [NSURL URLWithString:[urlWithName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"PUT"];
    
    // 3
    self.uploadTask = [upLoadSession uploadTaskWithRequest:request fromData:imageData];
    
    // 4
    self.uploadView.hidden = NO;

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // 5
    [_uploadTask resume];
}

#pragma mark - NSURLSessionTaskDelegate methods

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
   didSendBodyData:(int64_t)bytesSent
    totalBytesSent:(int64_t)totalBytesSent
totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_progress setProgress:
         (double)totalBytesSent /
         (double)totalBytesExpectedToSend animated:YES];
    });
    
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    _uploadView.hidden = YES;
    [_uploadView removeFromSuperview];
    [self getImages];
    
}

#pragma mark CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    currentLocation = [locations objectAtIndex:0];
    [locationManager stopUpdatingLocation];
    NSLog(@"Detected Location : %f, %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:currentLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (error){
                           NSLog(@"Geocode failed with error: %@", error);
                           return;
                       }
                       CLPlacemark *placemark = [placemarks objectAtIndex:0];
                       NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
                       
                   }];
    [self getAddressFromLatLon:currentLocation];

}


- (void)getAddressFromLatLon:(CLLocation *)bestLocation
{
    NSLog(@"%f %f", bestLocation.coordinate.latitude, bestLocation.coordinate.longitude);
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:bestLocation
                   completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error){
             NSLog(@"Geocode failed with error: %@", error);
             return;
         }
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
         NSLog(@"locality %@",placemark.locality);
         NSLog(@"postalCode %@",placemark.postalCode);
         strAddressFromLatLong = placemark.locality;
         
     }];

}

@end
