import 'dart:convert';

import 'package:enterprise/db.dart';

Profile profileFromJson(String str) {
  final jsonData = json.decode(str);
  return Profile.fromMap(jsonData);
}

Profile profileFromJsonApi(String str) {
  final jsonData = json.decode(str);
  return Profile.fromMap(jsonData["application"]);
}

String profiletToJson(Profile data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Profile {
  int id;
  String firstName;
  String lastName;
  String middleName;
  String phone;
  String itn;
  String email;
  String photo;
  String photoData;
  bool blocked;
  Passport passport;
  String civilStatus;
  String children;
  String education;
  String specialty;
  String additionalEducation;
  String lastWorkPlace;
  String skills;
  String languages;
  bool disability;
  bool pensioner;

  Profile(
      {this.id,
      this.firstName,
      this.lastName,
      this.middleName,
      this.phone,
      this.itn,
      this.email,
      this.photo,
      this.photoData,
      this.blocked,
      this.passport,
      this.civilStatus,
      this.children,
      this.education,
      this.specialty,
      this.additionalEducation,
      this.lastWorkPlace,
      this.skills,
      this.languages,
      this.disability,
      this.pensioner});

  factory Profile.fromMap(Map<String, dynamic> json) => new Profile(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        middleName: json["middle_name"],
        phone: json["phone"],
        itn: json["itn"],
        email: json["email"],
        photo: json["photo"],
        photoData: json["photo_data"],
        blocked: json["blocked"] == 1,
        passport: Passport.fromMap(json["passport"]),
        civilStatus: json["civil_status"],
        children: json["children"],
        education: json['education'],
        specialty: json['specialty'],
        additionalEducation: json['additional_education'],
        lastWorkPlace: json["last_work_place"],
        skills: json["skills"],
        languages: json["languages"],
        disability: json["disability"],
        pensioner: json["pensioner"],
      );

  factory Profile.fromDB(Map<String, dynamic> json) => new Profile(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        middleName: json["middle_name"],
        phone: json["phone"],
        itn: json["itn"],
        email: json["email"],
        photo: json["photo"],
        photoData: json["photo_data"],
        blocked: json["blocked"] == 1,
        passport: Passport.fromDB(json),
        civilStatus: json["civil_status"],
        children: json["children"],
        education: json['education'],
        specialty: json['specialty'],
        additionalEducation: json['additional_education'],
        lastWorkPlace: json["last_work_place"],
        skills: json["skills"],
        languages: json["languages"],
        disability: json["disability"],
        pensioner: json["pensioner"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "middle_name": middleName,
        "phone": phone,
        "itn": itn,
        "email": email,
        "photo": photo,
        "photo_data": photoData,
        "blocked": blocked,
        "passport": passport.toMap(),
        "civil_status": civilStatus,
        "children": children,
        "ducation": education,
        "specialty": specialty,
        "additional_education": additionalEducation,
        "last_work_place": lastWorkPlace,
        "skills": skills,
        "languages": languages,
        "disability": disability,
        "pensioner": pensioner,
      };
}

class Passport {
  String series;
  String number;
  String issued;
  String date;

  Passport({
    this.series,
    this.number,
    this.issued,
    this.date,
  });

  factory Passport.fromMap(Map<String, dynamic> json) => new Passport(
        series: json["series"],
        number: json["number"],
        issued: json["issued"],
        date: json["date"],
      );

  factory Passport.fromDB(Map<String, dynamic> json) => new Passport(
        series: json["passport_series"],
        number: json["passport_number"],
        issued: json["passport_issued"],
        date: json["passport_date"],
      );

  Map<String, dynamic> toMap() => {
        "series": series,
        "number": number,
        "issued": issued,
        "date": date,
      };
}

class Timing {
  int id;
  String userID;
  String date;
  String operation;
  String startTime;
  String endTime;

  Timing({
    this.id,
    this.userID,
    this.date,
    this.operation,
    this.startTime,
    this.endTime,
  });

  factory Timing.fromMap(Map<String, dynamic> json) => new Timing(
        id: json["id"],
        userID: json["user_id"],
        date: json["date"],
        operation: json["operation"],
        startTime: json["start_time"],
        endTime: json["end_time"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "user_id": userID,
        "date": date,
        "operation": operation,
        "start_time": startTime,
        "end_time": endTime,
      };
//  static Future<List<Timing>> getUserTiming(String date, String userID) async {
//    return DBProvider.db.getUserTiming(date, userID);
//  }
}

class Chanel {
  int id;
  String title;
  String news;
  String date;

  Chanel({
    this.id,
    this.title,
    this.news,
    this.date,
  });

  factory Chanel.fromMap(Map<String, dynamic> json) => new Chanel(
        id: json["id"],
        title: json["title"],
        news: json["news"],
        date: json["date"],
      );
}
