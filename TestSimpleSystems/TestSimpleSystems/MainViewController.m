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

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
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
    NSIndexPath *choosedCell;
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
    
    
    SomePoint *testPoint = [[SomePoint alloc] init];
    testPoint.pointID = 1;
    testPoint.title = @"title";
    testPoint.desc = @"desc";
    testPoint.lat = 121.325432;
    testPoint.lng = 15.345236236;
    
    [allPoints addObject:testPoint];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(bool)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
#warning обработать задание адреса
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

//delegate datasource
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
    choosedCell = indexPath;
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
        [allPoints removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
#warning удалять точку и на сервере
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"addEditPoint"])
    {
        AddEditPointViewController *aepVC = (AddEditPointViewController*)segue.destinationViewController;
        aepVC.isAdding = addPoint;
        if (!addPoint)
        {
            aepVC.editingPoint = [allPoints objectAtIndex:choosedCell.row];
        }
    }
}

@end
