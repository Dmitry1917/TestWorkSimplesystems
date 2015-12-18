//
//  AddEditPointViewController.h
//  TestSimpleSystems
//
//  Created by Дмитрий on 18.12.15.
//  Copyright © 2015 DmitrySinyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SomePoint;
@interface AddEditPointViewController : UIViewController

@property bool isAdding;
@property SomePoint *editingPoint;

@end
