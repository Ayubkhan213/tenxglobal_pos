import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tenxglobal_pos/config.dart';

class POSWebViewScreen extends StatefulWidget {
  const POSWebViewScreen({super.key});

  @override
  State<POSWebViewScreen> createState() => _POSWebViewScreenState();
}

class _POSWebViewScreenState extends State<POSWebViewScreen> {
  InAppWebViewController? _webViewController;
  double _progress = 0;

  // Call this to reload the WebView
  void reloadWebView() {
    if (_webViewController != null) {
      _webViewController!.reload();
      print("WebView reloaded!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_webViewController != null) {
          final canGoBack = await _webViewController!.canGoBack();
          if (canGoBack) {
            _webViewController!.goBack();
            return false;
          }
        }
        return false;
      },
      child: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(AppConfig.posUrl)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              supportZoom: false,
              useOnDownloadStart: true,
              useShouldOverrideUrlLoading: true,
              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              allowFileAccessFromFileURLs: true,
              allowUniversalAccessFromFileURLs: true,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
              print("WebView created");
            },
            onLoadStart: (controller, url) {
              setState(() => _progress = 0);
            },
            onLoadStop: (controller, url) async {
              setState(() => _progress = 0);
            },
            onProgressChanged: (controller, progress) {
              setState(() => _progress = progress / 100);
            },
            onReceivedError: (controller, request, error) {
              print('WebView error: $error');
            },
          ),
          if (_progress > 0 && _progress < 1)
            Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey.shade800,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                minHeight: 3,
              ),
            ),
        ],
      ),
    );
  }
}
