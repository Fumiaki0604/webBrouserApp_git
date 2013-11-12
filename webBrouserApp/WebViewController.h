//
//  WebViewController.h
//  webBrouserApp
//
//  Created by 佐藤　史渉 on 2013/11/06.
//  Copyright (c) 2013年 佐藤　史渉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebAppDelegate.h"
#import "MBProgressHUD.h"

@interface WebViewController : UIViewController
<UIWebViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webViewer;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *fwdBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIView *addressView;
@property (weak, nonatomic) IBOutlet UITextField *addressText;
@property (weak, nonatomic) IBOutlet UILabel *urlTitle;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *selPic;
@property (weak, nonatomic) IBOutlet UIButton *upLoad;

- (IBAction)backBtn:(id)sender;
- (IBAction)fwdBtn:(id)sender;
- (IBAction)googleSearch:(id)sender;
- (IBAction)opnURL:(id)sender;
- (IBAction)saveBtn:(id)sender;
- (IBAction)selPic:(id)sender;
- (IBAction)upLoad:(id)sender;


@end
