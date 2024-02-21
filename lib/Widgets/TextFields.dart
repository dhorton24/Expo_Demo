import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class TextWidget extends StatelessWidget {

  final String textFieldName;
  final TextEditingController textEditingController;
  final bool? password;
  final TextInputType? textInputType;

  const TextWidget({
    super.key,
    required this.textEditingController,
    required this.textFieldName,
    this.password,
    this.textInputType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(textFieldName,style: GoogleFonts.lifeSavers(
            color: Colors.black,
            fontSize: 18,
            // fontWeight: FontWeight.bold
          ),),
          TextField(
            keyboardType: textInputType ?? TextInputType.text,
            controller: textEditingController,
            obscureText: password ?? false,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              fillColor: Colors.grey[200],
              filled: true,
              hintText: textFieldName,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(8),
                ),
                // border: OutlineInputBorder(
                //     borderRadius: BorderRadius.circular(8),
                // )
            ),
          ),
        ],
      ),
    );
  }
}