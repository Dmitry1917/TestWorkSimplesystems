//
//  SomePoint.m
//  TestSimpleSystems
//
//  Created by Дмитрий on 18.12.15.
//  Copyright © 2015 DmitrySinyov. All rights reserved.
//

#import "SomePoint.h"

@implementation SomePoint

+(SomePoint*)pointFromDictionary:(NSDictionary*)pointDict
{
    SomePoint *point = [[SomePoint alloc] init];
    
    point.pointID = [pointDict objectForKey:@"id"];
    point.title = [pointDict objectForKey:@"title"];
    point.lat = [[pointDict objectForKey:@"lat"] doubleValue];
    point.lng = [[pointDict objectForKey:@"lng"] doubleValue];
    point.desc = [pointDict objectForKey:@"desc"];
    
    return point;
}

@end
