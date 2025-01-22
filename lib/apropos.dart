import 'package:alikavoa1/thirdPage.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:checkbox_formfield/checkbox_formfield.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scrollable_text_indicator/scrollable_text_indicator.dart';
import 'main.dart';

class Apropos extends StatefulWidget {
  Apropos({Key? key}) : super(key: key);

  @override
  _MyApropos createState() => _MyApropos();
}

class _MyApropos extends State<Apropos> {


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
                    """A Propos \nAlikavoA comprend deux types de contenus: \n\n1) Les embouteillages renseignés par les utilisateurs\nIl existe deux types d'embouteillages en fonction du motif. \nSi le motif est: 'travaux', L'embouteillage sera affiché jusqu'à son retrait à la fin des travaux
                    \nSi le motif est différent de 'travaux' ou vide, la durée de l'information est d'une journée. Nous garantissons l'actualisation de ces données
                    \n\n2)La météo\nLa météo est reccueillie via un API sur https://openweathermap.org \n\nPour toute information ou demande, vous pouvez nous écrire à armand.hinvi@gmail.com en précisant dans le motif AlikavoA""",
                    style: TextStyle(color: Colors.white, fontSize: 20),
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
