#import "HttpProxyPlugin.h"
#import <CFNetwork/CFNetwork.h>

@implementation HttpProxyPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
            methodChannelWithName:@"com.lm.http.proxy"
                  binaryMessenger:[registrar messenger]];
    HttpProxyPlugin* instance = [[HttpProxyPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getProxyHost" isEqualToString:call.method]) {
        NSString *proxyHost = [self getProxyForURL:@"https://duckduckgo.com" returnType:0];
        result(proxyHost);
    }
    else if ([@"getProxyPort" isEqualToString:call.method]) {
        NSString *proxyPort = [self getProxyForURL:@"https://duckduckgo.com" returnType:1];
        result(proxyPort);
    }
    else if ([@"isPACUsed" isEqualToString:call.method]) {
        BOOL isPACUsed = [self isPACUsed];
        result(@(isPACUsed));
    }
    else if ([@"getPACURL" isEqualToString:call.method]) {
        NSString *pacURL = [self getPACURL];
        result(pacURL);
    }
    else {
        result(FlutterMethodNotImplemented);
    }
}

- (NSString *)getProxyForURL:(NSString *)urlString returnType:(NSInteger)returnType {
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        return nil;
    }

    NSArray *proxies = (__bridge_transfer NSArray *)CFNetworkCopyProxiesForURL((__bridge CFURLRef)url, CFNetworkCopySystemProxySettings());
    
    if (proxies.count > 0) {
        NSDictionary *proxyDict = proxies[0];
        NSString *proxyHost = proxyDict[(NSString *)kCFNetworkProxiesHTTPProxy];
        NSNumber *proxyPort = proxyDict[(NSString *)kCFNetworkProxiesHTTPPort];

        if (returnType == 0) {
            return proxyHost ? proxyHost : nil;
        } else if (returnType == 1) {
            return proxyPort ? proxyPort.stringValue : nil;
        }
    }
    
    return nil;
}

- (BOOL)isPACUsed {
    CFDictionaryRef proxySettings = CFNetworkCopySystemProxySettings();
    NSDictionary *dictProxy = (__bridge_transfer id)proxySettings;

    return [[dictProxy objectForKey:@"ProxyAutoConfigEnable"] boolValue];
}

- (NSString *)getPACURL {
    CFDictionaryRef proxySettings = CFNetworkCopySystemProxySettings();
    NSDictionary *dictProxy = (__bridge_transfer id)proxySettings;

    if ([[dictProxy objectForKey:@"ProxyAutoConfigEnable"] boolValue]) {
        return [dictProxy objectForKey:@"ProxyAutoConfigURLString"];
    }
    else {
        return nil;
    }
}

@end
