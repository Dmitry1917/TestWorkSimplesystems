//
//  SomePoint.swift
//  TestSimpleSystemsSwift
//
//  Created by DMITRY SINYOV on 22.01.16.
//  Copyright © 2016 DMITRY SINYOV. All rights reserved.
//

import UIKit

class SomePoint: NSObject {
    var pointID: String? = ""
    var title: String? = ""
    var desc: String? = ""
    var lat: double_t? = 0
    var lng: double_t? = 0
    
    class func pointFromDictionary(pointDict: NSDictionary) -> SomePoint
    {
        let point = SomePoint()
        point.pointID = pointDict.objectForKey("id") as? String
        point.title = pointDict.objectForKey("title") as? String
        if let latStr = pointDict.objectForKey("lat") as? String
        {
            point.lat = Double(latStr)
        }
        else {point.lat = nil}
        if let lngStr = pointDict.objectForKey("lng") as? String
        {
            point.lng = Double(lngStr)
        }
        else {point.lng = nil}
        //point.lng = Double(pointDict.objectForKey("lng") as? String) - так сделать нельзя - приходится обрабатывать отдельно случай отсутствия поля перед преобразованием в число
        point.desc = pointDict.objectForKey("desc") as? String
        return point;
    }
}
