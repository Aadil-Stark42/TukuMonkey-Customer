import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gdeliverycustomer/apiservice/EndPoints.dart';
import 'package:gdeliverycustomer/locationpicker/src/place_picker.dart';
import 'package:gdeliverycustomer/res/ResColor.dart';
import 'package:gdeliverycustomer/ui/home/HomeScreen.dart';
import 'package:gdeliverycustomer/utils/LocalStorageName.dart';
import 'package:permission_handler/permission_handler.dart' as permis;
import 'package:shared_preferences/shared_preferences.dart';

import '../../apiservice/ApiService.dart';
import '../../apiservice/EndPoints.dart';
import '../../res/ResString.dart';
import '../../uicomponents/MyProgressBar.dart';
import '../../uicomponents/progress_button.dart';
import '../../utils/Utils.dart';
import '../order/OrderSummaryScreen.dart';

class SelectAddressScreen extends StatefulWidget {
  final bool IsJustChangeAddress;
  final String GstPer;
  final bool IsForCart;

  SelectAddressScreen(this.IsJustChangeAddress, this.GstPer, this.IsForCart);

  @override
  SelectAddressScreenState createState() => SelectAddressScreenState();
}

class SelectAddressScreenState extends State<SelectAddressScreen> {
  bool IsSelected = false;
  List<dynamic>? list;
  List<String> radioValues = [];
  ButtonState buttonState = ButtonState.normal;

  int val = -1;
  String ClickedImage = "${imagePath}unselect_button.png";
  int selectedIndex = 0;
  String SelectedAddressId = "";

  @override
  void initState() {
    super.initState();
    GetAddressList();
  }

  static final kInitialPosition = LatLng(-33.8567844, 151.213108);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                  pinned: false,
                  backgroundColor: whiteColor,
                  floating: true,
                  snap: false,
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(),
                  elevation: 0.5,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset(
                          imagePath + "ic_back2.png",
                          width: 30,
                          height: 30,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        SelectAddress,
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: Inter_bold,
                            color: darkMainColor2),
                      ),
                    ],
                  ),
                  actions: [
                    GestureDetector(
                      onTap: () async {
                        final serviceStatusLocation =
                            await permis.Permission.locationWhenInUse.isGranted;
                        bool isLocation = serviceStatusLocation ==
                            permis.ServiceStatus.enabled;
                        final status =
                            await permis.Permission.locationWhenInUse.request();
                        if (status == permis.PermissionStatus.granted) {
                          print('Permission Granted');
                          OpenLocationPicker();
                        } else {
                          print('Permission denied');
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add,
                            color: darkMainColor2,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            AddAddress,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: Segoe_ui_semibold,
                              color: darkMainColor2,
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    )
                  ]),
              SliverList(
                  delegate: SliverChildListDelegate([
                HandleAddressListView(),
              ]))
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Container(
            color: mainColor,
            height: 45,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: ProgressButton(
                child: Text(
                  CONTINUE,
                  style: TextStyle(
                    color: whiteColor,
                    fontFamily: Segoe_ui_semibold,
                    height: 1.1,
                  ),
                ),
                onPressed: () {
                  if (widget.IsJustChangeAddress == false) {
                    if (SelectedAddressId.isNotEmpty) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                          (Route<dynamic> route) => false);
                    } else {
                      ShowToast("Please Pick Address", context);
                    }
                  } else {
                    if (widget.IsForCart) {
                      Navigator.of(context, rootNavigator: true)
                          .push(MaterialPageRoute(
                        builder: (context) => OrderSummaryScreen(
                            widget.GstPer,
                            list![selectedIndex][address_id].toString(),
                            list![selectedIndex][address].toString()),
                      ));
                    } else {
                      Navigator.pop(context);
                    }
                  }
                },
                buttonState: buttonState,
                backgroundColor: mainColor,
                progressColor: whiteColor,
                border_radius: Full_Rounded_Button_Corner,
              ),
            ),
          )),
    );
  }

  Future<void> GetAddressList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var header = <String, dynamic>{};
    String? token = prefs.getString(TOKEN);
    header[Authorization] = Bearer + token.toString();
    print("HEADERSSS${header.toString()}");
    var ApiCalling = GetApiInstanceWithHeaders(header);
    Response response;
    response = await ApiCalling.get(ADDRESS_LIST);
    setState(() {
      if (response.data[status]) {
        print("responseresponse${response.data.toString()}");
        list = response.data[address_list];
        if (prefs.getString(SELECTED_ADDRESS_ID) != null) {
          for (var i = 0; i < list!.length; i++) {
            if (list![i][address_id].toString() ==
                prefs.getString(SELECTED_ADDRESS_ID)) {
              selectedIndex = i;
              SetSelectedIndex(selectedIndex);
              break;
            }
          }
        } else {
          SetSelectedIndex(0);
        }

        print(list);
      } else {
        ShowToast(response.data[MESSAGE], context);
      }
    });
  }

  void SetSelectedIndex(int index) async {
    print("SetSelectedIndexSetSelectedIndex");
    print("index$index");
    print("list${list![index][address]}");
    setState(() {
      selectedIndex = index;
    });
    SelectedAddressId = list![index][address_id].toString();
    if (widget.IsForCart == false) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(SELECTED_ADDRESS_ID, list![index][address_id].toString());
      prefs.setString(SELECTED_ADDDRESS, list![index][address].toString());
      prefs.setString(SELECTED_ADDDRESS_TYPE, list![index][type].toString());
      prefs.setString(SELECTED_LATITUDE, list![index][latitude].toString());
      prefs.setString(SELECTED_LONGITUDE, list![index][longitude].toString());
      print("longitude${list![index][longitude].toString()}");
    }
  }

  Future<void> OpenLocationPicker() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacePicker(
          apiKey: Platform.isAndroid ? MAP_API_KEY : "YOUR IOS API KEY",
          onPlacePicked: (result) {
            print(result.formattedAddress);
            Navigator.pop(context);
            GetAddressList();
          },
          IsComeFromHome: false,
          initialPosition: const LatLng(-33.8567844, 151.213108),
          useCurrentLocation: true,
        ),
      ),
    );
  }

  Widget HandleAddressListView() {
    Size size = MediaQuery.of(context).size;
    if (list != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              DeliveryCharges,
              style: TextStyle(
                fontSize: 12,
                fontFamily: Segoe_ui_semibold,
                color: blackColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: list!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                        onTap: () {
                          SetSelectedIndex(index);
                        },
                        child: Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {},
                                        child: Image.asset(
                                          selectedIndex == index
                                              ? "${imagePath}select_button.png"
                                              : "${imagePath}unselect_button.png",
                                          height: 30,
                                          width: 30,
                                          color: greyColor,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              list![index][type],
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontFamily: Inter_medium,
                                                fontWeight: FontWeight.bold,
                                                color: blackColor,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              list![index][address],
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: Inter_medium,
                                                color: blackColor,
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 0.1,
                                  color: greyColor,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        Remove,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: Segoe_bold,
                                          color: mainColor,
                                        ),
                                      ),
                                      Text(
                                        EditAddress,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontFamily: Segoe_bold,
                                          color: mainColor,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 0.1,
                                  color: greyColor,
                                ),
                              ],
                            )) //your content here
                        );
                  },
                ),
              ],
            ),
          )
        ],
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(top: size.height / 2.7),
        child: MyProgressBar(),
      );
    }
  }
}
