import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:gdeliverycustomer/apiservice/EndPoints.dart';
import 'package:gdeliverycustomer/models/CartDataModel.dart';
import 'package:gdeliverycustomer/models/SlotsDataModel.dart';
import 'package:gdeliverycustomer/res/ResColor.dart';
import 'package:gdeliverycustomer/utils/LocalStorageName.dart';
import 'package:gdeliverycustomer/utils/LowerCaseTextFormatter.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../apiservice/ApiService.dart';
import '../../../apiservice/EndPoints.dart';
import '../../../res/ResString.dart';
import '../../../uicomponents/MyProgressBar.dart';
import '../../../uicomponents/progress_button.dart';
import '../../../uicomponents/rounded_input_field.dart';
import '../../../utils/UpperCaseTextFormatter.dart';
import '../../../utils/Utils.dart';
import '../../address/SelectAddressScreen.dart';
import '../HomeScreen.dart';

class CartSubScreen extends StatefulWidget {
  final bool IstitleShow;
  final bool IsComeFromHome;
  final VoidCallback ContinueShopingClick;

  CartSubScreen(
      this.IstitleShow, this.IsComeFromHome, this.ContinueShopingClick);

  @override
  CartSubScreenState createState() => CartSubScreenState();
}

class CartSubScreenState extends State<CartSubScreen> {
  bool DataVisible = false;
  CartDataModel cartDataModel = CartDataModel();
  ButtonState buttonState = ButtonState.normal;
  String Instrucvalue = "";
  String CouponValue = "";
  String dropdownvalue = 'Select';
  String slotsId = '';
  bool isClickCouponAplly = false;

  @override
  void initState() {
    super.initState();
    GetCartList(000);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: whiteColor,
        body: CartMainview(),
      ),
    );
  }

  Future<void> GetCartList(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var header = <String, dynamic>{};
    String? token = prefs.getString(TOKEN);
    header[Authorization] = Bearer + token.toString();
    print("HEADERSSS${header.toString()}");

    var Params = <String, dynamic>{};
    Params[device_id] = prefs.getString(DEVICE_ID);
    Params[address_id] = prefs.getString(SELECTED_ADDRESS_ID);

    print("ParamsParamsParams${Params.toString()}");
    var ApiCalling = GetApiInstanceWithHeaders(header);

    Response response;
    response = await ApiCalling.post(CARTDATA, data: Params);

    setState(() {
      DataVisible = true;
      if (index != 000) {
        cartDataModel.products![index].isPlusLoading = false;
        cartDataModel.products![index].isMinusLoading = false;
      }
      cartDataModel = CartDataModel.fromJson(response.data);
      if (response.data[status] != true) {
        cartDataModel.status = false;
        ShowToast(response.data[message].toString(), context);
      }
      if (cartDataModel.products == null || cartDataModel.products!.isEmpty) {
        cartDataModel.status = false;
      }
      if (isClickCouponAplly) {
        if (cartDataModel.couponDiscount.toString() != "0.00") {
          showCouponDialog();
        }
      }

      print("responseresponseresponse${response.toString().toString()}");
      print("cartDataModel.products!.length${cartDataModel.status}");
    });
  }

  Widget CartProductList() {
    return ListView.builder(
        itemCount: cartDataModel.products!.length,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Column(
                          children: [
                            Text(
                              cartDataModel.products![index].productName
                                  .toString(),
                              style: TextStyle(
                                fontFamily: Segoeui,
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                                height: 1.0,
                                color: darkMainColor2,
                              ),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Visibility(
                              visible: cartDataModel.products![index].size
                                          .toString() ==
                                      " "
                                  ? false
                                  : true,
                              child: Text(
                                cartDataModel.products![index].size.toString(),
                                style: TextStyle(
                                  fontFamily: Segoe_ui_semibold,
                                  fontSize: 11,
                                  height: 1.0,
                                  color: greyColor,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  )),

                  Text(
                    "₹${cartDataModel.products![index].amount.toString()}",
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: Segoe_ui_semibold,
                        color: darkMainColor),
                  ),
                  SizedBox(
                    width: 60,
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        splashColor: greyColor,
                        onTap: () {
                          setState(() {
                            cartDataModel.products![index].isMinusLoading =
                                true;
                          });
                          AddOrRemoveProduct(
                              cartDataModel.products![index].cartProductId
                                  .toString(),
                              "-1",
                              index);
                        },
                        child: cartDataModel.products![index].isMinusLoading ==
                                false
                            ? Image.asset(
                                imagePath + "ic_minus.png",
                                width: 20,
                                height: 20,
                              )
                            : SizedBox(
                                width: 20,
                                height: 20,
                                child: SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 1, color: mainColor),
                                )),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        cartDataModel.products![index].quantity.toString(),
                        style: TextStyle(
                            fontSize: 13,
                            fontFamily: Poppinsmedium,
                            color: blackColor),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        splashColor: greyColor2,
                        onTap: () {
                          setState(() {
                            cartDataModel.products![index].isPlusLoading = true;
                          });
                          AddOrRemoveProduct(
                              cartDataModel.products![index].cartProductId
                                  .toString(),
                              "1",
                              index);
                        },
                        child: cartDataModel.products![index].isPlusLoading ==
                                false
                            ? Image.asset(
                                imagePath + "ic_plus.png",
                                width: 20,
                                height: 20,
                                fit: BoxFit.fill,
                              )
                            : SizedBox(
                                width: 20,
                                height: 20,
                                child: SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 1, color: mainColor),
                                )),
                      ),
                    ],
                  ),
                  //Farzi
                ],
              ));
        });
  }

  Widget BillDetailsView() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: greyColor10, width: 1),
          borderRadius: BorderRadius.circular(30)),
      padding: EdgeInsets.only(left: 13, right: 13, bottom: 12, top: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            BillDetails,
            style: TextStyle(
              fontFamily: Inter_bold,
              fontSize: 15,
              height: 1.0,
              color: blackColor,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                SubTotal,
                style: TextStyle(
                  fontFamily: Poppinsmedium,
                  fontSize: 12,
                  height: 1.0,
                  color: greyColor,
                ),
              ),
              Text(
                "₹${cartDataModel.subTotal}",
                style: TextStyle(
                  fontFamily: Poppinsmedium,
                  fontSize: 13,
                  height: 1.0,
                  color: greyColor,
                ),
              )
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CouponDiscount,
                style: TextStyle(
                  fontFamily: Poppinsmedium,
                  fontSize: 12,
                  height: 1.0,
                  color: cartDataModel.couponDiscount.toString() != "0.00"
                      ? redColor
                      : greyColor,
                ),
              ),
              Text(
                "₹${cartDataModel.couponDiscount}",
                style: TextStyle(
                  fontFamily: Poppinsmedium,
                  fontSize: 13,
                  height: 1.0,
                  color: cartDataModel.couponDiscount.toString() != "0.00"
                      ? redColor
                      : greyColor,
                ),
              )
            ],
          ),

          /*  Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                GST + " ${cartDataModel.gstPer}%",
                style: TextStyle(
                  fontFamily: Poppinsmedium,
                  fontSize: 12,
                  height: 1.0,
                  color: GreyColor,
                ),
              ),
              Text(
                "₹${cartDataModel.gstPrice}",
                style: TextStyle(
                  fontFamily: Poppinsmedium,
                  fontSize: 13,
                  height: 1.0,
                  color: GreyColor,
                ),
              )
            ],
          ),*/
          SizedBox(
            height: 15,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                PackingCharges,
                style: TextStyle(
                  fontFamily: Poppinsmedium,
                  fontSize: 12,
                  height: 1.0,
                  color: greyColor,
                ),
              ),
              Text(
                "₹${cartDataModel.packingCharge}",
                style: TextStyle(
                  fontFamily: Poppinsmedium,
                  fontSize: 13,
                  height: 1.0,
                  color: greyColor,
                ),
              )
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                TotalFoodCost,
                style: TextStyle(
                  fontFamily: Segoe_ui_bold,
                  fontSize: 18,
                  height: 1.0,
                  color: blackColor,
                ),
              ),
              Text(
                "₹${cartDataModel.total}",
                style: TextStyle(
                  fontFamily: Segoe_ui_bold,
                  fontSize: 18,
                  height: 1.0,
                  color: blackColor,
                ),
              )
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            DeliveryChargesmaybeApplicable,
            style: TextStyle(
              fontFamily: Poppinsmedium,
              fontSize: 10,
              height: 1.0,
              color: greyColor,
            ),
          ),
          SizedBox(
            height: 45,
          ),
          ProgressButton(
            child: Text(
              CONTINUE,
              style: TextStyle(
                color: whiteColor,
                fontFamily: Segoe_ui_semibold,
                height: 1.1,
              ),
            ),
            onPressed: () {
              if (cartDataModel.shopDetails!.shop_isopened == true) {
                OrderSchedule();
              } else {
                ShopCloseDialog();
              }
            },
            buttonState: buttonState,
            backgroundColor: mainColor,
            progressColor: whiteColor,
            border_radius: Rounded_Button_Corner,
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Future<void> AddOrRemoveProduct(
      String cartProductId, String qnty, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var header = <String, dynamic>{};
    String? token = prefs.getString(TOKEN);
    header[Authorization] = Bearer + token.toString();
    print("HEADERSSS${header.toString()}");
    var Params = <String, dynamic>{};
    Params[cart_product_id] = cartProductId;
    Params[quantity] = qnty;
    print("ParamsParamsParams${Params.toString()}");
    var ApiCalling = GetApiInstanceWithHeaders(header);
    Response response;
    response = await ApiCalling.post(MANAGECARTPRODUCT, data: Params);
    if (!response.data[status]) {
      ShowToast(response.data[message], context);
    }
    GetCartList(index);
    print("responseresponseresponse${response.data.toString()}");
  }

  Widget EmptyDataView() {
    return Stack(
      children: [
        Positioned.fill(
          top: 100,
          child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Image.asset(
                      imagePath + "ic_emptycart_man.png",
                      color: mainColor,
                      height: 300,
                      width: 300,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Opps!",
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: Segoe_ui_bold,
                          color: greyColor),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      YourCartEmpty,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: Segoe_ui_semibold,
                          color: greyColor),
                    )
                  ],
                ),
              )),
        ),
        Positioned(
            bottom: 30,
            child: Container(
              height: 50,
              width: 300,
              margin: EdgeInsets.only(left: 45),
              child: ProgressButton(
                child: Text(
                  CONTINUESHOPPING,
                  style: TextStyle(
                    color: whiteColor,
                    fontFamily: Segoe_ui_semibold,
                    height: 1.1,
                  ),
                ),
                onPressed: () {
                  widget.ContinueShopingClick();
                  if (widget.IsComeFromHome) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                        (Route<dynamic> route) => false);
                  } else {
                    Navigator.pop(context);
                  }
                },
                buttonState: buttonState,
                backgroundColor: mainColor,
                progressColor: whiteColor,
                border_radius: Rounded_Button_Corner,
              ),
            ))
      ],
    );
  }

  Widget CartMainview() {
    print("cartDataModel.status${cartDataModel.status}");
    if (cartDataModel.status != null) {
      if (cartDataModel.status != false) {
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: false,
              backgroundColor: whiteColor,
              floating: true,
              snap: false,
              flexibleSpace: FlexibleSpaceBar(),
              elevation: 0,
              forceElevated: true,
              centerTitle: false,
              automaticallyImplyLeading: false,
              leading: null,
              title: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      imagePath + "ic_back2.png",
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      Cart,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: TextStyle(
                          fontSize: 17,
                          height: 1.0,
                          fontFamily: Segoe_ui_bold,
                          color: darkMainColor2),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: greyColor10, width: 1),
                          borderRadius: BorderRadius.circular(30)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 12, right: 12, bottom: 12, top: 15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15.0)),
                                    child: SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: FadeInImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(
                                          cartDataModel.shopDetails!.shopImage
                                              .toString()
                                              .toString(),
                                        ),
                                        placeholder: AssetImage(
                                            "${imagePath}ic_logo.png"),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
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
                                          cartDataModel.shopDetails!.shopName
                                              .toString(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: Segoe_ui_semibold,
                                              color: blackColor),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          cartDataModel.shopDetails!.shopStreet
                                              .toString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 11,
                                              fontFamily: Segoeui,
                                              color: greyColor),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              width: double.maxFinite,
                              height: 1,
                              color: greyColor10,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: CartProductList(),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Container(
                              padding: const EdgeInsets.all(5.0),
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: greyColor2),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(22)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                      child: RoundedInputField(
                                    hintText: instructions,
                                    onChanged: (value) {
                                      Instrucvalue = value.toString();
                                    },
                                    inputType: TextInputType.name,
                                    icon: Icons.note_alt_outlined,
                                    Corner_radius: 20,
                                    horizontal_margin: 0,
                                    elevations: 0,
                                    formatter: LowerCaseTextFormatter(),
                                  )),
                                  Container(
                                    width: 80,
                                    height: 45,
                                    child: ProgressButton(
                                      child: Text(
                                        ADD,
                                        style: TextStyle(
                                          color: whiteColor,
                                          fontFamily: Segoe_ui_semibold,
                                          height: 1.1,
                                        ),
                                      ),
                                      onPressed: () {
                                        if (Instrucvalue.isNotEmpty) {
                                          AddInstruction();
                                        } else {
                                          ShowToast("Please enter instruction",
                                              context);
                                        }
                                      },
                                      buttonState: buttonState,
                                      backgroundColor: mainColor,
                                      progressColor: whiteColor,
                                      border_radius: 18,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                          ]),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      padding: const EdgeInsets.all(5.0),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: greyColor2),
                        borderRadius: BorderRadius.all(Radius.circular(22)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                              child: RoundedInputField(
                            hintText: CouponCode,
                            onChanged: (value) {
                              CouponValue = value;
                            },
                            inputType: TextInputType.name,
                            icon: Icons.bookmark_border_sharp,
                            Corner_radius: 20,
                            horizontal_margin: 0,
                            elevations: 0,
                            formatter: UpperCaseTextFormatter(),
                          )),
                          Container(
                            width: 80,
                            height: 45,
                            child: ProgressButton(
                              child: Text(
                                APPLY,
                                style: TextStyle(
                                  color: whiteColor,
                                  fontFamily: Segoe_ui_semibold,
                                  height: 1.1,
                                ),
                              ),
                              onPressed: () {
                                if (CouponValue.isNotEmpty) {
                                  isClickCouponAplly = true;
                                  AddCouponCode();
                                } else {
                                  ShowToast(
                                      "Please enter coupon code", context);
                                }
                              },
                              buttonState: buttonState,
                              backgroundColor: mainColor,
                              progressColor: whiteColor,
                              border_radius: 18,
                            ),
                          ),
                          SizedBox(
                            width: 3,
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    BillDetailsView(),
                    SizedBox(
                      height: 15,
                    )
                  ],
                ),
              )
            ]))
          ],
        );
      } else {
        return EmptyDataView();
      }
    } else {
      return MyProgressBar();
    }
  }

  Future<void> AddInstruction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var header = <String, dynamic>{};
    String? token = prefs.getString(TOKEN);
    header[Authorization] = Bearer + token.toString();
    print("HEADERSSS${header.toString()}");
    var Params = <String, dynamic>{};
    Params[cart_id] = cartDataModel.shopDetails!.cartId.toString();
    Params[instructions_param] = Instrucvalue;
    print("ParamsParamsParams${Params.toString()}");
    var ApiCalling = GetApiInstanceWithHeaders(header);
    Response response;
    response = await ApiCalling.post(ADD_INSTRUCTION, data: Params);
    ShowToast(response.data[message].toString(), context);
    print("responseresponseresponse${response.data.toString()}");
  }

  Future<void> AddCouponCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var header = <String, dynamic>{};
    String? token = prefs.getString(TOKEN);
    header[Authorization] = Bearer + token.toString();
    print("HEADERSSS${header.toString()}");
    var Params = <String, dynamic>{};
    Params[device_id] = cartDataModel.shopDetails!.cartId.toString();
    Params[coupon_code] = CouponValue;
    print("ParamsParamsParams${Params.toString()}");
    var ApiCalling = GetApiInstanceWithHeaders(header);
    Response response;
    response = await ApiCalling.post(APPLY_COUPON, data: Params);
    ShowToast(response.data[message].toString(), context);
    if (response.data[status]) {
      GetCartList(000);
    }
    print("responseresponseresponse${response.data.toString()}");
  }

  Future<void> OrderSchedule() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var header = <String, dynamic>{};
    String? token = prefs.getString(TOKEN);
    header[Authorization] = Bearer + token.toString();
    print("HEADERSSS${header.toString()}");
    var Params = <String, dynamic>{};
    Params[shop_id] = cartDataModel.shopDetails!.shopId.toString();
    Params[address_id] = prefs.getString(SELECTED_ADDRESS_ID);
    Params[cart_id] = cartDataModel.shopDetails!.cartId.toString();
    Params["instructions"] = Instrucvalue;
    Params[latitude] = prefs.getString(SELECTED_LATITUDE);
    Params[longitude] = prefs.getString(SELECTED_LONGITUDE);
    print("ParamsParamsParams${Params.toString()}");
    var ApiCalling = GetApiInstanceWithHeaders(header);
    Response response;
    response = await ApiCalling.post(SLOTS, data: Params);

    if (response.data[status]) {
      SlotsDataModel slotsDataModel = SlotsDataModel.fromJson(response.data);
      if (slotsDataModel.slots!.isNotEmpty) {
        dropdownvalue = slotsDataModel.slots![0].time.toString();
        slotsId = slotsDataModel.slots![0].slotId.toString();

        ScheduleOrderDialog(slotsDataModel);
      } else {
        WithoutScheduleOrderDialog();
      }
    } else {
      ShowToast(response.data[message].toString(), context);
    }
    print("responseresponseresponse${response.data.toString()}");
  }

  void ScheduleOrderDialog(SlotsDataModel slotsDataModel) {
    ButtonState buttonState = ButtonState.normal;
    List<String> slottimelist = [];
    slotsDataModel.slots!.forEach((element) {
      slottimelist.add(element.time.toString());
    });
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        builder: (builder) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setState /*You can rename this!*/) {
            return Container(
              height: 200,
              child: Padding(
                padding: EdgeInsets.only(top: 20, left: 15, right: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.maxFinite,
                      child: Text(
                        "Schedule your delivery time",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: Inter_bold,
                            color: blackColor),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: 40,
                      width: double.maxFinite,
                      padding: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: greyColor,
                            style: BorderStyle.solid,
                            width: 0.8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          // Initial Value
                          value: dropdownvalue,

                          borderRadius: BorderRadius.circular(8),
                          // Down Arrow Icon
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: greyColor,
                          ),
                          // Array list of items
                          items: slottimelist.map((String slotetiem) {
                            return DropdownMenuItem(
                              value: slotetiem,
                              child: Text(slotetiem.toString(),
                                  style: TextStyle(
                                      color: greyColor,
                                      fontSize: 13,
                                      fontFamily: Poppinsmedium)),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            dropdownvalue = value.toString();
                            slotsDataModel.slots!.forEach((element) {
                              if (value == element.time.toString()) {
                                slotsId = element.slotId.toString();
                              }
                            });
                          },
                          // After selecting the desired option,it will
                          // change button value to selected value
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      width: 170,
                      child: ProgressButton(
                        child: Text(
                          "Schedule Order",
                          style: TextStyle(
                            color: whiteColor,
                            fontFamily: Segoe_ui_semibold,
                            height: 1.1,
                          ),
                        ),
                        onPressed: () {
                          BookSchedule("1");
                        },
                        buttonState: buttonState,
                        backgroundColor: mainColor,
                        progressColor: whiteColor,
                        border_radius: 8,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  Future<void> BookSchedule(String deliverytype) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var header = <String, dynamic>{};
    String? token = prefs.getString(TOKEN);
    header[Authorization] = Bearer + token.toString();
    print("HEADERSSS${header.toString()}");
    var Params = <String, dynamic>{};
    Params[slot_id] = slotsId;
    Params[cart_id] = cartDataModel.shopDetails!.cartId.toString();
    Params[delivery_type] = deliverytype;
    print("ParamsParamsParams${Params.toString()}");
    var ApiCalling = GetApiInstanceWithHeaders(header);
    Response response;
    response = await ApiCalling.post(BOOK_SLOT, data: Params);
    ShowToast(response.data[message].toString(), context);
    if (response.data[status]) {
      Navigator.pop(context);
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
            builder: (context) => SelectAddressScreen(
                true, cartDataModel.gstPer.toString(), true)),
      );
    }
    print("responseresponseresponse${response.data.toString()}");
  }

  void WithoutScheduleOrderDialog() {
    ButtonState buttonState = ButtonState.normal;
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        builder: (builder) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setState /*You can rename this!*/) {
            return Container(
              height: 200,
              child: Padding(
                padding: EdgeInsets.only(top: 20, left: 15, right: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Estimated delivery time: 45min to 1hr on order confirmation.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: Inter_bold,
                              color: Colors.black),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: TextButton(
                                    child: Text(Cancel,
                                        style: TextStyle(fontSize: 14)),
                                    style: ButtonStyle(
                                        padding: MaterialStateProperty.all<EdgeInsets>(
                                            EdgeInsets.all(15)),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                mainColor),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                side: const BorderSide(
                                                    color: mainColor)))),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    })),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: TextButton(
                                    child: Text("Confirm",
                                        style: TextStyle(fontSize: 14)),
                                    style: ButtonStyle(
                                        padding: MaterialStateProperty.all<EdgeInsets>(
                                            EdgeInsets.all(15)),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                                whiteColor),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                mainColor),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                                side: const BorderSide(color: mainColor)))),
                                    onPressed: () {
                                      {
                                        BookSchedule("0");
                                      }
                                    })),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  void ShopCloseDialog() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
        ),
        builder: (builder) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setState /*You can rename this!*/) {
            return Container(
              height: 250,
              child: Padding(
                padding: EdgeInsets.only(top: 20, left: 15, right: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.close_rounded,
                            color: blackColor,
                            size: 25,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Image.asset(
                      imagePath + "ic_shop_closed.png",
                      width: 80,
                      height: 80,
                      fit: BoxFit.fill,
                    ),
                    Text(
                      "Shop Closed",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15,
                          fontFamily: Inter_bold,
                          color: redColor),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "This shop is closed right now,\n"
                      "come back another time",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          fontFamily: Inter_regular,
                          color: redColor),
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  showCouponDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: double.maxFinite,
                margin: EdgeInsets.symmetric(horizontal: 10),
                height: 355,
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 200),
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: Lottie.asset(
                            imagePath + "saved_money.json",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 170,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 25,
                                ),
                                Text(
                                  "\'" + CouponValue.toUpperCase() + "\'",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: Segoe_ui_semibold,
                                    fontSize: 13,
                                    height: 1.0,
                                    color: greyColor5,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  "applied",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: Segoe_ui_semibold,
                                    fontSize: 11,
                                    height: 1.0,
                                    color: greyColor5,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Text(
                              "YOU SAVED " +
                                  RUPPEE +
                                  cartDataModel.couponDiscount.toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: Segoe_bold,
                                fontSize: 19,
                                height: 1.0,
                                color: blackColor,
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Text(
                              "with this coupon code.",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: Segoe_ui_semibold,
                                fontSize: 12,
                                height: 1.0,
                                color: greyColor5,
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Text(
                              "Woohoo! Thanks..",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: Segoe_ui_semibold,
                                fontSize: 13,
                                height: 1.0,
                                color: redColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
