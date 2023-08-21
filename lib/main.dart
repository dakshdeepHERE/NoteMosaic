import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    ),
  );
}

@immutable
abstract class LoadAction {
  const LoadAction();
}

@immutable
class LoadPersonsAction implements LoadAction {
  final PersonsURL url;

  const LoadPersonsAction({required this.url}) : super();
}

enum PersonsURL { persons1, persons2 }

extension UrlString on PersonsURL {
  String get urlString {
    switch (this) {
      case PersonsURL.persons1:
        return 'http://127.0.0.1:5500/api/persons1.json';
      case PersonsURL.persons2:
        return 'http://127.0.0.1:5500/api/persons2.json';
    }
  }
}

@immutable
class Person {
  final String name;
  final int age;

  const Person({required this.name, required this.age});

  Person.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        age = json['age'] as int;
}

Future<Iterable<Person>> getPerson(String url) => HttpClient()
    .getUrl(Uri.parse(url)) //This gives us requests
    .then((req) => req.close()) //Request becomes a response here
    .then((resp) => resp
        .transform(utf8.decoder)
        .join()) // Response comes here and becomes a String
    .then((str) => json.decode(str)
        as List<dynamic>) // String comes here and become a List
    .then(
      (list) => list.map((e) => Person.fromJson(
          e)), //List comes here and becomes an iterable of persons
    );

@immutable
class FetchResult {
  final Iterable<Person> persons;
  final bool isRetrievedFromCache;

  const FetchResult(
      {required this.persons, required this.isRetrievedFromCache});
  @override
  String toString() =>
      'FetchResult(isRetrievedFromCache = $isRetrievedFromCache, $persons)';
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(
          'Home Page',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
