#import "HttpProxyPlugin.h"

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
        NSString *proxyHost = [self getProxyHost];
        result(proxyHost);
    }
    else if ([@"getProxyPort" isEqualToString:call.method]) {
        NSString *proxyPort = [self getProxyPort];
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

- (NSString *)getProxyHost {
    CFDictionaryRef proxySettings = CFNetworkCopySystemProxySettings();
    NSDictionary *dictProxy = (__bridge_transfer id)proxySettings;

    if ([[dictProxy objectForKey:@"HTTPEnable"] boolValue]) {
        return [dictProxy objectForKey:@"HTTPProxy"];
    }
    else {
        return nil;
    }
}

- (NSString *)getProxyPort {
    CFDictionaryRef proxySettings = CFNetworkCopySystemProxySettings();
    NSDictionary *dictProxy = (__bridge_transfer id)proxySettings;

    if ([[dictProxy objectForKey:@"HTTPEnable"] boolValue]) {
        return [NSString stringWithFormat:@"%ld", [[dictProxy objectForKey:@"HTTPPort"] integerValue]];
    }
    else {
        return nil;
    }
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
