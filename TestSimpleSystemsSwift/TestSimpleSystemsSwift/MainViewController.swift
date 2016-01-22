//
//  MainViewController.swift
//  TestSimpleSystemsSwift
//
//  Created by DMITRY SINYOV on 22.01.16.
//  Copyright © 2016 DMITRY SINYOV. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var mapListChooser: UISegmentedControl!
    @IBOutlet weak var pointsTable: UITableView!
    
    private var allPoints: Array<SomePoint> = []
    private var isAddingPoint: Bool = false
    private var choosedPointNumber: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pointsTable.registerNib(UINib(nibName: "PointTableViewCell", bundle: nil), forCellReuseIdentifier: "pointCell")

        // Do any additional setup after loading the view.
        pointsTable.delegate = self
        pointsTable.dataSource = self
        
        let point1: SomePoint = SomePoint()
        point1.title = "title1"
        point1.lat = 30.0
        point1.lng = 25.0
        let point2: SomePoint = SomePoint()
        point2.title = "title2"
        point2.lat = 60.0
        point2.lng = 55.0
        
        allPoints.append(point1)
        allPoints.append(point2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func mapListChanged(sender: AnyObject)
    {
        NSLog("mapListChanged %d", mapListChooser.selectedSegmentIndex)
    }

    @IBAction func addNewPointTouched(sender: AnyObject)
    {
        NSLog("addNewPointTouched")
        
        isAddingPoint = true
        self.performSegueWithIdentifier("addModifyPoint", sender: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let amvc: AddModifyPointViewController = segue.destinationViewController as! AddModifyPointViewController
        amvc.isAddingPoint = isAddingPoint
        if !isAddingPoint
        {
            amvc.choosedPoint = allPoints[choosedPointNumber]
        }
    }
    
    
    //tableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPoints.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:PointTableViewCell = tableView.dequeueReusableCellWithIdentifier("pointCell", forIndexPath: indexPath) as! PointTableViewCell
        let currentPoint: SomePoint = allPoints[indexPath.row]
        
        cell.titleLabel.text = currentPoint.title
        cell.latLabel.text = String(format: "%.5f", currentPoint.lat)
        cell.lngLabel.text = String(format: "%.5f", currentPoint.lng)
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        isAddingPoint = false
        choosedPointNumber = indexPath.row
        self.performSegueWithIdentifier("addModifyPoint", sender: nil)
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.Delete
        {
            allPoints.removeAtIndex(indexPath.row)
//TODO: при удалении отправлять команду на сервер
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
}
