//
//  SomePoint.h
//  TestSimpleSystems
//
//  Created by Дмитрий on 18.12.15.
//  Copyright © 2015 DmitrySinyov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SomePoint : NSObject

@property NSString *pointID;
@property NSString *title;
@property NSString *desc;
@property double lat;
@property double lng;

+(SomePoint*)pointFromDictionary:(NSDictionary*)pointDict;

@end
