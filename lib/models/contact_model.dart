// To parse this JSON data, do
//
//     final contactModel = contactModelFromJson(jsonString);

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taguigconnect/constants/color_constant.dart';

ContactModel contactModelFromJson(String str) =>
    ContactModel.fromJson(json.decode(str));

String contactModelToJson(ContactModel data) => json.encode(data.toJson());

class ContactModel {
  String? firstname;
  String? lastname;
  String? email;
  String? contact;
  String? image;

  ContactModel({
    this.firstname,
    this.lastname,
    this.email,
    this.contact,
    this.image,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
        firstname: json["firstname"],
        lastname: json["lastname"],
        email: json["email"],
        contact: json["contact"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "firstname": firstname,
        "lastname": lastname,
        "email": email,
        "contact": contact,
        "image": image,
      };

  Widget buildContactWidget() {
    String firstLetter =
        firstname!.isNotEmpty ? firstname![0].toUpperCase() : '?';

    return ListTile(
      leading: image != null
          ? CircleAvatar(
              backgroundColor: tcAsh,
              backgroundImage: MemoryImage(
                base64Decode(image!),
              ),
            )
          : CircleAvatar(
              backgroundColor: tcAsh,
              child: Center(
                child: Text(
                  firstLetter,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: tcBlack,
                  ),
                ),
              ),
            ),
      title: Text(firstname ?? ''),
      subtitle: Text(contact ?? ''),
      onTap: () {
        // Print the data of the selected contact
        printContactData();
      },
    );
  }

  void printContactData() {
    print('Firstname: $firstname');
    print('Lastname: $lastname');
    print('Email: $email');
    print('Contact: $contact');
    print('Image: $image');
  }
}
