import 'package:alikavoa1/thirdPage.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:checkbox_formfield/checkbox_formfield.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scrollable_text_indicator/scrollable_text_indicator.dart';
import 'main.dart';

class Privacy extends StatefulWidget {
  Privacy({Key? key}) : super(key: key);

  @override
  _MyPrivacyState createState() => _MyPrivacyState();
}

class _MyPrivacyState extends State<Privacy> {
  bool checkboxIconFormFieldValue = false;
  bool varaccord = false;
  bool vartjours = false;

  void sessManager() async {
    await SessionManager().set("accord", varaccord);
    await SessionManager().set("toujours", vartjours);
    debugPrint(vartjours.toString());
  }

  Future<void> _checkGps() async {
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
    setState(() {});
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
                flex: 7,
                child: ScrollableTextIndicator(
                  text: Text(
                    """Politique de confidentialité\n 1.Collecte de l’information\n
    Nous recueillons des informations sur votre localisation sans votre identité sur AliKaVoA en arrière plan dans le but de pouvoir filtrer les embouteillages enregistrés dans sa base et, vous proposer que ceux sur votre trajectoire. Celà est indispensable au bon fonctionnement de l'application. Ces données ne sont pas enregistrées.\n

    2.Utilisation des informations\n
    Toutes les informations que nous recueillons auprès de vous peuvent être utilisées pour :\n

    Vous permettre de trouver les embouteillages dans le cercle de diamètre vous et votre destination\n
    
    3.Confidentialité du commerce en ligne\n
    Nous sommes les seuls propriétaires des informations recueillies sur ce site. Vos informations personnelles ne seront pas vendues, échangées, transférées, ou données à une autre société pour n’importe quelle raison, sans votre consentement.\n

    4.Divulgation à des tiers\n
    Nous ne vendons, n’échangeons et ne transférons pas vos informations personnelles identifiables à des tiers. Cela ne comprend pas les tierce parties de confiance qui nous aident à exploiter notre application ou à mener nos affaires, tant que ces parties conviennent de garder ces informations confidentielles.
    Nous pensons qu’il est nécessaire de partager des informations afin d’enquêter, de prévenir ou de prendre des mesures concernant des activités illégales, fraudes présumées, situations impliquant des menaces potentielles à la sécurité physique de toute personne, violations de nos conditions d’utilisation, ou quand la loi nous y contraint.
    Les informations non-privées, cependant, peuvent être fournies à d’autres parties pour le marketing, la publicité, ou d’autres utilisations.\n
    
    5.Protection des informations\n
    Nous mettons en œuvre une variété de mesures de sécurité pour préserver la sécurité de vos informations personnelles. Ces informations ne sont accessibles que par l’administrateur de l’application AliKaVoA\n
    Est-ce que nous utilisons des cookies ?\n
    Nous enregistrons votre localisation en session de même qu'une variable nous indiquant si c'est votre première connection\n
    6.Suppression des informations\n
    Vous pouvez demander la suppression de vos informations personnelles à tout moment en envoyant
    Un mail à HINVI Armand Armel : armand.hinvi@gmail.com tout en précisant l’objet de votre demande\n

    7.Consentement\n
    En utilisant notre application AliKaVoA, vous consentez à notre politique de confidentialité. """,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: CheckboxListTileFormField(
                  title: Text(
                    'Ne plus demander',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onSaved: (bool? value) {
                    checkboxIconFormFieldValue = value ?? false;
                  },
                  onChanged: (value) {
                    vartjours = value;
                    if (value) {
                      debugPrint("Icon Checked :)");
                    } else {
                      debugPrint("Icon Not Checked :(");
                    }
                  },
                  autovalidateMode: AutovalidateMode.always,
                  contentPadding: EdgeInsets.all(1),
                ),
              ),
              new Flex(direction: Axis.horizontal, children: <Widget>[
                Expanded(
                  flex: 2,
                  child: MaterialButton(
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () async {
                      varaccord = true;
                      await _checkGps();
                      sessManager();
                      Future.delayed(Duration(seconds: 1)).then((value) =>
                          Navigator.of(context)
                            ..pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => Screen()),
                                (route) => false));
                    },
                    child: Text(
                      "Accepter",
                      style: TextStyle(
                        color: Color(0xffffffff),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: MaterialButton(
                    color: Theme.of(context).colorScheme.secondary,
                    onPressed: () async {
                      Alert(
                        context: context,
                        type: AlertType.info,
                        title: "Information",
                        desc:
                            "Vous ne pouvez utiliser correctement cette application sans cet accord. Voulez vous accepter",
                        buttons: [
                          DialogButton(
                            child: Text(
                              "Oui",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () async {
                              varaccord = true;
                              await _checkGps();
                              sessManager();
                              Future.delayed(Duration(seconds: 1)).then(
                                  (value) => Navigator.of(context)
                                    ..pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) => Screen()),
                                        (route) => false));
                            },
                            color: Color.fromRGBO(0, 179, 134, 1.0),
                            radius: BorderRadius.circular(0.0),
                          ),
                          DialogButton(
                            child: Text(
                              "Non",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Future.delayed(Duration(seconds: 1)).then(
                                  (value) => Navigator.of(context)
                                    ..pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MyThirdPage()),
                                        (route) => false));
                            },
                            color: Color.fromRGBO(0, 179, 134, 1.0),
                            radius: BorderRadius.circular(0.0),
                          ),
                        ],
                      ).show();
                    },
                    child: Text(
                      "Refuser",
                      style: TextStyle(
                        color: Color(0xffffffff),
                      ),
                    ),
                  ),
                )
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
