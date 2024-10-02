import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_js/flutter_js.dart';


MethodChannel _channel = MethodChannel('com.lm.http.proxy');

Future<String?> _getProxyHost() async {
  /*
  if (Platform.isIOS) {
    if (await _channel.invokeMethod('isPACUsed')) {
      final pacProxyService = PACProxyService();
      try {
        return await pacProxyService._getProxyHost();
      } catch (e) {
        print("Oh no something went wrong when trying to get ProxyHost from PAC file:\n" + e.toString());
        return await _channel.invokeMethod('getProxyHost');
      }
    }
    return await _channel.invokeMethod('getProxyHost');
  }
   */
  return await _channel.invokeMethod('getProxyHost');
}

Future<String?> _getProxyPort() async {
  /*
  if (Platform.isIOS) {
    if (await _channel.invokeMethod('isPACUsed')) {
      final pacProxyService = PACProxyService();
      try {
        return await pacProxyService._getProxyPort();
      } catch (e) {
        print("Oh no something went wrong when trying to get ProxyHost from PAC file:\n" + e.toString());
        return null;
      }
    }
    return await _channel.invokeMethod('getProxyPort');
  }
   */
  return await _channel.invokeMethod('getProxyPort');
}

/// Only works on iOS
Future<String?> _isPACUsed() async {
  if (Platform.isIOS) {
    return await _channel.invokeMethod('isPACUsed');
  }
  return "false";
}

/// Only works on iOS
Future<String?> _getPACURL() async {
  if (Platform.isIOS) {
    return await _channel.invokeMethod('getPACURL');
  }
  return null;
}

class HttpProxy extends HttpOverrides {
  String? host;
  String? port;

  MethodChannel _channel = MethodChannel('com.lm.http.proxy');

  HttpProxy._(this.host, this.port);

  static Future<HttpProxy> createHttpProxy() async {
    return HttpProxy._(await _getProxyHost(), await _getProxyPort());
  }

  static Future<String?> isPACUsed() async {
    return await _isPACUsed();
  }

  static Future<String?> getPACURL() async {
    return await _getPACURL();
}

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    var client = super.createHttpClient(context);
    client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
      return true;
    };
    return client;
  }

  @override
  String findProxyFromEnvironment(Uri url, Map<String, String>? environment) {
    if (host == null) {
      return super.findProxyFromEnvironment(url, environment);
    }

    if (environment == null) {
      environment = {};
    }

    if (port != null) {
      environment['http_proxy'] = '$host:$port';
      environment['https_proxy'] = '$host:$port';
    } else {
      environment['http_proxy'] = '$host:8888';
      environment['https_proxy'] = '$host:8888';
    }

    return super.findProxyFromEnvironment(url, environment);
  }
}

class PACProxyService {
  static const MethodChannel _channel = MethodChannel('com.lm.http.proxy');

  Future<String> getPACURL() async {
    return await _channel.invokeMethod('getPACURL');
  }

  Future<String?> _getProxyHost() async {
    String pacUrl = await getPACURL();
    String pacContent = await fetchPacFile(pacUrl);

    // Placeholder values just to get the Proxy host
    String placeholderUrl = 'https://duckduckgo.com/';
    String placeholderHost = 'duckduckgo.com';

    String proxy = await parsePacFile(pacContent, placeholderUrl, placeholderHost);
    return proxy.split(':').first; // Return only the host part
  }

  Future<String?> _getProxyPort() async {
    String pacUrl = await getPACURL();
    String pacContent = await fetchPacFile(pacUrl);

    // Placeholder values just to get the Proxy port
    String placeholderUrl = 'https://duckduckgo.com/';
    String placeholderHost = 'duckduckgo.com';

    String proxy = await parsePacFile(pacContent, placeholderUrl, placeholderHost);
    return proxy.split(':').last; // Return only the port part
  }

  Future<String> fetchPacFile(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
    return response.body;
    } else {
    throw Exception('Failed to load PAC file');
    }
  }

  Future<String> parsePacFile(String pacContent, String url, String host) async {
    final JavascriptRuntime jsRuntime = getJavascriptRuntime();
    await jsRuntime.evaluate(pacContent);
    final result = await jsRuntime.evaluate('FindProxyForURL("$url", "$host")');

    return result.stringResult;
  }
}
