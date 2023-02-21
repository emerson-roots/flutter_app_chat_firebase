import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

void main() async {
  runApp(MyApp());

  await Firebase.initializeApp();

  String nomeDocumento = "mensagens";

  // INSERT/UPDATE - gravando no banco de dados
  /*await FirebaseFirestore.instance
      .collection(nomeDocumento)
      .doc()
      .set({"texto": "Tudo bem??", "from": "João", "read": false});
      //.update({"texto": "Tudo bem??", "from": "João", "read": false});*/

  // SELECT ALL - lendo o banco de dados
  /*QuerySnapshot snapshotAll =
      await FirebaseFirestore.instance.collection(nomeDocumento).get();
  snapshotAll.docs.forEach((element) {
    print(element.data());
  });*/

  // SELECT BY ID - lendo o banco de dados
  /* DocumentSnapshot documentSnapshot =
  await FirebaseFirestore.instance.collection(nomeDocumento).doc("msg1").get();
  print(documentSnapshot.id);*/

  // escuta/recupera em tempo real qualquer atualização no banco de dados (collection) inteira
  /*FirebaseFirestore.instance.collection(nomeDocumento).snapshots().listen((dados) {
    dados.docs.forEach((element) {
      print(element.data());
    });
  });*/

  // escuta/recupera em tempo real a atualização de um documento (id) especifico
  /*FirebaseFirestore.instance.collection(nomeDocumento).doc("msg1").snapshots().listen((dado) {

    print(dado.data());

  });*/
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      home: ChatScreen(),
    );
  }
}
