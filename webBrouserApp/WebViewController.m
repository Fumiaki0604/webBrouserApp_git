//
//  WebViewController.m
//  webBrouserApp
//
//  Created by 佐藤　史渉 on 2013/11/06.
//  Copyright (c) 2013年 佐藤　史渉. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

//選択写真イメージ記録用
UIImage* pictureImg;
//非同期通信用
NSURLConnection *connection = nil;
NSMutableData *async_data = nil;

- (void)viewDidLoad
{
    [super viewDidLoad];
    WebAppDelegate* load = [[UIApplication sharedApplication] delegate];
    load.flag = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
      
        NSLog(@"iPhoneの処理");
    }else{
        NSLog(@"iPadの処理");
    }

	//ページをWebViewのサイズに合わせて表示するよう設定
    _webViewer.scalesPageToFit = YES;
    _webViewer.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    //WebViewにdelegate先のオブジェクトを指定
    _webViewer.delegate = self;
    
    //「進む」、「戻る」ボタンを無効化する。
    _backBtn.enabled = NO;
    _fwdBtn.enabled = NO;
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://test.rapinics.jp/sato/index.html"]];
    //NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.yahoo.co.jp"]];
    [_webViewer loadRequest:req];
    // Do any additional setup after loading the view, typically from a nib.}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// web を解放
- (void)dealloc {
        _webViewer.delegate = nil;
}

//URL入力フィールド
- (IBAction)opnURL:(id)sender {
    //特定URLの指定(safariで起動)
    NSString *safariURL = @"http://www.google.com";
    // URLを指定
    NSURL *url = [NSURL URLWithString: _addressText.text];
    NSLog(@"%@",url);
    if ([_addressText.text isEqualToString:safariURL]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    else{
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        // リクエストを投げる
        [_webViewer loadRequest:request];
        
        // UIWebViewのインスタンスをビューに追加
        [self.view addSubview:_webViewer];
    }
    [self setFlag];
    NSLog(@"URLを入力しました");
    //キーボードを閉じる
    [sender resignFirstResponder];
}

//写真選択
- (IBAction)selPic:(id)sender {
    UIImagePickerController* picController = [[UIImagePickerController alloc]init];
    
    [self presentViewController:picController animated:YES completion:nil];
    picController.delegate = self;
    picController.allowsEditing = YES;
}

//写真選択→choose
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    pictureImg =[info objectForKey:UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSURL *photourl = [info objectForKey: UIImagePickerControllerReferenceURL];
    NSLog(@"%@",photourl);
    NSString *message = @"写真を選択しました";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                    message: message
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
    [alert show];

}

//写真選択→cancel
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//アップロード
- (IBAction)upLoad:(id)sender {

}

//画像を保存
- (IBAction)saveBtn:(id)sender {
    //[self performSelectorInBackground:@selector(saveBackground) withObject:nil];
    NSURL *url = [NSURL URLWithString:@"http://test.rapinics.jp/sato/images/image_2.png"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

// 非同期通信 ヘッダーが返ってきた
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	// データを初期化
	async_data = [[NSMutableData alloc] initWithData:0];
}

// 非同期通信 ダウンロード中
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	// データを追加する
	[async_data appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection*)connection
{
    NSURL *url = [NSURL URLWithString:@"http://test.rapinics.jp/sato/images/image_2.png"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSLog(@"%@",url);
    UIImage *image = [UIImage imageWithData:data];
    //画像保存完了時のセレクタ指定
    SEL selector = @selector(onCompleteCapture:didFinishSavingWithError:contextInfo:);
    //画像を保存する
    UIImageWriteToSavedPhotosAlbum(image, self, selector, NULL);
}

/*-(void)saveBackground
{
    NSURL *url = [NSURL URLWithString:@"http://test.rapinics.jp/sato/images/image_2.png"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    //画像保存完了時のセレクタ指定
    SEL selector = @selector(onCompleteCapture:didFinishSavingWithError:contextInfo:);
    //画像を保存する
    UIImageWriteToSavedPhotosAlbum(image, self, selector, NULL);
}*/

//画像保存完了時のセレクタ
- (void)onCompleteCapture:(UIImage *)screenImage
 didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"画像を保存しました";
    if (error) message = @"画像の保存に失敗しました";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @""
                                                    message: message
                                                   delegate: nil
                                          cancelButtonTitle: @"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

//検索フィールド
- (IBAction)googleSearch:(id)sender {
    NSString *query = [_searchBar.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSURL *queryUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.co.jp/search?q=%@", query]];
    NSURLRequest *queryRequest = [NSURLRequest requestWithURL:queryUrl];
    [_webViewer loadRequest:queryRequest];
    NSLog(@"検索しました");
    [self setFlag];
    //キーボードを閉じる
    [self.view endEditing: YES];
}
//「進む」ボタン
- (IBAction)fwdBtn:(id)sender {
    [self setFlag];
    [_webViewer goForward];
}

//「戻る」ボタン
- (IBAction)backBtn:(id)sender {
    WebAppDelegate* load = [[UIApplication sharedApplication] delegate];
    load.flag = 0;
    NSLog(@"%ld",(long)load.flag);
    [_webViewer goBack];
}

//-----------検証用--------------
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    NSLog(@"タッチしました");
    NSLog(@"%ld",(long)touch.view.tag);
    if ( touch.view.tag == _webViewer.tag ){
        NSLog(@"画面タッチ");}
    else if (touch.view.tag == _backBtn.tag){
        NSLog(@"ボタンタッチ");}
}

//Webページのロード（表示）の開始前
- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // リンクがクリックされたとき
    NSString* url = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
    if (navigationType == UIWebViewNavigationTypeLinkClicked){
        if ([self isTwitterURL:[request URL]]) { // yes
            // TwitterのURLの場合はログに書く
            NSLog(@"Twitter");
            return NO;
        }
        NSLog(@"%@",url);
        NSLog(@"リンクをクリック");
        [self setFlag];
    }
    return YES;
}

- (BOOL)isTwitterURL:(NSURL *)url
{
    NSString *urlString = [url absoluteString];
    NSString *twitterUrlString = @"twitter.com";
    
    // Twitterページか?
    NSRange range = [urlString rangeOfString:twitterUrlString];
    if (range.location != NSNotFound) {
        return YES;
    } else {
        return NO;
    }
}
//----------------------
- (void)webViewDidStartLoad:(UIWebView *)webView {
	// ページのロードが開始されたので、ステータスバーのロード中インジケータを表示する。
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    WebAppDelegate* load = [[UIApplication sharedApplication] delegate];
    if(load.flag == 0)
    {
        //ローディング画面(ライブラリMBProgressHUD使用)
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_webViewer animated:YES];
        hud.labelText = @"Now Loading...";
        hud.dimBackground = YES;
        load.flag = 1;
        NSLog(@"%ld",(long)load.flag);
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	// ページのロードが終了したので、ステータスバーのロード中インジケータを非表示にする。
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self closeHud];
    // ページの「進む」および「戻る」が可能かチェックし、各ボタンの有効／無効を指定する。
    _backBtn.enabled = [webView canGoBack];
	_fwdBtn.enabled = [webView canGoForward];
    //ページのURLを取得
    NSString* url = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
    _addressText.text = url;
    //ページのタイトルを取得
    NSString* title = [_webViewer stringByEvaluatingJavaScriptFromString:@"document.title"];
    //NSLog(@"%@",title);
    _urlTitle.text = title;
}

-(void)setFlag
{
    WebAppDelegate* load = [[UIApplication sharedApplication] delegate];
    if(load.flag ==1)
        load.flag = 0;
    NSLog(@"%ld",(long)load.flag);
}

-(void)closeHud
{
    [MBProgressHUD hideAllHUDsForView:_webViewer animated:YES];
}


@end
