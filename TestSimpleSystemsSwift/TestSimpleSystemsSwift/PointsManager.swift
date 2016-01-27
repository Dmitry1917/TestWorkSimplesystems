//
//  PointsManager.swift
//  TestSimpleSystemsSwift
//
//  Created by DMITRY SINYOV on 26.01.16.
//  Copyright © 2016 DMITRY SINYOV. All rights reserved.
//

import UIKit

let NOTIFICATION_ALL_POINTS_LOADED = "NOTIFICATION_ALL_POINTS_LOADED"
let NOTIFICATION_ALL_POINTS_FAILED = "NOTIFICATION_ALL_POINTS_FAILED"

let NOTIFICATION_ADD_POINT_SUCCESS = "NOTIFICATION_ADD_POINT_SUCCESS"
let NOTIFICATION_ADD_POINT_FAILED = "NOTIFICATION_ADD_POINT_FAILED"

let NOTIFICATION_GET_FULL_POINT_SUCCESS = "NOTIFICATION_GET_FULL_POINT_SUCCESS"
let NOTIFICATION_GET_FULL_POINT_FAILED = "NOTIFICATION_GET_FULL_POINT_FAILED"

let NOTIFICATION_UPDATE_POINT_SUCCESS = "NOTIFICATION_UPDATE_POINT_SUCCESS"
let NOTIFICATION_UPDATE_POINT_FAILED = "NOTIFICATION_UPDATE_POINT_FAILED"

let NOTIFICATION_DELETE_POINT_SUCCESS = "NOTIFICATION_DELETE_POINT_SUCCESS"
let NOTIFICATION_DELETE_POINT_FAILED = "NOTIFICATION_DELETE_POINT_FAILED"

class PointsManager: NSObject {
    
    static let sharedInstance: PointsManager = {
        let instance = PointsManager()
        //тут можно проинициализировать
        return instance
    }()
    
    private var allPoints: Array<SomePoint> = []
    var urlOrIpServer = ""
    
    func setAdress(urlOrIp: String)
    {
        urlOrIpServer = urlOrIp
    }
    
    func loadAllPoints()
    {
        let urlString = String(format: "http://%@:3000/points", arguments: [urlOrIpServer])//"http://yandex.ru")
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            
            if let httpResponse = response as? NSHTTPURLResponse
            {
                NSLog("get points response status: %ld", httpResponse.statusCode)
                if let httpData = data
                {
                    NSLog("get points response %@", String(data: httpData, encoding: NSUTF8StringEncoding)!)
                    
                    if httpResponse.statusCode == 200
                    {
                        do
                        {
                            let pointsDictArray: Array = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! Array<NSDictionary>
                            
                            self.allPoints.removeAll()
                            
                            for pointDict in pointsDictArray
                            {
                                let point = SomePoint.pointFromDictionary(pointDict)
                                self.allPoints.append(point)
                            }
                            NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_ALL_POINTS_LOADED, object: nil)
                        }
                        catch let err as NSError
                        {
                            print("json error: \(err.localizedDescription)")
                        }
                    }
                    else
                    {
                        NSLog("get points error: %@", error!)
                        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_ALL_POINTS_FAILED, object: nil)
                    }
                }
            }
        })
        
        dataTask.resume()
    }
    
    func addPoint(point: SomePoint)
    {
        let urlString = String(format: "http://%@:3000/points", arguments: [urlOrIpServer])
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dictPoint = NSDictionary(objects: [point.title, String(format: "%f", arguments: [point.lat]), String(format: "%f", arguments: [point.lng]), point.desc], forKeys: ["title", "lat", "lng", "desc"])
        
        var postData = NSData()
        do
        {
            postData = try NSJSONSerialization.dataWithJSONObject(dictPoint, options: NSJSONWritingOptions.PrettyPrinted)
        }
        catch let error as NSError
        {
            print("json error: \(error.localizedDescription)")
        }
        request.HTTPBody = postData
        
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            
            if let httpResponse = response as? NSHTTPURLResponse
            {
                NSLog("add point response status: %ld", httpResponse.statusCode)
                if let httpData = data
                {
                    NSLog("add point response %@", String(data: httpData, encoding: NSUTF8StringEncoding)!)
                    
                    if httpResponse.statusCode == 200
                    {
                        do
                        {
                            let pointDict: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                            
                            let point = SomePoint.pointFromDictionary(pointDict)
                            self.allPoints.append(point)
                            
                            NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_ADD_POINT_SUCCESS, object: nil)
                        }
                        catch let err as NSError
                        {
                            print("json error: \(err.localizedDescription)")
                        }
                    }
                    else
                    {
                        if error != nil {NSLog("add point error: %@", error!)}
                        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_ADD_POINT_FAILED, object: nil)
                    }
                }
            }
        })
        dataTask.resume()
    }
    
    func getFullPointWithID(pointID: String)
    {
        let urlString = String(format: "http://%@:3000/points/%@", arguments: [urlOrIpServer, pointID])
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            
            if let httpResponse = response as? NSHTTPURLResponse
            {
                NSLog("get point response status: %ld", httpResponse.statusCode)
                if let httpData = data
                {
                    NSLog("get point response %@", String(data: httpData, encoding: NSUTF8StringEncoding)!)
                    
                    if httpResponse.statusCode == 200
                    {
                        do
                        {
                            let pointDict: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                            
                            let point = SomePoint.pointFromDictionary(pointDict)
                            
                            self.replaceOrAddOrDeletePoint(point, delete: false)
                            
                            NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_GET_FULL_POINT_SUCCESS, object: nil)
                        }
                        catch let err as NSError
                        {
                            print("json error: \(err.localizedDescription)")
                        }
                    }
                    else
                    {
                        NSLog("get point error: %@", error!)
                        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_GET_FULL_POINT_FAILED, object: nil)
                    }
                }
            }
        })
        
        dataTask.resume()
    }
    
    func updatePoint(point: SomePoint)
    {
        let urlString = String(format: "http://%@:3000/points/%@", arguments: [urlOrIpServer, point.pointID])
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
        request.HTTPMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dictPoint = NSDictionary(objects: [point.title, String(format: "%f", arguments: [point.lat]), String(format: "%f", arguments: [point.lng]), point.desc], forKeys: ["title", "lat", "lng", "desc"])
        
        var postData = NSData()
        do
        {
            postData = try NSJSONSerialization.dataWithJSONObject(dictPoint, options: NSJSONWritingOptions.PrettyPrinted)
        }
        catch let error as NSError
        {
            print("json error: \(error.localizedDescription)")
        }
        request.HTTPBody = postData
        
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            
            if let httpResponse = response as? NSHTTPURLResponse
            {
                NSLog("update point response status: %ld", httpResponse.statusCode)
                if let httpData = data
                {
                    NSLog("update point response %@", String(data: httpData, encoding: NSUTF8StringEncoding)!)
                    
                    if httpResponse.statusCode == 200
                    {
                        do
                        {
                            let pointDict: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                            
                            let point = SomePoint.pointFromDictionary(pointDict)
                            self.replaceOrAddOrDeletePoint(point, delete: false)
                            
                            NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_UPDATE_POINT_SUCCESS, object: nil)
                        }
                        catch let err as NSError
                        {
                            print("json error: \(err.localizedDescription)")
                        }
                    }
                    else
                    {
                        if error != nil {NSLog("update point error: %@", error!)}
                        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_UPDATE_POINT_FAILED, object: nil)
                    }
                }
            }
        })
        dataTask.resume()
    }
    
    func deletePointWithID(pointID: String)
    {
        let urlString = String(format: "http://%@:3000/points/%@", arguments: [urlOrIpServer, pointID])
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
        request.HTTPMethod = "DELETE"
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {(data, response, error) -> Void in
            
            if let httpResponse = response as? NSHTTPURLResponse
            {
                NSLog("delete point response status: %ld", httpResponse.statusCode)
                if let httpData = data
                {
                    NSLog("delete point response %@", String(data: httpData, encoding: NSUTF8StringEncoding)!)
                    
                    if httpResponse.statusCode == 200
                    {
                        do
                        {
                            let pointDict: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                            
                            let point = SomePoint.pointFromDictionary(pointDict)
                            self.replaceOrAddOrDeletePoint(point, delete: true)
                            
                            NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_DELETE_POINT_SUCCESS, object: nil)
                        }
                        catch let err as NSError
                        {
                            print("json error: \(err.localizedDescription)")
                        }
                    }
                    else
                    {
                        if error != nil {NSLog("delete point error: %@", error!)}
                        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_DELETE_POINT_FAILED, object: nil)
                    }
                }
            }
        })
        dataTask.resume()
    }
    
    func replaceOrAddOrDeletePoint(point: SomePoint, delete:Bool)
    {
        var foundedOldPoint: SomePoint? = nil
        
        for oldPoint in allPoints
        {
            if oldPoint.pointID == point.pointID
            {
                foundedOldPoint = oldPoint
                break
            }
        }
        if foundedOldPoint != nil
        {
            allPoints.removeAtIndex(allPoints.indexOf(foundedOldPoint!)!)
        }
        if !delete { allPoints.append(point) }
    }
    
    func getResultFullPointWithID(pointID: String) -> SomePoint?
    {
        for point in allPoints
        {
            if point.pointID == pointID
            {
                return point
            }
        }
        
        return nil
    }
    
    func getAllPoints() -> Array<SomePoint>
    {
        var array:Array<SomePoint> = Array()
        array.appendContentsOf(allPoints)
        
        return array
    }
    
}
