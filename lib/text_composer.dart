import 'package:flutter/material.dart';

class TextComposer extends StatefulWidget {

  // aula 190 -
  TextComposer(this.sendMessage, {super.key});
  Function(String) sendMessage;


  @override
  State<TextComposer> createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {



   final TextEditingController _controller = TextEditingController();
  // vai indicar se está compondo um texto ou não
  bool _isComposing = false;

  void _resetFormulario(){
    _controller.clear();
    setState((){
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
            onPressed: () {},
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
              onSubmitted: (text) { // aula 190 - onSubmitted é o evento ao usar o botão "Enter" do próprio teclado android
                // aula 190 - envia texto ao apertar o botão enviar do teclado invés do botão da tela
                widget.sendMessage(text);

                _resetFormulario();
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _isComposing ? () {
              // uma função aqui
              widget.sendMessage(_controller.text);

              _resetFormulario();
            } : null,
          ),
        ],
      ),
    );
  }
}
