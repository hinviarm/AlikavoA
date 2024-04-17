import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

class MyFourthPage extends StatefulWidget {
  final String liste;
  MyFourthPage({required this.liste, Key? key}) : super(key: key);

  @override
  _MyFourthPageState createState() => _MyFourthPageState();
}

class _MyFourthPageState extends State<MyFourthPage> {
  late List<String> _MyListOID;
  var _Rep = 0;
  var _OID = '';

  @override
  void initState() {
    var genereList = widget.liste;
    _MyListOID = genereList.split(";");
    if (_MyListOID != []) {
      _OID = _MyListOID[0];
      _MyListOID.removeAt(0);
      _MyListOID[0] = "Départ voie: " + _MyListOID[0];
      _MyListOID[1] = "Fin voie: " + _MyListOID[1];
      _MyListOID[2] = "Lieu de l'embouteillage: " + _MyListOID[2];
      _MyListOID[3] = "Ville de l'embouteillage: " + _MyListOID[3];
    } else {
      _MyListOID[0] = "Vous n'avez pas sélectionné une ligne d'embouteillage";
    }

    super.initState();
  }

  void _MiseAjour(Uri url) async {
    var response = await http.put(url);
    _Rep = response.statusCode;
  }

  @override
  Widget build(BuildContext context) {
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
          new Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(_MyListOID[index]),
                      ),
                    );
                  },
                  itemCount: _MyListOID.length,
                ),
              ),
              Expanded(
                flex: 2,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xffF18265),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    debugPrint(_OID);
                    var urlString =
                        'http://149.202.45.36:8000/miseAJour?IDEmbouteillage=${int.parse(_OID)}';
                    var url = Uri.parse(urlString);
                    _MiseAjour(url);
                    if (_Rep == 200) {
                      Alert(
                        context: context,
                        type: AlertType.success,
                        title: "Merci !",
                        desc: "La ligne a été Mise à jour avec succès",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "Fermer",
                              style:
                              TextStyle(color: Colors.white, fontSize: 20),
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
                        desc: "La ligne n'a pas pu être Mise à jour",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "Fermer",
                              style:
                              TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () => Navigator.pop(context),
                            width: 120,
                          )
                        ],
                      ).show();
                    }
                  },
                  child: Text(
                    "Archiver",
                    style: TextStyle(
                      color: Color(0xffffffff),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}