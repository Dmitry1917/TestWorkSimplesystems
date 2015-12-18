//
//  MainViewController.m
//  TestSimpleSystems
//
//  Created by Дмитрий on 18.12.15.
//  Copyright © 2015 DmitrySinyov. All rights reserved.
//

#import "MainViewController.h"
#import "MapKit/MapKit.h"

@interface MainViewController ()
@property (strong, nonatomic) IBOutlet UISegmentedControl *listMapController;
@property (strong, nonatomic) IBOutlet UITableView *pointsTable;
@property (strong, nonatomic) IBOutlet MKMapView *pointsMap;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    }
    else//map
    {
        [_pointsMap setHidden:NO];
        [_pointsTable setHidden:YES];
    }
}

@end
