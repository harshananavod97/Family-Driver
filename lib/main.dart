import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_booking/utils/firebase_option.dart';
import '/model/FileModel.dart';
import '../network/RestApis.dart';
import '../utils/Extensions/dataTypeExtensions.dart';
import 'AppTheme.dart';
import 'languageConfiguration/AppLocalizations.dart';
import 'languageConfiguration/BaseLanguage.dart';
import 'languageConfiguration/LanguageDataConstant.dart';
import 'languageConfiguration/LanguageDefaultJson.dart';
import 'languageConfiguration/ServerLanguageResponse.dart';
import 'screens/NoInternetScreen.dart';
import 'screens/SplashScreen.dart';
import 'service/ChatMessagesService.dart';
import 'service/NotificationService.dart';
import 'service/UserServices.dart';
import 'store/AppStore.dart';
import 'utils/Colors.dart';
import 'utils/Common.dart';
import 'utils/Constants.dart';
import 'utils/Extensions/app_common.dart';

LanguageJsonData? selectedServerLanguageData;
List<LanguageJsonData>? defaultServerLanguageData = [];

AppStore appStore = AppStore();
late SharedPreferences sharedPref;
Color textPrimaryColorGlobal = textPrimaryColor;
Color textSecondaryColorGlobal = textSecondaryColor;
Color defaultLoaderBgColorGlobal = Colors.white;
LatLng polylineSource = LatLng(0.00, 0.00);
LatLng polylineDestination = LatLng(0.00, 0.00);
late BaseLanguage language;
late List<FileModel> fileList = [];
bool mIsEnterKey = false;
final GlobalKey netScreenKey = GlobalKey();
final GlobalKey locationScreenKey = GlobalKey();
ChatMessageService chatMessageService = ChatMessageService();
NotificationService notificationService = NotificationService();
UserService userService = UserService();
late Position currentPosition;
final navigatorKey = GlobalKey<NavigatorState>();

get getContext => navigatorKey.currentState?.overlay?.context;
var app_update_check = null;
LatLng? sourceLocation;
late BitmapDescriptor riderIcon;
String sourceLocationTitle = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPref = await SharedPreferences.getInstance();
  if (Platform.isIOS) {
    await Firebase.initializeApp();
  } else {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  appStore.setLanguage(
      sharedPref.getString(SELECTED_LANGUAGE_CODE) ?? defaultLanguageCode);
  await appStore.setLoggedIn(sharedPref.getBool(IS_LOGGED_IN) ?? false,
      isInitializing: true);
  await appStore.setUserEmail(sharedPref.getString(USER_EMAIL) ?? '',
      isInitialization: true);
  await appStore.setUserProfile(sharedPref.getString(USER_PROFILE_PHOTO) ?? '');
  try {
    initJsonFile();
  } catch (e) {}
  try {
    oneSignalSettings();
  } catch (e) {}
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  FlutterError.onError = (FlutterErrorDetails details) {
    // FlutterError.dumpErrorToConsole(details);
    // print("ERRORTYPE1::${details.runtimeType}");
    // print("ERRORTYPE2::${details.library}");
    // print("ERRORTYPE3::${details.silent}");
    // print("ERRORTYPE3::${details.stackFilter}");
    // details.
    // if(!details.exception.toString().contains("Warning")&&!details.exception.toString().contains("RenderFlex")){
    //   print("CheckError:::${details.exception} ==>${details.stack}");
    //   runApp(CustomErrorView(details));
    // }
  };
  print("CheckPlayerID:::${sharedPref.getString(PLAYER_ID)}");
  runApp(MyApp());
}

Future<void> updatePlayerId() async {
  Map req = {
    "player_id": sharedPref.getString(PLAYER_ID),
  };
  updateStatus(req).then((value) {
    //
  }).catchError((error) {
    //
  });
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
    connectivitySubscription.cancel();
  }

  void init() async {
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((e) {
      if (e.contains(ConnectivityResult.none)) {
        log('not connected');
        launchScreen(
            navigatorKey.currentState!.overlay!.context, NoInternetScreen());
      } else {
        if (netScreenKey.currentContext != null) {
          if (Navigator.canPop(navigatorKey.currentState!.overlay!.context)) {
            Navigator.pop(navigatorKey.currentState!.overlay!.context);
          }
        }
        log('connected');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: mAppName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) {
          return ScrollConfiguration(behavior: MyBehavior(), child: child!);
        },
        home: SplashScreen(),
        supportedLocales: getSupportedLocales(),
        locale: Locale(
            appStore.selectedLanguage.validate(value: defaultLanguageCode)),
        localizationsDelegates: [
          AppLocalizations(),
          CountryLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
      );
    });
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
