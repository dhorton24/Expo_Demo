import 'package:cloud_firestore/cloud_firestore.dart';

class ChartData{


  String categoryName;
  int total;
  String id;

  ChartData({
    required this.categoryName,
    required this.total,
    required this.id
});


  factory ChartData.fromFireStore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options){
    final data = snapshot.data();
    return ChartData(
      categoryName: data?['categoryName'],
       total: data?["total"],
      id: data?['id']
    );
  }

  Map<String, dynamic> toFireStore(){
    return{
      'categoryName':categoryName,
      'total':total,
      'id':id
    };
  }

}