import 'dart:io';

import 'package:chat/chat_message.dart';
import 'package:chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String DOCUMENTO_MENSAGENS = "mensagens";

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  User? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<User?> _getUser() async {
    if (_currentUser != null) return _currentUser;

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      // recupera token de acesso para fazer conexao com firebase
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = authResult.user;
      return user;
    } catch (error) {
      // TODO
      // return null;
    }
  }

  Future<void> _sendMessage({String? texto, File? imgFile}) async {
    final User? user = await _getUser();

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Não foi possível fazer o login. Tente novamente'),
        backgroundColor: Colors.red,
      ));
    }

    Map<String, dynamic> dados = {
      "uid": user!.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoURL,
      "time": Timestamp.now()
    };

    if (imgFile != null) {
      String nomeArquivo = DateTime.now().millisecondsSinceEpoch.toString();
      UploadTask task =
          FirebaseStorage.instance.ref().child(nomeArquivo).putFile(imgFile);

      setState(() {
        _isLoading = true;
      });

      // captura a URL da imagem enviada ao firebase
      TaskSnapshot taskSnapshot = await task;
      String url = await taskSnapshot.ref.getDownloadURL();
      dados['imgUrl'] = url;

      setState(() {
        _isLoading = false;
      });
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
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(_currentUser != null
            ? 'Olá, ${_currentUser!.displayName}'
            : 'Chat App'),
        elevation: 0,
        actions: [
          _currentUser != null
              ? IconButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Logout efetuado com sucesso!'),
                    ));
                  },
                  icon: Icon(Icons.exit_to_app),
                )
              : Container()
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(DOCUMENTO_MENSAGENS)
                  .orderBy('time')
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> docs =
                        snapshot.data!.docs.reversed.toList();
                    return ListView.builder(
                      itemCount: docs.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return ChatMessage(
                          data: docs[index].data() as Map<String, dynamic>,
                          // determina o lado em que as mensagems irão aparecer
                          mine: docs[index].get('uid') == _currentUser?.uid,
                        );
                      },
                    );
                }
              },
            ),
          ),
          _isLoading ? const LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
