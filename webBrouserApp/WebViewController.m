//
//  WebViewController.m
//  webBrouserApp
//
//  Created by 佐藤　史渉 on 2013/11/06.
//  Copyright (c) 2013年 佐藤　史渉. All rights reserved.
//

#import "WebViewController.h"
#import "MyNSURLConnection.h"

@interface WebViewController ()

@end

@implementation WebViewController

//選択写真イメージ記録用
UIImage* pictureImg;
//非同期通信用
NSMutableData *picture_Data = nil;
// アップロードURL
#define UPLOAD_URL @"http://test.rapinics.jp/sato/receive.php"
// アップロードファイルのパラメーター名
#define UPLOAD_PARAM @"upfile"

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
    //ローディング画面
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_webViewer animated:YES];
    hud.labelText = @"サーバーへアップロード中";
    hud.dimBackground = YES;
    
    NSData* imageData = [[NSData alloc] initWithData:UIImagePNGRepresentation( pictureImg )];
    
    // 送信データの境界
	NSString *boundary = @"1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
	// アップロードする際のファイル名
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
	[dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
	NSString *uploadFileName = [dateFormatter stringFromDate:[NSDate date]];
	// 送信するデータ（前半）
	NSMutableString *sendDataStringPrev = [NSMutableString stringWithString:@"--"];
	[sendDataStringPrev appendString:boundary];
	[sendDataStringPrev appendString:@"\r\n"];
	[sendDataStringPrev appendString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpg\"\r\n",UPLOAD_PARAM,uploadFileName]];
	[sendDataStringPrev appendString:@"Content-Type: image/jpeg\r\n\r\n"];
	// 送信するデータ（後半）
	NSMutableString *sendDataStringNext = [NSMutableString stringWithString:@"\r\n"];
	[sendDataStringNext appendString:@"--"];
	[sendDataStringNext appendString:boundary];
	[sendDataStringNext appendString:@"--"];
	
	// 送信データの生成
	NSMutableData *sendData = [NSMutableData data];
	[sendData appendData:[sendDataStringPrev dataUsingEncoding:NSUTF8StringEncoding]];
	[sendData appendData:imageData];
	[sendData appendData:[sendDataStringNext dataUsingEncoding:NSUTF8StringEncoding]];
    
    // リクエストヘッダー
	NSDictionary *requestHeader = [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSString stringWithFormat:@"%d",[sendData length]],@"Content-Length",
								   [NSString stringWithFormat:@"multipart/form-data;boundary=%@",boundary],@"Content-Type",nil];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:UPLOAD_URL]];
	[request setAllHTTPHeaderFields:requestHeader];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:sendData];
	
	MyNSURLConnection *conn = [[MyNSURLConnection alloc]
                               initWithRequest:request delegate:self startImmediately:NO];
    conn.tag=2;
    //通信開始
    [conn start];
}


//画像を保存(NSURLConnectionを使用し非同期通信で保存)
- (IBAction)saveBtn:(id)sender {
    //[self performSelectorInBackground:@selector(saveBackground) withObject:nil];
    NSURL *url = [NSURL URLWithString:@"http://test.rapinics.jp/sato/images/image_4.jpg"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    // NSURLConnectionのインスタンスを作成したら、すぐに指定したURLへリクエストを送信。
    // delegate指定すると、サーバーからデータを受信したり、エラーが発生したりするとメソッドが呼び出される。
    // startImmediately:NOでコネクションのみ作成し通信は行わない
    MyNSURLConnection *conn = [[MyNSURLConnection alloc]
                               initWithRequest:request delegate:self startImmediately:NO];
    conn.tag=1;
    //通信開始
    [conn start];
}

// 非同期通信 データ受信時に１回だけ呼び出される。
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    MyNSURLConnection *conn = (MyNSURLConnection*)connection;
    //保存時
    if(conn.tag == 1)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:_webViewer animated:YES];
        hud.labelText = @"画像を保存中";
        hud.dimBackground = YES;
        // データを初期化
        picture_Data = [[NSMutableData alloc] initWithData:0];
        NSLog(@"ダウンロード開始");
    }
    //アップロード時
    else if(conn.tag == 2)
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"%d",httpResponse.statusCode);
        [self closeHud];
        if(httpResponse.statusCode == 200)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"アップロード完了" message:@"アップロード完了しました"
                                                          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"エラー" message:@"レスポンスエラー"
                                                          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}

// 非同期通信 ダウンロード中(受信したデータをpicture_Dataに追加する)
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    MyNSURLConnection *conn = (MyNSURLConnection*)connection;
    if(conn.tag == 1)
    {
        // データを追加する
        [picture_Data appendData:data];
        NSLog(@"ダウンロード中");
    }
}

//データ受信終了時に呼び出される
- (void) connectionDidFinishLoading:(NSURLConnection*)connection
{
    MyNSURLConnection *conn = (MyNSURLConnection*)connection;
    if(conn.tag == 1)
    {
        //NSDataをUIImageに変換する
        UIImage *pic_Image = [[UIImage alloc] initWithData:picture_Data];
        [self closeHud];
            //画像保存完了時のセレクタ指定
        SEL selector = @selector(onCompleteCapture:didFinishSavingWithError:contextInfo:);
        //画像を保存する
        UIImageWriteToSavedPhotosAlbum(pic_Image, self, selector, NULL);
    }
}

// エラーが発生した場合
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    MyNSURLConnection *conn = (MyNSURLConnection*)connection;
    if(conn.tag == 2){
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"エラー" message:@"ネットワークエラー"
												  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];}
}

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
    NSLog(@"%@",query);
    //検索文字列をURLエンコード(日本語検索のため)
    NSString *escapedUrlString = [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@",escapedUrlString);
    NSURL *queryUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.co.jp/search?q=%@", escapedUrlString]];
    NSLog(@"%@",queryUrl);
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
    NSString* clickUrl = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
    if (navigationType == UIWebViewNavigationTypeLinkClicked){
        if ([self isZipURL:[request URL]]) { // yes
            // ZipのURLの場合はログに書く(検証用)
            NSLog(@"Zip");
            return NO;
        }
        NSLog(@"%@",clickUrl);
        NSLog(@"リンクをクリック");
        [self setFlag];
    }
    return YES;
}

- (BOOL)isZipURL:(NSURL *)clickUrl
{
    NSString *urlString = [clickUrl absoluteString];
    NSString *zipUrlString = @".zip";
    
    // Zipか?
    NSRange range = [urlString rangeOfString:zipUrlString];
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
    //サイトアクセス時、何度もローディング画面が呼ばれるのを防ぐ
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
    WebAppDelegate* load = [[UIApplication sharedApplication] delegate];
    if(load.flag == 1)
        //ローディング終了処理
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

//既に一回ローディング画面が呼ばれていたら、フラグを０にしておく
-(void)setFlag
{
    WebAppDelegate* load = [[UIApplication sharedApplication] delegate];
    if(load.flag ==1)
        load.flag = 0;
    NSLog(@"%ld",(long)load.flag);
}

//ローディング終了メソッド
-(void)closeHud
{
    [MBProgressHUD hideAllHUDsForView:_webViewer animated:YES];
}


@end
