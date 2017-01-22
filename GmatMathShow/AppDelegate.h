//
//  AppDelegate.h
//  GmatMathShow
//
//  Created by KMF-ZXX on 2017/1/12.
//  Copyright © 2017年 com.enhance.zxx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

- (void)wft;
@end

