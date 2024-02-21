

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expo_demo/Custom%20Data/chartData.dart';
import 'package:expo_demo/Custom%20Data/customerInfo.dart';
import 'package:uuid/uuid.dart';

class CustomerFirebase{


  num total = 0;

  ///function to create a customer object and send to firebase
Future createCustomer(Customer customer,num selectedTotal, overTotal) async{

  //generate random id number to append to customer
  var uuid = Uuid();
  var id = uuid.v4();
  
 // num total = 0;

  customer.id = id;


  //create reference to database to store customer
    final docRef = FirebaseFirestore.instance
        .collection('customers')
        .doc(id)
        .withConverter(
        fromFirestore: Customer.fromFireStore,
        toFirestore: (Customer customer, options) => customer.toFireStore());



    try{
      await docRef.set(customer);
    }catch (e){
    }

    //now update donut chart data

  final chartRef = FirebaseFirestore.instance
      .collection('chartData')
      .doc(customer.industry)
      .withConverter(
      fromFirestore: ChartData.fromFireStore,
      toFirestore: (ChartData chartData, options) => chartData.toFireStore());


   chartRef.update({'total': selectedTotal + 1});


//reference to update total
  final totalRef = FirebaseFirestore.instance
      .collection('chartData')
  .doc('Total')
      .withConverter(
      fromFirestore: ChartData.fromFireStore,
      toFirestore: (ChartData chartData, options) => chartData.toFireStore());

 totalRef.update({'total':overTotal + 1});


   // final newRef = FirebaseFirestore.instance
   //     .collection('chartData')
   //     .doc("Total")
   //     .withConverter(
   //     fromFirestore: ChartData.fromFireStore,
   //     toFirestore: (ChartData chartData, options) => chartData.toFireStore());
   //
   // newRef.update({"total":overallTotal +1});



}

Future updateTotal(num total)async{
  final newRef = FirebaseFirestore.instance
      .collection('chartData')
      .doc("Total")
      .withConverter(
      fromFirestore: ChartData.fromFireStore,
      toFirestore: (ChartData chartData, options) => chartData.toFireStore());

  newRef.update({"total":total});
}


Future clearAllData()async{
  final corpRef = FirebaseFirestore.instance
      .collection('chartData')
  .doc('Corporate')
      .withConverter(
      fromFirestore: ChartData.fromFireStore,
      toFirestore: (ChartData chartData, options) => chartData.toFireStore());


  corpRef.update({"total":0});

  final eduRef = FirebaseFirestore.instance
      .collection('chartData')
      .doc('Education')
      .withConverter(
      fromFirestore: ChartData.fromFireStore,
      toFirestore: (ChartData chartData, options) => chartData.toFireStore());


  eduRef.update({"total":0});

  final healthRef = FirebaseFirestore.instance
      .collection('chartData')
      .doc('Healthcare')
      .withConverter(
      fromFirestore: ChartData.fromFireStore,
      toFirestore: (ChartData chartData, options) => chartData.toFireStore());


  healthRef.update({"total":0});

  final otherRef = FirebaseFirestore.instance
      .collection('chartData')
      .doc('Other')
      .withConverter(
      fromFirestore: ChartData.fromFireStore,
      toFirestore: (ChartData chartData, options) => chartData.toFireStore());


  otherRef.update({"total":0});

  final retailRef = FirebaseFirestore.instance
      .collection('chartData')
      .doc('Retail')
      .withConverter(
      fromFirestore: ChartData.fromFireStore,
      toFirestore: (ChartData chartData, options) => chartData.toFireStore());


  retailRef.update({"total":0});

  final techRef = FirebaseFirestore.instance
      .collection('chartData')
      .doc('Tech')
      .withConverter(
      fromFirestore: ChartData.fromFireStore,
      toFirestore: (ChartData chartData, options) => chartData.toFireStore());


  techRef.update({"total":0});


  final totalRef = FirebaseFirestore.instance
      .collection('chartData')
      .doc('Total')
      .withConverter(
      fromFirestore: ChartData.fromFireStore,
      toFirestore: (ChartData chartData, options) => chartData.toFireStore());


  totalRef.update({"total":0});
}

}