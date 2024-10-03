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
        NSString *proxyHost = [self getProxyForURL:0];
        result(proxyHost);
    }
    else if ([@"getProxyPort" isEqualToString:call.method]) {
        NSString *proxyPort = [self getProxyForURL:1];
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

    - (NSString *)getProxyForURL:(NSInteger)returnType {
        NSURL *url = [NSURL URLWithString:@"http://duckduckgo.com"];

        NSDictionary *proxySettings = (__bridge_transfer NSDictionary *)CFNetworkCopySystemProxySettings();

        NSArray *proxies = (__bridge_transfer NSArray *)CFNetworkCopyProxiesForURL((__bridge CFURLRef)url, (__bridge CFDictionaryRef)proxySettings);

        for (NSDictionary *proxy in proxies) {
            NSString *proxyHost = proxy[(NSString *)kCFProxyHostNameKey];
            NSNumber *proxyPortNumber = proxy[(NSString *)kCFProxyPortNumberKey];

            // Convert the port to a string
            NSString *proxyPort = [proxyPortNumber stringValue];

            if (proxyHost && proxyPort) {
                NSLog(@"Proxy Host: %@", proxyHost);
                NSLog(@"Proxy Port: %@", proxyPort);
            }

            if (returnType == 0) {
                return proxyHost;
            } else {
                return proxyPort;
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
