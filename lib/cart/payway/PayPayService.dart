import 'dart:convert';
import 'package:http/http.dart' as http;

class PayPayService {
  final String apiKey = 'a_nIEpGYHPnj_CApN';
  final String apiSecret = '4SvV9NR6ANYhWsH8OJ9Pac6btPbANW7imQA0RjlaPzQ=';
  final String merchantId = '358238824351637504';
  final String baseUrl = 'https://api.paypay.ne.jp/v2';

  Future<void> createPayment(double amount, String orderId) async {
    final url = Uri.parse('$baseUrl/payments');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };
    final body = jsonEncode({
      'merchantPaymentId': orderId,
      'amount': {
        'amount': amount,
        'currency': 'JPY'
      },
      'codeType': 'ORDER_QR',
      'orderDescription': 'Payment for Order $orderId',
      'redirectUrl': 'your-app://payment-callback',
      'redirectType': 'WEB_LINK',
    });

    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      // Handle success
      final responseData = jsonDecode(response.body);
      print('Payment created: ${responseData['data']['url']}');
    } else {
      // Handle error
      print('Error creating payment: ${response.body}');
    }
  }
}