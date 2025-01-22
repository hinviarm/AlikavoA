import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

import 'dart:convert' as convert;

class MySecondPage extends StatefulWidget {
  const MySecondPage({super.key});

  @override
  State<MySecondPage> createState() => _MySecondPageState();
}

class _MySecondPageState extends State<MySecondPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  var _Deb = '';
  var _Fin = '';
  var _Ville = '';
  var _Lieu = '';
  var _Commentaire = '';
  var _MyList = [];
  var _Rep = 0;
  double latitude = 0.0;
  double longitude = 0.0;

  final Deb = TextEditingController();
  final Fin = TextEditingController();
  final Ville = TextEditingController();
  final Lieu = TextEditingController();
  final Commentaire = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    Deb.dispose();
    Fin.dispose();
    Ville.dispose();
    Lieu.dispose();
    Commentaire.dispose();
    super.dispose();
  }

  // Fields in a Widget subclass are always marked "final".

  //final Widget title;
  _onChangeText(value) => debugPrint("_onChangeText: $value");
  _onSubmittedText(value) => debugPrint("_onSubmittedText: $value");

  String endwithSpace(tmp) {
    while (tmp.endsWith(' ')) {
      tmp = tmp.substring(0, tmp.length - 1);
    }
    return tmp;
  }

  Future<void> _Detection(Uri url) async {
    var response = await http.get(url);
    List<String> list = [];
    _Deb = Deb.text;
    _Fin = Fin.text;
    _Ville = Ville.text;
    _Lieu = Lieu.text;
    _Commentaire = Commentaire.text;
    if (response.statusCode == 200) {
      //var wordShow = (convert.jsonDecode(response.body)as List)?.map((item) => item as String)?.toList();
      var wordShow = convert.jsonDecode(response.body);
      for (var elem in wordShow) {
        elem =
            elem.toString().replaceAll("[", "").replaceAll("]", "").split(", ");
        if (elem[4] == _Ville) {
          list.add(
              "Vous avez déjà un embouteillage sur l'axe: ${elem[1]} à ${elem[2]} dans la ville de ${elem[4]} précisément à ${elem[3]}");
          debugPrint('$elem');
        }
      }
    }
    if (list.isEmpty) {
      debugPrint(
          'Deb = ${endwithSpace(_Deb)}, fin = ${endwithSpace(_Fin)}, ville = ${endwithSpace(_Ville)}, lieu = ${endwithSpace(_Lieu)}');
      var urlStringPost = 'http://149.202.45.36:8000/insertion';
      var urlPost = Uri.parse(urlStringPost);
      var response = await http.post(
        urlPost,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: convert.jsonEncode(<String, String>{
          'nomDeb': endwithSpace(_Deb),
          'nomFin': endwithSpace(_Fin),
          'nomQuartier': endwithSpace(_Lieu),
          'nomVille': endwithSpace(_Ville),
          'commentaire': endwithSpace(_Commentaire)
        }),
      );
      list.add('Votre demande a été prise en compte');
      _Rep = response.statusCode;
      debugPrint('$_Rep');
    }
    _MyList = list;
  }

  bool alertvalidation(String valid) {
    RegExp exp = RegExp(
        r"^([a-zA-Z0-9áàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ]+[._-]?\s?)+$");
    if (valid.isEmpty || !exp.hasMatch(valid)) {
      Alert(
        context: context,
        type: AlertType.error,
        title: "Alerte",
        desc:
            "Ce champ ne peut ni être vide ni contenir des caractères spéciaux. La syntaxe de:<< ${valid} >> est incorrecte",
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          )
        ],
      ).show();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final heigh = MediaQuery.of(context).size.height * 0.15;
    return Scaffold(
      appBar: AppBar(
        title: Text("AliKaVoA"),
      ),
      body: new Stack(
        children: <Widget>[
          new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("assets/images/fond.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  children: [
                    FormBuilderTextField(
                      controller: Deb,
                      onChanged: _onChangeText,
                      name: 'Debut',
                      decoration: const InputDecoration(
                          labelText: 'Début de la route',
                          hintText: "Début de la route"),
                      validator: (value) {
                        if (Deb.text.isEmpty) {
                          return 'S\'il vous plaît entrez le lieu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 0.2),
                    FormBuilderTextField(
                      controller: Fin,
                      onChanged: _onChangeText,
                      name: 'Fin',
                      decoration: const InputDecoration(
                          labelText: 'Fin de la route',
                          hintText: "Fin de la route de l'embouteillage"),
                      validator: (value) {
                        if (Fin.text.isEmpty) {
                          return 'S\'il vous plaît entrez le lieu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 0.2),
                    FormBuilderTextField(
                      controller: Ville,
                      onChanged: _onChangeText,
                      name: 'Ville',
                      decoration: const InputDecoration(
                          labelText: 'Ville',
                          hintText: "Ville où il y a l'embouteillage"),
                      validator: (value) {
                        if (Ville.text.isEmpty) {
                          return 'S\'il vous plaît entrez le lieu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 0.2),
                    FormBuilderTextField(
                      controller: Lieu,
                      onChanged: _onChangeText,
                      name: 'Lieu',
                      decoration: const InputDecoration(
                          labelText: "Lieu d'embouteillage",
                          hintText: "Lieu exact de l'embouteillage"),
                      validator: (value) {
                        if (Lieu.text.isEmpty) {
                          return 'S\'il vous plaît entrez le lieu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 0.2),
                    FormBuilderTextField(
                      controller: Commentaire,
                      onChanged: _onChangeText,
                      name: 'Motif',
                      decoration: const InputDecoration(
                          labelText: "Motif de l'embouteillage",
                          hintText: "Commentaire"),
                    ),
                    MaterialButton(
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () async {
                        if (alertvalidation(Deb.text) &&
                            alertvalidation(Fin.text) &&
                            alertvalidation(Ville.text) &&
                            alertvalidation(Lieu.text)) {
                          var ville = _Lieu.toLowerCase();

                          var urlString =
                              'http://149.202.45.36:8000/consultationAno?ville=${ville}&position=${ville}';
                          var url = Uri.parse(urlString);
                          await _Detection(url);
                          if (_Rep == 200) {
                            Alert(
                              context: context,
                              type: AlertType.success,
                              title: "Merci !",
                              desc: "La ligne a été ajoutée avec succès",
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "Fermer",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  width: 120,
                                )
                              ],
                            ).show();
                          } else {
                            Alert(
                              context: context,
                              type: AlertType.error,
                              title: "Merci !",
                              desc: "La ligne n'a pas pu être ajoutée",
                              buttons: [
                                DialogButton(
                                  child: Text(
                                    "Fermer",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  width: 120,
                                )
                              ],
                            ).show();
                          }
                          debugPrint(
                              'Deb = ${_Deb}, fin = ${_Fin}, ville = ${_Ville}, lieu = ${_Lieu}');
                        }
                      },
                      child: Text(
                        "Valider",
                        style: TextStyle(
                          color: Color(0xffffffff),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
