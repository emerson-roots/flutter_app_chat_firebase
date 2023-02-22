import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  // aula 190 -
  TextComposer(this.sendMessage, {super.key});

  final Function({String texto, File imgFile}) sendMessage;

  @override
  State<TextComposer> createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  final TextEditingController _controller = TextEditingController();

  // vai indicar se está compondo um texto ou não
  bool _isComposing = false;

  void _resetFormulario() {
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () async {
              XFile? file =
                  await ImagePicker().pickImage(source: ImageSource.camera);

              if (file == null) {
                return;
              } else {
                widget.sendMessage(imgFile: File(file.path));
              }
            },
            icon: Icon(Icons.photo_camera),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration:
                  InputDecoration.collapsed(hintText: 'Enviar uma mensagem...'),
              onChanged: (text) {
                setState(() {
                  // se o texto não estiver vazio, estou compondo
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                // aula 190 - onSubmitted é o evento ao usar o botão "Enter" do próprio teclado android
                widget.sendMessage(texto: text);
                _resetFormulario();
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _isComposing
                ? () {
                    // uma função aqui
                    widget.sendMessage(texto: _controller.text);
                    _resetFormulario();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
