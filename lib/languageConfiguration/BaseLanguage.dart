import 'package:flutter/material.dart';

import 'LanguageDataConstant.dart';

class BaseLanguage {
  static BaseLanguage? of(BuildContext context) {
    try {
      return Localizations.of<BaseLanguage>(context, BaseLanguage);
    } catch (e) {
      throw e;
    }
  }

  String get appName => getContentValueFromKey(1);

  String get thisFieldRequired => getContentValueFromKey(2);

  String get email => getContentValueFromKey(3);

  String get password => getContentValueFromKey(4);

  String get forgotPassword => getContentValueFromKey(5);

  String get logIn => getContentValueFromKey(6);

  String get orLogInWith => getContentValueFromKey(7);

  String get donHaveAnAccount => getContentValueFromKey(8);

  String get signUp => getContentValueFromKey(9);

  String get createAccount => getContentValueFromKey(10);

  String get firstName => getContentValueFromKey(11);

  String get lastName => getContentValueFromKey(12);

  String get userName => getContentValueFromKey(13);

  String get phoneNumber => getContentValueFromKey(14);

  String get alreadyHaveAnAccount => getContentValueFromKey(15);

  String get changePassword => getContentValueFromKey(16);

  String get oldPassword => getContentValueFromKey(17);

  String get newPassword => getContentValueFromKey(18);

  String get confirmPassword => getContentValueFromKey(19);

  String get passwordDoesNotMatch => getContentValueFromKey(20);

  String get passwordInvalid => getContentValueFromKey(21);

  String get yes => getContentValueFromKey(22);

  String get no => getContentValueFromKey(23);

  String get writeMessage => getContentValueFromKey(24);

  String get enterTheEmailAssociatedWithYourAccount => getContentValueFromKey(25);

  String get submit => getContentValueFromKey(26);

  String get language => getContentValueFromKey(27);

  String get notification => getContentValueFromKey(28);

  String get useInCaseOfEmergency => getContentValueFromKey(29);

  String get notifyAdmin => getContentValueFromKey(30);

  String get notifiedSuccessfully => getContentValueFromKey(31);

  String get complain => getContentValueFromKey(32);

  String get pleaseEnterSubject => getContentValueFromKey(33);

  String get writeDescription => getContentValueFromKey(34);

  String get saveComplain => getContentValueFromKey(35);

  String get editProfile => getContentValueFromKey(36);

  String get address => getContentValueFromKey(37);

  String get updateProfile => getContentValueFromKey(38);

  String get notChangeUsername => getContentValueFromKey(39);

  String get notChangeEmail => getContentValueFromKey(40);

  String get profileUpdateMsg => getContentValueFromKey(41);

  String get emergencyContact => getContentValueFromKey(42);

  String get areYouSureYouWantDeleteThisNumber => getContentValueFromKey(43);

  String get addContact => getContentValueFromKey(44);

  String get save => getContentValueFromKey(45);

  String get availableBalance => getContentValueFromKey(46);

  String get recentTransactions => getContentValueFromKey(47);

  String get moneyDeposited => getContentValueFromKey(48);

  String get addMoney => getContentValueFromKey(49);

  String get cancel => getContentValueFromKey(50);

  String get pleaseSelectAmount => getContentValueFromKey(51);

  String get amount => getContentValueFromKey(52);

  String get capacity => getContentValueFromKey(53);

  String get paymentMethod => getContentValueFromKey(54);

  String get chooseYouPaymentLate => getContentValueFromKey(55);

  String get enterPromoCode => getContentValueFromKey(56);

  String get confirm => getContentValueFromKey(57);

  String get forInstantPayment => getContentValueFromKey(58);

  String get bookNow => getContentValueFromKey(59);

  String get wallet => getContentValueFromKey(60);

  String get paymentDetail => getContentValueFromKey(61);

  String get rideId => getContentValueFromKey(62);

  String get viewHistory => getContentValueFromKey(63);

  String get paymentDetails => getContentValueFromKey(64);

  String get paymentType => getContentValueFromKey(65);

  String get paymentStatus => getContentValueFromKey(66);

  String get priceDetail => getContentValueFromKey(67);

  String get basePrice => getContentValueFromKey(68);

  String get distancePrice => getContentValueFromKey(69);

  String get waitTime => getContentValueFromKey(70);

  String get extraCharges => getContentValueFromKey(71);

  String get couponDiscount => getContentValueFromKey(72);

  String get total => getContentValueFromKey(73);

  String get payment => getContentValueFromKey(74);

  String get cash => getContentValueFromKey(75);

  String get updatePaymentStatus => getContentValueFromKey(76);

  String get waitingForDriverConformation => getContentValueFromKey(77);

  String get continueNewRide => getContentValueFromKey(78);

  String get payToPayment => getContentValueFromKey(79);

  String get tip => getContentValueFromKey(80);

  String get pay => getContentValueFromKey(81);

  String get howWasYourRide => getContentValueFromKey(82);

  String get wouldYouLikeToAddTip => getContentValueFromKey(83);

  String get addMoreTip => getContentValueFromKey(84);

  String get addMore => getContentValueFromKey(85);

  String get addReviews => getContentValueFromKey(86);

  String get writeYourComments => getContentValueFromKey(87);

  String get continueD => getContentValueFromKey(88);

  String get aboutDriver => getContentValueFromKey(89);

  String get rideHistory => getContentValueFromKey(90);

  String get emergencyContacts => getContentValueFromKey(91);

  String get logOut => getContentValueFromKey(92);

  String get areYouSureYouWantToLogoutThisApp => getContentValueFromKey(93);

  String get whatWouldYouLikeToGo => getContentValueFromKey(94);

  String get enterYourDestination => getContentValueFromKey(95);

  String get currentLocation => getContentValueFromKey(96);

  String get destinationLocation => getContentValueFromKey(97);

  String get chooseOnMap => getContentValueFromKey(98);

  String get profile => getContentValueFromKey(99);

  String get privacyPolicy => getContentValueFromKey(100);

  String get helpSupport => getContentValueFromKey(101);

  String get termsConditions => getContentValueFromKey(102);

  String get aboutUs => getContentValueFromKey(103);

  String get lookingForNearbyDrivers => getContentValueFromKey(104);

  String get weAreLookingForNearDriversAcceptsYourRide => getContentValueFromKey(105);

  String get get => getContentValueFromKey(106);

  String get rides => getContentValueFromKey(107);

  String get people => getContentValueFromKey(108);

  String get done => getContentValueFromKey(109);

  String get availableOffers => getContentValueFromKey(110);

  String get off => getContentValueFromKey(111);

  String get sendOTP => getContentValueFromKey(112);

  String get carModel => getContentValueFromKey(113);

  String get sos => getContentValueFromKey(114);

  String get driverReview => getContentValueFromKey(115);

  String get signInUsingYourMobileNumber => getContentValueFromKey(116);

  String get otp => getContentValueFromKey(117);

  String get newRideRequested => getContentValueFromKey(118);

  String get accepted => getContentValueFromKey(119);

  String get arriving => getContentValueFromKey(120);

  String get arrived => getContentValueFromKey(121);

  String get inProgress => getContentValueFromKey(122);

  String get cancelled => getContentValueFromKey(123);

  String get completed => getContentValueFromKey(124);

  String get pleaseEnableLocationPermission => getContentValueFromKey(125);

  String get pending => getContentValueFromKey(126);

  String get failed => getContentValueFromKey(127);

  String get paid => getContentValueFromKey(128);

  String get male => getContentValueFromKey(129);

  String get female => getContentValueFromKey(130);

  String get other => getContentValueFromKey(131);

  String get deleteAccount => getContentValueFromKey(132);

  String get account => getContentValueFromKey(133);

  String get areYouSureYouWantPleaseReadAffect => getContentValueFromKey(134);

  String get deletingAccountEmail => getContentValueFromKey(135);

  String get areYouSureYouWantDeleteAccount => getContentValueFromKey(136);

  String get yourInternetIsNotWorking => getContentValueFromKey(137);

  String get allow => getContentValueFromKey(138);

  String get mostReliableMightyRiderApp => getContentValueFromKey(139);

  String get toEnjoyYourRideExperiencePleaseAllowPermissions => getContentValueFromKey(140);

  String get txtURLEmpty => getContentValueFromKey(141);

  String get lblFollowUs => getContentValueFromKey(142);

  String get duration => getContentValueFromKey(143);

  String get paymentVia => getContentValueFromKey(144);

  String get demoMsg => getContentValueFromKey(145);

  String get findPlace => getContentValueFromKey(146);

  String get pleaseWait => getContentValueFromKey(147);

  String get selectPlace => getContentValueFromKey(148);

  String get placeNotInArea => getContentValueFromKey(149);

  String get youCannotChangePhoneNumber => getContentValueFromKey(150);

  String get complainList => getContentValueFromKey(151);

  String get writeMsg => getContentValueFromKey(152);

  String get pleaseEnterMsg => getContentValueFromKey(153);

  String get viewAll => getContentValueFromKey(154);

  String get pleaseSelectRating => getContentValueFromKey(155);

  String get moneyDebit => getContentValueFromKey(156);

  String get pleaseAcceptTermsOfServicePrivacyPolicy => getContentValueFromKey(157);

  String get rememberMe => getContentValueFromKey(158);

  String get iAgreeToThe => getContentValueFromKey(159);

  String get driverInformation => getContentValueFromKey(160);

  String get nameFieldIsRequired => getContentValueFromKey(161);

  String get phoneNumberIsRequired => getContentValueFromKey(162);

  String get enterName => getContentValueFromKey(163);

  String get enterContactNumber => getContentValueFromKey(164);

  String get invoice => getContentValueFromKey(165);

  String get customerName => getContentValueFromKey(166);

  String get sourceLocation => getContentValueFromKey(167);

  String get invoiceNo => getContentValueFromKey(168);

  String get invoiceDate => getContentValueFromKey(169);

  String get orderedDate => getContentValueFromKey(170);

  String get lblCarNumberPlate => getContentValueFromKey(171);

  String get lblRide => getContentValueFromKey(172);

  String get lblRideInformation => getContentValueFromKey(173);

  String get lblWhereAreYou => getContentValueFromKey(174);

  String get lblDropOff => getContentValueFromKey(175);

  String get lblDistance => getContentValueFromKey(176);

  String get lblSomeoneElse => getContentValueFromKey(177);

  String get lblYou => getContentValueFromKey(178);

  String get lblWhoRidingMsg => getContentValueFromKey(179);

  String get lblNext => getContentValueFromKey(180);

  String get lblLessWalletAmount => getContentValueFromKey(181);

  String get lblPayWhenEnds => getContentValueFromKey(182);

  String get maximum => getContentValueFromKey(183);

  String get required => getContentValueFromKey(184);

  String get minimum => getContentValueFromKey(185);

  String get withDraw => getContentValueFromKey(186);

  String get withdrawHistory => getContentValueFromKey(187);

  String get approved => getContentValueFromKey(188);

  String get requested => getContentValueFromKey(189);

  String get minimumFare => getContentValueFromKey(190);

  String get cancelRide => getContentValueFromKey(191);

  String get cancelledReason => getContentValueFromKey(192);

  String get selectReason => getContentValueFromKey(193);

  String get writeReasonHere => getContentValueFromKey(194);

  String get driverGoingWrongDirection => getContentValueFromKey(195);

  String get pickUpTimeTakingTooLong => getContentValueFromKey(196);

  String get driverAskedMeToCancel => getContentValueFromKey(197);

  String get others => getContentValueFromKey(198);

  String get baseFare => getContentValueFromKey(199);

  String get perDistance => getContentValueFromKey(200);

  String get perMinDrive => getContentValueFromKey(201);

  String get perMinWait => getContentValueFromKey(202);

  String get min => getContentValueFromKey(203);

  String get unsupportedPlateForm => getContentValueFromKey(204);

  String get invoiceCapital => getContentValueFromKey(205);

  String get description => getContentValueFromKey(206);

  String get price => getContentValueFromKey(207);

  String get gallery => getContentValueFromKey(208);

  String get camera => getContentValueFromKey(209);

  String get bankInfoUpdated => getContentValueFromKey(210);

  String get bankInfo => getContentValueFromKey(211);

  String get bankName => getContentValueFromKey(212);

  String get bankCode => getContentValueFromKey(213);

  String get accountHolderName => getContentValueFromKey(214);

  String get accountNumber => getContentValueFromKey(215);

  String get updateBankDetail => getContentValueFromKey(216);

  String get addBankDetail => getContentValueFromKey(217);

  String get locationNotAvailable => getContentValueFromKey(218);

  String get servicesNotFound => getContentValueFromKey(219);

  String get paymentFailed => getContentValueFromKey(220);

  String get checkConsoleForError => getContentValueFromKey(221);

  String get transactionFailed => getContentValueFromKey(222);

  String get transactionSuccessful => getContentValueFromKey(223);

  String get payWithCard => getContentValueFromKey(224);

  String get success => getContentValueFromKey(225);

  String get skip => getContentValueFromKey(226);

  String get declined => getContentValueFromKey(227);

  String get validateOtp => getContentValueFromKey(228);

  String get otpCodeHasBeenSentTo => getContentValueFromKey(229);

  String get pleaseEnterOtp => getContentValueFromKey(230);

  String get selectSources => getContentValueFromKey(231);

  String get whoWillBeSeated => getContentValueFromKey(232);

  String get via => getContentValueFromKey(233);

  String get status => getContentValueFromKey(234);

  String get riderInformation => getContentValueFromKey(235);

  String get minutePrice => getContentValueFromKey(236);

  String get waitingTimePrice => getContentValueFromKey(237);

  String get additionalFees => getContentValueFromKey(238);

  String get settings => getContentValueFromKey(239);

  String get welcome => getContentValueFromKey(240);

  String get signContinue => getContentValueFromKey(241);

  String get passwordLength => getContentValueFromKey(242);

  String get bothPasswordNotMatch => getContentValueFromKey(243);

  String get missingBankDetail => getContentValueFromKey(244);

  String get close => getContentValueFromKey(245);

  String get copied => getContentValueFromKey(246);

  String get noNearByDriverFound => getContentValueFromKey(247);

  String get paymentSuccess => getContentValueFromKey(248);

  String get safetyConcerns => getContentValueFromKey(249);

  String get driverNotShown => getContentValueFromKey(250);

  String get noNeedRide => getContentValueFromKey(251);

  String get needToEditRideOld => getContentValueFromKey(251);

  String get infoNotMatch => getContentValueFromKey(252);

  String get rideCanceledByDriver => getContentValueFromKey(253);

  String get networkErr => getContentValueFromKey(254);

  String get tryAgain => getContentValueFromKey(255);

  String get noConnected => getContentValueFromKey(256);

  String get rideComplete => getContentValueFromKey(257);

  String get detailScreen => getContentValueFromKey(258);

  String get bankInfoNotFound => getContentValueFromKey(259);

  String get noBalanceValidate => getContentValueFromKey(260);

  String get iban => getContentValueFromKey(261);

  String get swift => getContentValueFromKey(262);

  String get routingNumber => getContentValueFromKey(263);

  String get fixedPrice => getContentValueFromKey(264);

  String get viewDropLocations => getContentValueFromKey(265);

  String get viewMore => getContentValueFromKey(266);

  String get addDropPoint => getContentValueFromKey(267);

  String get dropPoint => getContentValueFromKey(268);

  String get needToEditRide => getContentValueFromKey(269);

  String get walkthrough_title_1 => getContentValueFromKey(270);

  String get walkthrough_title_2 => getContentValueFromKey(271);

  String get walkthrough_title_3 => getContentValueFromKey(272);

  String get walkthrough_subtitle_1 => getContentValueFromKey(273);

  String get walkthrough_subtitle_2 => getContentValueFromKey(274);

  String get walkthrough_subtitle_3 => getContentValueFromKey(275);

  String get driver_walkthrough_title_1 => getContentValueFromKey(362);

  String get driver_walkthrough_title_2 => getContentValueFromKey(363);

  String get driver_walkthrough_title_3 => getContentValueFromKey(364);

  String get driver_walkthrough_subtitle_1 => getContentValueFromKey(365);

  String get driver_walkthrough_subtitle_2 => getContentValueFromKey(366);

  String get driver_walkthrough_subtitle_3 => getContentValueFromKey(367);

  String get bid_for_ride => getContentValueFromKey(369);
  String get bids => getContentValueFromKey(368);
  String get no_bids_note => getContentValueFromKey(378);
  String get bid_book => getContentValueFromKey(370);

  String get note => getContentValueFromKey(380);
  String get fullCashPayment => getContentValueFromKey(381);
  String get moreMoneyForWalletPayment => getContentValueFromKey(382);
  String get tripDistance => getContentValueFromKey(383);

  String get updateAvailable => getContentValueFromKey(387);
  String get updateNote => getContentValueFromKey(388);
  String get updateNow => getContentValueFromKey(389);
}
