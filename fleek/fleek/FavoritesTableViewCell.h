//
//  FavoritesTableViewCell.h
//  fleek
//
//  Created by Dulio Denis on 2/25/15.
//  Copyright (c) 2015 ddApps. See included LICENSE file.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface FavoritesTableViewCell : SWTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;
@end
