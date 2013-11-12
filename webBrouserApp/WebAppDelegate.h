//
//  WebAppDelegate.h
//  webBrouserApp
//
//  Created by 佐藤　史渉 on 2013/11/06.
//  Copyright (c) 2013年 佐藤　史渉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebAppDelegate : UIResponder <UIApplicationDelegate>
{
    //グローバル変数
    NSInteger flag;
}

@property (strong, nonatomic) UIWindow *window;
@property (readwrite)NSInteger flag;
@end
