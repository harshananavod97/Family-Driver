import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../languageConfiguration/LanguageDataConstant.dart';
import '../languageConfiguration/ServerLanguageResponse.dart';
import '../service/VersionServices.dart';
import '../utils/Common.dart';
import '../utils/Extensions/dataTypeExtensions.dart';
import '../main.dart';
import '../../screens/WalkThroughtScreen.dart';
import '../../utils/Colors.dart';
import '../../utils/Constants.dart';
import '../../utils/Extensions/app_common.dart';
import '../network/RestApis.dart';
import '../utils/images.dart';
import 'EditProfileScreen.dart';
import 'SignInScreen.dart';
import 'DashBoardScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkNotifyPermission();
  }

  void init() async {
    List<ConnectivityResult> b = await Connectivity().checkConnectivity();
    if (b.contains(ConnectivityResult.none)) {
      return toast(language.yourInternetIsNotWorking);
    }
    await Future.delayed(Duration(seconds: 1));
    if (sharedPref.getBool(IS_FIRST_TIME) ?? true) {
      await Geolocator.requestPermission().then((value) async {
        launchScreen(context, WalkThroughScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
        Geolocator.getCurrentPosition().then((value) {
          sharedPref.setDouble(LATITUDE, value.latitude);
          sharedPref.setDouble(LONGITUDE, value.longitude);
        });
      }).catchError((e) {
        launchScreen(context, WalkThroughScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
      });
    } else {
      if (!appStore.isLoggedIn) {
        launchScreen(context, SignInScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
      } else {
        if (sharedPref.getString(CONTACT_NUMBER).validate().isEmptyOrNull) {
          launchScreen(context, EditProfileScreen(isGoogle: true), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide);
        } else {
          getUserDetail(userId: sharedPref.getInt(USER_ID)).then((value) {
            appStore.setUserEmail(value.data!.email.validate());
            appStore.setUserName(value.data!.username.validate());
            appStore.setFirstName(value.data!.firstName.validate());
            appStore.setUserProfile(value.data!.profileImage.validate());

            sharedPref.setString(USER_EMAIL, value.data!.email.validate());
            sharedPref.setString(FIRST_NAME, value.data!.firstName.validate());
            sharedPref.setString(LAST_NAME, value.data!.lastName.validate());
            sharedPref.setString(USER_PROFILE_PHOTO, value.data!.profileImage.validate());

            appStore.setLoading(false);
            setState(() {});
          }).catchError((error) {
            log(error.toString());
            appStore.setLoading(false);
          });
          if (await checkPermission())
            await Geolocator.requestPermission().then((value) async {
              await Geolocator.getCurrentPosition().then((value) {
                sharedPref.setDouble(LATITUDE, value.latitude);
                sharedPref.setDouble(LONGITUDE, value.longitude);
                launchScreen(context, DashBoardScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
              });
            }).catchError((e) {
              launchScreen(context, DashBoardScreen(), pageRouteAnimation: PageRouteAnimation.Slide, isNewTask: true);
            });
        }
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(ic_logo_white, fit: BoxFit.contain, height: 150, width: 150),
            SizedBox(height: 16),
            Text(mAppName, style: boldTextStyle(color: Colors.white, size: 22)),
          ],
        ),
      ),
    );
  }

  void _checkNotifyPermission() async {
    String versionNo =  sharedPref.getString(CURRENT_LAN_VERSION)??LanguageVersion;
    await getLanguageList(versionNo).then((value) {
      appStore.setLoading(false);
      app_update_check=value.rider_version;
      if (value.status == true) {
        setValue(CURRENT_LAN_VERSION, value.currentVersionNo.toString());
        if (value.data!.length > 0) {
          defaultServerLanguageData = value.data;
          performLanguageOperation(defaultServerLanguageData);
          setValue(LanguageJsonDataRes, value.toJson());
          bool isSetLanguage = sharedPref.getBool(IS_SELECTED_LANGUAGE_CHANGE)??false;
          if (!isSetLanguage) {
            for (int i = 0; i < value.data!.length; i++) {
              if (value.data![i].isDefaultLanguage == 1) {
                setValue(SELECTED_LANGUAGE_CODE, value.data![i].languageCode);
                setValue(SELECTED_LANGUAGE_COUNTRY_CODE, value.data![i].countryCode);
                appStore.setLanguage(value.data![i].languageCode!, context: context);
                break;
              }
            }
          }
        } else {
          defaultServerLanguageData = [];
          selectedServerLanguageData = null;
          setValue(LanguageJsonDataRes, "");
        }
      } else {
        String getJsonData = sharedPref.getString(LanguageJsonDataRes)??'';

        if (getJsonData.isNotEmpty) {
          ServerLanguageResponse languageSettings = ServerLanguageResponse.fromJson(json.decode(getJsonData.trim()));
          if (languageSettings.data!.length > 0) {
            defaultServerLanguageData = languageSettings.data;
            performLanguageOperation(defaultServerLanguageData);
          }
        }
      }
    }).catchError((error) {
      appStore.setLoading(false);
      log(error);
    });
    if (await Permission.notification.isGranted) {
      init();
    } else {
      await Permission.notification.request();
      init();
    }
  }
}
