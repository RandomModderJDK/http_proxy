#import "HttpProxyPlugin.h"

@implementation HttpProxyPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
            methodChannelWithName:@"com.lm.http.proxy"
                  binaryMessenger:[registrar messenger]];
    HttpProxyPlugin* instance = [[HttpProxyPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}
// Don't remove otherwise crashes
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"123" isEqualToString:call.method]) {
    }else{
        result(FlutterMethodNotImplemented);
    }
}

@end