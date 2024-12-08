import 'dart:convert';
import 'package:flutter/material.dart';
import '../chatting/chatting.dart';
import '../env.dart';
import 'package:http/http.dart' as http;
import 'payway.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../BottomNav.dart';
import '../home/shopping/detail.dart';
import 'address/judge_addr.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:core';
import 'dart:io';
import '../home/shopping/mainHome.dart';
import 'Utility.dart';
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'payway/PayPayService.dart';
import  'package:keyboard_actions/keyboard_actions.dart';

class mainCart extends StatefulWidget {
  mainCart({Key key}) : super(key: key);
  mainCartState createState() => mainCartState();
}

class mainCartState extends State<mainCart> {
  dynamic flagForBack = false;
  var irregularProducts = [];
  double totalPrice = 0;
  double totalPriceTax = 0;
  String uniqueId = null;
  var totalProducts = [];
  List<int> reCounts = [];
  List<double> irCounts = [];
  bool tflag = true;
  double height = 400;
  bool flag = false;
  int status;
  double regularTotal = 0;
  double regularTotalTax = 0;
  double irregularTotal = 0;
  double irregularTotalTax = 0;
  SharedPreferences pref;
  bool isServerPossibeTime = false;
  String serviceTime = '';

  int cartCount = 0;

  FocusNode focusNode = FocusNode();

  TextEditingController _pointController;

  String payMethod = '';
  String selectedAddress = '请决定一个地址.';
  var addresses = [], payments = [];
  var delivery = null;
  int purse;
  int point = 0;
  List category = [];
  int addressIndex = -1;
  int selected_method = 0;
  int payway = -1;

  String cartErrMessage = "";
  String payBtnTitle = "提交订单";
  Color payBtnColor = Colors.grey;

  bool isRegularOkay = false;
  bool isDeleted = false;
  int deliveryType = 1; //Set as Kyowa Delivery
  int deliveryFee = -1;

  int regularUpdated = 0;
  int userId = 0;
  int usePoints = 0;
  TextEditingController _irQtyController;

  var _subscription;
  var _msgSubscr;
  VideoPlayerController _audioController;

  bool started = false;
  final PayPayService payPayService = PayPayService();
  bool isNewMsg = false;
  bool firstScreenOpened = true;

  List<Widget> irregularWidgets = [];
  List<Widget> uniqueIrregularWidgets = [];
  List<Widget> regularWidgets = [];

  Future<void> playSound() async {
    await _audioController.play();
  }

  Future<void> initializeFirebase() {
    debugPrint("*** Initializing Firebase");
    DateTime currentTime = DateTime.now();
    regularUpdated = currentTime.millisecondsSinceEpoch;
    if (uniqueId == null || uniqueId.isEmpty) {
      setButtonAndMessage();
    } else {
      DatabaseReference ref = FirebaseDatabase.instance.ref('$dbProduct/$uniqueId');
      _subscription = ref.onValue.listen((event) {
        if (event.snapshot.exists) {
          Map cartData = event.snapshot.value;
          cartData.forEach((key, value) {
            if (key == "data") {
              setState(() {
                if (cartData["data"]["isOkay"] != null) isRegularOkay = cartData["data"]["isOkay"];
                else isRegularOkay = false;

                if (deliveryType != 1) {
                  deliveryFee = (cartData["data"]["deliveryFee"] != null) ? cartData["data"]["deliveryFee"] : -1;
                }
              });
              debugPrint("Cart Data = ${cartData["data"]}");
              if (cartData["data"]["isDeleted"] != null && cartData["data"]["isDeleted"] == true) {
                playSound();
                pref.setInt("lastApiCallTime", 100);
                setState(() {
                  getCount = 0;
                });
                initialize();
              }
              if (cartData["data"]["regularUpdated"] != null && cartData["data"]["regularUpdated"] > regularUpdated) {
                playSound();
                pref.setInt("lastApiCallTime", 100);
                setState(() {
                  getCount = 0;
                });
                initialize();
              }
            }
          });
        }
        setButtonAndMessage();
      });

      DatabaseReference ref1 = FirebaseDatabase.instance.ref('$dbMessage/$uniqueId');
      _msgSubscr = ref1.onValue.listen((event) {
        if (event.snapshot.exists) {
          Map map = event.snapshot.value;
          var temp = [];
          map.forEach((key, value) {
            temp.add(value);
          });

          temp.sort((a, b) => DateTime.parse(a['datetime']).compareTo(DateTime.parse(b['datetime'])));
          if (temp.isNotEmpty) {
            var lastElement = temp.last;
            if (userId != 0 && lastElement['sender_id'].toString() != userId.toString() && tflag) {
              if (!firstScreenOpened) playSound();
              firstScreenOpened = false;
              setState(() {
                tflag = false;
                isNewMsg = true;
              });
            }
          }
        }
      });
    }
  }

  void setButtonAndMessage() {
    payBtnColor = Colors.grey;
    payBtnTitle = "提交订单";
    cartErrMessage = "";

    bool isDeliveryOkay = false;
    if (totalProducts.isEmpty && irregularProducts.isEmpty) isRegularOkay = true;
    if (deliveryType == 1 || deliveryFee >= 0) isDeliveryOkay = true;

    String startErrorMessage = "为了保证订单的准确性，请耐心等候。。。";
    int countIndex = 1;
    setState(() {
      String errMsg = "";
      if (!isRegularOkay) {
        errMsg += "\n${countIndex++}.客服需要在库确认。";
      }
      if (!isDeliveryOkay) {
        errMsg += "\n${countIndex++}.客服需要yamato运费确认。";
      }
      if (errMsg != "") {
        cartErrMessage = startErrorMessage + errMsg;
      }

      if (uniqueId == null) {
        payBtnColor = Colors.redAccent;
        payBtnTitle = "提交订单";
      } else {
        payBtnTitle = "支付";
        payBtnColor = Colors.grey;
        if (cartErrMessage == "") {
          payBtnColor = Colors.red;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _audioController = VideoPlayerController.asset('assets/audios/notification.mp3')
    ..initialize().then((_) {
    });
  }


  @override
  void dispose() {
    // Cancel the Firebase listener to avoid memory leaks
    _audioController?.dispose();
    _msgSubscr?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  int getCount = 0;
  Future<bool> initialize() async {
    getCount++;
    if (getCount > 1) return true;
    debugPrint("*** Initializing MainCart...");
    try {
      pref = await SharedPreferences.getInstance();
      pref.setBool('payEnable', false);
      pref.setDouble('irregularTotal', 0);
      final String token = pref.getString('token');

      if (token == null || token.isEmpty) {
        Navigator.popAndPushNamed(context, '/login', arguments: '/cart');
      } else {

        _pointController = TextEditingController(text: '0');
        final lastApiCall = pref.getInt('lastApiCallTime');
        final now = DateTime.now().millisecondsSinceEpoch;

        if (lastApiCall != null && (now - lastApiCall) < 30 * 1000) {
          // Use cached data
          var cachedCartData = pref.getString("CartInfo");
          if (cachedCartData != null && cachedCartData.isNotEmpty) {
            _parseAndSetCartData(cachedCartData, pref);
          } else {
            await pref.setInt("lastApiCallTime", 100);
            setState(() {
              getCount = 0;
            });
            initialize();
          }
        } else {
          final appJson = await http.get(Uri.parse('$serverUrl/api/${environment['cart']}'), headers: {'Authorization': token});
          setState(() {
            totalProducts = [];
            irregularProducts = [];
            reCounts = [];
            irCounts = [];
            regularTotal = 0;
            irregularTotal = 0;
            totalPrice = 0;
            deliveryFee = -1;
            deliveryType = -1;
            delivery = null;
            totalPriceTax = 0;
            irregularWidgets = [];
            uniqueIrregularWidgets = [];
          });
          if (appJson.statusCode == 200) {
            await pref.setString("CartInfo", appJson.body);
            debugPrint("*** Cart data = ${json.decode(appJson.body)}");
            await pref.setInt('lastApiCallTime', now);  // Save the current timestamp
            _parseAndSetCartData(appJson.body, pref);
          } else {
            // If API call fails, fall back to cached data if it exists
            var cachedCartData = pref.getString("CartInfo");
            await pref.setInt('lastApiCallTime', 100);
            if (cachedCartData != null && cachedCartData.isNotEmpty) {
              _parseAndSetCartData(cachedCartData, pref);
            } else {
              await pref.setInt('cartCount', 0);
            }
          }
        }
      }
    } catch (e, stackTrace) {
      debugPrint("*** I got catch $e");
      return false;
    }
    return true;
  }

  void calcTotalPriceTax() {
    reCounts = [];
    irCounts = [];
    regularTotal = 0;
    irregularTotal = 0;
    regularTotalTax = 0;
    irregularTotalTax = 0;
    totalPrice = 0;
    totalPriceTax = 0;
    for (int i = 0; i < totalProducts.length || i < irregularProducts.length; i++) {
      if (i < totalProducts.length) {
        reCounts.add(totalProducts[i]['qty']);
        regularTotal += totalProducts[i]['price'];
        regularTotalTax += totalProducts[i]['price']*(1+totalProducts[i]['product']['tax']);
        Object obj = {
          'id': '${totalProducts[i]['product_id']}',
          'qty': '${totalProducts[i]['qty']}',
          'price': '${totalProducts[i]['price']}',
          'tax': '${totalProducts[i]['product']['tax']}',
          'unit_id': '${totalProducts[i]['product']['unit']['id']}',
          'point': '${totalProducts[i]['product']['point']}'
        };
        category.add(obj);
      }

      if (i < irregularProducts.length) {
        irCounts.add((irregularProducts[i]['qty']).toDouble());
        irregularTotal += irregularProducts[i]['price'];
        irregularTotalTax += irregularProducts[i]['price']*(1+irregularProducts[i]['product']['tax']);
        Object obj = {
          'id': '${irregularProducts[i]['product_id']}',
          'qty': '${irregularProducts[i]['qty']}',
          'price': '${irregularProducts[i]['price']}',
          'tax': '${irregularProducts[i]['product']['tax']}',
          'unit_id': '${irregularProducts[i]['product']['unit']['id']}',
          'point': '${irregularProducts[i]['product']['point']}'
        };
        category.add(obj);
      }
    }

    totalPrice = irregularTotal + regularTotal;
    totalPriceTax = irregularTotalTax + regularTotalTax;
  }

  // Function to parse the cart data and update the state
  void _parseAndSetCartData(String cartData, SharedPreferences pref) async {
    final parsedJson = json.decode(cartData);

    // Extract data from the parsed JSON
    bool isServerPossibeTime = parsedJson['is_service_time'];
    Map serviceTimeLife = parsedJson['service_time_life'];
    String serviceTime = '${serviceTimeLife['start'].toString().substring(0, 5)}~${serviceTimeLife['end'].toString().substring(0, 5)}';

    List<dynamic> totalProducts = parsedJson['regular'];
    List<dynamic> irregularProducts = parsedJson['irregular'];

    int userId = parsedJson['user_id'];
    List<int> reCounts = [];
    List<double> irCounts = [];
    List category = [];
    double regularTotal = 0;
    double irregularTotal = 0;
    double regularTotalTax = 0;
    double irregularTotalTax = 0;
    double totalPrice = 0;
    double totalPriceTax = 0;

    for (int i = 0; i < totalProducts.length || i < irregularProducts.length; i++) {
      if (i < totalProducts.length) {
        reCounts.add(totalProducts[i]['qty']);
        regularTotal += totalProducts[i]['price'];
        regularTotalTax += totalProducts[i]['price']*(1+totalProducts[i]['product']['tax']);
        Object obj = {
          'id': '${totalProducts[i]['product_id']}',
          'qty': '${totalProducts[i]['qty']}',
          'price': '${totalProducts[i]['price']}',
          'tax': '${totalProducts[i]['product']['tax']}',
          'unit_id': '${totalProducts[i]['product']['unit']['id']}',
          'point': '${totalProducts[i]['product']['point']}'
        };
        category.add(obj);
      }

      if (i < irregularProducts.length) {
        irCounts.add((irregularProducts[i]['qty']).toDouble());
        irregularTotal += irregularProducts[i]['price'];
        irregularTotalTax += irregularProducts[i]['price']*(1+irregularProducts[i]['product']['tax']);
        Object obj = {
          'id': '${irregularProducts[i]['product_id']}',
          'qty': '${irregularProducts[i]['qty']}',
          'price': '${irregularProducts[i]['price']}',
          'tax': '${irregularProducts[i]['product']['tax']}',
          'unit_id': '${irregularProducts[i]['product']['unit']['id']}',
          'point': '${irregularProducts[i]['product']['point']}'
        };
        category.add(obj);
      }
    }

    String uniqueId = parsedJson['unique'];
    var addresses = parsedJson['addresses'] ?? [];
    int addressIndex = addresses.length == 1 ? 0 : -1;
    String selectedAddress = "请决定一个地址。";

    int deliveryType = 1;
    int deliveryFee = -1;

    if (uniqueId != null) {
      pref.setString('unique', uniqueId);
      Map<String, dynamic> address = parsedJson['address'];
      addressIndex = addresses.indexWhere((element) => element['id'].toString() == address['id'].toString());
      selectedAddress = '${address['area_name']}   ${address['building_name']}';
      delivery = address['delivery'];
      deliveryType = address["delivery_type"] ?? 1;
    } else {
      pref.setString('unique', '');
      if (addressIndex > -1) {
        Map<String, dynamic> address = addresses[addressIndex];
        selectedAddress = '${address['area_name']}   ${address['building_name']}';
        delivery = address['delivery'];
        deliveryType = address["delivery_type"] ?? 1;
      }
    }

    pref.setInt('cartCount', totalProducts.length + irregularProducts.length);

    int purse = parsedJson['purses'][0]['point'];
    List<dynamic> payments = parsedJson['payments'];
    int selectedMethod = 0;

    totalPrice = regularTotal + irregularTotal;
    totalPriceTax = regularTotalTax + irregularTotalTax;

    if (deliveryType == 1) {
      if (delivery == null || delivery['min_price'] == null) {
        deliveryFee = 100;
      } else {
        if (totalPriceTax >= delivery['max_price']) {
          deliveryFee = 0;
        } else {
          deliveryFee = delivery['delivery_fee'];
        }
      }
    }

    int status = 200;  // Assuming status code 200 as success
    bool started = true;

    // Update state
    setState(() {
      this.cartCount = totalProducts.length + irregularProducts.length;
      this.isServerPossibeTime = isServerPossibeTime;
      this.serviceTime = serviceTime;
      this.totalProducts = totalProducts;
      this.irregularProducts = irregularProducts;
      this.userId = userId;
      this.reCounts = reCounts;
      this.irCounts = irCounts;
      this.uniqueId = uniqueId;
      this.addresses = addresses;
      this.regularTotal = regularTotal;
      this.regularTotalTax = regularTotalTax;
      this.irregularTotalTax = irregularTotalTax;
      this.irregularTotal = irregularTotal;
      this.totalPrice = totalPrice;
      this.totalPriceTax = totalPriceTax;
      this.category = category;
      this.irregularWidgets = irregularWidgets;
      this.uniqueIrregularWidgets = uniqueIrregularWidgets;
      this.addressIndex = addressIndex;
      this.selectedAddress = selectedAddress;
      this.deliveryType = deliveryType;
      this.deliveryFee = deliveryFee;
      this.payments = payments;
      this.delivery = delivery;
      this.selected_method = selectedMethod;
      this.purse = purse;
      this.status = status;
      this.started = started;
    });

    _subscription?.cancel();
    initializeFirebase();
  }

  // int buffering = 0;
  // void qtyIrregularUpdate(bool plus, int index) {
  //   if (_debounce?.isActive ?? false) _debounce?.cancel();
  //
  //   Map product = irregularProducts[index];
  //   plus ? buffering++ : buffering--;
  //
  //   // Set a new debounce timer
  //   _debounce = Timer(Duration(milliseconds: 1000), () {
  //     // Call the API after the debounce time has passed
  //     debugPrint("*** Calling Debounce ${buffering}");
  //     if (buffering == 0) return;
  //     http.post(
  //       Uri.parse('$serverUrl/api/qtySet'),
  //       headers: {
  //         'Authorization': pref.getString('token') ?? '',
  //       },
  //       body: {
  //         'cart_id': product['id'].toString(),
  //         'qty': '-1',
  //       },
  //     ).then((response) {
  //       if (response.statusCode == 200) {
  //         pref.setInt("lastApiCallTime", 100);
  //         setState(() {
  //           irCounts[index] = irCounts[index] - 1.0;
  //           irregularTotalTax -= product['product']['retailsales']['retailsale'] * (1 + product['product']['tax']);
  //           irregularTotal -= product['product']['retailsales']['retailsale'];
  //           totalPriceTax = regularTotalTax + irregularTotalTax;
  //         });
  //       } else {
  //         // Handle cases where status code is not 200
  //         print("Failed to update quantity: ${response.statusCode}");
  //       }
  //     }).catchError((error) {
  //       // Handle errors here
  //       print("An error occurred: $error");
  //     });
  //   });
  // }

  Widget irregular(Map e, int index) {
    _irQtyController = TextEditingController(text: '${irCounts[index]}');
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(
                  left: 0, right: 20, top: 10, bottom: 10),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromRGBO(247, 150, 70, 1.0))),
              child: GestureDetector(
                  child: e['product']['images'] != null && e['product']['images'].length > 0
                      ? Image.network(
                      '$serverUrl${environment['image_url']}${e['product']['images'][0]['image_src']}',
                      width: MediaQuery.of(context).size.width * 0.1428)
                      : Image.asset('assets/images/item1.png',
                      width: MediaQuery.of(context).size.width * 0.1428),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              Detail(
                                productId: e['product']['id'],
                                exploringData: const {'id': -1},
                              ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero),
                    );
                  }),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${e['product']['name']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          '${e['product']['retailsales']['retailsale']}円（税抜）',
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              child: Visibility(
                                visible: uniqueId == null,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (irCounts[index] > 1.0) {
                                      final response = await http.post(
                                          Uri.parse('$serverUrl/api/qtyupdate'),
                                          headers: {
                                            'Authorization':
                                            pref.getString('token')
                                          },
                                          body: {
                                            'cart_id': e['id'].toString(),
                                            'qty': '-1'
                                          });
                                      if (response.statusCode == 200) {
                                        pref.setInt("lastApiCallTime", 100);
                                        setState(() {
                                          irCounts[index] = irCounts[index] - 1.0;
                                          irregularTotalTax -= (e['product']['retailsales']['retailsale'])*(1 + e['product']['tax']);
                                          irregularTotal = irregularTotal - e['product']['retailsales']['retailsale'];
                                          totalPriceTax = regularTotalTax + irregularTotalTax;
                                        });
                                      }
                                    }
                                  },
                                  style: ButtonStyle(
                                    minimumSize: MaterialStateProperty.all<Size>(Size(32.0, 32.0)),
                                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(1.0)),
                                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(79, 129, 189, 1.0)),
                                    shape: MaterialStateProperty.all<OutlinedBorder>(
                                      CircleBorder(),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                            // Container(
                            //   alignment: Alignment.center,
                            //   padding: EdgeInsets.fromLTRB(8, 6, 8, 8),
                            //   decoration: BoxDecoration(
                            //     color: (uniqueId == null) ? Colors.white : Colors.grey,
                            //     border: Border.all(width: 2, color: Colors.blueAccent,),
                            //   ),
                            //   child: Text(
                            //     '${irCounts[index]}',
                            //     textAlign: TextAlign.center,
                            //     style: const TextStyle(fontSize: 18),
                            //   ),
                            // ),
                            Container(
                              width: 80,
                              height: 50,
                              alignment: Alignment.center,
                              padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                              decoration: BoxDecoration(
                                color: (uniqueId == null) ? Colors.white : Colors.grey,
                                border: Border.all(width: 2, color: Colors.blueAccent),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Platform.isIOS ? KeyboardActions(
                                  config: _buildConfig(context, e),
                                  child: TextField(
                                    enabled: (uniqueId == null) || uniqueId.isEmpty ,
                                    focusNode: focusNode,
                                    controller: _irQtyController,
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      border: InputBorder.none, // Removes the underline
                                    ),
                                    style: TextStyle(
                                      fontSize: 12, // Adjust the font size to visually align
                                    ),
                                  ),
                                ) : TextField(
                                  enabled: uniqueId == null || uniqueId.isEmpty,
                                  controller: _irQtyController,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  onSubmitted: (String val) {
                                    var irQty = double.tryParse(val) ?? 0.0;
                                    if (irQty > 0) {
                                      http.post(
                                        Uri.parse('$serverUrl/api/qtySet'),
                                        headers: {
                                          'Authorization': pref.getString('token'),
                                        },
                                        body: {
                                          'cart_id': e['id'].toString(),
                                          'qty': irQty.toString(),
                                        },
                                      ).then((response) {
                                        if (response.statusCode == 200) {
                                          pref.setInt("lastApiCallTime", 100);
                                          setState(() {
                                            getCount = 0;
                                          });
                                          initialize();
                                        }
                                      }).catchError((error) {
                                        // Handle error here if needed
                                        print('Error: $error');
                                      });
                                    }
                                  },
                                  style: TextStyle(
                                    fontSize: 14, // Adjust the font size to visually align
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none, // Removes the underline
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              child: Visibility(
                                visible: uniqueId == null,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final response = await http.post(
                                      Uri.parse('$serverUrl/api/qtyupdate'),
                                      headers: {
                                        'Authorization': pref.getString('token'),
                                      },
                                      body: {
                                        'cart_id': e['id'].toString(),
                                        'qty': '1',
                                      },
                                    );
                                    if (response.statusCode == 200) {
                                      pref.setInt("lastApiCallTime", 100);
                                      setState(() {
                                        irCounts[index] = irCounts[index] + 1.0;
                                        irregularTotal += e['product']['retailsales']['retailsale'];
                                        irregularTotalTax += (e['product']['retailsales']['retailsale'])*(1 + e['product']['tax']);
                                        totalPriceTax = regularTotalTax + irregularTotalTax;
                                      });
                                    }
                                  },
                                  style: ButtonStyle(
                                    minimumSize: MaterialStateProperty.all<Size>(Size(32.0, 32.0)),
                                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(1.0)),
                                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(79, 129, 189, 1.0)),
                                    shape: MaterialStateProperty.all<OutlinedBorder>(
                                      CircleBorder(),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8,),
                ],
              ),
            )
          ],
        ),
      ),
      Visibility(
          visible: uniqueId == null,
          child: GestureDetector(
            child: Container(
              padding: EdgeInsets.all(0),
              margin: EdgeInsets.only(top: 15),
              child: Image.asset(
                'assets/images/delete.png',
                width: 18,
              ),
            ),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              '确定要从列表删除此商品吗?',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        final response = await http.delete(
                                          Uri.parse(
                                              '$serverUrl/api/${environment['delete']}/${e['id']}'),
                                          headers: {
                                            'Authorization': pref.getString('token')
                                          },
                                        );
                                        if (response.statusCode == 200) {
                                          pref.setInt("lastApiCallTime", 100);
                                          setState(() {
                                            getCount = 0;
                                          });
                                          initialize();
                                        }
                                        Navigator.pop(context);
                                      },
                                      style: TextButton.styleFrom(backgroundColor: const Color.fromRGBO(247, 150, 70, 1.0)),
                                      child: const Text(
                                        '确定',
                                        style: TextStyle(),
                                      ),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          if (Navigator.canPop(context))
                                            Navigator.pop(context);
                                        },
                                        style: TextButton.styleFrom(backgroundColor: const Color.fromRGBO(247, 150, 70, 1.0,)),
                                        child: const Text('取消')),
                                  ],
                                ))
                          ],
                        ));
                  });
            },
          )
      )
    ]);
  }

  KeyboardActionsConfig _buildConfig(BuildContext context, Map e) {
    return KeyboardActionsConfig(
        keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
        keyboardBarColor: Colors.grey[200],
        nextFocus: true,
        actions: [
          KeyboardActionsItem(focusNode: focusNode, toolbarButtons: [
                (node) {
              return GestureDetector(
                onTap: () async {
                  node.unfocus();

                  var irQty = double.tryParse(_irQtyController.text) ?? 0.0;
                  if (irQty > 0) {
                    http.post(
                      Uri.parse('$serverUrl/api/qtySet'),
                      headers: {
                        'Authorization': pref.getString('token'),
                      },
                      body: {
                        'cart_id': e['id'].toString(),
                        'qty': irQty.toString(),
                      },
                    ).then((response) {
                      if (response.statusCode == 200) {
                        pref.setInt("lastApiCallTime", 100);
                        setState(() {
                          getCount = 0;
                        });
                        initialize();
                      }
                    }).catchError((error) {
                      // Handle error here if needed
                      print('Error: $error');
                    });
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "DONE",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              );
            }
          ])
        ]
    );
  }

  Widget regular(Map e, int index) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(
                  left: 0, right: 20, top: 10, bottom: 10),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromRGBO(247, 150, 70, 1.0))),
              child: GestureDetector(
                  child: e['product']['images'] != null && e['product']['images'].length > 0
                      ? Image.network(
                          '$serverUrl${environment['image_url']}${e['product']['images'][0]['image_src']}',
                          width: MediaQuery.of(context).size.width * 0.1428)
                      : Image.asset('assets/images/item1.png',
                          width: MediaQuery.of(context).size.width * 0.1428),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              Detail(
                                productId: e['product']['id'],
                                exploringData: const {'id': -1},
                              ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero),
                    );
                  }),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${e['product']['name']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          '${e['product']['retailsales']['retailsale']}円（税抜）',
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                                child: Visibility(
                                    visible: uniqueId == null,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (reCounts[index] > 1) {
                                          final response = await http.post(
                                              Uri.parse('$serverUrl/api/qtyupdate'),
                                              headers: {
                                                'Authorization':
                                                pref.getString('token')
                                              },
                                              body: {
                                                'cart_id': e['id'].toString(),
                                                'qty': '-1'
                                              });
                                          if (response.statusCode == 200) {
                                            pref.setInt("lastApiCallTime", 100);
                                            setState(() {
                                              reCounts[index]--;
                                              regularTotal = regularTotal -
                                                  e['product']['retailsales']
                                                  ['retailsale'];
                                              regularTotalTax -= (e['product']['retailsales']['retailsale'])*(1 + e['product']['tax']);
                                              totalPriceTax = regularTotalTax + irregularTotalTax;
                                            });
                                          }
                                        }
                                      },
                                      style: ButtonStyle(
                                        minimumSize: MaterialStateProperty.all<Size>(Size(32.0, 32.0)),
                                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(1.0)),
                                        backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(79, 129, 189, 1.0)),
                                        shape: MaterialStateProperty.all<OutlinedBorder>(
                                          CircleBorder(),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.remove,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.fromLTRB(8, 6, 8, 8),
                              decoration: BoxDecoration(
                                color: (uniqueId == null) ? Colors.white : Colors.grey,
                                border: Border.all(width: 2, color: Colors.blueAccent,),
                              ),
                              child: Text(
                                '${reCounts[index]}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            Container(
                              child: Visibility(
                                visible: uniqueId == null,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final response = await http.post(
                                      Uri.parse('$serverUrl/api/qtyupdate'),
                                      headers: {
                                        'Authorization': pref.getString('token'),
                                      },
                                      body: {
                                        'cart_id': e['id'].toString(),
                                        'qty': '1',
                                      },
                                    );
                                    if (response.statusCode == 200) {
                                      pref.setInt("lastApiCallTime", 100);
                                      setState(() {
                                        reCounts[index]++;
                                        regularTotal += e['product']['retailsales']['retailsale'];
                                        regularTotalTax += (e['product']['retailsales']['retailsale'])*(1 + e['product']['tax']);
                                        totalPriceTax = regularTotalTax + irregularTotalTax;
                                      });
                                    }
                                  },
                                  style: ButtonStyle(
                                    minimumSize: MaterialStateProperty.all<Size>(Size(32.0, 32.0)),
                                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(1.0)),
                                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(79, 129, 189, 1.0)),
                                    shape: MaterialStateProperty.all<OutlinedBorder>(
                                      CircleBorder(),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      Visibility(
          visible: uniqueId == null,
          child: GestureDetector(
        child: Container(
          padding: EdgeInsets.all(0),
          margin: EdgeInsets.only(top: 15),
          child: Image.asset(
            'assets/images/delete.png',
            width: 18,
          ),
        ),
        onTap: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '确定要从列表删除此商品吗?',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    final response = await http.delete(
                                      Uri.parse(
                                          '$serverUrl/api/${environment['delete']}/${e['id']}'),
                                      headers: {
                                        'Authorization': pref.getString('token')
                                      },
                                    );
                                    if (response.statusCode == 200) {
                                      pref.setInt("lastApiCallTime", 100);
                                      setState(() {
                                        getCount = 0;
                                      });
                                      initialize();
                                    }
                                    Navigator.pop(context);
                                  },
                                  style: TextButton.styleFrom(backgroundColor: const Color.fromRGBO(247, 150, 70, 1.0)),
                                  child: const Text(
                                    '确定',
                                    style: TextStyle(),
                                  ),
                                ),
                                TextButton(
                                    onPressed: () {
                                      if (Navigator.canPop(context))
                                        Navigator.pop(context);
                                    },
                                    style: TextButton.styleFrom(backgroundColor: const Color.fromRGBO(247, 150, 70, 1.0,)),
                                    child: const Text('取消')),
                              ],
                            ))
                      ],
                    ));
              });
        },
      )
      )
    ]);
  }

  Widget list(bool isRegular, BuildContext context) {
    if (!isRegular) {
      irregularWidgets = irregularProducts.map((e) => irregular(e, irregularProducts.indexOf(e))).toList();
      return buildContainerWithBorder(irregularWidgets, context, marginTop: 10);
    } else {
      regularWidgets = totalProducts.map((e) => regular(e, totalProducts.indexOf(e))).toList();
      if (regularWidgets.isNotEmpty) {
        regularWidgets.add(buildRegularTotalWidget(context));
      }
      return buildContainerWithBorder(regularWidgets, context, marginTop: 30);
    }
  }

  Widget buildRegularTotalWidget(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Text('小计 :  ${regularTotal.toInt()} 円（税抜）\n            ${regularTotalTax.toInt()} 円（税込）', style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold),),
    );
  }

  void updateAddressInfo() {
    var deliveryFee = 0;
    var deliveryType = -1;
    var delivery = null;
    var selectedAddress = '请决定一个地址.';

    if (addressIndex > -1) {
      var address = addresses[addressIndex];
      selectedAddress = '${address['area_name']}   ${address['building_name']}';
      delivery = address['delivery'];
      deliveryType = address['delivery_type'] ?? 0;
      if (deliveryType == 1) {
        if (delivery == null || delivery['min_price'] == null) {
          deliveryFee = 10;
        } else {
          if (totalPriceTax >= delivery['max_price']) {
            deliveryFee = 0;
          } else {
            deliveryFee = delivery['delivery_fee'];
          }
        }
      } else {
        deliveryFee = 0;
      }
    } else {
      deliveryType = -1;
      deliveryFee = 0;
      delivery = null;
    }

    setState(() {
      this.delivery = delivery;
      this.deliveryFee = deliveryFee;
      this.deliveryType = deliveryType;
      this.selectedAddress = selectedAddress;
    });
  }

  Widget buildContainerWithBorder(List<Widget> tempWidgets, BuildContext context,
      {double marginTop = 7}) {
    return Container(
      margin: EdgeInsets.only(right: 0, left: 0, top: marginTop, bottom: 10),
      decoration: BoxDecoration(
        border: tempWidgets.isNotEmpty
            ? Border(bottom: BorderSide(color: Color.fromRGBO(247, 150, 70, 1.0), width: 2, style: BorderStyle.solid,),)
            : Border(),
      ),
      child: Column(children: tempWidgets,),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        initialData: true,
        future: initialize(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          final loadingWidget = Scaffold(
            backgroundColor: Colors.white,
            appBar: buildAppBar(),
            body: Center(child: Image.asset('assets/images/animated_loading.gif'),),
            bottomNavigationBar: BottomNav(pageName: 'cart'),
          );

          if (snapshot.hasData && snapshot.data == true) {
            if (status == 200) {
              if (totalProducts.length == 0 && irregularProducts.length == 0) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  appBar: buildAppBar(),
                  body: Center(child: Text('您的購物車中沒有產品'),),
                  bottomNavigationBar: BottomNav(pageName: 'mainCart',),
                );
              }
              return Scaffold(
                body: Stack(
                  children: [
                    Scaffold(
                      backgroundColor: Colors.white,
                      appBar: buildAppBar(),
                      body: Column(children: [
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 15),
                            children: [
                              Table(
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: <TableRow>[
                                  TableRow(
                                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Color.fromRGBO(247, 150, 70, 1.0), width: 2, style: BorderStyle.solid,)),),
                                      children: [
                                        Text('收获地址：', style: TextStyle(fontSize: 13),),
                                        Container(
                                            alignment: Alignment.centerRight,
                                            height: MediaQuery.of(context).size.height * 0.08,
                                            child: GestureDetector(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: addresses.length == 0 ? Text('地址尚未登录,请在【我的 -> 地址】中输入地址。输入地址后发生审查业务，审查需要1天以内的时间。',
                                                        style: TextStyle(color: Colors.redAccent, fontSize: 12),
                                                        textAlign: TextAlign.left,
                                                      )
                                                          : addresses.length == 1 ? Text('${addresses[0]['area_name']}   ${addresses[0]['building_name']}', textAlign: TextAlign.right)
                                                          : Text(selectedAddress, textAlign: TextAlign.right, style: TextStyle(color: Colors.black26),),
                                                    ),
                                                    (addresses.length > 1 && uniqueId == null)
                                                        ? Icon(Icons.arrow_forward_ios, color: Colors.deepOrangeAccent,)
                                                        : Container(),
                                                  ],
                                                ),
                                                onTap: () async {
                                                  if (uniqueId != null) return;
                                                  if (addresses.length > 1) {
                                                    addressIndex = await showDialog<int>(context: context,
                                                        builder: (BuildContext ctx) {return JudgeAddress(addr_info: addresses, flag: addressIndex);});
                                                    updateAddressInfo();
                                                  }
                                                }))
                                      ]),
                                  TableRow(
                                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.deepOrangeAccent, width: 2, style: BorderStyle.solid,))),
                                      children: [
                                        Text('到货时段：', style: TextStyle(fontSize: 13),),
                                        Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.symmetric(horizontal: 5),
                                          height: MediaQuery.of(context).size.height * 0.08,
                                          child: Text('今天  13 ： 00  - 18 ： 00',),
                                        )
                                      ]),
                                ],
                                columnWidths: {0: FractionColumnWidth(0.2)},
                              ),
                              list(true, context),
                              list(false, context),
                              Table(
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: <TableRow>[
                                  if (irregularProducts.isNotEmpty)
                                    TableRow(
                                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.deepOrangeAccent, width: 2, style: BorderStyle.solid))),
                                      children: [
                                        TableCell(
                                          child: Text('', style: TextStyle(fontSize: 13)),
                                        ),
                                        TableCell(
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            height: MediaQuery.of(context).size.height * 0.08,
                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                            child: Row(
                                              children: [
                                                Spacer(flex: 3),
                                                Text('不规则小计:  ${irregularTotal.toInt()} 円（税抜）\n                      ${irregularTotalTax.toInt()} 円（税込）', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                                Spacer(flex: 1),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  TableRow(
                                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.deepOrangeAccent, width: 2, style: BorderStyle.solid))),
                                    children: [
                                      TableCell(
                                        child: Text('', style: TextStyle(fontSize: 13)),
                                      ),
                                      TableCell(
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          height: MediaQuery.of(context).size.height * 0.06,
                                          padding: EdgeInsets.symmetric(horizontal: 5),
                                          child: Row(
                                            children: [
                                              Text(
                                                '总织分:   ${purse} 分',
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                              Spacer(flex: 2),
                                              Text(
                                                '使用: ',
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical padding (adjust as needed)
                                                  child: TextFormField(
                                                    controller: _pointController, // Use controller to manage the value
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(),
                                                    ),
                                                    keyboardType: TextInputType.number,
                                                    onChanged: (value) {
                                                      // Parse the input value to an integer, use 0 if parsing fails
                                                      usePoints = int.tryParse(value) ?? 0;

                                                      // Calculate the maximum points allowed based on totalPriceTax and deliveryFee
                                                      int maxPointsByTotal = (totalPriceTax + deliveryFee).toInt();

                                                      // Determine the minimum between maxPointsByTotal and purse
                                                      int minPoints = maxPointsByTotal < purse ? maxPointsByTotal : purse;

                                                      // Ensure usePoints doesn't exceed the calculated minPoints
                                                      if (usePoints > minPoints) {
                                                        _pointController.text = minPoints.toString();
                                                        _pointController.selection = TextSelection.fromPosition(
                                                          TextPosition(offset: _pointController.text.length),
                                                        );
                                                      }

                                                      // Update usePoints with the final value after comparison
                                                      setState(() {
                                                        usePoints = int.parse(_pointController.text);
                                                      });
                                                    },
                                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              Spacer(flex: 1),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.deepOrangeAccent, width: 2, style: BorderStyle.solid))),
                                    children: [
                                      TableCell(
                                        child: Text('', style: TextStyle(fontSize: 13)),
                                      ),
                                      TableCell(
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          height: MediaQuery.of(context).size.height * 0.06,
                                          padding: EdgeInsets.symmetric(horizontal: 5),
                                          child: Row(
                                            children: [
                                              Spacer(flex: 1),
                                              Text(deliveryType == 1 && delivery != null ? '最小订单${delivery['min_price']}円\n${delivery['max_price']}円免邮费' : "",
                                                textAlign: TextAlign.right,
                                                style: TextStyle(fontSize: 12, color: Colors.black38),
                                              ),
                                              Spacer(flex: 1),
                                              Text('邮费:   ${deliveryFee == null || deliveryFee < 0 ? 0 : deliveryFee} 円', style: Theme.of(context).textTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                              Spacer(flex: 1),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.deepOrangeAccent, width: 2, style: BorderStyle.solid))),
                                    children: [
                                      TableCell(
                                        child: Text('', style: TextStyle(fontSize: 13)),
                                      ),
                                      TableCell(
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          height: MediaQuery.of(context).size.height * 0.06,
                                          padding: EdgeInsets.symmetric(horizontal: 5),
                                          child: Row(
                                            children: [
                                              Spacer(flex: 3),
                                              Text('说计:   ${(totalPriceTax + deliveryFee).toInt()} 円', style: Theme.of(context).textTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                              Spacer(flex: 1),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                columnWidths: {0: FractionColumnWidth(0.2)},
                              ),
                            ],
                          ),
                        ),
                        cartErrMessage.isNotEmpty && (uniqueId != null)
                            ? Container(
                                alignment: Alignment.center,
                                height: 90,
                                decoration: BoxDecoration(color: Colors.red),
                                child: Text(cartErrMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.white),),
                                margin: EdgeInsets.all(3),)
                            : Container(),
                        Container(
                            color: Color.fromRGBO(247, 150, 70, 1.0),
                            alignment: Alignment.bottomCenter,
                            height: MediaQuery.of(context).size.height * 0.07,
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                // Expanded(child: Container()),
                                GestureDetector(
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    width: MediaQuery.of(context).size.width * 0.45,
                                    decoration: BoxDecoration(
                                        color: payBtnColor,
                                        borderRadius:
                                            BorderRadius.circular(5)),
                                    child: Center(
                                      child: Text(
                                        payBtnTitle,
                                        style: TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 2),
                                      ),
                                    ),
                                  ),
                                  onTap: () async {

                                    // final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
                                    // final paymentUrl = await payPayService.createPayment(1000, orderId);
                                    //
                                    // if (paymentUrl != null) {
                                    //   bool canLaunchUrl = await canLaunchUrl(paymentUrl);
                                    //
                                    //   if (canLaunchUrl) {
                                    //     await launch(paymentUrl);
                                    //   } else {
                                    //     print('Could not launch $paymentUrl');
                                    //   }
                                    // } else {
                                    //   print('Failed to create payment');
                                    // }

                                    if (payBtnColor == Colors.grey) return;
                                    if (uniqueId == null || uniqueId.isEmpty) {
                                      await updateCartForChats();
                                      return;
                                    }
                                    if (uniqueId != null && uniqueId.isNotEmpty && cartErrMessage.isEmpty) {
                                      debugPrint("*** Delivery = ${delivery}");
                                      debugPrint("*** Cost = ${totalPriceTax}");
                                      final String deliveryMethod = deliveryType == 1 ? "京和" : "Yamato";
                                      // if (deliveryType == 1 && totalPriceTax < delivery['min_price']) {
                                      //   showDialog(
                                      //       context: context,
                                      //       builder: (BuildContext Dialogcontext) {
                                      //         return AlertDialog(
                                      //           content: Text('您的费用低于最低运送金额。', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyText1),
                                      //           actions: [
                                      //             Container(
                                      //               margin: EdgeInsets.fromLTRB(0, 0, 100, 0),
                                      //               padding: EdgeInsets.all(5.0),
                                      //               child: TextButton(
                                      //                 onPressed: () async {
                                      //                   Navigator.pop(Dialogcontext);
                                      //                 },
                                      //                 child: const Text('知道了', style: TextStyle(color: Colors.white),),
                                      //                 style: TextButton.styleFrom(
                                      //                   backgroundColor: Colors.redAccent,
                                      //                   shape: RoundedRectangleBorder(
                                      //                     borderRadius: BorderRadius.circular(4.0),
                                      //                   ),
                                      //                 ),
                                      //               ),
                                      //             )
                                      //           ],
                                      //         );
                                      //       });
                                      //   return;
                                      // }
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext Dialogcontext) {
                                            return AlertDialog(
                                              content: Text('$deliveryMethod 运费是: $deliveryFee円\n你可以支付了.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyText1),
                                              actions: [
                                                Container(
                                                  margin: EdgeInsets.fromLTRB(0, 0, 100, 0),
                                                  padding: EdgeInsets.all(5.0),
                                                  child: TextButton(
                                                    onPressed: () async {
                                                      Navigator.pop(Dialogcontext);
                                                      final double price = totalPriceTax + deliveryFee - usePoints;
                                                      final payway = await showDialog<int>(
                                                        context: context,
                                                        builder: (BuildContext ctx) {
                                                          return payDialog(payBank: payments, price: price);
                                                        },
                                                      );
                                                      await processPayment(payway);
                                                    },
                                                    child: const Text('知道了', style: TextStyle(color: Colors.white),),
                                                    style: TextButton.styleFrom(
                                                      backgroundColor: Colors.redAccent,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(4.0),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            );
                                          });
                                    }
                                  },
                                ),
                                Expanded(child: Container()),
                              ],
                            )),
                        Container(height: 0,)
                      ]),
                      bottomNavigationBar: BottomNav(pageName: 'cart', cartCount: cartCount),
                      floatingActionButton: (addresses != null && addresses.length > 0)
                          ? Stack(
                        clipBehavior: Clip.none, // Allow the red dot to overflow the Stack bounds
                        children: [
                          FloatingActionButton(
                            onPressed: () async {
                              isNewMsg = false;
                              bool hasPermission = await checkPermission();
                              if (hasPermission) {
                                if (uniqueId != null) {
                                  setState(() {
                                    tflag = false;
                                  });
                                } else {
                                  uniqueId = null;
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext dialogContext) {
                                        return AlertDialog(
                                          content: Text(
                                            '提交订单后可以联系客服。',
                                            style: Theme.of(context).textTheme.bodyText1,
                                          ),
                                          actions: [
                                            Container(
                                              margin: EdgeInsets.fromLTRB(0, 0, 100, 0),
                                              padding: EdgeInsets.all(5.0),
                                              child: TextButton(
                                                onPressed: () {
                                                  Navigator.pop(dialogContext);
                                                },
                                                child: const Text(
                                                  '确定',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                                style: TextButton.styleFrom(
                                                  backgroundColor: myBlueColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(4.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      });
                                }
                              } else {
                                print('now it is time to check permission for microphone');
                              }
                            },
                            tooltip: 'Make a Call',
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: myBlueColor,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/servicecall.png',
                                  width: 35,
                                ),
                                SizedBox(height: 4), // Space between the image and text
                                Text(
                                  '在线客服',
                                  style: TextStyle(
                                    fontSize: 10, // Text size
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isNewMsg) // Show red dot only when isNewMsg is true
                            Positioned(
                              right: 0, // Position at top right of the button
                              top: -4, // Slightly above to center it on the corner
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.blue, // Red dot color
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      )
                          : null,
                    ),
                    Positioned(
                      bottom: 0, // adjust the position of the widget using the height of the keyboard
                      child: tflag
                          ? Container()
                          : Container(
                              width: MediaQuery.of(context).size.width,
                              height: height,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(6.0), topRight: Radius.circular(6.0),),
                                  border: Border.all(color: Colors.blue, width: 2, style: BorderStyle.solid)),
                              child: Material(
                                  child: Column(children: [
                                Container(
                                  color: myBlueColor,
                                  height: 50,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.45,),
                                      Container(child: Text('客服', style: TextStyle(fontSize: 20, color: Colors.white,),), padding: EdgeInsets.only(bottom: 6),),
                                      Spacer(flex: 1,),
                                      Container(
                                        padding: EdgeInsets.only(right: 15),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            GestureDetector(
                                              child: Container(
                                                decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2.0)),
                                                child: SizedBox(width: 15, height: 15,),
                                              ),
                                              onTap: () => {
                                                setState(() {
                                                  height = flag ? MediaQuery.of(context).size.height * 0.65 : MediaQuery.of(context).size.height * 0.9;
                                                  flag = !flag;
                                                })
                                              },
                                            ),
                                            SizedBox(width: 15,),
                                            GestureDetector(
                                              child: Icon(Icons.clear, size: 30, color: Colors.white,),
                                              onTap: () => {
                                                setState(() {
                                                  tflag = true;
                                                })
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(child: Chatting(receiver: uniqueId, flag: tflag, info: pref.getString('token')),)
                              ]))),
                    ),
                  ],
                ),
              );
            } else {
              if (started == false) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  appBar: buildAppBar(),
                  body: Center(child: Image.asset('assets/images/animated_loading.gif')),
                  bottomNavigationBar: BottomNav(pageName: 'mainCart'),
                );
              } else {
                debugPrint("*** Failed = $status");
                if (status == null) {
                  return Scaffold(
                    backgroundColor: Colors.white,
                    appBar: buildAppBar(),
                    body: Center(child: Text('您的購物車中沒有產品'),),
                    bottomNavigationBar: BottomNav(pageName: 'mainCart',),
                  );
                } else {
                  return Scaffold(
                    backgroundColor: Colors.white,
                    appBar: buildAppBar(),
                    body: status == 404 ? _buildErrorMessage('You can\'t connect to the server. There is a problem with the server')
                        : status == 500
                        ? _buildErrorMessage('No response to your request. Try it again, please.')
                        : Center(child: Image.asset('assets/images/animated_loading.gif')),
                    bottomNavigationBar: BottomNav(pageName: 'mainCart'),
                  );
                }
              }
            }
          } else {
            debugPrint("*** Loading Widget = $snapshot");
            return loadingWidget;
          }
        });
  }

  Widget _buildErrorMessage(String message) {
    return Center(child: Text(message, style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.w200),),);
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      shadowColor: Colors.transparent,
      backgroundColor: Color.fromRGBO(247, 150, 70, 1.0),
      title: Text("购物车", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
      centerTitle: true,
    );
  }

  IconButton buildCallButton() {
    return IconButton(
      icon: Stack(
        children: [
          Icon(Icons.call, size: 28),
        ],
      ),
      onPressed: () async {
          isNewMsg = false;
          bool hasPermission = await checkPermission();
          if (hasPermission) {
            if (uniqueId != null) {
              setState(() {
                tflag = false;
              });
            } else {
              uniqueId = null;
              showDialog(
                  context: context,
                  builder: (BuildContext Dialogcontext) {
                    return AlertDialog(
                      content: Text('提交订单后可以联系客服。', style: Theme.of(context).textTheme.bodyText1),
                      actions: [
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 100, 0),
                          padding: EdgeInsets.all(5.0),
                          child: TextButton(
                            onPressed: () async {
                              Navigator.pop(Dialogcontext);
                            },
                            child: const Text('确定', style: TextStyle(color: Colors.white),),
                            style: TextButton.styleFrom(
                              backgroundColor: myBlueColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  });
            }
          } else {
            print('now it is time to check permission for microphone');
          }
      },
    );
  }

  Future<void> updateCartForChats() async {
    if (addressIndex < 0 || addresses.length < 1) {
      Utility.showAlertDialog(context, "警报", "请选择您的地址。", null);
      return;
    }
    Map address = addresses[addressIndex];
    var delivery = address['delivery'];
    if (address['delivery_type']  == 1 && delivery != null && delivery['min_price'] != null && totalPriceTax < delivery['min_price']) {
      Utility.showAlertDialog(context, "警报", "您至少应该按最低交货价格购买。", null);
      return;
    }

    try {
      final res = await http.post(
        Uri.parse(serverUrl + '/api/' + environment['createChat']),
        headers: {
          'Authorization': pref.getString('token'),
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'address_id': address['id'].toString()}),
      );

      if (res.statusCode == 200) {
        setState(() {
          uniqueId = jsonDecode(res.body)['unique'].toString();
          if (uniqueId != null) {
            DatabaseReference ref1 = FirebaseDatabase.instance.ref('$dbProduct');
            ref1.update({"isAssigned": DateTime.now().millisecondsSinceEpoch});
          }
          getCount = 0;
        });
        pref.setString('unique', uniqueId);
        pref.setInt("lastApiCallTime", 100);
        initialize();
      } else {
        uniqueId = null;
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> processPayment(int payway) async {
    if (addressIndex < 0 || addresses.length <1)
      return;
    if (payway > -1) {
      setState(() {
        payMethod = payments[payway]['name'];
      });
      pref..setInt('cartCount', 0);
      try {
        final http.Response res = await http.post(
          Uri.parse('$serverUrl/api/${environment['store']}'),
          headers: {
            'Authorization': pref.getString('token'),
            'Content-type': 'application/json',
          },
          body: jsonEncode({
            "address_id": "${addresses[addressIndex]['id']}",
            "payment_id": "${payments[payway]['id']}",
            "delivery_method": "${delivery == null ? 0 : delivery['id']}",
            "delivery_type": "$deliveryType",
            "freight": "$deliveryFee",
            "point": "$usePoints",
            "products": category,
            "unique": uniqueId,
          }),
        );
        if (res.statusCode == 200) {
          DatabaseReference ref = FirebaseDatabase.instance.ref('products/' + uniqueId.toString() + "/data");
          pref.setString('unique', '');
          ref.update({"paid": true});
          pref.setInt("lastApiCallTime", 100);
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => mainHome(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        } else {
          debugPrint("*** res = ${res.statusCode}");
          showDialog(
            context: context,
            builder: (BuildContext Dialogcontext) {
              return AlertDialog(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Failed to Order",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: () { Navigator.pop(Dialogcontext); },
                            child: Text(
                              'Ok',
                              style: Theme.of(context).textTheme.bodyText2.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: myBlueColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0),),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        }
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    await Permission.photos.request().isGranted;
    await Permission.storage.request().isGranted;
    return true;
  }
}
