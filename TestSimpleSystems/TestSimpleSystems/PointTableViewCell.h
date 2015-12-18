//
//  PointTableViewCell.h
//  TestSimpleSystems
//
//  Created by Дмитрий on 18.12.15.
//  Copyright © 2015 DmitrySinyov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PointTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *latLabel;
@property (strong, nonatomic) IBOutlet UILabel *lngLabel;

@end
