import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_links/app_links.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../onepay_paygate_flutter.dart';

// ignore: must_be_immutable
class OnePayPaygateView extends StatefulWidget {
  OPPaymentEntity paymentEntity;
  OnPayResult? onPayResult;
  OnPayFail? onPayFail;

  OnePayPaygateView(
      {super.key, required this.paymentEntity, this.onPayResult, this.onPayFail});

  @override
  // ignore: no_logic_in_create_state, library_private_types_in_public_api
  _OnePayPaygateViewState createState() => _OnePayPaygateViewState(
        paymentEntity: paymentEntity,
        onPayResult: onPayResult,
        onPayFail: onPayFail,
      );
}

class _OnePayPaygateViewState extends State<OnePayPaygateView> {
  OPPaymentEntity paymentEntity;
  OnPayResult? onPayResult;
  OnPayFail? onPayFail;
  _OnePayPaygateViewState(
      {required this.paymentEntity, this.onPayResult, this.onPayFail});
  StreamSubscription<Uri>? _subscription;
  WebViewController? _webViewController;

  @override
  void initState() {
    // Initialize the WebViewController
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (url.startsWith(paymentEntity.returnUrl)) {
              handlePaymentResult(url);
            }
          },
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            var errorResult = OPErrorResult(
                errorCase: OnePayErrorCase.NOT_CONNECT_WEB_ONEPAY);
            onPayFail?.call(errorResult);
          },
          onUrlChange: (UrlChange change) {},
        ),
      );
    
    // Load the initial payment URL
    var url = paymentEntity.createUrlPayment();
    _webViewController!.loadRequest(Uri.parse(url));
    
    _subscription = AppLinks().uriLinkStream.listen((uri) {
      handleDeeplink(uri.toString());
    });
    initAppLinks().then((value) {
      handleDeeplink(value);
    });
    super.initState();
  }

  Future<String?> initAppLinks() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final initialLink = AppLinks().getInitialLink;
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
      return initialLink.toString();
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
      return "";
    }
  }

  void handleDeeplink(String? deeplink) {
    if (deeplink == null) {
      return;
    }
    if (deeplink.contains(paymentEntity.returnUrl)) {
      var uri = Uri.parse(deeplink);
      var encryptLink = uri.queryParameters["deep_link"];
      if (encryptLink != null && encryptLink.isNotEmpty) {
        var base64Decoder = const Base64Decoder();
        var deeplinkUri = Uri.parse("${base64Decoder.convert(encryptLink)}");
        var url = deeplinkUri.queryParameters["url"];
        if (url != null && url.isNotEmpty) {
          _webViewController?.loadRequest(Uri.parse(url));
        }
        return;
      }
      var url = uri.queryParameters["url"];
      if (url != null && url.isNotEmpty) {
        _webViewController?.loadRequest(Uri.parse(url));
        return;
      }
      _webViewController?.loadRequest(Uri.parse(uri.toString()));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(
          controller: _webViewController!,

        ),
      ),
    );
  }

  void handlePaymentResult(String url) {
    var uri = Uri.parse(url);
    var queries = uri.queryParameters;
    var code = queries["vpc_TxnResponseCode"];
    var isSuccess = false;
    if (code != null && code == "0") {
      isSuccess = true;
    }
    Navigator.pop(context);
    onPayResult?.call(OPPaymentResult(
        isSuccess: isSuccess,
        amount: queries["vpc_Amount"],
        card: queries["vpc_Card"],
        cardNumber: queries["vpc_CardNum"],
        command: queries["vpc_Command"],
        merchTxnRef: queries["vpc_MerchTxnRef"],
        merchant: queries["vpc_Merchant"],
        message: queries["vpc_Message"],
        orderInfo: queries["vpc_OrderInfo"],
        payChannel: queries["vpc_PayChannel"],
        transactionNo: queries["vpc_TransactionNo"],
        version: queries["vpc_Version"]));
  }

  void openCustomUrl(String url) {
    OnePayPaygate.openCustomURL(url);
  }
}
