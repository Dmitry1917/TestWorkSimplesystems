//
//  MainViewController.m
//  TestSimpleSystems
//
//  Created by Дмитрий on 18.12.15.
//  Copyright © 2015 DmitrySinyov. All rights reserved.
//

#import "MainViewController.h"
#import "MapKit/MapKit.h"

#import "PointTableViewCell.h"
#import "SomePoint.h"

#import "AddEditPointViewController.h"

#import "PointsManager.h"

@interface AnnotationWithPointID : MKPointAnnotation {
}
@property (nonatomic, retain) NSString *pointID;
@end
@implementation AnnotationWithPointID
@end

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UISegmentedControl *listMapController;
@property (strong, nonatomic) IBOutlet UITableView *pointsTable;
@property (strong, nonatomic) IBOutlet MKMapView *pointsMap;
@property (strong, nonatomic) IBOutlet UITextField *siteOrIpField;

@end

@implementation MainViewController
{
    NSMutableArray <SomePoint*> *allPoints;
    bool isTableActive;
    bool addPoint;
    NSInteger choosedCell;
    
    bool tryDeletePoint;
    
    CLLocationManager *locationManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent = NO;//какой-то баг - не все элементы интерфейса считают координаты правильно, если не задать это тут, хотя в xib уже есть
    
    _siteOrIpField.delegate = self;
    _pointsTable.delegate = self;
    _pointsTable.dataSource = self;
    
    allPoints = [NSMutableArray array];
    
    UINib *nib = [UINib nibWithNibName:@"PointTableViewCell" bundle:nil];
    [_pointsTable registerNib:nib forCellReuseIdentifier:@"pointTableViewCell"];
    
    [[PointsManager sharedInstance] setAddress:@"192.168.1.33"];
    [_siteOrIpField setText:@"192.168.1.33"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAllPointsSuccess)
                                                 name:NOTIFICATION_ALL_POINTS_LOADED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAllPointsFail)
                                                 name:NOTIFICATION_ALL_POINTS_FAILED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAddPointSuccess)
                                                 name:NOTIFICATION_ADD_POINT_SUCCESS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveGetFullPointSuccess)
                                                 name:NOTIFICATION_GET_FULL_POINT_SUCCESS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveUpdatePointSuccess)
                                                 name:NOTIFICATION_UPDATE_POINT_SUCCESS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeletePointsSuccess)
                                                 name:NOTIFICATION_DELETE_POINT_SUCCESS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeletePointsFail)
                                                 name:NOTIFICATION_DELETE_POINT_FAILED
                                               object:nil];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;

#warning только 1 из этих методов использовать
    [locationManager requestWhenInUseAuthorization];//только foreground
    //[locationManager requestAlwaysAuthorization];//и background тоже
    
    [locationManager startUpdatingLocation];
    
    _pointsMap.delegate = self;
    
//    SomePoint *testPoint = [[SomePoint alloc] init];
//    testPoint.pointID = @"1";
//    testPoint.title = @"title";
//    testPoint.desc = @"desc";
//    testPoint.lat = 121.325432;
//    testPoint.lng = 15.345236236;
//    
//    [allPoints addObject:testPoint];
}

-(void)receiveAllPointsSuccess
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateInterface];
    });
}

-(void)receiveAllPointsFail
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Points can't be load" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

-(void)receiveAddPointSuccess
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateInterface];
    });
}

#warning при необходимости можно переделать, чтобы не обновлять всё при изменении одной точки
-(void)receiveGetFullPointSuccess
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateInterface];
    });
}

-(void)receiveUpdatePointSuccess
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateInterface];
    });
}

-(void)receiveDeletePointsSuccess
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateInterface];
        tryDeletePoint = NO;
    });
}
-(void)receiveDeletePointsFail
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (tryDeletePoint)
        {
            tryDeletePoint = NO;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Point can't be deleted" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    });
}

-(void)updateInterface
{
    [allPoints removeAllObjects];
    [allPoints addObjectsFromArray:[[PointsManager sharedInstance] getAllPoints]];
    
    CLLocationCoordinate2D currentCoord = _pointsMap.userLocation.location.coordinate;
    [_pointsMap setCenterCoordinate:currentCoord animated:YES];
    
    //NSLog(@"current coord %f %f", currentCoord.latitude, currentCoord.longitude);
    [allPoints sortUsingComparator:^NSComparisonResult(SomePoint* point1, SomePoint* point2) {
        NSNumber* distance1 = [NSNumber numberWithDouble:[_pointsMap.userLocation.location distanceFromLocation:[[CLLocation alloc] initWithLatitude:point1.lat longitude:point1.lng]]];
        NSNumber* distance2 = [NSNumber numberWithDouble:[_pointsMap.userLocation.location distanceFromLocation:[[CLLocation alloc] initWithLatitude:point2.lat longitude:point2.lng]]];
        return [distance2 compare:distance1];
    }];
    
    [_pointsTable reloadData];
    
//обновить карту
    [_pointsMap removeAnnotations:_pointsMap.annotations];
    for (SomePoint *point in allPoints)
    {
        AnnotationWithPointID *annotation = [[AnnotationWithPointID alloc] init];
        [annotation setCoordinate:CLLocationCoordinate2DMake(point.lat, point.lng)];
        [annotation setTitle:point.title];
        [annotation setPointID:point.pointID];
        [_pointsMap addAnnotation:annotation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(bool)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _siteOrIpField)
    {
        [[PointsManager sharedInstance] setAddress:textField.text];
    }
    [textField resignFirstResponder];
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)listMapChanged:(id)sender
{
    if (_listMapController.selectedSegmentIndex == 0)//list
    {
        [_pointsMap setHidden:YES];
        [_pointsTable setHidden:NO];
        isTableActive = YES;
    }
    else//map
    {
        [_pointsMap setHidden:NO];
        [_pointsTable setHidden:YES];
        isTableActive = NO;
    }
}

- (IBAction)addPointTouched:(id)sender
{
    addPoint = YES;
    [self performSegueWithIdentifier:@"addEditPoint" sender:nil];
}

- (IBAction)getPointsTouched:(id)sender
{
    [[PointsManager sharedInstance] loadAllPoints];
}

//tableview delegate datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [allPoints count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SomePoint *point = [allPoints objectAtIndex:indexPath.row];
    
    NSString *cellIdentifier = @"pointTableViewCell";
    PointTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell.nameLabel setText:point.title];
    [cell.latLabel setText:[NSString stringWithFormat:@"%.03f", point.lat]];
    [cell.lngLabel setText:[NSString stringWithFormat:@"%.03f", point.lng]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    addPoint = NO;
    choosedCell = indexPath.row;
    
    //[[PointsManager sharedInstance] getFullPointWithID:[allPoints objectAtIndex:indexPath.row].pointID];
    
    [self performSegueWithIdentifier:@"addEditPoint" sender:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        tryDeletePoint = YES;
        [[PointsManager sharedInstance] deletePointWithID:[allPoints objectAtIndex:indexPath.row].pointID];
    }
}

//mapview delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"location"];
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"callout tapped for %@", view.annotation.title);
    
    for (int i = 0; i < allPoints.count; i++)
    {
        SomePoint *point = [allPoints objectAtIndex:i];
        if ([point.pointID isEqualToString:((AnnotationWithPointID*)view.annotation).pointID])
        {
            choosedCell = i;
            addPoint = NO;
            [self performSegueWithIdentifier:@"addEditPoint" sender:nil];
            break;
        }
    }
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
#warning проверить и заменить при необходимости
    //MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    //[_pointsMap setRegion:[_pointsMap regionThatFits:region] animated:YES];
}

//navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"addEditPoint"])
    {
        AddEditPointViewController *aepVC = (AddEditPointViewController*)segue.destinationViewController;
        aepVC.isAdding = addPoint;
        if (!addPoint)
        {
            aepVC.editingPoint = [allPoints objectAtIndex:choosedCell];
        }
    }
}

@end
