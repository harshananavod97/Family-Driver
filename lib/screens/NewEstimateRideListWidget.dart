import 'dart:async';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_booking/screens/RideDetailScreen.dart';
import '../../components/CouPonWidget.dart';
import '../../components/RideAcceptWidget.dart';
import '../../main.dart';
import '../../network/RestApis.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/AppButtonWidget.dart';
import '../../utils/Extensions/app_common.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../components/BookingWidget.dart';
import '../components/CarDetailWidget.dart';
import '../languageConfiguration/LanguageDefaultJson.dart';
import '../model/CurrentRequestModel.dart';
import '../model/EstimatePriceModel.dart';
import '../model/FRideBookingModel.dart';
import '../screens/ReviewScreen.dart';
import '../screens/WalletScreen.dart';
import '../service/RideService.dart';
import '../utils/Extensions/context_extension.dart';
import '../utils/Extensions/dataTypeExtensions.dart';
import '../utils/images.dart';
import 'BidingScreen.dart';
import 'DashBoardScreen.dart';
import 'RidePaymentDetailScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;

class NewEstimateRideListWidget extends StatefulWidget {
  final LatLng sourceLatLog;
  final LatLng destinationLatLog;
  final String sourceTitle;
  final String destinationTitle;
  bool isCurrentRequest;
  final int? servicesId;
  final int? id;
  Map? multiDropLocationNamesObj;
  Map? multiDropObj;
  String? callFrom;
  String? dt;

  NewEstimateRideListWidget(
      {required this.sourceLatLog,
      required this.destinationLatLog,
      required this.sourceTitle,
      required this.destinationTitle,
      this.isCurrentRequest = false,
      this.servicesId,
      this.id,
      this.multiDropLocationNamesObj,
      this.multiDropObj, this.callFrom, this.dt});

  @override
  NewEstimateRideListWidgetState createState() => NewEstimateRideListWidgetState();
}

class NewEstimateRideListWidgetState extends State<NewEstimateRideListWidget> with WidgetsBindingObserver {
  late Stream stream;
  String serviceMarker='';
  RideService rideService = RideService();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController promoCode = TextEditingController();
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? googleMapController;
  final Set<Marker> markers = {};
  String countryCode = defaultCountryCode;
  Set<Polyline> polyLines = Set<Polyline>();
  late PolylinePoints polylinePoints;
  late Marker sourceMarker;
  late Marker destinationMarker;
  late LatLng userLatLong;
  late DateTime scheduleData;
  String? distanceUnit = DISTANCE_TYPE_KM;
  bool isBooking = false;
  bool isRideSelection = false;
  bool bidingEnabled = false;
  bool bidRaised = false;
  bool isRideForOther = true;
  int selectedIndex = 0;
  int rideRequestId = 0;
  num mTotalAmount = 0;
  double? durationOfDrop = 0.0;
  bool rideCancelDetected = false;
  double? distance = 0;
  double locationDistance = 0.0;
  String? mSelectServiceAmount;
  List<String> cashList = [CASH, WALLET];
  List<ServicesListData> serviceList = [];
  List<LatLng> polylineCoordinates = [];
  LatLng? driverLatitudeLocation;
  String paymentMethodType = '';
  String? oldPaymentType;
  ServicesListData? servicesListData;
  OnRideRequest? rideRequestData;
  Driver? driverData;
  Timer? timer;
  var key = GlobalKey<ScaffoldState>();
  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;
  late BitmapDescriptor driverIcon;
  bool currentScreen = true;

  late FocusNode myFocusNode;
  TextEditingController bidAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // print("Call From:::${widget.callFrom}");
    // print("ChekLocation destinationLatLog Points:::${widget.destinationLatLog}");
    // print("ChekLocation destinationTitle Points:::${widget.destinationTitle}");
    // print("ChekLocation sourceLatLog Points:::${widget.sourceLatLog}");
    // print("ChekLocation sourceTitle Points:::${widget.sourceTitle}");
    myFocusNode = FocusNode();
    WidgetsBinding.instance!.addObserver(this);
    init();
  }
  // orignal 280
  // ChekLocation destinationLatLog Points:::LatLng(21.9611708, 70.7938777) Gondal
  // ChekLocation sourceLatLog Points:::LatLng(22.2862485, 70.7725263) KKV Hall

  // error case 280
  // ChekLocation destinationLatLog Points:::LatLng(21.9611708, 70.7938777) Gondal
  // ChekLocation sourceLatLog Points:::LatLng(22.3193506, 70.7679973) KKV Hall

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (key.currentContext != null) {
      if (state == AppLifecycleState.resumed) {
        final GoogleMapController controller = await _controller.future;
        onMapCreated(controller);
      }
    }
  }

  void init() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), Platform.isIOS ? SourceIOSIcon : SourceIcon);
    destinationIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), DestinationIcon);
    driverIcon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), Platform.isIOS ? DriverIOSIcon : DriverIcon);
    getCurrentRequest();
    if (!widget.isCurrentRequest) getNewService();
    isBooking = widget.isCurrentRequest;
    getWalletDataApi();
  }

  getCurrentRequest() async {
    try {
      timer!.cancel();
    } catch (e) {}
    await getCurrentRideRequest().then((value) {
      serviceMarker=value.service_marker.validate();
      rideRequestData = value.rideRequest ?? value.onRideRequest;
      if (value.driver != null) {
        driverData = value.driver!;
        getUserDetailLocation();
      } else {
        getServiceList();
      }
      if (rideRequestData != null) {
        if (rideRequestData != null) {
          if (driverData != null && rideRequestData!.status != COMPLETED) {
            timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
              DateTime? d = DateTime.tryParse(sharedPref.getString("UPDATE_CALL").toString());
              if (d != null && DateTime.now().difference(d).inSeconds > 10) {
                if (rideRequestData != null && (rideRequestData!.status == ACCEPTED || rideRequestData!.status == ARRIVING || rideRequestData!.status == ARRIVED)) {
                  getUserDetailLocation();
                } else {
                  try {
                    timer!.cancel();
                  } catch (e) {}
                }
                sharedPref.setString("UPDATE_CALL", DateTime.now().toString());
              } else if (d == null) {
                sharedPref.setString("UPDATE_CALL", DateTime.now().toString());
              }
            });
          } else {
            timer?.cancel();
            timer = null;
          }
        }
        setState(() {});
        if (rideRequestData!.status == COMPLETED && rideRequestData != null && driverData != null) {
          if (timer != null) {
            timer!.cancel();
          }
          timer = null;
          if (currentScreen != false) {
            currentScreen = false;
            launchScreen(context, ReviewScreen(rideRequest: rideRequestData!, driverData: driverData), pageRouteAnimation: PageRouteAnimation.SlideBottomTop, isNewTask: true);
          }
        }
      } else if (appStore.isRiderForAnother == "1" && value.payment != null && value.payment!.paymentStatus == SUCCESS) {
        if (currentScreen != false) {
          currentScreen = false;
          Future.delayed(
            Duration(seconds: 1),
            () {
              launchScreen(context, RidePaymentDetailScreen(rideId: value.payment!.rideRequestId), pageRouteAnimation: PageRouteAnimation.SlideBottomTop, isNewTask: true);
            },
          );
        }
      }
    }).catchError((error, stack) {
      FirebaseCrashlytics.instance.recordError("review_navigate_issue::" + error.toString(), stack, fatal: true);
      log("Error-- " + error.toString());
    });
  }

  Future<void> getServiceList() async {
    markers.clear();
    polylinePoints = PolylinePoints();
    setPolyLines(
      sourceLocation: LatLng(widget.sourceLatLog.latitude, widget.sourceLatLog.longitude),
      destinationLocation: LatLng(widget.destinationLatLog.latitude, widget.destinationLatLog.longitude),
      driverLocation: driverLatitudeLocation,
    );
    MarkerId id = MarkerId('Source');
    markers.add(
      Marker(
        markerId: id,
        position: LatLng(widget.sourceLatLog.latitude, widget.sourceLatLog.longitude),
        infoWindow: InfoWindow(title: widget.sourceTitle),
        icon: sourceIcon,
      ),
    );
    MarkerId id2 = MarkerId('DriverLocation');
    markers.remove(id2);

    if (rideRequestData != null &&
        rideRequestData!.multiDropLocation != null &&
        rideRequestData!.multiDropLocation!.isNotEmpty &&
        rideRequestData!.status != ACCEPTED &&
        rideRequestData!.status != ARRIVING &&
        rideRequestData!.status != ARRIVED) {
    } else {
      MarkerId id3 = MarkerId('Destination');
      markers.remove(id3);
      if(rideRequestData != null && (rideRequestData!.status == ACCEPTED || rideRequestData!.status == ARRIVING || rideRequestData!.status == ARRIVED)){
        try{
          var driverIcon1 = await getNetworkImageMarker(serviceMarker.validate());
          markers.add(
            Marker(
              markerId: id2,
              position: LatLng(driverLatitudeLocation!.latitude, driverLatitudeLocation!.longitude),
              icon: driverIcon1,
            ),
          );
          setState(() {});
        }catch(e,s){
          markers.add(
              Marker(
                markerId: id2,
                position: LatLng(driverLatitudeLocation!.latitude, driverLatitudeLocation!.longitude),
                icon: driverIcon,
              ),
            );
        }
        // markers.add(
        //   Marker(
        //     markerId: id2,
        //     position: LatLng(driverLatitudeLocation!.latitude, driverLatitudeLocation!.longitude),
        //     icon: driverIcon,
        //   ),
        // );
      }else{
        markers.add(
          Marker(
            markerId: id3,
            position: LatLng(widget.destinationLatLog.latitude, widget.destinationLatLog.longitude),
            infoWindow: InfoWindow(title: widget.destinationTitle),
            icon: destinationIcon,
          ),
        );
      }
    }
    setState(() {});
  }

  Future<void> getNewService({bool coupon = false}) async {
    appStore.setLoading(true);
    Map req = {
      "pick_lat": widget.sourceLatLog.latitude,
      "pick_lng": widget.sourceLatLog.longitude,
      "drop_lat": widget.destinationLatLog.latitude,
      "drop_lng": widget.destinationLatLog.longitude,
      if (coupon) "coupon_code": promoCode.text.trim(),
    };
    var dataJustCheck = [];
    dataJustCheck.add({"lat": widget.sourceLatLog.latitude, "lng": widget.sourceLatLog.longitude});
    if (widget.multiDropObj != null && widget.multiDropObj!.isNotEmpty) {
      widget.multiDropObj!.forEach(
        (key, value) {
          LatLng s = value as LatLng;
          dataJustCheck.add({
            "lat": s.latitude,
            "lng": s.longitude,
          });
          // dataJustCheck.add({"drop": key, "lat": s.latitude, "lng": s.longitude, "dropped_at": null, "address": widget.multiDropLocationNamesObj![key]});
        },
      );
      req['multi_location'] = dataJustCheck;
    }

    await estimatePriceList(req).then((value) {
      appStore.setLoading(false);
      serviceList.clear();
      value.data!.sort((a, b) => a.totalAmount!.compareTo(b.totalAmount!));
      serviceList.addAll(value.data!);
      if (serviceList.isNotEmpty) {
        locationDistance = serviceList[0].dropoffDistanceInKm!.toDouble();
        if (serviceList[0].distanceUnit == DISTANCE_TYPE_KM) {
          locationDistance = serviceList[0].dropoffDistanceInKm!.toDouble();
          distanceUnit = DISTANCE_TYPE_KM;
        } else {
          locationDistance = serviceList[0].dropoffDistanceInKm!.toDouble() * 0.621371;
          distanceUnit = DISTANCE_TYPE_MILE;
        }
        durationOfDrop = serviceList[0].duration!.toDouble();
      }

      if (serviceList.isNotEmpty) servicesListData = serviceList[0];
      if (serviceList.isNotEmpty) paymentMethodType = serviceList[0].paymentMethod!;
      if (serviceList.isNotEmpty) cashList = paymentMethodType == CASH_WALLET ? cashList = [CASH, WALLET] : cashList = [paymentMethodType];
      if (serviceList.isNotEmpty) {
        if (serviceList[0].discountAmount != 0) {
          mSelectServiceAmount = serviceList[0].subtotal!.toStringAsFixed(fixedDecimal);
        } else {
          mSelectServiceAmount = serviceList[0].totalAmount!.toStringAsFixed(fixedDecimal);
        }
      }
      if (oldPaymentType != null) {
        paymentMethodType = oldPaymentType ?? '';
      }
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString(), print: true);
    });
  }

  Future<void> getCouponNewService() async {
    appStore.setLoading(true);
    Map req = {
      "pick_lat": widget.sourceLatLog.latitude,
      "pick_lng": widget.sourceLatLog.longitude,
      "drop_lat": widget.destinationLatLog.latitude,
      "drop_lng": widget.destinationLatLog.longitude,
      "coupon_code": promoCode.text.trim(),
    };
    if (widget.multiDropObj != null) {
      var dataJustCheck = [];
      dataJustCheck.add({"lat": widget.sourceLatLog.latitude, "lng": widget.sourceLatLog.longitude});
      widget.multiDropObj!.forEach(
        (key, value) {
          LatLng s = value as LatLng;
          dataJustCheck.add({
            "lat": s.latitude,
            "lng": s.longitude,
          });
        },
      );
      req['multi_location'] = dataJustCheck;
    }

    await estimatePriceList(req).then((value) {
      appStore.setLoading(false);
      serviceList.clear();
      value.data!.sort((a, b) => a.totalAmount!.compareTo(b.totalAmount!));
      serviceList.addAll(value.data!);
      if (serviceList.isNotEmpty) {
        locationDistance = serviceList[selectedIndex].dropoffDistanceInKm!.toDouble();

        if (serviceList[selectedIndex].distanceUnit == DISTANCE_TYPE_KM) {
          locationDistance = serviceList[selectedIndex].dropoffDistanceInKm!.toDouble();
          distanceUnit = DISTANCE_TYPE_KM;
        } else {
          locationDistance = serviceList[selectedIndex].dropoffDistanceInKm!.toDouble() * 0.621371;
          distanceUnit = DISTANCE_TYPE_MILE;
        }
        durationOfDrop = serviceList[selectedIndex].duration!.toDouble();
      }
      if (serviceList.isNotEmpty) servicesListData = serviceList[selectedIndex];
      if (serviceList.isNotEmpty) paymentMethodType = serviceList[selectedIndex].paymentMethod!;
      if (serviceList.isNotEmpty) cashList = paymentMethodType == CASH_WALLET ? /*cashList =*/ [CASH, WALLET] : /*cashList = */[paymentMethodType];
      if (serviceList.isNotEmpty) {
        if (serviceList[selectedIndex].discountAmount != 0) {
          mSelectServiceAmount = serviceList[selectedIndex].subtotal!.toStringAsFixed(fixedDecimal);
        } else {
          mSelectServiceAmount = serviceList[selectedIndex].totalAmount!.toStringAsFixed(fixedDecimal);
        }
      }
      setState(() {});
      Navigator.pop(context);
    }).catchError((error) {
      promoCode.clear();
      Navigator.pop(context);

      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  Future<void> setPolyLinesDriver({required LatLng sourceLocation, LatLng? driverLocation}) async {
    try {
      for (int i = 0; i < rideRequestData!.multiDropLocation!.length; i++) {
        PolylineResult b = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: GOOGLE_MAP_API_KEY,
          request: PolylineRequest(
              origin:
                  i == 0 ? PointLatLng(sourceLocation.latitude, sourceLocation.longitude) : PointLatLng(rideRequestData!.multiDropLocation![i - 1].lat, rideRequestData!.multiDropLocation![i - 1].lng),
              destination: PointLatLng(rideRequestData!.multiDropLocation![i].lat, rideRequestData!.multiDropLocation![i].lng),
              mode: TravelMode.driving),
        );
        List<LatLng> routeCoordinates = [];
        markers.add(
          Marker(
            markerId: MarkerId("multi_drop_$i"),
            position: LatLng(rideRequestData!.multiDropLocation![i].lat, rideRequestData!.multiDropLocation![i].lng),
            infoWindow: InfoWindow(title: "${rideRequestData!.multiDropLocation![i].address}"),
            icon: destinationIcon,
          ),
        );
        b.points.forEach((element) {
          routeCoordinates.add(LatLng(element.latitude, element.longitude));
        });
        polyLines.add(Polyline(
          visible: true,
          width: 5,
          polylineId: PolylineId('multi_poly_$i'),
          color: Color.fromARGB(255, 40, 122, 198),
          points: routeCoordinates, // Use the local list for this polyline
        ));
      }
      setState(() {});
    } catch (e) {
      throw e;
    }
  }

  Future<void> setPolyLines({required LatLng sourceLocation, required LatLng destinationLocation, LatLng? driverLocation}) async {
    print("PolyLineCreatedCall");
    polyLines.clear();
    polylineCoordinates.clear();
    PolylineResult result;
    if (rideRequestData != null &&
        rideRequestData!.multiDropLocation != null &&
        rideRequestData!.multiDropLocation!.isNotEmpty &&
        rideRequestData!.status != ACCEPTED &&
        rideRequestData!.status != ARRIVING &&
        rideRequestData!.status != ARRIVED) {
      print("PolyLineCreatedCall410");
      await setPolyLinesDriver(sourceLocation: sourceLocation, driverLocation: driverLocation);
    } else if (widget.multiDropObj != null && widget.multiDropObj!.isNotEmpty && rideRequestData == null) {
      print("PolyLineCreatedCall414");
      try {
        for (int i = 0; i < widget.multiDropObj!.length; i++) {
          PolylineResult b = await polylinePoints.getRouteBetweenCoordinates(
            googleApiKey: GOOGLE_MAP_API_KEY,
            request: PolylineRequest(
                origin: i == 0 ? PointLatLng(sourceLocation.latitude, sourceLocation.longitude) : PointLatLng(widget.multiDropObj![i - 1].latitude, widget.multiDropObj![i - 1].longitude),
                destination: PointLatLng(widget.multiDropObj![i].latitude, widget.multiDropObj![i].longitude),
                mode: TravelMode.driving),
          );
          List<LatLng> routeCoordinates = [];
          markers.add(
            Marker(
              markerId: MarkerId("multi_drop_$i"),
              position: LatLng(widget.multiDropObj![i].latitude, widget.multiDropObj![i].longitude),
              infoWindow: InfoWindow(title: "${widget.multiDropLocationNamesObj![i]}"),
              icon: destinationIcon,
            ),
          );
          b.points.forEach((element) {
            routeCoordinates.add(LatLng(element.latitude, element.longitude));
          });
          polyLines.add(Polyline(
            visible: true,
            width: 5,
            polylineId: PolylineId('multi_poly_$i'),
            color: Color.fromARGB(255, 40, 122, 198),
            points: routeCoordinates, // Use the local list for this polyline
          ));
        }
        setState(() {});
      } catch (e) {
        throw e;
      }
    } else {
      try {
        result = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: GOOGLE_MAP_API_KEY,
          request: PolylineRequest(
              origin: PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
              destination: rideRequestData != null && (rideRequestData!.status == ACCEPTED || rideRequestData!.status == ARRIVING || rideRequestData!.status == ARRIVED)
                  ? PointLatLng(driverLocation!.latitude, driverLocation.longitude)
                  : PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
              mode: TravelMode.driving),
        );
        if (result.points.isNotEmpty) {
          polylineCoordinates.clear();
          result.points.forEach((element) {
            polylineCoordinates.add(LatLng(element.latitude, element.longitude));
          });
          polyLines.clear();
          polyLines.add(Polyline(
            visible: true,
            width: 5,
            polylineId: PolylineId('poly'),
            color: Color.fromARGB(255, 40, 122, 198),
            points: polylineCoordinates,
          ));
          setState(() {});
        }
      } catch (e) {}
    }
  }

  onMapCreated(GoogleMapController controller) async {
    try {
      googleMapController = controller;
      _controller.complete(controller);
      await Future.delayed(Duration(milliseconds: 50));
      await googleMapController!.animateCamera(CameraUpdate.newLatLngBounds(
          LatLngBounds(
              southwest: LatLng(widget.sourceLatLog.latitude <= widget.destinationLatLog.latitude ? widget.sourceLatLog.latitude : widget.destinationLatLog.latitude,
                  widget.sourceLatLog.longitude <= widget.destinationLatLog.longitude ? widget.sourceLatLog.longitude : widget.destinationLatLog.longitude),
              northeast: LatLng(widget.sourceLatLog.latitude <= widget.destinationLatLog.latitude ? widget.destinationLatLog.latitude : widget.sourceLatLog.latitude,
                  widget.sourceLatLog.longitude <= widget.destinationLatLog.longitude ? widget.destinationLatLog.longitude : widget.sourceLatLog.longitude)),
          100));
      setState(() {});
    } catch (e) {
      if (mounted) setState(() {});
    }
  }

  getWalletDataApi() {
    getWalletData().then((value) {
      mTotalAmount = value.totalAmount!;
    }).catchError((error) {
      log('${error.toString()}');
    });
  }

  Future<void> getUserDetailLocation() async {
    if (rideRequestData!.status != COMPLETED) {
      if (driverData == null) return;
      getUserDetail(userId: driverData!.id).then((value) {
        driverLatitudeLocation = LatLng(double.parse(value.data!.latitude!), double.parse(value.data!.longitude!));
        getServiceList();
      }).catchError((error) {
        log(error.toString());
      });
    } else {
      if (timer != null) timer?.cancel();
    }
  }

  @override
  void dispose() {
    // Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value) {
    //   polylineSource = LatLng(value.latitude, value.longitude);
    // });
    WidgetsBinding.instance!.removeObserver(this);
    if (timer != null) timer!.cancel();
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget mSomeOnElse() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(language.lblRideInformation, style: boldTextStyle()),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  icon: Icon(Icons.close),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: AppTextField(
              controller: nameController,
              autoFocus: false,
              isValidationRequired: false,
              textFieldType: TextFieldType.NAME,
              keyboardType: TextInputType.name,
              errorThisFieldRequired: language.thisFieldRequired,
              decoration: inputDecoration(context, label: language.enterName),
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: AppTextField(
              controller: phoneController,
              autoFocus: false,
              isValidationRequired: false,
              textFieldType: TextFieldType.PHONE,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              errorThisFieldRequired: language.thisFieldRequired,
              decoration: inputDecoration(
                context,
                label: language.enterContactNumber,
                prefixIcon: IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CountryCodePicker(
                        padding: EdgeInsets.zero,
                        initialSelection: countryCode,
                        showCountryOnly: false,
                        dialogSize: Size(MediaQuery.of(context).size.width - 60, MediaQuery.of(context).size.height * 0.6),
                        showFlag: true,
                        showFlagDialog: true,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                        textStyle: primaryTextStyle(),
                        dialogBackgroundColor: Theme.of(context).cardColor,
                        barrierColor: Colors.black12,
                        dialogTextStyle: primaryTextStyle(),
                        searchDecoration: InputDecoration(
                          focusColor: primaryColor,
                          iconColor: Theme.of(context).dividerColor,
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).dividerColor)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
                        ),
                        searchStyle: primaryTextStyle(),
                        onInit: (c) {
                          countryCode = c!.dialCode!;
                        },
                        onChanged: (c) {
                          countryCode = c.dialCode!;
                        },
                      ),
                      VerticalDivider(color: Colors.grey.withOpacity(0.5)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: AppButtonWidget(
              width: MediaQuery.of(context).size.width,
              text: language.done,
              textStyle: boldTextStyle(color: Colors.white),
              color: primaryColor,
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isBooking,
      onPopInvoked: (didPop) {
        if (didPop == false) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        key: key,
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light, statusBarBrightness: Brightness.dark, statusBarColor: Colors.black38),
          leadingWidth: 50,
          leading: Visibility(
            visible: !isBooking,
            child: inkWellWidget(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                margin: EdgeInsets.only(left: 12, bottom: 16),
                padding: EdgeInsets.all(0),
                decoration: BoxDecoration(color: context.cardColor, shape: BoxShape.circle, border: Border.all(color: dividerColor)),
                child: Icon(Icons.close, color: context.iconColor, size: 20),
              ),
            ),
          ),
        ),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            if (sharedPref.getDouble(LATITUDE) != null && sharedPref.getDouble(LONGITUDE) != null)
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: GoogleMap(
                  padding: EdgeInsets.only(top: context.statusBarHeight + 4 + 24),
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled:true,
                  // myLocationEnabled: true,
                  myLocationEnabled: rideRequestData != null && (rideRequestData!.status == IN_PROGRESS) ? true : false,
                  // myLocationButtonEnabled: false,
                  compassEnabled: true,
                  onMapCreated: onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: widget.sourceLatLog ?? LatLng(sharedPref.getDouble(LATITUDE)!, sharedPref.getDouble(LONGITUDE)!),
                    zoom: 17,
                  ),
                  markers: markers,
                  mapType: MapType.normal,
                  polylines: polyLines,
                ),
              ),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(2 * defaultRadius), topRight: Radius.circular(2 * defaultRadius))),
              child: !isBooking
                  ? bookRideWidget()
                  : StreamBuilder(
                      stream: rideService.fetchRide(rideId: rideRequestId == 0 ? widget.id : rideRequestId),
                      builder: (context, snap) {
                        if (snap.hasData) {
                          List<FRideBookingModel> data = snap.data!.docs.map((e) => FRideBookingModel.fromJson(e.data() as Map<String, dynamic>)).toList();
                          if (data.isEmpty) {
                            Future.delayed(
                              Duration(seconds: 1),
                              () {
                                if (currentScreen == false) return;
                                currentScreen = false;
                                checkRideCancel();
                              },
                            );
                          }
                          if (data.length != 0) {
                            if (data[0].onRiderStreamApiCall == 0) {
                              getCurrentRequest();
                              rideService.updateStatusOfRide(rideID: rideRequestId == 0 ? widget.id : rideRequestId, req: {'on_rider_stream_api_call': 1});
                            }
                            if (rideRequestData != null && rideRequestData!.status == COMPLETED) {
                              if (currentScreen != false) {
                                currentScreen = false;
                                if (rideRequestData!.isRiderRated == 1) {
                                  launchScreen(context, RideDetailScreen(orderId: rideRequestData!.id!), pageRouteAnimation: PageRouteAnimation.SlideBottomTop, isNewTask: true);
                                  // launchScreen(context, DashBoardScreen(), isNewTask: true);
                                } else {
                                  Future.delayed(
                                    Duration(seconds: 1),
                                    () {
                                      launchScreen(context, ReviewScreen(rideRequest: rideRequestData!, driverData: driverData),
                                          pageRouteAnimation: PageRouteAnimation.SlideBottomTop, isNewTask: true);
                                    },
                                  );
                                }
                              }
                              ;
                            }
                            // widget.rideRequest!.status == COMPLETED,
                            return rideRequestData != null
                                ? rideRequestData!.status == NEW_RIDE_REQUESTED
                                    ? BookingWidget(id: rideRequestId == 0 ? widget.id : rideRequestId, isLast: true,dt: widget.dt,)
                                    : RideAcceptWidget(rideRequest: rideRequestData, driverData: driverData)
                                // :SizedBox();
                                : data[0] != null && data[0].status == NEW_RIDE_REQUESTED
                                    ? BookingWidget(id: rideRequestId == 0 ? widget.id : rideRequestId, isLast: true, dt: widget.dt,)
                                    : loaderWidget();
                          } else {
                            return SizedBox();
                          }
                        } else {
                          return SizedBox();
                        }
                      }),
            ),
            Observer(builder: (context) {
              return Visibility(visible: appStore.isLoading, child: loaderWidget());
            }),

          ],
        ),
      ),
    );
  }

  Widget bookRideWidget() {
    return Stack(
      children: [
        Visibility(
          visible: serviceList.isNotEmpty,
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(2 * defaultRadius), topRight: Radius.circular(2 * defaultRadius))),
            child: SingleChildScrollView(
              child:
                  // true?bidBookingOption():
                  isRideSelection == false && appStore.isRiderForAnother == "1"
                      ? riderSelectionWidget()
                      :  serviceSelectWidget(),
            ),
          ),
        ),
        Visibility(
          visible: !appStore.isLoading && serviceList.isEmpty,
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(2 * defaultRadius), topRight: Radius.circular(2 * defaultRadius))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                emptyWidget(),
                Text(language.servicesNotFound, style: boldTextStyle()),
                SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget riderSelectionWidget() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: 16),
              height: 5,
              width: 70,
              decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(defaultRadius)),
            ),
          ),
          Text(language.whoWillBeSeated, style: primaryTextStyle(size: 18)),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              inkWellWidget(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: textSecondaryColorGlobal, width: 1)),
                            padding: EdgeInsets.all(12),
                            child: Image.asset(ic_add_user, fit: BoxFit.fill),
                          ),
                          if (!isRideForOther)
                            Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
                              child: Icon(Icons.check, color: Colors.white),
                            ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(language.lblSomeoneElse, style: primaryTextStyle()),
                    ],
                  ),
                  onTap: () {
                    isRideForOther = false;
                    showDialog(
                      context: context,
                      builder: (_) {
                        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                          return AlertDialog(
                            contentPadding: EdgeInsets.all(0),
                            content: mSomeOnElse(),
                          );
                        });
                      },
                    ).then((value) {
                      setState(() {});
                    });
                    setState(() {});
                  }),
              SizedBox(width: 30),
              inkWellWidget(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: commonCachedNetworkImage(appStore.userProfile.validate(), height: 70, width: 70, fit: BoxFit.cover),
                          ),
                          if (isRideForOther)
                            Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
                              child: Icon(Icons.check, color: Colors.white),
                            ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(language.lblYou, style: primaryTextStyle()),
                    ],
                  ),
                  onTap: () {
                    isRideForOther = true;
                    setState(() {});
                  })
            ],
          ),
          SizedBox(height: 12),
          Text(language.lblWhoRidingMsg, style: secondaryTextStyle()),
          SizedBox(height: 8),
          AppButtonWidget(
            color: primaryColor,
            onTap: () async {
              if (!isRideForOther) {
                if (nameController.text.isEmptyOrNull || phoneController.text.isEmptyOrNull) {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                        return AlertDialog(
                          contentPadding: EdgeInsets.all(0),
                          content: mSomeOnElse(),
                        );
                      });
                    },
                  ).then((value) {
                    setState(() {});
                  });
                } else {
                  isRideSelection = true;
                }
              } else {
                isRideSelection = true;
              }
              setState(() {});
            },
            text: language.lblNext,
            textStyle: boldTextStyle(color: Colors.white),
            width: MediaQuery.of(context).size.width,
          ),
        ],
      ),
    );
  }

  Widget serviceSelectWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(bottom: 8, top: 16),
            height: 5,
            width: 70,
            decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(defaultRadius)),
          ),
        ),
        SingleChildScrollView(
          padding: EdgeInsets.only(left: 8, right: 8),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: serviceList.map((e) {
              return GestureDetector(
                onTap: () {
                  if(servicesListData == e){
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(2 * defaultRadius), topLeft: Radius.circular(2 * defaultRadius))),
                      builder: (_) {
                        return CarDetailWidget(service: e);
                      },
                    );
                    return;
                  }
                  if (cashList.length > 1) {
                    oldPaymentType = paymentMethodType;
                  }
                  if (e.discountAmount != 0) {
                    mSelectServiceAmount = e.subtotal!.toStringAsFixed(fixedDecimal);
                  } else {
                    mSelectServiceAmount = e.totalAmount!.toStringAsFixed(fixedDecimal);
                  }
                  selectedIndex = serviceList.indexOf(e);
                  servicesListData = e;
                  if (e.distanceUnit == DISTANCE_TYPE_KM) {
                    locationDistance = e.dropoffDistanceInKm!.toDouble();
                    distanceUnit = DISTANCE_TYPE_KM;
                  } else {
                    locationDistance = e.dropoffDistanceInKm!.toDouble() * 0.621371;
                    distanceUnit = DISTANCE_TYPE_MILE;
                  }
                  durationOfDrop = serviceList[0].duration!.toDouble();
                  paymentMethodType = e.paymentMethod!;

                  // cashList =
                  paymentMethodType == CASH_WALLET ? cashList = [CASH, WALLET] : cashList = [paymentMethodType];
                  if (e.paymentMethod == CASH_WALLET && oldPaymentType != null) {
                    paymentMethodType = oldPaymentType!;
                  }
                  setState(() {});
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  margin: EdgeInsets.only(top: 16, left: 8, right: 8),
                  decoration: BoxDecoration(
                    color: selectedIndex == serviceList.indexOf(e) ? primaryColor : Colors.white,
                    border: Border.all(color: dividerColor),
                    borderRadius: BorderRadius.circular(defaultRadius),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      commonCachedNetworkImage(e.serviceImage.validate(), height: 50, width: 100, fit: BoxFit.contain, alignment: Alignment.center),
                      // SizedBox(height: 6),
                      Text(e.name.validate(), style: boldTextStyle(color: selectedIndex == serviceList.indexOf(e) ? Colors.white : textPrimaryColorGlobal)),
                      // SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language.capacity, style: secondaryTextStyle(size: 12, color: selectedIndex == serviceList.indexOf(e) ? Colors.white : textPrimaryColorGlobal)),
                          SizedBox(width: 4),
                          Text(e.capacity.toString() + " + 1", style: secondaryTextStyle(color: selectedIndex == serviceList.indexOf(e) ? Colors.white : textPrimaryColorGlobal)),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              printAmountWidget(
                                amount: '${e.totalAmount!.toStringAsFixed(digitAfterDecimal)}',
                                weight: e.discountAmount != 0 ? FontWeight.normal : FontWeight.bold,
                                textDecoration:e.discountAmount != 0 ?TextDecoration.lineThrough:TextDecoration.none,
                                color: selectedIndex == serviceList.indexOf(e) ? Colors.white : textPrimaryColorGlobal,
                              ),
                              if (e.discountAmount != 0)
                                printAmountWidget(
                                  amount: '${e.subtotal!.toStringAsFixed(digitAfterDecimal)}',
                                  color: selectedIndex == serviceList.indexOf(e) ? Colors.white : textPrimaryColorGlobal,
                                ),
                            ],
                          ),
                          SizedBox(width: 8),
                          inkWellWidget(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(2 * defaultRadius), topLeft: Radius.circular(2 * defaultRadius))),
                                builder: (_) {
                                  return CarDetailWidget(service: e);
                                },
                              );
                            },
                            child: Icon(Icons.info_outline_rounded, size: 16, color: selectedIndex == serviceList.indexOf(e) ? Colors.white : textPrimaryColorGlobal),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 8),
        inkWellWidget(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) {
                return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                  return Observer(builder: (context) {
                    return Stack(
                      children: [
                        AlertDialog(
                          contentPadding: EdgeInsets.all(16),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(language.paymentMethod, style: boldTextStyle()),
                                    inkWellWidget(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                                        child: Icon(Icons.close, color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(language.chooseYouPaymentLate, style: secondaryTextStyle()),
                                // Text(isRideForOther.toString(), style: secondaryTextStyle()),
                                // isRideForOther == false
                                //     ? RadioListTile(
                                //         contentPadding: EdgeInsets.zero,
                                //         dense: true,
                                //         controlAffinity: ListTileControlAffinity.trailing,
                                //         activeColor: primaryColor,
                                //         value: CASH,
                                //         groupValue: CASH,
                                //         title: Text(language.cash, style: boldTextStyle()),
                                //         onChanged: (String? val) {},
                                //       )
                                //     :
                                Column(
                                        children: cashList.map((e) {
                                          return RadioListTile(
                                            dense: true,
                                            contentPadding: EdgeInsets.zero,
                                            controlAffinity: ListTileControlAffinity.trailing,
                                            activeColor: primaryColor,
                                            value: e,
                                            groupValue: paymentMethodType == CASH_WALLET ? CASH : paymentMethodType,
                                            title: Text(paymentStatus(e), style: boldTextStyle()),
                                            onChanged: (String? val) {
                                              paymentMethodType = val!;
                                              setState(() {});
                                            },
                                          );
                                        }).toList(),
                                      ),
                                SizedBox(height: 16),
                                AppTextField(
                                  controller: promoCode,
                                  autoFocus: false,
                                  textFieldType: TextFieldType.EMAIL,
                                  keyboardType: TextInputType.emailAddress,
                                  errorThisFieldRequired: language.thisFieldRequired,
                                  readOnly: true,
                                  onTap: () async {
                                    // servicesListData.id;
                                    // selectedIndex;
                                    var data = await showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.white,
                                      builder: (_) {
                                        return CouPonWidget();
                                      },
                                    );
                                    if (data != null) {
                                      promoCode.text = data;
                                      setState(() {});
                                    }
                                  },
                                  decoration: inputDecoration(context,
                                      label: language.enterPromoCode,
                                      suffixIcon: promoCode.text.isNotEmpty
                                          ? inkWellWidget(
                                              onTap: () {
                                                getNewService(coupon: false);
                                                promoCode.clear();
                                                setState(() {});
                                              },
                                              child: Icon(Icons.close, color: Colors.black, size: 25),
                                            )
                                          : null),
                                ),
                                SizedBox(height: 16),
                                AppButtonWidget(
                                  width: MediaQuery.of(context).size.width,
                                  text: language.confirm,
                                  textStyle: boldTextStyle(color: Colors.white),
                                  color: primaryColor,
                                  onTap: () {
                                    if (promoCode.text.isNotEmpty) {
                                      getCouponNewService();
                                    } else {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        Observer(builder: (context) {
                          return Visibility(visible: appStore.isLoading, child: loaderWidget());
                        }),
                      ],
                    );
                  });
                });
              },
            ).then((value) {
              setState(() {});
            });
          },
          child: Container(
            margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(border: Border.all(color: dividerColor), borderRadius: BorderRadius.circular(defaultRadius)),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language.paymentVia, style: secondaryTextStyle(size: 12)),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      margin: EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(defaultRadius)),
                      child: Icon(
                          paymentMethodType == CASH_WALLET || paymentMethodType == CASH?
                          Icons.attach_money:Icons.wallet_outlined, size: 20, color: Colors.white),
                      // child: Icon(Icons.wallet_outlined, size: 20, color: Colors.white),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isRideForOther == false
                                      ? language.cash
                                      : paymentMethodType == CASH_WALLET
                                          ? language.cash
                                          : paymentStatus(paymentMethodType),
                                  style: boldTextStyle(size: 14),
                                ),
                              ),
                              if (mSelectServiceAmount != null && paymentMethodType != CASH_WALLET && paymentMethodType == WALLET && double.parse(mSelectServiceAmount!) >= mTotalAmount.toDouble())
                                inkWellWidget(
                                  onTap: () {
                                    oldPaymentType = paymentMethodType;
                                    launchScreen(context, WalletScreen()).then((value) {
                                      init();
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(border: Border.all(color: dividerColor), color: primaryColor, borderRadius: radius()),
                                    child: Text(language.addMoney, style: primaryTextStyle(size: 14, color: Colors.white)),
                                  ),
                                )
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(paymentMethodType != CASH_WALLET ? language.forInstantPayment : language.lblPayWhenEnds, style: secondaryTextStyle(size: 12)),
                          if (mSelectServiceAmount != null && paymentMethodType != CASH_WALLET && paymentMethodType == WALLET && double.parse(mSelectServiceAmount!) >= mTotalAmount.toDouble())
                            Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(language.lblLessWalletAmount, style: boldTextStyle(size: 12, color: Colors.red, letterSpacing: 0.5, weight: FontWeight.w500)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 0),
          child: AppButtonWidget(
            onTap: () {
              if (mSelectServiceAmount != null && paymentMethodType != CASH_WALLET && paymentMethodType == WALLET && double.parse(mSelectServiceAmount!) >= mTotalAmount.toDouble()) {
                return toast(language.noBalanceValidate);
              }
              saveBookingData();
            },
            text: language.bookNow,
            textStyle: boldTextStyle(color: Colors.white),
            width: MediaQuery.of(context).size.width,
          ),
        ),
        if(appStore.isBidEnable=="1")
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text("OR"),
              ),
              Expanded(child: Divider()),
            ],
          ),
        ),
        if(appStore.isBidEnable=="1")
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
          child: AppButtonWidget(
            onTap: () {
              if (mSelectServiceAmount != null && paymentMethodType != CASH_WALLET && paymentMethodType == WALLET && double.parse(mSelectServiceAmount!) >= mTotalAmount.toDouble()) {
                return toast(language.noBalanceValidate);
              }
              saveBookingData(ride_type:"with_bidding");
              // saveBidBookingData();
            },
            text: language.bid_book,
            textStyle: boldTextStyle(color: Colors.white),
            width: MediaQuery.of(context).size.width,
          ),
        ),
        if(appStore.isBidEnable!="1")
          SizedBox(height: 12,)
      ],
    );
  }

  Future<void> saveBookingData({String? ride_type}) async {
    if (isRideForOther == false && nameController.text.isEmpty) {
      return toast(language.nameFieldIsRequired);
    } else if (isRideForOther == false && phoneController.text.isEmpty) {
      return toast(language.phoneNumberIsRequired);
    }
    appStore.setLoading(true);
    widget.dt=DateTime.now().toUtc().toString().replaceAll("Z", "");
    print("CHeck2${DateTime.now().toUtc().toString()}");

    Map req = {
      "rider_id": sharedPref.getInt(USER_ID).toString(),
      "service_id": servicesListData!.id.toString(),
      "datetime": DateTime.now().toUtc().toString().replaceAll("Z", ""),
      "start_latitude": widget.sourceLatLog.latitude.toString(),
      "start_longitude": widget.sourceLatLog.longitude.toString(),
      "start_address": widget.sourceTitle,
      "end_latitude": widget.destinationLatLog.latitude.toString(),
      "end_longitude": widget.destinationLatLog.longitude.toString(),
      "end_address": widget.destinationTitle,
      "seat_count": servicesListData!.capacity.toString(),
      "status": NEW_RIDE_REQUESTED,
      "payment_type":

      // isRideForOther == false
      //     ? CASH
      //     :
      paymentMethodType == CASH_WALLET
              ? CASH
              : paymentMethodType,
      if (promoCode.text.isNotEmpty) "coupon_code": promoCode.text,
      "is_schedule": 0,
      if (isRideForOther == false) "is_ride_for_other": 1,
      if (isRideForOther == false)
        "other_rider_data": {
          "name": nameController.text.trim(),
          "contact_number": '${countryCode}${phoneController.text.trim()}',
        }
    };
    if(ride_type!=null){
      req['ride_type']=ride_type;
    }
    var abc = [];
    if (widget.multiDropObj != null) {
      widget.multiDropObj!.forEach(
        (key, value) {
          LatLng s = value as LatLng;
          abc.add({"drop": key, "lat": s.latitude, "lng": s.longitude, "dropped_at": null, "address": widget.multiDropLocationNamesObj![key]});
        },
      );
      req['multi_location'] = abc;
    }
    FRideBookingModel rideBookingModel = FRideBookingModel();
    rideBookingModel.riderId = sharedPref.getInt(USER_ID);
    rideBookingModel.status = NEW_RIDE_REQUESTED;
    rideBookingModel.paymentStatus = null;
    rideBookingModel.paymentType = isRideForOther == false
        ? CASH
        : paymentMethodType == CASH_WALLET
            ? CASH
            : paymentMethodType;
    log('$req');
    await saveRideRequest(req).then((value) async {

      rideRequestId = value.rideRequestId!;
      rideBookingModel.rideId = rideRequestId;
      Future.delayed(
        Duration(seconds: 3),
        () {
          rideService.updateStatusOfRide(rideID: rideRequestId, req: {'on_stream_api_call': 0});
        },
      );
      widget.isCurrentRequest = true;

      if(ride_type!=null){
        appStore.setLoading(false);
        setState(() {});
        launchScreen(
          context,
          isNewTask: true,
          Bidingscreen(
            dt: widget.dt,
            ride_id:value.rideRequestId!,
            source: {
              "start_latitude": widget.sourceLatLog.latitude.toString(),
              "start_longitude": widget.sourceLatLog.longitude.toString(),
              "start_address": widget.sourceTitle,
            },
            endLocation: {
              "end_latitude": widget.destinationLatLog.latitude.toString(),
              "end_longitude": widget.destinationLatLog.longitude.toString(),
              "end_address": widget.destinationTitle,
            },
            multiDropObj: widget.multiDropObj,
            multiDropLocationNamesObj: widget.multiDropLocationNamesObj,
          ),
          pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
        );
      }else{
        isBooking = true;
        appStore.setLoading(false);
        setState(() {});
      }
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  void checkRideCancel() async {
    if (rideCancelDetected) return;
    rideCancelDetected = true;
    appStore.setLoading(true);
    sharedPref.remove(IS_TIME);
    sharedPref.remove(REMAINING_TIME);
    await rideDetail(orderId: rideRequestId == 0 ? widget.id : rideRequestId).then((value) {
      appStore.setLoading(false);
      if (value.data!.status == CANCELED && value.data!.cancelBy == DRIVER) {
        launchScreen(getContext, DashBoardScreen(cancelReason: value.data!.reason), isNewTask: true);
      } else {
        launchScreen(getContext, DashBoardScreen(), isNewTask: true);
      }
    }).catchError((error) {
      appStore.setLoading(false);
      launchScreen(getContext, DashBoardScreen(), isNewTask: true);
      log(error.toString());
    });
  }

  Future<BitmapDescriptor> getNetworkImageMarker(String imageUrl) async {
    print("OPERATION111");
    final http.Response response = await http.get(Uri.parse(imageUrl));
    final Uint8List bytes = response.bodyBytes;

    // Load the image as a codec (which includes its dimensions)
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    print("OPERATION222");
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    print("OPERATION232");
    final ByteData? byteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    print("OPERATION232");
    final Uint8List resizedBytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(resizedBytes);
  }
}
