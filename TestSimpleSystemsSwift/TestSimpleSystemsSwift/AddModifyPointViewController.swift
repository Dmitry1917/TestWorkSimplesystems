//
//  AddModifyPointViewController.swift
//  TestSimpleSystemsSwift
//
//  Created by DMITRY SINYOV on 22.01.16.
//  Copyright © 2016 DMITRY SINYOV. All rights reserved.
//

import UIKit

let DESC_NOT_LOADED = "DESCRIPTION_NOT_LOADED"

class AddModifyPointViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var latField: UITextField!
    @IBOutlet weak var lngField: UITextField!
    @IBOutlet weak var descView: UITextView!
    var isAddingPoint: Bool = false
    var editingPoint: SomePoint?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NSLog("AddModifyPointViewController %@", String(isAddingPoint))
        if (isAddingPoint)
        {
            self.navigationItem.rightBarButtonItem = nil;
        }
        else
        {
            if editingPoint!.title != nil
            {
                titleField.text = editingPoint?.title
                NSLog("choosed point %@", editingPoint!.title!)
            }
            if editingPoint!.lat != nil
            {
                latField.text = String(format: "%.03f", arguments: [editingPoint!.lat!])
            }
            if editingPoint!.lng != nil
            {
                lngField.text = String(format: "%.03f", arguments: [editingPoint!.lng!])
            }
            if (editingPoint!.desc != nil)
            {
                descView.text = editingPoint!.desc
            }
            else
            {
                descView.text = DESC_NOT_LOADED
                
                
                
                
                
                
                
                //PointsManager.sharedInstance.getFullPointWithID(editingPoint!.pointID)
            }
        }
        
        titleField.delegate = self
        latField.delegate = self
        lngField.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("taped:"))
        self.view.addGestureRecognizer(tapRecognizer)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receiveAddPointSuccess"), name: NOTIFICATION_ADD_POINT_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receiveAddPointFail"), name: NOTIFICATION_ADD_POINT_FAILED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receiveGetFullPointSuccess"), name: NOTIFICATION_GET_FULL_POINT_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receiveGetFullPointFail"), name: NOTIFICATION_GET_FULL_POINT_FAILED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receiveUpdatePointSuccess"), name: NOTIFICATION_UPDATE_POINT_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receiveUpdatePointFail"), name: NOTIFICATION_UPDATE_POINT_FAILED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receiveDeletePointsSuccess"), name: NOTIFICATION_DELETE_POINT_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receiveDeletePointsFail"), name: NOTIFICATION_DELETE_POINT_FAILED, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
    func taped(sender: UITapGestureRecognizer? = nil)//параметр по умолчанию
    {
        self.view.endEditing(true)
    }
    
    @IBAction func SaveButtonTouched(sender: AnyObject)
    {
        
    }

    @IBAction func removeButtonTouched(sender: AnyObject)
    {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    /*
    -(void)receiveAddPointSuccess
    {
    dispatch_async(dispatch_get_main_queue(), ^{
    
    [self.navigationController popViewControllerAnimated:YES];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Point added successfully" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
    });
    }
    
    -(void)receiveAddPointFail
    {
    dispatch_async(dispatch_get_main_queue(), ^{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Point adding failed" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
    });
    }
    
    -(void)receiveGetFullPointSuccess
    {
    dispatch_async(dispatch_get_main_queue(), ^{
    SomePoint *replacePoint = [[PointsManager sharedInstance] getResultFullPointWithID:_editingPoint.pointID];
    
    if (replacePoint)
    {
    _editingPoint = replacePoint;
    [_descTextView setText:_editingPoint.desc];
    }
    });
    }
    -(void)receiveGetFullPointFail
    {
    //пока никакой реакции не требуется
    }
    
    -(void)receiveUpdatePointSuccess
    {
    dispatch_async(dispatch_get_main_queue(), ^{
    SomePoint *replacePoint = [[PointsManager sharedInstance] getResultFullPointWithID:_editingPoint.pointID];
    
    if (replacePoint)
    {
    _editingPoint = replacePoint;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Point updated" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
    }
    });
    }
    -(void)receiveUpdatePointFail
    {
    dispatch_async(dispatch_get_main_queue(), ^{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Point update fail" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
    });
    }
    
    -(void)receiveDeletePointSuccess
    {
    dispatch_async(dispatch_get_main_queue(), ^{
    
    [self.navigationController popViewControllerAnimated:YES];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Point deleted successfully" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
    });
    }
    
    -(void)receiveDeletePointFail
    {
    dispatch_async(dispatch_get_main_queue(), ^{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Point delete fail" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
    });
    }
    
    - (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    }
    
    -(void)dealloc
    {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    - (IBAction)deleteButtonTouched:(id)sender
    {
    if (!_isAdding)
    {
    [[PointsManager sharedInstance] deletePointWithID:_editingPoint.pointID];
    }
    }
    
    -(bool)latLngRegex:(NSString*)checkedString
    {
    NSRange   checkedRange = NSMakeRange(0, [checkedString length]);
    NSString *pattern = @"[-+]?[0-9]*\\.?[0-9]+";
    NSError  *error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    NSRange range   = [regex rangeOfFirstMatchInString:checkedString
    options:0
    range:checkedRange];
    NSLog(@"regex range %lu %lu", range.location, range.length);
    
    if (range.location == 0 && range.length == checkedString.length)
    {
    return YES;
    }
    else return NO;
    }
    
    - (IBAction)saveButtonTouched:(id)sender
    {
    //обработать корректность данных
    bool titleCorrect = YES;
    if (_titleField.text.length == 0) titleCorrect = NO;
    
    bool latCorrect = YES;
    if (_latField.text.length > 0)
    {
    latCorrect = [self latLngRegex:[_latField.text stringByReplacingOccurrencesOfString:@"," withString:@"."]];
    }
    else latCorrect = NO;
    if (latCorrect)
    {
    double lat = [_latField.text stringByReplacingOccurrencesOfString:@"," withString:@"."].doubleValue;
    if (lat <= -90 || lat >= 90) latCorrect = NO;
    }
    
    bool lngCorrect = YES;
    if (_lngField.text.length > 0)
    {
    lngCorrect = [self latLngRegex:[_lngField.text stringByReplacingOccurrencesOfString:@"," withString:@"."]];
    }
    else lngCorrect = NO;
    if (lngCorrect)
    {
    double lng = [_lngField.text stringByReplacingOccurrencesOfString:@"," withString:@"."].doubleValue;
    if (lng <= -180 || lng >= 180) lngCorrect = NO;
    }
    
    if (!titleCorrect)
    {
    [_titleField setBackgroundColor:[UIColor redColor]];
    }
    else
    {
    [_titleField setBackgroundColor:[UIColor clearColor]];
    }
    if (!latCorrect)
    {
    [_latField setBackgroundColor:[UIColor redColor]];
    }
    else
    {
    [_latField setBackgroundColor:[UIColor clearColor]];
    }
    if (!lngCorrect)
    {
    [_lngField setBackgroundColor:[UIColor redColor]];
    }
    else
    {
    [_lngField setBackgroundColor:[UIColor clearColor]];
    }
    if (!titleCorrect || !latCorrect || !lngCorrect)
    {
    return;
    }
    
    if (_isAdding)
    {
    SomePoint *point = [[SomePoint alloc] init];
    
    point.title = [NSString stringWithString:_titleField.text];
    point.lat = [_latField.text stringByReplacingOccurrencesOfString:@"," withString:@"."].doubleValue;
    point.lng = [_lngField.text stringByReplacingOccurrencesOfString:@"," withString:@"."].doubleValue;
    point.desc = [NSString stringWithString:_descTextView.text];
    
    [[PointsManager sharedInstance] addPoint:point];
    }
    else
    {
    #warning Такая проверка и реакция на неё, конечно, неудачны, но как обрабатывать подобные ситуации (не получили полных данных о точке, которую хотим поменять) и что показывать пользователю обычно решается совместно, а не единолично разработчиком.
    if ([_descTextView.text isEqualToString:DESC_NOT_LOADED])
    {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Point was not fully loaded" message:@"It will be better not update point, before full data available." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
    _editingPoint.title = [NSString stringWithString:_titleField.text];
    _editingPoint.lat = [_latField.text stringByReplacingOccurrencesOfString:@"," withString:@"."].doubleValue;
    _editingPoint.lng = [_lngField.text stringByReplacingOccurrencesOfString:@"," withString:@"."].doubleValue;
    _editingPoint.desc = [NSString stringWithString:_descTextView.text];
    
    [[PointsManager sharedInstance] updatePoint:_editingPoint];
    }
    }
    }
    */
}
