//
//  AddEditPointViewController.m
//  TestSimpleSystems
//
//  Created by Дмитрий on 18.12.15.
//  Copyright © 2015 DmitrySinyov. All rights reserved.
//

#import "AddEditPointViewController.h"
#import "SomePoint.h"

@interface AddEditPointViewController () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *titleField;
@property (strong, nonatomic) IBOutlet UITextField *latField;
@property (strong, nonatomic) IBOutlet UITextField *lngField;
@property (strong, nonatomic) IBOutlet UITextView *descTextView;

@end

@implementation AddEditPointViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSLog(@"isAdding %d", _isAdding);
    self.navigationController.navigationBar.translucent = NO;//почему-то задание в storyboard и xib не работало
    
    _titleField.delegate = self;
    _latField.delegate = self;
    _lngField.delegate = self;
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(taped)];
    [self.view addGestureRecognizer: tapRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(bool)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
#warning обработать корректность данных
    return YES;
}

-(void)taped
{
    [[self view] endEditing:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)saveButtonTouched:(id)sender
{
    
}

@end