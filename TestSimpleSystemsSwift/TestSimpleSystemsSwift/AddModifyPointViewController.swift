//
//  AddModifyPointViewController.swift
//  TestSimpleSystemsSwift
//
//  Created by DMITRY SINYOV on 22.01.16.
//  Copyright © 2016 DMITRY SINYOV. All rights reserved.
//

import UIKit

class AddModifyPointViewController: UIViewController {
    var isAddingPoint: Bool = false
    var choosedPoint: SomePoint?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NSLog("AddModifyPointViewController %@", String(isAddingPoint))
        if isAddingPoint
        {
            self.navigationItem.rightBarButtonItem = nil
        }
        if choosedPoint != nil
        {
            NSLog("choosed point %@", choosedPoint!.title)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

}
