//
//  MainViewController.swift
//  TestSimpleSystemsSwift
//
//  Created by DMITRY SINYOV on 22.01.16.
//  Copyright © 2016 DMITRY SINYOV. All rights reserved.
//

import UIKit
import MapKit

class AnnotationWithPointID : MKPointAnnotation {
    var pointID = ""
}

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapListChooser: UISegmentedControl!
    @IBOutlet weak var pointsTable: UITableView!
    @IBOutlet weak var pointsMap: MKMapView!
    @IBOutlet weak var siteField: UITextField!
    
    private var allPoints: Array<SomePoint> = []
    private var isAddingPoint: Bool = false
    private var choosedPointNumber: Int = 0
    private var tryDeletePoint: Bool = false
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pointsTable.registerNib(UINib(nibName: "PointTableViewCell", bundle: nil), forCellReuseIdentifier: "pointCell")
        
        PointsManager.sharedInstance.setAdress("192.168.1.33")
        siteField.text = "192.168.1.33"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receiveAllPointsSuccess"), name: NOTIFICATION_ALL_POINTS_LOADED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receiveAllPointsFail"), name: NOTIFICATION_ALL_POINTS_FAILED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receiveAddPointSuccess"), name: NOTIFICATION_ADD_POINT_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receiveGetFullPointSuccess"), name: NOTIFICATION_GET_FULL_POINT_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receiveUpdatePointSuccess"), name: NOTIFICATION_UPDATE_POINT_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receiveDeletePointsSuccess"), name: NOTIFICATION_DELETE_POINT_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receiveDeletePointsFail"), name: NOTIFICATION_DELETE_POINT_FAILED, object: nil)

        // Do any additional setup after loading the view.
        pointsTable.delegate = self
        pointsTable.dataSource = self
        
        siteField.delegate = self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
        
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()//только foreground
        locationManager.startUpdatingLocation()
        pointsMap.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func mapListChanged(sender: AnyObject)
    {
        NSLog("mapListChanged %d", mapListChooser.selectedSegmentIndex)
        
        if mapListChooser.selectedSegmentIndex == 0
        {
            pointsMap.hidden = true
            pointsTable.hidden = false
        }
        else
        {
            pointsMap.hidden = false
            pointsTable.hidden = true
        }
    }

    @IBAction func addNewPointTouched(sender: AnyObject)
    {
        NSLog("addNewPointTouched")
        
        isAddingPoint = true
        self.performSegueWithIdentifier("addModifyPoint", sender: nil)
    }
    
    @IBAction func getPointsTouched(sender: AnyObject)
    {
        PointsManager.sharedInstance.loadAllPoints()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
    func handleTap(sender: UITapGestureRecognizer? = nil)//параметр по умолчанию
    {
        self.view.endEditing(true)
    }
    
    //notifications
    func receiveAllPointsSuccess()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.updateInterface()
        })
    }
    func receiveAllPointsFail()
    {
        dispatch_async(dispatch_get_main_queue(), {
            let alertController = UIAlertController(title: "Points can't be load", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let alertActionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(alertActionOK)
            self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    func receiveAddPointSuccess()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.updateInterface()
        })
    }
    func receiveGetFullPointSuccess()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.updateInterface()
        })
    }
    func receiveUpdatePointSuccess()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.updateInterface()
        })
    }
    func receiveDeletePointsSuccess()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.updateInterface()
            self.tryDeletePoint = false
        })
    }
    func receiveDeletePointsFail()
    {
        dispatch_async(dispatch_get_main_queue(), {
            if self.tryDeletePoint
            {
                self.tryDeletePoint = false
                let alertController = UIAlertController(title: "Point can't be deleted", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                let alertActionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                alertController.addAction(alertActionOK)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        })
    }
    
    func updateInterface()
    {
        allPoints.removeAll()
        allPoints.appendContentsOf(PointsManager.sharedInstance.getAllPoints())
        
        let loc = pointsMap.userLocation.location
        if loc != nil
        {
            let currentCoord = loc!.coordinate
            pointsMap.setCenterCoordinate(currentCoord, animated: true)
            
            let arrTemp = (allPoints as NSArray).sortedArrayUsingComparator(){
                (p1:AnyObject, p2:AnyObject) -> NSComparisonResult in
                
                let point1 = p1 as! SomePoint
                let point2 = p2 as! SomePoint
                let distance1 = NSNumber(double:self.pointsMap.userLocation.location!.distanceFromLocation(CLLocation(latitude: point1.lat, longitude: point1.lng)))
                let distance2 = NSNumber(double:self.pointsMap.userLocation.location!.distanceFromLocation(CLLocation(latitude: point2.lat, longitude: point2.lng)))
                
                return distance2.compare(distance1)
            }
            
            allPoints = arrTemp as! Array<SomePoint>
            
            //обновить карту
            pointsMap.removeAnnotations(pointsMap.annotations)
            for point in allPoints
            {
                let annotation = AnnotationWithPointID()
                annotation.coordinate = CLLocationCoordinate2DMake(point.lat, point.lng)
                annotation.title = point.title
                annotation.pointID = point.pointID
                pointsMap.addAnnotation(annotation)
            }
        }
        
        pointsTable.reloadData()
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
            amvc.editingPoint = allPoints[choosedPointNumber]
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
            tryDeletePoint = true
            PointsManager.sharedInstance.deletePointWithID(allPoints[indexPath.row].pointID)
        }
    }
    
    //mapview delegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation.isKindOfClass(MKUserLocation) {return nil}
        
        let anView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "location")
        anView.canShowCallout = true
        anView.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
        return anView
    }
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        NSLog("callout tapped for %@", view.annotation!.title!!)
        
        for var i = 0; i < allPoints.count; i++
        {
            let point = allPoints[i]
            
            if point.pointID == (view.annotation as! AnnotationWithPointID).pointID
            {
                choosedPointNumber = i
                isAddingPoint = false
                self.performSegueWithIdentifier("addModifyPoint", sender: nil)
                break
            }
        }
    }
}
