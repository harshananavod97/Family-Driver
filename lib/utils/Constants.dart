import 'package:flutter/material.dart';
import 'images.dart';

//region App name
const mAppName = 'Family Driver';
//endregion
// region Google map key
const GOOGLE_MAP_API_KEY = 'AIzaSyDUBAIjQdKM4JwMmBj_v0ew1uNQCgnsvE4';
//endregion

//region DomainUrl
const DOMAIN_URL =
    'https://familydriver.lk'; // Don't add slash at the end of the url
//endregion

//region OneSignal Keys
//You have to generate 2 onesignal app one for rider and one for driver
const mOneSignalAppIdDriver = 'e6ac2f3b-62d5-43ff-9f1a-0646134ea99a';
const mOneSignalRestKeyDriver =
    'os_v2_app_42wc6o3c2vb77hy2azdbgtvjtinjitqdohvehnf7wyujb7s6hqmuo5gte27cvwznd6ctqrt75gyxanvnorqwujezoiojfo4ei4gwruq';
const mOneSignalDriverChannelID = 'YOUR_ONESIGNAL_CHANNEL_ID_DRIVER';

const mOneSignalAppIdRider = 'a51778b5-a765-470a-bcea-abbde4138c04';
const mOneSignalRestKeyRider =
    'os_v2_app_uulxrnnhmvdqvphkvo66ie4maqn5d22anurut6f4mfw45o6dldn3yg2m6wydir22kubna4vwvgbih3qijuyqu6qpiahawxzrxqiltqi';
const mOneSignalRiderChannelID = 'YOUR_ONESIGNAL_CHANNEL_ID_RIDER';
//endregion

//region firebase configuration
// FIREBASE VALUES FOR ANDROID APP
const apiKeyFirebase =
    'AIzaSyCeQkx7cNH0n0BnrixKEmX0Fv2DfhRr1GI'; // Current API key
const appIdAndroid =
    '1:486159786077:android:deef92e584e41de0f7edb4'; // Correct app ID
const projectId = 'family-driver-40a64'; // Correct project ID
const storageBucket =
    'family-driver-40a64.firebasestorage.app'; // Correct storage bucket
const messagingSenderId = '486159786077'; // Extracted from the project info
const authDomain = "family-driver-40a64.firebaseapp.com"; // Correct auth domain
const measurementId =
    "G-BZZTH7LFZ2"; // Replace with your actual measurement ID, if available.
// You'll need to get this from Firebase Analytics
// FIREBASE VALUES FOR IOS APP
const appIdIOS = '1:486159786077:ios:7bc1b27a84be4008f7edb4';
const IOS_BUNDLE_ID = 'com.familydriver.rider';
const AndroidClientID =
    '486159786077-2901stfnv1m8nuee9fme9h2hfg5r30sl.apps.googleusercontent.com';
const IOSClientID =
    "486159786077-bi407oi799qvbv3qo6c4macpilbk5uka.apps.googleusercontent.com";
//endregion

//region Currency & country code
const currencySymbol = 'RS';
const currencyNameConst = 'LKR';
const defaultCountry = 'LK';
const digitAfterDecimal = 2;
//endregion

//region top up default value
const PRESENT_TOP_UP_AMOUNT_CONST = '1000|2000|3000';
const PRESENT_TIP_AMOUNT_CONST = '10|20|30';
//endregion

const walkthrough_image_1 = ic_walk1;
const walkthrough_image_2 = ic_walk2;
const walkthrough_image_3 = ic_walk3;

//region url
const mBaseUrl = "$DOMAIN_URL/api/";
//endregion

//region userType
const ADMIN = 'admin';
const DRIVER = 'driver';
const RIDER = 'rider';
//endregion

const PER_PAGE = 15;
const passwordLengthGlobal = 8;
const defaultRadius = 10.0;
const defaultSmallRadius = 6.0;

const textPrimarySizeGlobal = 16.00;
const textBoldSizeGlobal = 16.00;
const textSecondarySizeGlobal = 14.00;

double tabletBreakpointGlobal = 600.0;
double desktopBreakpointGlobal = 720.0;
double statisticsItemWidth = 230.0;
double defaultAppButtonElevation = 4.0;

bool enableAppButtonScaleAnimationGlobal = true;
int? appButtonScaleAnimationDurationGlobal;
ShapeBorder? defaultAppButtonShapeBorder;

var customDialogHeight = 140.0;
var customDialogWidth = 220.0;

enum ThemeModes { SystemDefault, Light, Dark }

//region loginType
const LoginTypeApp = 'app';
const LoginTypeGoogle = 'google';
const LoginTypeOTP = 'otp';
const LoginTypeApple = 'apple';
//endregion

//region SharedReference keys
const REMEMBER_ME = 'REMEMBER_ME';
const IS_FIRST_TIME = 'IS_FIRST_TIME';
const IS_LOGGED_IN = 'IS_LOGGED_IN';
const LEFT = 'left';

const USER_ID = 'USER_ID';
const FIRST_NAME = 'FIRST_NAME';
const LAST_NAME = 'LAST_NAME';
const TOKEN = 'TOKEN';
const USER_EMAIL = 'USER_EMAIL';
const USER_TOKEN = 'USER_TOKEN';
const USER_PROFILE_PHOTO = 'USER_PROFILE_PHOTO';
const USER_TYPE = 'USER_TYPE';
const USER_NAME = 'USER_NAME';
const USER_PASSWORD = 'USER_PASSWORD';
const USER_ADDRESS = 'USER_ADDRESS';
const STATUS = 'STATUS';
const CONTACT_NUMBER = 'CONTACT_NUMBER';
const PLAYER_ID = 'PLAYER_ID';
const UID = 'UID';
const ADDRESS = 'ADDRESS';
const IS_OTP = 'IS_OTP';
const IS_GOOGLE = 'IS_GOOGLE';
const GENDER = 'GENDER';
const IS_TIME = 'IS_TIME';
const IS_TIME2 = 'IS_TIME_BID';
const REMAINING_TIME = 'REMAINING_TIME';
const REMAINING_TIME2 = 'REMAINING_TIME_BID';
const LOGIN_TYPE = 'login_type';
const COUNTRY = 'COUNTRY';
const LATITUDE = 'LATITUDE';
const LONGITUDE = 'LONGITUDE';
//endregion

//region Taxi Status
const ACTIVE = 'active';
const IN_ACTIVE = 'inactive';
const PENDING = 'pending';
const BANNED = 'banned';
const REJECT = 'reject';
//endregion

//region Wallet keys
const CREDIT = 'credit';
const DEBIT = 'debit';
const OTHERS = 'Others';
//endregion

//region paymentType
const PAYMENT_TYPE_STRIPE = 'stripe';
const PAYMENT_TYPE_RAZORPAY = 'razorpay';
const PAYMENT_TYPE_PAYSTACK = 'paystack';
const PAYMENT_TYPE_FLUTTERWAVE = 'flutterwave';
const PAYMENT_TYPE_PAYPAL = 'paypal';
const PAYMENT_TYPE_PAYTABS = 'paytabs';
const PAYMENT_TYPE_MERCADOPAGO = 'mercadopago';
const PAYMENT_TYPE_PAYTM = 'paytm';
const PAYMENT_TYPE_MYFATOORAH = 'myfatoorah';

const stripeURL = 'https://api.stripe.com/v1/payment_intents';
//endregion

var errorThisFieldRequired = 'This field is required';

//region Ride Status
const UPCOMING = 'upcoming';
const NEW_RIDE_REQUESTED = 'new_ride_requested';
const ACCEPTED = 'accepted';
const BID_ACCEPTED = 'bid_accepted';
const ARRIVING = 'arriving';
const ARRIVED = 'arrived';
const IN_PROGRESS = 'in_progress';
const CANCELED = 'canceled';
const COMPLETED = 'completed';
const SUCCESS = 'payment_status_message';
const AUTO = 'auto';
const COMPLAIN_COMMENT = "complaintcomment";
//endregion

///fix Decimal
const fixedDecimal = digitAfterDecimal;

//region
const CHARGE_TYPE_FIXED = 'fixed';
const CHARGE_TYPE_PERCENTAGE = 'percentage';
const CASH_WALLET = 'cash_wallet';
const CASH = 'cash';
const MALE = 'male';
const FEMALE = 'female';
const OTHER = 'other';
const WALLET = 'wallet';
const DISTANCE_TYPE_KM = 'km';
const DISTANCE_TYPE_MILE = 'mile';
//endregion

//region app setting key
const CLOCK = 'clock';
const PRESENT_TOPUP_AMOUNT = 'preset_topup_amount';
const PRESENT_TIP_AMOUNT = 'preset_tip_amount';
const RIDE_FOR_OTHER = 'RIDE_FOR_OTHER';
const IS_MULTI_DROP = 'RIDE_MULTIPLE_DROP_LOCATION';
const IS_BID_ENABLE = 'is_bidding';
const MAX_TIME_FOR_RIDER_MINUTE =
    'max_time_for_find_drivers_for_regular_ride_in_minute';
const MAX_TIME_FOR_DRIVER_SECOND =
    'ride_accept_decline_duration_for_driver_in_second';
const MIN_AMOUNT_TO_ADD = 'min_amount_to_add';
const MAX_AMOUNT_TO_ADD = 'max_amount_to_add';
//endregion

//region FireBase Collection Name
const MESSAGES_COLLECTION = "RideTalk";
// const MESSAGES_COLLECTION = "messages";
const RIDE_CHAT = "RideTalkHistory";
const RIDE_COLLECTION = 'rides';

const USER_COLLECTION = "users";
// const CONTACT_COLLECTION = "contact";
// const CHAT_DATA_IMAGES = "chatImages";
//endregion

const IS_ENTER_KEY = "IS_ENTER_KEY";
const SELECTED_WALLPAPER = "SELECTED_WALLPAPER";
const PER_PAGE_CHAT_COUNT = 50;
const TEXT = "TEXT";
const IMAGE = "IMAGE";
const VIDEO = "VIDEO";
const AUDIO = "AUDIO";
const FIXED_CHARGES = "fixed_charges";
const MIN_DISTANCE = "min_distance";
const MIN_WEIGHT = "min_weight";
const PER_DISTANCE_CHARGE = "per_distance_charges";
const PER_WEIGHT_CHARGE = "per_weight_charges";
const PAID = 'paid';
const PAYMENT_PENDING = 'pending';
const PAYMENT_FAILED = 'failed';
const PAYMENT_PAID = 'paid';
const THEME_MODE_INDEX = 'theme_mode_index';
const CHANGE_MONEY = 'CHANGE_MONEY';
const CHANGE_LANGUAGE = 'CHANGE_LANGUAGE';
List<String> rtlLanguage = ['ar', 'ur'];

enum MessageType { TEXT, IMAGE, VIDEO, AUDIO }

extension MessageExtension on MessageType {
  String? get name {
    switch (this) {
      case MessageType.TEXT:
        return 'TEXT';
      case MessageType.IMAGE:
        return 'IMAGE';
      case MessageType.VIDEO:
        return 'VIDEO';
      case MessageType.AUDIO:
        return 'AUDIO';
      default:
        return null;
    }
  }
}

var errorSomethingWentWrong = 'Something Went Wrong';

var demoEmail = 'admin@familydriver.lk';
const mRazorDescription = mAppName;
const mStripeIdentifier = 'LK';
