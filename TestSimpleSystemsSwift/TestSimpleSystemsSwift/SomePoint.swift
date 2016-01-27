//
//  SomePoint.swift
//  TestSimpleSystemsSwift
//
//  Created by DMITRY SINYOV on 22.01.16.
//  Copyright © 2016 DMITRY SINYOV. All rights reserved.
//

import UIKit

class SomePoint: NSObject {
    var pointID: String = ""
    var title: String = ""
    var desc: String = ""
    var lat: double_t = 0
    var lng: double_t = 0
    
    class func pointFromDictionary(pointDict: NSDictionary) -> SomePoint
    {
        let point = SomePoint()
        if let pointID = pointDict.objectForKey("id") as? String
        {
            point.pointID = pointID
        }
        else
        {
            point.pointID = ""
        }
        if let title = pointDict.objectForKey("title") as? String
        {
            point.title = title
        }
        if let latStr = pointDict.objectForKey("lat") as? String
        {
            if let lat = Double(latStr)
            {
                point.lat = lat
            }
            else
            {
                point.lat = 0
            }
        }
        if let lngStr = pointDict.objectForKey("lng") as? String
        {
            if let lng = Double(lngStr)
            {
                point.lng = lng
            }
            else
            {
                point.lng = 0
            }
        }
        
        if let desc = pointDict.objectForKey("desc") as? String
        {
            point.desc = desc
        }
        else
        {
            point.desc = DESC_NOT_LOADED
        }
        
        return point;
    }
}
