
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:expo_demo/Custom%20Data/customerInfo.dart';
import 'package:expo_demo/Firebase/CustomerFirebase.dart';
import 'package:expo_demo/Widgets/TextFields.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int touchedIndex = -1;

  int total = 0;


  //variable for indicators
  num retail = 0;
  num tech = 0;
  num healthCare = 0;
  num education = 0;
  num corporate = 0;
  num other = 0;

  bool showForms = true;
  bool showQRCodes = false;

  bool customerButton = true;
  bool businessButton = false;

  TextEditingController firstName = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController email = TextEditingController();

  String selectedIndustry = '';
  String selectedLocation = '';

  bool agreement = false;

  late QrImage websiteQR;

  // late QrImage FBQR;
  // late QrImage linkInQR;

  num selectedTotal = 0;

  Stream<QuerySnapshot> chartStream = FirebaseFirestore.instance
      .collection('chartData')
      .snapshots();
  List<DocumentSnapshot> chartList = [];

  Customer customer = Customer(
      customerType: 'Customer',
      name: '',
      companyLocation: '',
      email: '',
      industry: '',
      phoneNumber: '',
      receiveInformation: false,
      id: '');

  bool isLoading = false;

  late Stream<QuerySnapshot> myStream;

  List<DropdownMenuItem<String>> menuItems = [
    const DropdownMenuItem(
      value: '',
      child: Text(""),
    ),
    const DropdownMenuItem(
      value: 'Retail',
      child: Text("Retail"),
    ),
    const DropdownMenuItem(
      value: 'Tech',
      child: Text("Tech"),
    ),
    const DropdownMenuItem(
      value: 'Healthcare',
      child: Text("Healthcare"),
    ),
    const DropdownMenuItem(
      value: 'Education',
      child: Text("Education"),
    ),
    const DropdownMenuItem(
      value: 'Corporate',
      child: Text("Corporate"),
    ),
    const DropdownMenuItem(
      value: 'Other',
      child: Text("Other"),
    ),
  ];

  List<DropdownMenuItem<String>> locationItems = [
    const DropdownMenuItem(
      value: '',
      child: Text(""),
    ),
    const DropdownMenuItem(
      value: 'Northwest AR',
      child: Text("Northwest AR"),
    ),
    const DropdownMenuItem(
      value: 'Northeast AR',
      child: Text("Northeast AR"),
    ),
    const DropdownMenuItem(
      value: 'Central AR',
      child: Text("Central AR"),
    ),
    const DropdownMenuItem(
      value: 'South AR',
      child: Text("South AR"),
    ),
    const DropdownMenuItem(
      value: 'Oklahoma',
      child: Text("Oklahoma"),
    ),
    const DropdownMenuItem(
      value: 'Texas',
      child: Text("Texas"),
    ),
    const DropdownMenuItem(
      value: 'Missouri',
      child: Text("Missouri"),
    ),
    const DropdownMenuItem(
      value: 'Other',
      child: Text("Other"),
    ),
  ];

  setUp() {
    DocumentReference totalReference = FirebaseFirestore.instance.collection(
        'chartData').doc('Total');
    totalReference.snapshots().listen((event) {
      setState(() {
        total = event.get('total');
      });
    });

    DocumentReference retailReference = FirebaseFirestore.instance.collection(
        'chartData').doc('Retail');
    retailReference.snapshots().listen((event) {
      setState(() {
        retail = event.get('total');
      });
    });


    DocumentReference techReference = FirebaseFirestore.instance.collection(
        'chartData').doc('Tech');
    techReference.snapshots().listen((event) {
      setState(() {
        tech = event.get('total');
      });
    });

    DocumentReference healthReference = FirebaseFirestore.instance.collection(
        'chartData').doc('Healthcare');
    healthReference.snapshots().listen((event) {
      setState(() {
        healthCare = event.get('total');
      });
    });

    DocumentReference educationReference = FirebaseFirestore.instance
        .collection('chartData').doc('Education');
    educationReference.snapshots().listen((event) {
      setState(() {
        education = event.get('total');
      });
    });

    DocumentReference corpReference = FirebaseFirestore.instance.collection(
        'chartData').doc('Corporate');
    corpReference.snapshots().listen((event) {
      setState(() {
        corporate = event.get('total');
      });
    });

    DocumentReference otherReference = FirebaseFirestore.instance.collection(
        'chartData').doc('Other');
    otherReference.snapshots().listen((event) {
      setState(() {
        other = event.get('total');
      });
    });
  }

  @override
  void initState() {
    super.initState();

    setUp();

    final qrCode = QrCode(8, QrErrorCorrectLevel.H)
      ..addData('https://linktr.ee/citex.tech');
    // final fbCode = QrCode(8, QrErrorCorrectLevel.H)
    //   ..addData('https://www.facebook.com/citex.tech');
    // final linkInCode = QrCode(8, QrErrorCorrectLevel.H)
    //   ..addData('https://www.linkedin.com/company/citex-llc');

    websiteQR = QrImage(qrCode);
    // FBQR = QrImage(fbCode);
    // linkInQR = QrImage(linkInCode);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: null,
        builder: (BuildContext context, AsyncSnapshot text) {
          return Scaffold(
            backgroundColor: Theme
                .of(context)
                .colorScheme
                .secondary,
            body: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  children: [leftContainer(context), rightContainer(context)],
                ),
                isLoading
                    ? const SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      strokeWidth: 10,
                    ))
                    : const SizedBox(),
              ],
            ),
          );
        }
    );
  }

  //container that holds pie chart
  Container leftContainer(BuildContext context) {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width / 1.8,
      height: MediaQuery
          .of(context)
          .size
          .height,
      color: Theme
          .of(context)
          .colorScheme
          .secondary,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        GestureDetector(
                          onLongPress: () {
                            //CustomerFirebase().clearAllData();
                          },
                          child: Image.asset(
                            'lib/Images/CITex_wSloganTRS.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 24.0, top: 8),
                          child: Text(
                            'Goal for the Day: 50',
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .primary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      showForms = true;
                                      showQRCodes = false;
                                    });
                                  },
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(
                                          Theme
                                              .of(context)
                                              .colorScheme
                                              .tertiary)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.format_list_bulleted_sharp,
                                      color: Theme
                                          .of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        showForms = false;
                                        showQRCodes = true;
                                      });
                                    },
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty
                                            .all(
                                            Theme
                                                .of(context)
                                                .colorScheme
                                                .tertiary)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.qr_code_2_outlined,
                                        color:
                                        Theme
                                            .of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                    )),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StreamBuilder(
                      stream: chartStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Error');
                        }
                        //while it connects
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        chartList = snapshot.data!.docs;

                        if (chartList.isEmpty) {
                          return Center(
                              child: Text(
                                'Empty Menu.',
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .primary),
                                textAlign: TextAlign.center,
                              ));
                        }


                        for (int i = 0; i < chartList.length; i++) {
                          if (chartList[i].id == 'Retail') {
                            retail = chartList[i]['total'];
                          }
                          if (chartList[i].id == 'Corporate') {
                            corporate = chartList[i]['total'];
                          }
                          if (chartList[i].id == 'Tech') {
                            tech = chartList[i]['total'];
                          }
                          if (chartList[i].id == 'Education') {
                            education = chartList[i]['total'];
                          }
                          if (chartList[i].id == 'Other') {
                            other = chartList[i]['total'];
                          }
                          if (chartList[i].id == 'Healthcare') {
                            healthCare = chartList[i]['total'];
                          }

                          //to get total inquires


                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                // touchCallback: (FlTouchEvent event,
                                //     pieTouchResponse) {
                                //   setState(() {
                                //     // if (!event.isInterestedForInteractions ||
                                //     //     pieTouchResponse == null ||
                                //     //     pieTouchResponse.touchedSection == null) {
                                //     //   touchedIndex = -1;
                                //     //   return;
                                //     // }
                                //     // touchedIndex = pieTouchResponse
                                //     //     .touchedSection!.touchedSectionIndex;
                                //   });
                            //    },
                              ),
                              borderData: FlBorderData(
                                show: false,
                              ),
                              sectionsSpace: 5,
                              centerSpaceRadius: MediaQuery
                                  .of(context)
                                  .size
                                  .width / 7,
                              sections: showingSections(),
                            ),
                          ),
                        );
                      }
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      total.toString(),
                      style: TextStyle(
                          fontSize: 75,
                          color: Theme
                              .of(context)
                              .colorScheme
                              .primary),
                    ),
                    Flexible(
                      child: Text(
                        "Industry Breakdown",
                        style: TextStyle(
                            color: Theme
                                .of(context)
                                .colorScheme
                                .primary,
                           // fontSize: 45
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8.0, right: 8, bottom: 60),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Indicator(
                  color: Colors.blue,
                  text: 'Retail',
                  isSquare: false,
                  textColor: Colors.white,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Colors.yellow,
                  text: 'Tech',
                  isSquare: false,
                  textColor: Colors.white,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Colors.purple,
                  text: 'Healthcare',
                  isSquare: false,
                  textColor: Colors.white,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Colors.red,
                  text: 'Education',
                  isSquare: false,
                  textColor: Colors.white,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Colors.green,
                  text: 'Corporate',
                  isSquare: false,
                  textColor: Colors.white,
                ),
                SizedBox(
                  height: 4,
                ),
                Indicator(
                  color: Colors.grey,
                  text: 'Other',
                  isSquare: false,
                  textColor: Colors.white,
                ),
                SizedBox(
                  height: 18,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 28,
          ),
        ],
      ),
    );
  }

  Widget rightContainer(BuildContext context) {
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width / 2.25,
      height: MediaQuery
          .of(context)
          .size
          .height,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50), bottomLeft: Radius.circular(50))),
      child: showForms ? SignUpTextFields() : qrCodes(),
    );
  }

  Widget SignUpTextFields() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8, left: 82, right: 82),
      child: Column(
        children: [
          Flexible(child: Image.asset('lib/Images/CITex.png')),

          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Select if you are a customer or own/operating a business",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          //toggle buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  child: Container(
                    width: 150,
                    height: 75,
                    decoration: BoxDecoration(
                        color: customerButton
                            ? Theme
                            .of(context)
                            .colorScheme
                            .primary
                            : Colors.grey[350],
                        borderRadius: BorderRadius.circular(8)),
                    child: const Center(
                        child: Text("Public",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22))),
                  ),
                  onTap: () {
                    setState(() {
                      customerButton = true;
                      businessButton = false;
                    });
                  },
                ),
                GestureDetector(
                    child: Container(
                      width: 150,
                      height: 75,
                      decoration: BoxDecoration(
                          color: businessButton
                              ? Theme
                              .of(context)
                              .colorScheme
                              .primary
                              : Colors.grey[350],
                          borderRadius: BorderRadius.circular(8)),
                      child: const Center(
                          child: Text(
                            "Business",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 22),
                          )),
                    ),
                    onTap: () {
                      setState(() {
                        customerButton = false;
                        businessButton = true;
                      });
                    }),
              ],
            ),
          ),

          TextWidget(
              textEditingController: firstName, textFieldName: "* Name"),

          ///company location
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Company Location',
                    style: GoogleFonts.lifeSavers(
                      color: Colors.black,
                      fontSize: 18,
                      // fontWeight: FontWeight.bold
                    )),
                DropdownButtonFormField(
                  items: locationItems,
                  value: selectedLocation,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedLocation = newValue!;
                    });


                  },
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      border: OutlineInputBorder(
                        borderSide:
                        const BorderSide(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      fillColor: Colors.grey[200],
                      filled: true),
                ),
              ],
            ),
          ),

          TextWidget(
            textEditingController: email,
            textFieldName: "* Email",
            textInputType: TextInputType.emailAddress,
          ),

          ///industry selection
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('*Which industry best fits your profession/business?',
                    style: GoogleFonts.lifeSavers(
                      color: Colors.black,
                      fontSize: 18,
                      // fontWeight: FontWeight.bold
                    )),
                DropdownButtonFormField(
                  items: menuItems,
                  value: selectedIndustry,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedIndustry = newValue!;
                    });


                  },
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      border: OutlineInputBorder(
                        borderSide:
                        const BorderSide(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      fillColor: Colors.grey[200],
                      filled: true),
                ),
              ],
            ),
          ),

          TextWidget(
            textEditingController: phoneNumber,
            textFieldName: "Phone Number",
            textInputType: TextInputType.phone,
          ),

          //checkbox
          Row(
            children: [
              Checkbox(
                  value: agreement,
                  onChanged: (bool? newValue) {
                    setState(() {
                      agreement = newValue!;
                    });
                  }),
              const Text("I accept to receive information about CITex")
            ],
          ),

          //submit button
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        //get internet status
                        final connect =
                        await (Connectivity().checkConnectivity());

                        if (firstName.text.isEmpty) {
                          //if name is empty
                          errorDialog('Please fill in first name',
                              'Incomplete Field',DialogType.error)
                              .show();
                        }
                        //if email isn't valid
                        else if (!RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(email.text)) {
                          errorDialog('Please provide valid email address',
                              'Invalid Email',DialogType.error)
                              .show();
                        } else if (email.text.isEmpty) {
                          //is email is empty
                          errorDialog(
                              'Please fill in email', 'Incomplete Field',DialogType.error)
                              .show();
                        } else if (selectedIndustry.isEmpty) {
                          //if industry isn't selected
                          errorDialog('Please select an industry',
                              'Incomplete Field',DialogType.error)
                              .show();
                        } else if (!agreement && businessButton == true) {
                          //if agreement isn't complete
                          errorDialog(
                              'Please accept agreement', 'Accept Agreement',DialogType.error)
                              .show();
                        } else if (connect == ConnectivityResult.none) {
                          //if no internet is found
                          //show loading icon and then display no internet found
                          setState(() {
                            isLoading = true;
                          });
                          Future.delayed(const Duration(seconds: 2))
                              .whenComplete(() =>
                          {
                            setState(() {
                              isLoading = false;
                            }),
                            errorDialog(
                                'No internet connection', 'Error',DialogType.error)
                                .show()
                          });
                          //errorDialog('No internet connection', 'Error').show();
                        } else {
                          setState(() {
                            //start loading icon
                            isLoading = true;

                            //load all data in customer variable
                            if (customerButton) {
                              customer.customerType = 'Customer';
                            } else {
                              customer.customerType = 'Business';
                            }

                            customer.name = firstName.text;
                            customer.companyLocation = selectedLocation;
                            customer.email = email.text;
                            customer.industry = selectedIndustry;
                            customer.phoneNumber = phoneNumber.text;
                            customer.receiveInformation = agreement;
                          });

                          //to get the total for the selected industry
                          if (customer.industry == 'Retail') {
                            selectedTotal = retail;
                          }
                          if (customer.industry == 'Tech') {
                            selectedTotal = tech;
                          }
                          if (customer.industry == 'Healthcare') {
                            selectedTotal = healthCare;
                          }
                          if (customer.industry == 'Education') {
                            selectedTotal = education;
                          }
                          if (customer.industry == 'Corporate') {
                            selectedTotal = corporate;
                          }
                          if (customer.industry == 'Other') {
                            selectedTotal = other;
                          }

                          //custom function to upload to firebase
                          try {
                            //to prevent submit button from being pressed again while loading

                            sendEmail(email.text, customer.companyLocation, customer.name, customer.industry, customer.phoneNumber, businessButton, agreement, total.toString());


                            await CustomerFirebase()
                                  .createCustomer(
                                  customer, selectedTotal, total)
                                  .whenComplete(() =>{
                                  setState(() {
                                    //clear forms
                                    firstName.clear();
                                    selectedLocation = '';
                                    email.clear();
                                    selectedIndustry = '';
                                    phoneNumber.clear();
                                    agreement = false;

                                    //to remove loading icon
                                    isLoading = false;


                                    //reset customer variable
                                    customer = Customer(
                                        customerType: 'Customer',
                                        name: '',
                                        companyLocation: '',
                                        email: '',
                                        industry: '',
                                        phoneNumber: '',
                                        receiveInformation: false,
                                        id: '');



                                    }),

                                  errorDialog("Success! Thank you for your interest in CITex.", 'Completed', DialogType.success).show()
    }
                              );


                          } catch (e) {
                            errorDialog('Unknown error', 'Error',DialogType.error).show();
                          }
                        }
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Theme
                                  .of(context)
                                  .colorScheme
                                  .primary)),
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                          !isLoading ?
                          Text(
                            "Submit",
                            style: TextStyle(
                                fontSize: 24,
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .secondary),
                          ) :
                          const CircularProgressIndicator(color: Colors.black,)
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void sendEmail(String clientEmail,String companyLocation, String name, String industry, String phoneNumber, bool isBusiness, bool receiveInfo, String total){

    final mailer = Mailer('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');
    const toAddress = Address('dhorton@citex.tech');
    const fromAddress = Address('dedrickhorton94@gmail.com');
    final content = Content('text/plain', 'Client Email: $clientEmail.\nName: $name\nCompany Location: $companyLocation.\nIndustry: $industry.\nPhone Number: $phoneNumber\nBusiness: $isBusiness.\nReceive Info: $receiveInfo\nCustomer # $total');
    const subject = 'Expo KPI';
    const personalization = Personalization([toAddress]);

    final email =
    Email([personalization], fromAddress, subject, content: [content]);
    mailer.send(email).then((result) {
    });
  }

  Widget qrCodes() {
    return SingleChildScrollView(
      child: Column(

        children: [
          const Center(child: AnimatedTextWidget()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              QRWidget(
                qrImage: websiteQR,
                image: 'lib/Images/CITex.png',
                height: 100,
              ),
              // QRWidget(
              //   qrImage: FBQR,
              //   image: 'lib/Images/facebookIcon.png',
              //   height: 100,
              // ),
              // QRWidget(
              //   qrImage: linkInQR,
              //   image: 'lib/Images/linkedInLogo.png',
              //   height: 100,
              // ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Visit our website and follow us on social media!",
              style: GoogleFonts.lifeSavers(
                  fontWeight: FontWeight.bold, fontSize: 24,),textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  AwesomeDialog errorDialog(String errorText, String errorTitle, DialogType type) {
    return AwesomeDialog(
        context: context,
        animType: AnimType.rightSlide,
        dialogType: type,
        body: Text(
          errorText,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        title: errorTitle,
        isDense: false,
        width: 600,
        btnCancel: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                  Theme
                      .of(context)
                      .colorScheme
                      .tertiary)),
          child: Text(
            "Ok",
            style: TextStyle(
                color: Theme
                    .of(context)
                    .colorScheme
                    .secondary,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
        ));
  }

  Column categoryButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              retail = retail + 1;

            });
          },
          child: const Text("Retail"),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              tech = tech + 1;
            });
          },
          child: const Text("Tech"),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              healthCare = healthCare + 1;
            });
          },
          child: const Text("Healthcare"),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              education = education + 1;
            });
          },
          child: const Text("Education"),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              corporate = corporate + 1;
              // total = total + 1;
            });
          },
          child: const Text("Corporate"),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              other = other + 1;
              // total = total + 1;
            });
          },
          child: const Text("Other"),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(6, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      // final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 5)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.blue,
            value: (tech == 0 &&
                retail == 0 &&
                healthCare == 0 &&
                education == 0 &&
                corporate == 0 &&
                other ==
                    0) //starting value. If one of the values are zero. Just make the starting value to prevent nan error
                ? 0
                : retail /
                (retail + tech + healthCare + education + corporate + other),
            title: ((retail /
                (retail + tech + healthCare + education + corporate + other) *
                100) //get percentage of this category based on the total.
                .toStringAsFixed(2))
                .toString(),
            radius: retail.toDouble(),
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.yellow,
            value: (tech == 0 &&
                retail == 0 &&
                healthCare == 0 &&
                education == 0 &&
                corporate == 0 &&
                other == 0)
                ? 0
                : tech /
                (retail + tech + healthCare + education + corporate + other),
            title: ((tech /
                (retail + tech + healthCare + education + corporate + other) *
                100)
                .toStringAsFixed(2))
                .toString(),
            radius: tech.toDouble(),
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.purple,
            value: (tech == 0 &&
                retail == 0 &&
                healthCare == 0 &&
                education == 0 &&
                corporate == 0 &&
                other == 0)
                ? 0
                : healthCare /
                (retail + tech + healthCare + education + corporate + other),
            //if any of the initials
            title: ((healthCare /
                (retail + tech + healthCare + education + corporate + other) *
                100)
                .toStringAsFixed(2))
                .toString(),
            radius: healthCare.toDouble(),
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: Colors.red,
            value: (tech == 0 &&
                retail == 0 &&
                healthCare == 0 &&
                education == 0 &&
                corporate == 0 &&
                other == 0)
                ? 0
                : education /
                (retail + tech + healthCare + education + corporate + other),
            title: ((education /
                (retail + tech + healthCare + education + corporate + other) *
                100)
                .toStringAsFixed(2))
                .toString(),
            radius: education.toDouble(),
            showTitle: true,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 4:
          return PieChartSectionData(
            color: Colors.green,
            value: (tech == 0 &&
                retail == 0 &&
                healthCare == 0 &&
                education == 0 &&
                corporate == 0 &&
                other == 0)
                ? 0
                : corporate /
                (retail + tech + healthCare + education + corporate + other),
            title: ((corporate /
                (retail + tech + healthCare + education + corporate + other) *
                100)
                .toStringAsFixed(2))
                .toString(),
            radius: corporate.toDouble(),
            showTitle: true,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 5:
          return PieChartSectionData(
            color: Colors.grey,
            value: (tech == 0 &&
                retail == 0 &&
                healthCare == 0 &&
                education == 0 &&
                corporate == 0 &&
                other ==
                    0) //starting value. If one of the values are zero. Just make the starting value to prevent nan error
                ? 0
                : other /
                (retail + tech + healthCare + education + corporate + other),
            title: ((other /
                (retail + tech + healthCare + education + corporate + other) *
                100) //get percentage of this category based on the total.
                .toStringAsFixed(2))
                .toString(),
            radius: other.toDouble(),
            showTitle: true,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );

        default:
          throw Error();
      }
    });
  }
}

class QRWidget extends StatelessWidget {
  const QRWidget({super.key,
    required this.qrImage,
    required this.image,
    this.width,
    this.height});

  final QrImage qrImage;
  final String image;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 175,
          height: 175,
          child: PrettyQrView(
            qrImage: qrImage,
            decoration: const PrettyQrDecoration(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
              width: width ?? 175,
              height: height ?? 125,
              child: Image.asset(
                image,
                fit: BoxFit.contain,
              )),
        )
      ],
    );
  }
}

class AnimatedTextWidget extends StatelessWidget {
  const AnimatedTextWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: SizedBox(
        width: 300,
        height: 400,
        child: DefaultTextStyle(
          textAlign: TextAlign.center,
          style: GoogleFonts.lifeSavers(
              textStyle: TextStyle(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .secondary,
                  fontSize: 70,
                  fontWeight: FontWeight.w900)),
          child: AnimatedTextKit(
            repeatForever: true,
            animatedTexts: [
              ScaleAnimatedText('Dream it',
                  duration: const Duration(milliseconds: 1000)),
              ScaleAnimatedText('Chase it',
                  duration: const Duration(milliseconds: 1000)),
              ScaleAnimatedText('Own it!',
                  duration: const Duration(milliseconds: 1000)),
              ScaleAnimatedText('Build Your Solution Today',
                  duration: const Duration(milliseconds: 5000),
                  textAlign: TextAlign.center),
            ],
            onTap: () {

            },
          ),
        ),
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  });

  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}
