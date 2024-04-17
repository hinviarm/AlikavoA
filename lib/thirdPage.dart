import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:async';
import 'dart:convert' as convert;
import 'fourthPage.dart';
import 'main.dart';

class MyThirdPage extends StatefulWidget {
  MyThirdPage({Key? key}) : super(key: key);

  @override
  _MyThirdPageState createState() => _MyThirdPageState();
}

class _MyThirdPageState extends State<MyThirdPage> {
  final FocusNode _focusNode = FocusNode();
  var loc = Localisation();
  var _MyList = [];
  var _MyListOID = [];
  var _Value = '';
  var _nom = '';
  double latitude = 0.0;
  double longitude = 0.0;
  bool varaccord = false;
  bool refus = false;

  _onChangeText(value) => _Value = "$value".toString();
  final Deb = TextEditingController();
  final Fin = TextEditingController();
  // Fields in a Widget subclass are always marked "final".

  @override
  void initState() {
    //getaccord();
    super.initState();
  }

/*Show dialog if GPS not enabled and open settings location*/
  Future<void> _checkGps() async {
    var textPricipal =
        "Cette application récupère votre localisation en arrière plan afin de trouver les embouteillages sur votre itinéraire. Acceptez vous?";
    //showAlert(context,textPricipal);
    if (!(await Geolocator.isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("AlikavoA ne peut obtenir votre localisation"),
              content: const Text('Activez votre GPS et réessayez'),
              actions: <Widget>[
                DialogButton(
                  child: Text('Ok'),
                  onPressed: () {
                    final AndroidIntent intent = AndroidIntent(
                        action: 'android.settings.LOCATION_SOURCE_SETTINGS');
                    intent.launch();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
    if (await Geolocator.isLocationServiceEnabled()) {
      LocationPermission permission = await Geolocator.checkPermission();
      if(permission == LocationPermission.denied){
        Alert(
          context: context,
          type: AlertType.warning,
          title: "Alerte Localisation",
          desc: "AlikavoA recueille votre localisation en arrière plan afin de trouver les embouteillages sur votre itinéraire.",
          buttons: [
            DialogButton(
              child: Text(
                "Accepter",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () async{
                final status = await Permission.location.request();
                if(status.isGranted){
                  showAlert(context, "AlikavoA récupère votre localisation!");
                  await loc.onStart();
                  longitude = loc.longitude;
                  latitude = loc.latitude;
                  refus = true;
                } else {
                  var text = "Veuillez entrer un lieu de départ si vous ne voulez autoriser votre localisation.";
                  showAlert(context, text );
                }
                Navigator.pop(context);
              },
              width: 120,
            ),
            DialogButton(
              child: Text(
                "Refuser",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
              Navigator.pop(context);
                },
              width: 120,
            )
          ],
        ).show();
      }

      /*
        Map<Permission, PermissionStatus> statuses = await [
          Permission.locationWhenInUse,
          Permission.locationAlways,
        ].request();
       */
        //final status = Permission.locationWhenInUse.serviceStatus;
        //_updateStatus(status);

// switch (status) {
        //     case PermissionStatus.disabled:
        //       await PermissionHandler().openAppSettings();
        //       break;
//    }
//    _updateStatus(status);


      /*
      if(longitude != 0.0 && latitude != 0.0){
        showAlert(context, "AlikavoA a récupéré votre localisation");
      }
       */
    }
    setState(() {});
  }

  void showAlert(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) {
        // Schedule a delayed dismissal of the alert dialog after 3 seconds
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop(); // Close the dialog
        });

        // Return the AlertDialog widget
        return AlertDialog(
          content: Text(text),
        );
      },
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    Deb.dispose();
    Fin.dispose();
    super.dispose();
  }

  void _Detection(Uri url) async {
    var response = await http.get(url);
    List<String> list = [];
    if (response.statusCode == 200) {
      //var wordShow = (convert.jsonDecode(response.body)as List)?.map((item) => item as String)?.toList();
      var wordShow = convert.jsonDecode(response.body);
      if (wordShow.toString() != "[]") {
        List<String> villes = [];
        for (var elem in wordShow) {
          elem = elem
              .toString()
              .replaceAll("[", "")
              .replaceAll("]", "")
              .split(", ");
          list.add(
              "Vous avez un embouteillage sur l'axe: ${elem[1]} à ${elem[2]} dans la ville de ${elem[4]} précisément à ${elem[3]}");
          debugPrint('$elem');
          _MyListOID.add(
              '${elem[0]};${elem[1]};${elem[2]};${elem[3]};${elem[4]}');
          if (villes.isEmpty) {
            villes.add(elem[4]);
          } else if (!villes.contains(elem[4])) {
            villes.add(elem[4]);
          }
        }
        var ensoleille = 1;
        if (villes != []) {
          ensoleille = 0;
          list.add("-----------");
          list.add("La météo des 5 prochains jours prévoit: ");
          list.add("-----------");
        }
        for (var ville in villes) {
          var url_apiString =
              "https://api.openweathermap.org/data/2.5/forecast?id=524901&q=${ville}&appid=502dbdfb15d5773f43890776ee8b7d7a&units=metric&lang=fr";
          var url_api = Uri.parse(url_apiString);
          var respMeteo = await http.get(url_api);
          if (respMeteo.statusCode == 200) {
            var resultMeteojson = convert.jsonDecode(respMeteo.body);
            var resultMeteo = resultMeteojson['list'];
            var stringSuiteDate = '';
            var stringSuiteheure = 0;
            var stringFin = '';
            var stringSuiteDateNuag = '';
            var stringSuiteheureNuag = 0;
            var stringFinNuag = '';
            for (var elem in resultMeteo) {
              for (var souslist in elem["weather"]) {
                var date = elem["dt_txt"].toString().split(" ");
                var amj = date[0].toString().split("-");
                var jma = "";
                switch (amj[1]) {
                  case "01":
                    jma = amj[2] + " " + "Janvier" + " " + amj[0];
                  case "02":
                    jma = amj[2] + " " + "Février" + " " + amj[0];
                  case "03":
                    jma = amj[2] + " " + "Mars" + " " + amj[0];
                  case "04":
                    jma = amj[2] + " " + "Avril" + " " + amj[0];
                  case "05":
                    jma = amj[2] + " " + "Mai" + " " + amj[0];
                  case "06":
                    jma = amj[2] + " " + "Juin" + " " + amj[0];
                  case "07":
                    jma = amj[2] + " " + "Juillet" + " " + amj[0];
                  case "08":
                    jma = amj[2] + " " + "Août" + " " + amj[0];
                  case "09":
                    jma = amj[2] + " " + "Septembre" + " " + amj[0];
                  case "10":
                    jma = amj[2] + " " + "Octobre" + " " + amj[0];
                  case "11":
                    jma = amj[2] + " " + "Novembre" + " " + amj[0];
                  case "12":
                    jma = amj[2] + " " + "Décembre" + " " + amj[0];
                }
                var datebon = jma + " à " + date[1];
                if (souslist["description"]
                    .toString()
                    .toLowerCase()
                    .contains("pluie")) {
                  //await Future.delayed(Duration(seconds: 20),() => tts.speak("Le" + datebon + "Il aura" + souslist["description"]));
                  if (date[0] == stringSuiteDate &&
                      int.parse(date[1].split(":")[0]) - 3 ==
                          stringSuiteheure) {
                    stringFin = "jusqu'à " + date[1].split(":")[0] + " heures";
                  } else {
                    if (stringFin.isNotEmpty) {
                      list.add(stringFin);
                      stringFin = '';
                    }
                    list.add("Le " +
                        datebon +
                        " Il aura " +
                        souslist["description"] +
                        " à " +
                        ville);
                    ensoleille = 1;
                  }
                  stringSuiteDate = date[0];
                  stringSuiteheure = int.parse(date[1].split(":")[0]);
                }
                if (souslist["description"]
                    .toString()
                    .toLowerCase()
                    .contains("nuageux")) {
                  if (date[0] == stringSuiteDateNuag &&
                      int.parse(date[1].split(":")[0]) - 3 ==
                          stringSuiteheureNuag) {
                    stringFinNuag =
                        "jusqu'à " + date[1].split(":")[0] + " heures";
                  } else {
                    if (stringFin.isNotEmpty) {
                      list.add(stringFin);
                      stringFin = '';
                    }
                    if (stringFinNuag.isNotEmpty) {
                      list.add(stringFinNuag);
                      stringFinNuag = '';
                    }
                    list.add("Le " +
                        datebon +
                        " le ciel sera " +
                        souslist["description"] +
                        " à " +
                        ville);
                    ensoleille = 1;
                  }
                  stringSuiteDateNuag = date[0];
                  stringSuiteheureNuag = int.parse(date[1].split(":")[0]);
                }
              }
            }
          }
        }
        if (ensoleille == 0) {
          _MyList.add("Pas de pluie les cinq prochains jours");
        }
      } else {
        list.add("Vous n'avez pas d'embouteillage déclaré sur votre trajet");
      }
    } else {
      list.add('Impossible de satisfaire votre demande');
    }
    setState(() {
      _MyList = list;
    });
  }

  String endwithSpace(tmp) {
    while (tmp.endsWith(' ')) {
      tmp = tmp.substring(0, tmp.length - 1);
    }
    return tmp;
  }

  Future<void> getaccord() async {
    varaccord = await SessionManager().get("accord") ?? false;
    debugPrint("getaccord " +
        varaccord.toString() +
        "-------------------------------");
    if (varaccord == true) {
      await _checkGps();
      //beginAlert(context);
      debugPrint("_checkGps " +
          varaccord.toString() +
          "-------------------------------");
      //loc.onStart();
    } else {
      showAlert(context,
          "AlikavoA va ne peut récupérer votre localisation ni votre point de départ");
    }
  }

  bool alertvalidation(String valid) {
    RegExp exp = RegExp(
        r"(^[a-zA-Z0-9áàâäãåçéèêëíìîïñóòôöõúùûüýÿæœÁÀÂÄÃÅÇÉÈÊËÍÌÎÏÑÓÒÔÖÕÚÙÛÜÝŸÆŒ]+[._-]?\s?)+$");
    debugPrint("Variable booléen ---------------- "+valid + "--- bool ---"+exp.hasMatch(valid).toString());
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
            direction: Axis.vertical,
            children: <Widget>[
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  height: 0.3,
                  child: SingleChildScrollView(
                    child: FormBuilder(
                      child: Column(children: [
                        FormBuilderTextField(
                          controller: Deb,
                          onChanged: _onChangeText,
                          name: 'Debut',
                          decoration: const InputDecoration(
                              labelText: 'Point de départ',
                              hintText: "N'écrivez rien ici si vous voulez"),
                          validator: (value) {
                            if (Deb.text.isEmpty && varaccord == false) {
                              showAlert(context,
                                  "AlikavoA va ne peut récupérer votre localisation ni votre point de départ");
                              return "S'il vous plaît ouvrez à nouveau l'application et acceptez la géolocalisation ou entrez votre point de départ";
                            }
                            return null;
                          },
                        ),
                        FormBuilderTextField(
                          controller: Fin,
                          onChanged: _onChangeText,
                          name: 'Fin',
                          decoration: const InputDecoration(
                              labelText: 'Entrez où vous allez',
                              hintText: "Entrez le lieu"),
                          validator: (value) {
                            if (Fin.text.isEmpty) {
                              showAlert(
                                  context, "Veuillez saisir votre destination");
                              return 'S\'il vous plaît entrez le lieu';
                            }
                            return null;
                          },
                        ),
                        MaterialButton(
                          color: Theme.of(context).colorScheme.secondary,
                          onPressed: () async {
                            if (!alertvalidation(Fin.text)) {
                              //showAlert(context, "Veillez saisir votre destination");
                              return;
                            }
                            var ville =
                                endwithSpace("${Fin.text}".toLowerCase());

                            if (Deb.text.isEmpty) {
                              await getaccord();
                              //latitude = await SessionManager().get("latitude");
                              //longitude = await SessionManager().get("longitude");
                              if (varaccord == false || refus == false) {
                                return;
                              }
                              //Future.delayed(Duration.zero, () => showAlert(context, "AlikavoA va envoyer votre localisation au serveur pour trouver les embouteillages."));
                              var urlString =
                                  'http://149.202.45.36:8000/consultation?ville=${ville}&latitude=${latitude}&longitude=${longitude}';
                              var url = Uri.parse(urlString);
                              debugPrint("longitude: " +
                                  longitude.toString() +
                                  " latitude:  " +
                                  latitude.toString());
                              _Detection(url);
                            } else {
                              if(!alertvalidation(Deb.text)){
                                return;
                              }
                              var debut =
                                  endwithSpace("${Deb.text}".toLowerCase());
                              var urlString =
                                  'http://149.202.45.36:8000/consultationAno?ville=${ville}&position=${debut}';
                              var url = Uri.parse(urlString);
                              _Detection(url);
                            }
                          },
                          child: Text(
                            "Rechercher",
                            style: TextStyle(
                              color: Color(0xffffffff),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return InkWell(
                      child: Container(
                        color: (index % 2 == 0)
                            ? Colors.white.withOpacity(0.7)
                            : Colors.cyanAccent.withOpacity(0.7),
                        child: Text(_MyList[index]),
                      ),
                      onTap: () => {
                        //debugPrint('${_MyList[index]}'),
                        /*Navigator.pushNamed(context, '/FourthPage',
                            arguments: _MyList[index]),*/
                        if (index < _MyListOID.length)
                          {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyFourthPage(
                                          liste: _MyListOID[index],
                                        ))),
                          }
                        else
                          {
                            Alert(
                              context: context,
                              type: AlertType.error,
                              title: "Désolé !",
                              desc:
                                  "Vous n'avez pas sélectionné une ligne d'embouteillage",
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
                            ).show(),
                          }
                      },
                    );
                  },
                  itemCount: _MyList.length,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
