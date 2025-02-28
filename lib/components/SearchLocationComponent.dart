import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:taxi_booking/utils/Extensions/dataTypeExtensions.dart';
import '../main.dart';
import '../screens/NewEstimateRideListWidget.dart';
import '../model/GoogleMapSearchModel.dart';
import '../model/ServiceModel.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/app_common.dart';
import '../screens/GoogleMapScreen.dart';

class SearchLocationComponent extends StatefulWidget {
  final String title;

  SearchLocationComponent({required this.title});

  @override
  SearchLocationComponentState createState() => SearchLocationComponentState();
}

class SearchLocationComponentState extends State<SearchLocationComponent> {
  TextEditingController sourceLocation = TextEditingController();
  TextEditingController destinationLocation = TextEditingController();

  FocusNode sourceFocus = FocusNode();
  FocusNode desFocus = FocusNode();
  List<TextEditingController> multipleDropPoints = [];
  var multiDropLatLng = {};
  List<FocusNode> multipleDropPointsFocus = [];
  int multiDropFieldPosition = 0;
  String mLocation = "";
  bool isDone = true;
  bool isPickup = true;
  bool isDrop = false;
  double? totalAmount;

  List<ServiceList> list = [];
  List<Prediction> listAddress = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    sourceLocation.text = widget.title;
    await getServices().then((value) {
      list.addAll(value.data!);
      setState(() {});
    });

    sourceFocus.addListener(() {
      sourceLocation.selection = TextSelection.collapsed(offset: sourceLocation.text.length);
      if (sourceFocus.hasFocus) sourceLocation.clear();
    });

    desFocus.addListener(() {
      if (desFocus.hasFocus) {
        if (mLocation.isNotEmpty) {
          sourceLocation.text = mLocation;
          sourceLocation.selection = TextSelection.collapsed(offset: sourceLocation.text.length);
        } else {
          sourceLocation.text = widget.title;
          sourceLocation.selection = TextSelection.collapsed(offset: sourceLocation.text.length);
        }
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
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
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.only(bottom: 16),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(defaultRadius)),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.near_me, color: Colors.green,shadows: [
                                BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 1,
                                    offset: Offset(1.5, 1.5),
                                    spreadRadius:5
                                ),
                                BoxShadow(
                                    color: Colors.white70,
                                    blurRadius:1,
                                    offset: Offset(-1, -1),
                                    spreadRadius:5
                                ),
                              ],),
                              SizedBox(width: 4),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isPickup == true) Text(language.lblWhereAreYou, style: secondaryTextStyle()),
                                    TextFormField(
                                      controller: sourceLocation,
                                      focusNode: sourceFocus,
                                      decoration: searchInputDecoration(hint: language.currentLocation),
                                      onTap: () {
                                        isPickup = false;
                                        setState(() {});
                                      },
                                      onChanged: (val) {
                                        if (val.isNotEmpty) {
                                          isPickup = true;
                                          if (val.length < 3) {
                                            isDone = false;
                                            listAddress.clear();
                                            setState(() {});
                                          } else {
                                            searchAddressRequest(search: val).then((value) {
                                              isDone = true;
                                              listAddress = value.predictions!;
                                              setState(() {});
                                            }).catchError((error) {
                                              log(error);
                                            });
                                          }
                                        } else {
                                          isPickup = false;
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 4),
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(width: 8),
                              SizedBox(
                                height: 46,
                                child: DottedLine(
                                  direction: Axis.vertical,
                                  lineLength: double.infinity,
                                  lineThickness: 1,
                                  dashLength: 3,
                                  dashColor: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          if (multipleDropPoints.isEmpty)
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.red,shadows: [
                                  BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 1,
                                    offset: Offset(1.5, 1.5),
                                    spreadRadius:5
                                  ),
                                  BoxShadow(
                                      color: Colors.white70,
                                      blurRadius:1,
                                      offset: Offset(-1, -1),
                                      spreadRadius:5
                                  ),
                                ],
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (isDrop == true) Text(language.lblDropOff, style: secondaryTextStyle()),
                                      TextFormField(
                                        controller: destinationLocation,
                                        focusNode: desFocus,
                                        autofocus: true,
                                        decoration: searchInputDecoration(hint: language.destinationLocation),
                                        onTap: () {
                                          isDrop = false;
                                          setState(() {});
                                        },
                                        onChanged: (val) {
                                          if (val.isNotEmpty) {
                                            isDrop = true;
                                            if (val.length < 3) {
                                              listAddress.clear();
                                              setState(() {});
                                            } else {
                                              searchAddressRequest(search: val).then((value) {
                                                listAddress = value.predictions!;
                                                setState(() {});
                                              }).catchError((error) {
                                                log(error);
                                              });
                                            }
                                          } else {
                                            isDrop = false;
                                            setState(() {});
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 4),
                              ],
                            ),
                          if (multipleDropPoints.isNotEmpty) reorderedView(),
                        ],
                      ),
                    ),
                  ),
                  if (appStore.isMultiDrop != null && appStore.isMultiDrop == "1")
                    TextButton(
                        onPressed: () {
                          if (multipleDropPoints.isEmpty) {
                            hideKeyboard(context);
                            multipleDropPoints = [TextEditingController(), TextEditingController()];
                            multipleDropPointsFocus = [FocusNode(), FocusNode()];
                          } else {
                            multipleDropPoints.add(TextEditingController());
                            multipleDropPointsFocus.add(FocusNode());
                          }
                          setState(() {});
                        },
                        child: Text(
                          language.addDropPoint,
                          style: primaryTextStyle(),
                        )),
                  if (listAddress.isNotEmpty) SizedBox(height: 16),
                  ListView.builder(
                    controller: ScrollController(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: listAddress.length,
                    itemBuilder: (context, index) {
                      Prediction mData = listAddress[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.location_on_outlined, color: primaryColor,),
                        minLeadingWidth: 16,
                        title: Text(mData.description ?? "", style: primaryTextStyle()),
                        onTap: () async {
                          await searchAddressRequestPlaceId(placeId: mData.placeId).then((value) async {
                            var data = value.result!.geometry;
                            if (sourceFocus.hasFocus) {
                              isDone = true;
                              mLocation = mData.description!;
                              sourceLocation.text = mData.description!;
                              polylineSource = LatLng(data!.location!.lat!, data.location!.lng!);
                              if (!sourceLocation.text.isEmptyOrNull && !destinationLocation.text.isEmptyOrNull) {
                                launchScreen(
                                    context,
                                    NewEstimateRideListWidget(
                                      callFrom:"267",
                                        sourceLatLog: polylineSource, destinationLatLog: polylineDestination, sourceTitle: sourceLocation.text, destinationTitle: destinationLocation.text),
                                    pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                                sourceLocation.clear();
                                destinationLocation.clear();
                              }
                            } else if (desFocus.hasFocus) {
                              polylineDestination = LatLng(data!.location!.lat!, data.location!.lng!);
                              destinationLocation.text = mData.description!;
                              if (!sourceLocation.text.isEmptyOrNull && !destinationLocation.text.isEmptyOrNull) {
                                launchScreen(
                                    context,
                                    NewEstimateRideListWidget(
                                        callFrom:"280",
                                        sourceLatLog: polylineSource, destinationLatLog: polylineDestination, sourceTitle: sourceLocation.text, destinationTitle: destinationLocation.text),
                                    pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                                sourceLocation.clear();
                                destinationLocation.clear();
                              }
                            } else if (multipleDropPoints.isNotEmpty) {
                              multiDropLatLng[multiDropFieldPosition] = LatLng(data!.location!.lat!, data.location!.lng!);
                              multipleDropPoints[multiDropFieldPosition].text = mData.description!;
                              try {
                                multipleDropPointsFocus[multiDropFieldPosition + 1].requestFocus();
                              } catch (e) {}
                            }
                            listAddress.clear();
                            setState(() {});
                          }).catchError((error) {
                            log(error);
                          });
                        },
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  if (multipleDropPoints.isEmpty || (multipleDropPoints.isNotEmpty && multiDropLatLng.length != multipleDropPoints.length))
                    AppButtonWidget(
                      width: MediaQuery.of(context).size.width,
                      onTap: () async {
                        if (sourceFocus.hasFocus) {
                          isDone = true;
                          PickResult selectedPlace = await launchScreen(context, GoogleMapScreen(isDestination: false), pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                          log(selectedPlace);
                          mLocation = selectedPlace.formattedAddress!;
                          sourceLocation.text = selectedPlace.formattedAddress!;
                          polylineSource = LatLng(selectedPlace.geometry!.location.lat, selectedPlace.geometry!.location.lng);

                          if (sourceLocation.text.isNotEmpty && destinationLocation.text.isNotEmpty) {
                            launchScreen(
                                context,
                                NewEstimateRideListWidget(
                                    callFrom:"319",
                                    sourceLatLog: polylineSource, destinationLatLog: polylineDestination, sourceTitle: sourceLocation.text, destinationTitle: destinationLocation.text),
                                pageRouteAnimation: PageRouteAnimation.SlideBottomTop);

                            sourceLocation.clear();
                            destinationLocation.clear();
                          } else {
                            desFocus.nextFocus();
                          }
                        } else if (desFocus.hasFocus) {
                          PickResult selectedPlace = await launchScreen(context, GoogleMapScreen(isDestination: true), pageRouteAnimation: PageRouteAnimation.SlideBottomTop);

                          destinationLocation.text = selectedPlace.formattedAddress!;
                          polylineDestination = LatLng(selectedPlace.geometry!.location.lat, selectedPlace.geometry!.location.lng);

                          if (sourceLocation.text.isNotEmpty && destinationLocation.text.isNotEmpty) {
                            log(sourceLocation.text);
                            log(destinationLocation.text);
                            launchScreen(
                                context,
                                NewEstimateRideListWidget(
                                    callFrom:"340",
                                    sourceLatLog: polylineSource, destinationLatLog: polylineDestination, sourceTitle: sourceLocation.text, destinationTitle: destinationLocation.text),
                                pageRouteAnimation: PageRouteAnimation.SlideBottomTop);

                            sourceLocation.clear();
                            destinationLocation.clear();
                          } else {
                            sourceFocus.nextFocus();
                          }
                        } else if (multipleDropPoints.isNotEmpty) {
                          int x = multipleDropPointsFocus.indexWhere(
                            (element) => element.hasFocus,
                          );
                          if (x != -1) {
                            PickResult selectedPlace = await launchScreen(context, GoogleMapScreen(isDestination: true), pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                            multipleDropPoints[x].text = selectedPlace.formattedAddress!;
                            multiDropLatLng[x] = LatLng(selectedPlace.geometry!.location.lat, selectedPlace.geometry!.location.lng);
                            try {
                              multipleDropPointsFocus[multiDropFieldPosition + 1].requestFocus();
                            } catch (e) {}
                            setState(() {});
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.my_location_sharp, color: Colors.white),
                          SizedBox(width: 16),
                          Text(language.chooseOnMap, style: boldTextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  if (multipleDropPoints.isNotEmpty && multiDropLatLng.length == multipleDropPoints.length)
                    AppButtonWidget(
                      width: MediaQuery.of(context).size.width,
                      onTap: () async {
                        if (multipleDropPoints.any(
                          (element) => element.text.trim().isEmpty,
                        )) {
                          return toast(language.required);
                        }
                        if (multipleDropPoints.length != multiDropLatLng.length) {
                          return toast("Select Proper Location required");
                        }
                        var abc = {};
                        polylineDestination = multiDropLatLng[multipleDropPoints!.length - 1];
                        destinationLocation.text = multipleDropPoints.last.text;
                        multipleDropPoints.removeLast();
                        for (int i = 0; i < multipleDropPoints.length; i++) {
                          abc[i] = multipleDropPoints[i].text;
                        }
                        multiDropLatLng.remove(multiDropLatLng.keys.toList().last);
                        print("CHeckData:45465::${polylineDestination}");
                        print("CHeckData:69966::${destinationLocation.text}");

                        await launchScreen(
                            context,
                            NewEstimateRideListWidget(
                                callFrom:"394",
                                sourceLatLog: polylineSource,
                                destinationLatLog: polylineDestination,
                                sourceTitle: sourceLocation.text,
                                multiDropObj: multiDropLatLng,
                                multiDropLocationNamesObj: abc,
                                destinationTitle: destinationLocation.text),
                            pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
                        multiDropLatLng.clear();
                        multipleDropPoints.clear();
                        multipleDropPointsFocus.clear();
                        multiDropFieldPosition=0;
                        sourceLocation.clear();
                        destinationLocation.clear();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(language.continueD, style: boldTextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget reorderedView() {
    return ReorderableListView(
      shrinkWrap: true,
      children: [
        for (int i = 0; i < multipleDropPoints.length; i++)
          Row(
            key: ValueKey("$i"),
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, color: Colors.red,shadows: [
                      BoxShadow(
                          color: Colors.black,
                          blurRadius: 1,
                          offset: Offset(1.5, 1.5),
                          spreadRadius:5
                      ),
                      BoxShadow(
                          color: Colors.white70,
                          blurRadius:1,
                          offset: Offset(-1, -1),
                          spreadRadius:5
                      ),
                    ],),
                    SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: multipleDropPoints[i],
                            focusNode: multipleDropPointsFocus[i],
                            autofocus: true,
                            decoration: searchInputDecoration(hint: "${language.dropPoint} ${i + 1}"),
                            onTap: () {
                              isDrop = false;
                              multiDropFieldPosition = i;
                              setState(() {});
                            },
                            onChanged: (val) {
                              if (val.isNotEmpty) {
                                isDrop = true;
                                multiDropFieldPosition = i;
                                try {
                                  multiDropLatLng.remove(multiDropFieldPosition);
                                } catch (e) {}
                                if (val.length < 3) {
                                  listAddress.clear();
                                  setState(() {});
                                } else {
                                  searchAddressRequest(search: val).then((value) {
                                    listAddress = value.predictions!;
                                    setState(() {});
                                  }).catchError((error) {
                                    log(error);
                                  });
                                }
                              } else {
                                isDrop = false;
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 4),
                  ],
                ),
              ),
              if (i > 0)
                IconButton(
                  onPressed: () {
                    if (multipleDropPoints.length == 2) {
                      multipleDropPoints.clear();
                      multipleDropPointsFocus.clear();
                      multiDropLatLng.clear();
                    } else {
                      multipleDropPoints.removeAt(i);
                      multipleDropPointsFocus.removeAt(i);
                      multiDropLatLng.remove(i);
                    }
                    setState(() {});
                  },
                  icon: Icon(Icons.remove_circle_outline),
                ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.menu),
              )
            ],
          ),
      ],
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = multipleDropPoints.removeAt(oldIndex);
          multipleDropPoints.insert(newIndex, item);
        });
      },
    );
  }
}
