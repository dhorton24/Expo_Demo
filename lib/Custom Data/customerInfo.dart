

import 'package:cloud_firestore/cloud_firestore.dart';

class Customer{

  String customerType;
  String name;
  String companyLocation;
  String email;
  String industry;
  String phoneNumber;
  bool receiveInformation;
  String id;


  Customer({
   required this.customerType,
  required this.name,
  required this.companyLocation,
  required this.email,
  required this.industry,
  required this.phoneNumber,
    required this.receiveInformation,
  required this.id
});


  factory Customer.fromFireStore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options){
    final data = snapshot.data();
    return Customer(
        customerType: data?['customerType'],
        name: data?['name'],
        companyLocation: data?['companyLocation'],
        email: data?['email'],
        industry: data?['industry'],

        phoneNumber: data?['phoneNumber'],
        receiveInformation: data?['receiveInformation'],
        id: data?['id'],
       );
  }

  Map<String, dynamic> toFireStore(){
    return{
      'customerType':customerType,
      'name':name,
      'companyLocation':companyLocation,
      'email': email,
      'industry': industry,

      'phoneNumber': phoneNumber,
      'receiveInformation':receiveInformation,
      'id':id,
    };
  }
}