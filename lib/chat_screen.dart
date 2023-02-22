import 'dart:io';

import 'package:chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String DOCUMENTO_MENSAGENS = "mensagens";

  void _sendMessage({String? texto, File? imgFile}) async {
    Map<String, dynamic> dados = {};

    if (imgFile != null) {
      String nomeArquivo = DateTime.now().millisecondsSinceEpoch.toString();
      UploadTask task =
          FirebaseStorage.instance.ref().child(nomeArquivo).putFile(imgFile);

      // captura a URL da imagem enviada ao firebase
      TaskSnapshot taskSnapshot = await task;
      String url = await taskSnapshot.ref.getDownloadURL();
      dados['imgUrl'] = url;
    }

    if (texto != null) {
      dados['text'] = texto;
    }

    // envia para o firebase
    await FirebaseFirestore.instance.collection(DOCUMENTO_MENSAGENS).add(dados);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Olá'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(DOCUMENTO_MENSAGENS)
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> docs = snapshot.data!.docs.reversed.toList();
                    return ListView.builder(
                      itemCount: docs.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(docs[index].get('text')),
                        );
                      },
                    );
                }
              },
            ),
          ),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
