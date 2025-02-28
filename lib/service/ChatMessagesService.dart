import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../model/ChatMessageModel.dart';
import '../utils/Constants.dart';
import 'BaseServices.dart';

class ChatMessageService extends BaseService {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  // late CollectionReference userRef;
  late CollectionReference rideChatRef;
  // FirebaseStorage _storage = FirebaseStorage.instance;

  ChatMessageService() {
    ref = fireStore.collection(MESSAGES_COLLECTION);
    // userRef = fireStore.collection(USER_COLLECTION);
    rideChatRef = fireStore.collection(RIDE_CHAT);
  }

  Query chatMessagesWithPagination({String? riderId, required String driverID, required int filter_msg}) {
    // ref!.doc('${currentUserId}_${receiverUserId}');
    return ref!.doc("${riderId}_${driverID}").collection("chats").orderBy("createdAt", descending: true);
    // return ref!.doc(currentUserId).collection(receiverUserId).orderBy("createdAt", descending: true);
    // return ref!.doc(currentUserId).collection(receiverUserId).orderBy("createdAt", descending: true);
  }

  Query rideSpecificChatMessagesWithPagination({required String rideId}) {
    return rideChatRef.doc(rideId).collection("messages").orderBy("createdAt", descending: true);
  }

  Future<bool> isRideChatHistory({required String rideId}) async {
    QuerySnapshot<Map<String, dynamic>> b = await rideChatRef.doc(rideId).collection("messages").get();
    if (b.docs.isEmpty) {
      return false;
    }
    return true;
  }

  Future<DocumentReference> addMessage(ChatMessageModel data) async {
    var doc2 = await ref!.doc("${data.senderId}_${data.receiverId}").collection("chats").add(data.toJson());
    doc2.update({'id': doc2.id});
    return doc2;
    var doc = await ref!.doc(data.senderId).collection(data.receiverId!).add(data.toJson());
    doc.update({'id': doc.id});
    return doc;
  }

  // Future<void> addMessageToDb(DocumentReference senderDoc, ChatMessageModel data, UserModel sender, UserModel? user, {File? image}) async {
  //   String imageUrl = '';
  //
  //   return;
  //   if (image != null) {
  //     String fileName = basename(image.path);
  //     Reference storageRef = _storage.ref().child("$CHAT_DATA_IMAGES/${sharedPref.getString(USER_ID)}/$fileName");
  //
  //     UploadTask uploadTask = storageRef.putFile(image);
  //
  //     await uploadTask.then((e) async {
  //       await e.ref.getDownloadURL().then((value) async {
  //         imageUrl = value;
  //
  //         fileList.removeWhere((element) => element.id == senderDoc.id);
  //       }).catchError((e) {
  //         log(e);
  //       });
  //     }).catchError((e) {
  //       log(e);
  //     });
  //   }
  //
  //   updateChatDocument(senderDoc, image: image, imageUrl: imageUrl);
  //
  //   userRef.doc(data.senderId).update({"lastMessageTime": data.createdAt});
  //   addToContacts(senderId: data.senderId, receiverId: data.receiverId);
  //
  //   DocumentReference receiverDoc = await ref!.doc(data.receiverId).collection(data.senderId!).add(data.toJson());
  //
  //   updateChatDocument(receiverDoc, image: image, imageUrl: imageUrl);
  //
  //   userRef.doc(data.receiverId).update({"lastMessageTime": data.createdAt});
  // }

  // DocumentReference? updateChatDocument(DocumentReference data, {File? image, String? imageUrl}) {
  //   Map<String, dynamic> sendData = {'id': data.id};
  //
  //   if (image != null) {
  //     sendData.putIfAbsent('photoUrl', () => imageUrl);
  //   }
  //   // log(sendData);
  //   data.update(sendData);
  //
  //   log("Data $sendData");
  //   return null;
  // }

  // DocumentReference getContactsDocument({String? of, String? forContact}) {
  //   return userRef.doc(of).collection(CONTACT_COLLECTION).doc(forContact);
  // }

  // addToContacts({String? senderId, String? receiverId}) async {
  //   Timestamp currentTime = Timestamp.now();
  //
  //   await addToSenderContacts(senderId, receiverId, currentTime);
  //   await addToReceiverContacts(senderId, receiverId, currentTime);
  // }

  // Future<void> addToSenderContacts(String? senderId, String? receiverId, currentTime) async {
  //   DocumentSnapshot senderSnapshot = await getContactsDocument(of: senderId, forContact: receiverId).get();
  //
  //   if (!senderSnapshot.exists) {
  //     //does not exists
  //     ContactDataModel receiverContact = ContactDataModel(
  //       uid: receiverId,
  //       addedOn: currentTime,
  //     );
  //
  //     await getContactsDocument(of: senderId, forContact: receiverId).set(receiverContact.toJson());
  //   }
  // }

  // Future<void> addToReceiverContacts(
  //   String? senderId,
  //   String? receiverId,
  //   currentTime,
  // ) async {
  //   DocumentSnapshot receiverSnapshot = await getContactsDocument(of: receiverId, forContact: senderId).get();
  //
  //   if (!receiverSnapshot.exists) {
  //     //does not exists
  //     ContactDataModel senderContact = ContactDataModel(
  //       uid: senderId,
  //       addedOn: currentTime,
  //     );
  //     await getContactsDocument(of: receiverId, forContact: senderId).set(senderContact.toJson());
  //   }
  // }

  //Fetch User List

  // Stream<QuerySnapshot> fetchContacts({String? userId}) {
  //   return userRef.doc(userId).collection(CONTACT_COLLECTION).snapshots();
  // }

  // Stream<List<UserModel>> getUserDetailsById({String? id, String? searchText}) {
  //   return userRef
  //       .where("uid", isEqualTo: id)
  //       .where('caseSearch', arrayContains: searchText.validate().isEmpty ? null : searchText!.toLowerCase())
  //       .snapshots()
  //       .map((event) => event.docs.map((e) => UserModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  // }

  // Stream<QuerySnapshot> fetchLastMessageBetween({required String senderId, required String receiverId}) {
  //   return ref!.doc(senderId.toString()).collection(receiverId.toString()).orderBy("createdAt", descending: false).snapshots();
  // }

  // Future<void> clearAllMessages({String? senderId, required String receiverId}) async {
  //   final WriteBatch _batch = fireStore.batch();
  //
  //   ref!.doc(senderId).collection(receiverId).get().then((value) {
  //     value.docs.forEach((document) {
  //       _batch.delete(document.reference);
  //     });
  //
  //     return _batch.commit();
  //   }).catchError((e) {});
  // }

  // Future<void> deleteChat({String? senderId, required String receiverId}) async {
  //   ref!.doc(senderId).collection(receiverId).doc().delete();
  //   userRef.doc(senderId).collection(CONTACT_COLLECTION).doc(receiverId).delete();
  // }

  Future<void> deleteSingleMessage({String? riderID, required String driverID, String? documentId}) async {
    try {
      // ref!.doc("${riderID}_${driverID}").collection("chats").doc(documentId).delete();
      final chatDocRef = ref!.doc("${riderID}_${driverID}").collection("chats").doc(documentId);
      await chatDocRef.update({
        'deleted': true
      });
    } on Exception catch (e) {
      log(e.toString());
      throw 'Something went wrong';
    }
  }

  Future<void> setUnReadStatusToTrue({required String riderID, required String driverID, String? documentId}) async {
    ref!.doc("${riderID}_${driverID}").collection("chats").where('senderId', isNotEqualTo: riderID).get().then((value) {
      value.docs.forEach((element) {
        element.reference.update({
          'isMessageRead': true,
        });
      });
    });

    return;
    // ref!.doc(senderId).collection(receiverId).where('senderId', isNotEqualTo: senderId).get().then((value) {
    //   value.docs.forEach((element) {
    //     element.reference.update({
    //       'isMessageRead': true,
    //     });
    //   });
    // });
    //
    // ref!.doc(receiverId).collection(senderId).where('senderId', isNotEqualTo: senderId).get().then((value) {
    //   value.docs.forEach((element) {
    //     element.reference.update({
    //       'isMessageRead': true,
    //     });
    //   });
    // });
  }

  Future<bool> justDeleteChat({required String senderId, required String receiverId,}) async {
    print("Check CHAT ROOM Id:::${senderId}_${receiverId}");
    try {
      var documentPath = "${senderId}_${receiverId}";
      CollectionReference collectionRef =ref!.doc(documentPath).collection("chats");
      QuerySnapshot querySnapshot = await collectionRef.get();
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      await ref!.doc(documentPath).delete();
      return true;
    } catch (e, s) {
      print("FailDelete Operation::$e ::::$s");
      return false;
    }
  }

  // Future<bool> exportChat({required String rideId, required String senderId, required String receiverId, bool? onlyDelete}) async {
  //   // chat export process
  //   // if (onlyDelete != true) {
  //   //   try {
  //   //     // QuerySnapshot<Map<String, dynamic>> b = await ref!.doc("$receiverId").collection("$senderId").get();
  //   //     QuerySnapshot<Map<String, dynamic>> b = await ref!.doc("${senderId}_${receiverId}").collection("chats").get();
  //   //     b.docs.forEach(
  //   //           (element) async {
  //   //         await rideChatRef.doc(rideId).collection("messages").add(element.data());
  //   //       },
  //   //     );
  //   //   } catch (e, s) {
  //   //     // FirebaseCrashlytics.instance.recordError("Export_Chat_Failed::" + e.toString(), s, fatal: true);
  //   //   }
  //   // }
  //   // remove chat process
  //   try {
  //     // await ref!.doc("${senderId}_${receiverId}").delete();
  //     // QuerySnapshot<Map<String, dynamic>> a = await ref!.doc("$senderId").collection("$receiverId").get();
  //     // QuerySnapshot<Map<String, dynamic>> c = await ref!.doc("$receiverId").collection("$senderId").get();
  //     // a.docs.forEach(
  //     //   (element1) async {
  //     //     await element1.reference.delete();
  //     //   },
  //     // );
  //     // c.docs.forEach(
  //     //   (element1) async {
  //     //     await element1.reference.delete();
  //     //   },
  //     // );
  //   } catch (e, s) {
  //     FirebaseCrashlytics.instance.recordError("Remove_Chat_Failed::" + e.toString(), s, fatal: true);
  //   }
  //   return true;
  // }

  Stream<int> getUnReadCount({String? senderId, required String receiverId, String? documentId}) {
    print("CHekYourUSErId::${senderId}:::$receiverId");
    return ref!.doc("${senderId}_${receiverId}").collection("chats")
        .where('isMessageRead', isEqualTo: false)
        .where('receiverId', isEqualTo: senderId)
        .snapshots()
        .map(
          (event) => event.docs.length,
    )
        .handleError((e) {
      return e;
    });
  }
}
