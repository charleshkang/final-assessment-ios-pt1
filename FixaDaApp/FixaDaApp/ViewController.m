//
//  ViewController.m
//  FixaDaApp
//
//  Created by Michael Kavouras on 2/14/16.
//  Copyright © 2016 Michael Kavouras. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "ViewController.h"
#import "FoursquareAPIManager.h"

@interface ViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
MKMapViewDelegate,
CLLocationManagerDelegate
>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic) CLLocation *location;
@property (nonatomic) BOOL hasUserLocation;

@property (nonatomic, assign) BOOL foundPlaces;

@property (nonatomic) NSArray *venues;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //    [self setCurrentLocation];
    [self startMaps];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.locationManager requestWhenInUseAuthorization];
}

# pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.venues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BeepBoopCellIdentifier" forIndexPath:indexPath];
    
    NSDictionary *venue = self.venues[indexPath.row];
    NSString *name = venue[@"name"];
    cell.textLabel.text = name;
    
    return cell;
}

# pragma mark - Map view delegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!self.foundPlaces) {
        self.foundPlaces = YES;
        
        [self zoomToLocation:userLocation.location];
        [self fetchVenuesAtLocation:userLocation.location];
    }
}

- (void)zoomToLocation:(CLLocation *)location
{
    MKCoordinateSpan span = MKCoordinateSpanMake(0.03f,0.03f);
    CLLocationCoordinate2D coordinate = location.coordinate;
    MKCoordinateRegion region = {coordinate, span};
    MKCoordinateRegion regionThatFits = [self.mapView regionThatFits:region];
    [self.mapView setRegion:regionThatFits animated:YES];
}

- (void)fetchVenuesAtLocation:(CLLocation *)location
{
    __weak typeof(self) weakSelf = self;
    [FoursquareAPIManager findSomething:@"music"
                             atLocation:location
                             completion:^(NSArray *data){
                                 
                                 weakSelf.venues = data;
                                 [weakSelf.tableView reloadData];
                                 [weakSelf showPinsForVenues];
                                 
                             }];
}

- (void)showPinsForVenues
{
    for (NSDictionary *venue in self.venues) {
        double lat = [venue[@"location"][@"lat"] doubleValue];
        double lng = [venue[@"location"][@"lng"] doubleValue];
        
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = CLLocationCoordinate2DMake(lat, lng);
        [self.mapView addAnnotation:point];
    }
}

# pragma mark - Charles' Methods

- (void)startMaps
{
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
}

- (void)showPinsForPlaces
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    for (NSDictionary *venueResults in self.venues) {
        double lat = [venueResults[@"location"][@"lat"] doubleValue];
        double lng = [venueResults[@"location"][@"lng"] doubleValue];
        
        MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
        pin.coordinate = CLLocationCoordinate2DMake(lat, lng);
        [self.mapView addAnnotation:pin];
    }
}
// don't need this
//- (void)setCurrentLocation
//{
//
//    if (self.locationManager == nil){
//        self.locationManager = [[CLLocationManager alloc]init];
//    }
//
//    self.locationManager.distanceFilter = kCLDistanceFilterNone;
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//}

@end
