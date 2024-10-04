import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:proxy_selector/models/proxy_dto.dart';
import 'package:proxy_selector/proxy_selector.dart';

Future<String?> _getProxyHost() async {
  final proxyPlugin = ProxySelector();
  try {
    final address = Uri.tryParse("https://duckduckgo.com/");
    final proxy = await proxyPlugin.getSystemProxyForUri(address!);
    if (proxy != null && proxy.isNotEmpty) {
      proxy.join();
      List<ProxyDto> proxies = List.from(proxy);
      proxies.removeWhere((element) => element.type == "NONE");
      if (proxies.isNotEmpty) {
        return proxies.first.host;
      }
    } else {
      return null;
    }
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
  return null;
}

Future<String?> _getProxyPort() async {
  final proxyPlugin = ProxySelector();
  try {
    final address = Uri.tryParse("https://duckduckgo.com/");
    final proxy = await proxyPlugin.getSystemProxyForUri(address!);
    if (proxy != null && proxy.isNotEmpty) {
      proxy.join();
      List<ProxyDto> proxies = List.from(proxy);
      proxies.removeWhere((element) => element.type == "NONE");
      if (proxies.isNotEmpty) {
        return proxies.first.port;
      }
    } else {
      return null;
    }
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
  return null;
}

class HttpProxy extends HttpOverrides {
  String? host;
  String? port;

  HttpProxy._(this.host, this.port);

  static Future<HttpProxy> createHttpProxy() async {
    return HttpProxy._(await _getProxyHost(), await _getProxyPort());
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
