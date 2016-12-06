//
//  ViewController.m
//  Wiotm
//
//  Created by ios on 2016/10/26.
//  Copyright © 2016年 ios. All rights reserved.
//
#define URLStr @"http://ahcof.31huiyi.com/"
#import "ViewController.h"

@interface ViewController ()<UIWebViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate>
{
    UIWebView *_webView;
    NSString *imgStr;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    //    self.title = @"博览会数组会务管理终端";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _webView = [[UIWebView alloc] init];
    _webView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _webView.delegate = self;//因为这个代理设置的self
    [self.view addSubview:_webView];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URLStr]]];
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longGes:)];
    longGesture.delegate = self;
    [self.view addGestureRecognizer:longGesture];
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(IBAction)comeBack:(id)sender
{
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //获取网页title
    NSString *htmlTitle = @"document.title";
    NSString *titleHtmlInfo = [webView stringByEvaluatingJavaScriptFromString:htmlTitle];
    if ([webView.request.URL.absoluteString isEqualToString:URLStr] || [webView.request.URL.absoluteString isEqualToString:@"http://ahcof.31huiyi.com/Search/IndexEn"] || [webView.request.URL.absoluteString isEqualToString:@"http://ahcof.31huiyi.com/Search/Index"]) {
        self.navigationItem.leftBarButtonItem = nil;
    }else
    {
        UIBarButtonItem *backBarButton;
        if (!backBarButton) {
            backBarButton= [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(comeBack:)];
        }
        self.navigationItem.leftBarButtonItem  = backBarButton;
        
    }
    self.title = titleHtmlInfo;
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}
// 如果返回NO，代表不允许加载这个请求
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.scheme isEqualToString:@"image-preview"]) {
        NSString* path = [request.URL.absoluteString substringFromIndex:[@"image-preview:" length]];
        path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //path 就是被点击图片的url
//        return NO;
    }
    // 说明协议头是ios
    return YES;
}
-(void)longGes:(UILongPressGestureRecognizer * )longtapGes{
    //只在长按手势开始的时候才去获取图片的url
    if (longtapGes.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [longtapGes locationInView:_webView];
    NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    NSString *urlToSave = [_webView stringByEvaluatingJavaScriptFromString:js];
    if (urlToSave.length == 0) {
        return;
    }
    if (longtapGes.state == UIGestureRecognizerStateBegan) {
        CGPoint pt = [longtapGes locationInView:self.view];
        pt= [_webView convertPoint:pt fromView:nil];
        
        CGPoint offset  = [_webView.scrollView contentOffset];
        CGSize viewSize = [self.view frame].size;
        CGSize windowSize = [self.view frame].size;
        
        CGFloat f = windowSize.width / viewSize.width;
        pt.x = pt.x * f + offset.x;
        pt.y = pt.y * f + offset.y;
        
        [self openContextualMenuAt:pt];
    }
}
- (void)openContextualMenuAt:(CGPoint)pt
{
//    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"Naving" ofType:@"bundle"]];
//    NSString *path = [bundle pathForResource:@"JSTools" ofType:@"js"];
//    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
//    [_webView stringByEvaluatingJavaScriptFromString:jsCode];
    //http://m5.31huiyi.com/Home/Index/5832c4456341980de816a813?invent=chat#chat
    
//    NSString *tags = [_webView stringByEvaluatingJavaScriptFromString:
//                      [NSString stringWithFormat:@"MyAppGetHTMLElementsAtPoint(%i,%i);",(NSInteger)pt.x,(NSInteger)pt.y]];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"图片保存到相册"
                                                       delegate:self cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil otherButtonTitles:nil];
    
//    if ([tags rangeOfString:@",A,"].location != NSNotFound) {
//        [sheet addButtonWithTitle:@"打开链接"];
//    }
//    NSLog(@"tags:%@",tags);
//    if ([_webView.request.URL.absoluteString isEqualToString:@"http://m5.31huiyi.com/Home/Index/5832c4456341980de816a813?invent=chat#chat"]) {
        //    if ([tags rangeOfString:@",IMG,"].location != NSNotFound) {
        NSString *str = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", pt.x, pt.y];
        imgStr= [_webView stringByEvaluatingJavaScriptFromString: str];
        
        [sheet addButtonWithTitle:@"保存图片"];
        //    }
//    }
    
    
    [sheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgStr]];
        UIImage* image = [UIImage imageWithData:data];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    
    if (error){
        NSLog(@"Error");
        UIAlertView *alertView;
        if (!alertView) {
            alertView= [[UIAlertView alloc] initWithTitle:nil message:@"保存图片失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
        }
        
    }else {
        UIAlertView *alertView;
        if (!alertView) {
            alertView= [[UIAlertView alloc] initWithTitle:nil message:@"保存图片成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
        }
        NSLog(@"OK");
    }
}
@end
