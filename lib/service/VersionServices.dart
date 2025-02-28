import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../components/UpdateAvailablePopUp.dart';

class VersionService {

  getVersionData(context,value) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    num currentBuildNumberAndroid = num.tryParse(packageInfo.buildNumber.toString()) ?? 0;
    if (Platform.isAndroid) {
      num liveBuildNumber = num.tryParse(value['android_version_code'].toString()) ?? 0;
      if (currentBuildNumberAndroid != 0 && currentBuildNumberAndroid < liveBuildNumber) {
        //   update is available
        if (value['android_force_update'].toString() == "1") {
          //   update force
          //   UpdateAvailable(force:true).launch(context);
          showDialog(context: context, builder: (context) => UpdateAvailable(force: true,storeUrl:value['playstore_url'].toString(),), barrierDismissible: false);
        } else {
          //   optional update suggest only skip-able
          //   UpdateAvailable(force:true).launch(context);
          showDialog(
            context: context,
            builder: (context) => UpdateAvailable(storeUrl:value['playstore_url'].toString()),
          );
        }
      } else {
        //   no update available
      }
    } else if (Platform.isIOS) {
      print("isVersionGreater.call ==>LIVE-VERSION:${value['ios_version'].toString()}  LOCAL-VERSION:${packageInfo.data['version'].toString()}");
      if (isVersionGreater(value['ios_version'].toString(), packageInfo.data['version'].toString())) {
        print("IOS_UPDATE_DETECTED");
        //   update is available
        if (value['ios_force_update'].toString() == "1") {
          //   update force
          showDialog(context: context, builder: (context) => UpdateAvailable(force: true,storeUrl: value['appstore_url'].toString(),), barrierDismissible: false);
        } else {
          //   optional update suggest only skip-able
          showDialog(
            context: context,
            builder: (context) => UpdateAvailable(storeUrl: value['appstore_url'].toString()),
          );
        }
      } else {
        print("IOS_NO_UPDATE");
        //   no update available
      }
    }
  }
}

bool isVersionGreater(String version1, String version2) {
  // Split the version strings into parts
  List<String> versionParts1 = version1.split('.');
  List<String> versionParts2 = version2.split('.');

  // Determine the maximum length of the version parts
  int maxLength = versionParts1.length > versionParts2.length ? versionParts1.length : versionParts2.length;

  // Pad shorter version with zeros
  while (versionParts1.length < maxLength) {
    versionParts1.add('0');
  }
  while (versionParts2.length < maxLength) {
    versionParts2.add('0');
  }

  // Compare each part of the version
  for (int i = 0; i < maxLength; i++) {
    // Parse each part as an integer
    int part1 = int.parse(versionParts1[i]);
    int part2 = int.parse(versionParts2[i]);

    // Compare the parts
    if (part1 > part2) return true;
    if (part1 < part2) return false;
  }

  // If all parts are equal, the versions are the same
  return false;
}
