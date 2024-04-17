import 'package:alikavoa1/privacy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:location/location.dart' as lc;
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart' as lot;
import 'dart:io' as io show Platform;
import 'dart:async';
import 'dart:convert' as convert;

import 'secondPage.dart';
import 'thirdPage.dart';
import 'fourthPage.dart';

//void main() => runApp(MyApp());
class GetSession {
  bool varaccord = false;
  bool vartjours = false;
  Future<(bool, bool)> stampSession() async {
    varaccord = await SessionManager().get("accord") ?? false;
    vartjours = await SessionManager().get("toujours") ?? false;
    debugPrint("vartjours st==" + vartjours.toString());
    return (varaccord, vartjours);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'AliKaVoA',
        home: Screen(),
        routes: {
          '/load': (context) => Load(),
          '/homeScreen': (context) => Screen(),
          '/secondPage': (context) => MySecondPage(),
          '/ThirdPage': (context) => MyThirdPage(),
          '/fourthPage': (context) => MyFourthPage(liste: ""),
        },
        initialRoute: '/load');
  }
}

class Load extends StatefulWidget {
  Load({Key? key}) : super(key: key);

  @override
  _LoadState createState() => _LoadState();
}

class _LoadState extends State<Load> {

  @override
  void initState() {
    super.initState();
    changvue();
  }

  void changvue() async {
    GetSession sess = GetSession();
    await sess.stampSession();
    debugPrint("vartjours == " +
        sess.vartjours.toString() +
        " varaccord == " +
        sess.varaccord.toString());
    if (sess.varaccord == true && sess.vartjours == true) {
      Future.delayed(Duration(seconds: 5)).then((value) => Navigator.of(context)
          .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Screen()),
              (route) => false));
    } else {
      Future.delayed(Duration(seconds: 5)).then((value) => Navigator.of(context)
          .pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => Privacy()),
              (route) => false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new Stack(
      children: <Widget>[
        Center(
          child: Container(
            height: 200.0,
            width: 200.0,
            child: lot.LottieBuilder.asset('assets/images/accueil.json'),
          ),
        ),
      ],
    ));
  }
}

class Screen extends StatefulWidget {
  Screen({Key? key}) : super(key: key);

  @override
  _MyScreen createState() => _MyScreen();
}

class _MyScreen extends State<Screen> {
  final PageController _controller = PageController(initialPage: 0);
  int _currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        controller: _controller,
        children: <Widget>[
          MyThirdPage(),
          MyHomePage(),
          MySecondPage(),
        ],
      ),
      bottomNavigationBar: new Theme(
        data: Theme.of(context).copyWith(
            // sets the background color of the `BottomNavigationBar`
            canvasColor: Colors.cyan,
            // sets the active color of the `BottomNavigationBar` if `Brightness` is light
            primaryColor: Colors.lightBlue,
            textTheme: Theme.of(context)
                .textTheme
                .copyWith(caption: new TextStyle(color: Colors.yellow))),
        child: new BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            _controller.jumpToPage(_currentIndex);
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Recherche',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.speaker_sharp),
              label: 'Audio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_road),
              label: 'Ajout Embouteillage',
            ),
          ],
        ),
      ),
    );
  }
}


class Localisation {
  var latitude = 0.0;
  var longitude = 0.0;
  Future<void> onStart() async {
    lc.Location location = new lc.Location();
    bool _serviceEnabled;
    lc.PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        debugPrint("-------------------Service------------------");
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        debugPrint("-------------------Permission------------------");
        return;
      }
    }
    lc.LocationData _locationData;
    _locationData = await location.getLocation();
    latitude = _locationData.latitude ?? 0.0;
    longitude = _locationData.longitude ?? 0.0;
    debugPrint("longitude: " +
        longitude.toString() +
        " latitude:  " +
        latitude.toString());
    location.enableBackgroundMode(enable: false);
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum TtsState { playing, stopped, paused, continued }

class _MyHomePageState extends State<MyHomePage> {
  //final service = FlutterBackgroundService();
  var loc = Localisation();
  SpeechToText _speechToText = SpeechToText();
  late FlutterTts flutterTts;
  TtsState ttsState = TtsState.stopped;
  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  bool _speechEnabled = false;
  String _lastWords = '';
  var stopLecture = 0;
  var _MyList = [];
  var _MyListOID = [];
  var latitude = 0.0;
  var longitude = 0.0;
  var destination = "";
  String? language;
  //String? engine;
  double volume = 1;
  double pitch = 1.0;
  double rate = 0.5;
  bool get isAndroid => !kIsWeb && io.Platform.isAndroid;
  bool refus = false;


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
  void initState() {
    //stopService();
    super.initState();
    initTts();
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() async {
      var text = _lastWords.toLowerCase();
      await _checkGps();

      if(refus == false){
        return;
      }
      //Future.delayed(Duration.zero, () => showAlert(context, "AlikavoA va envoyer votre localisation au serveur pour trouver les embouteillages."));
      var urlString =
          'http://149.202.45.36:8000/consultationAndroid?text=${text}&latitude=${latitude}&longitude=${longitude}';
      var url = Uri.parse(urlString);
      debugPrint("longitude: " +
          longitude.toString() +
          " latitude:  " +
          latitude.toString());
      _speak('Vous avez dit: $_lastWords');
      _Detection(url);
    });
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

/*Show dialog if GPS not enabled and open settings location*/
  Future<void> _checkGps() async {
    var textPricipal =
        "Cette application récupère votre localisation en arrière plan afin de trouver les embouteillages sur votre itinéraire. Acceptez vous?";
    //showAlert(context,textPricipal);
    //await Future.delayed(Duration(seconds: 4), () => _speak(textPricipal));
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
                  var text = "Utilisez la vue de recherche si vous ne voulez pas autoriser la géolocalisation";
                  showAlert(context, text );
                  await Future.delayed(Duration(seconds: 2), () => _speak(text));
                  Future.delayed(Duration(seconds: 5)).then((value) => Navigator.of(context)
                      .pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => Screen()),
                          (route) => false));
                }
                Navigator.pop(context);},
              width: 120,
            ),
            DialogButton(
              child: Text(
                "Refuser",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                Navigator.pop(context);
                return;
                },
              width: 120,
            )
          ],
        ).show();
      }

    }
    setState(() {});
  }

  void _Detection(Uri url) async {
    var response = await http.get(url);
    var list = [];
    stopLecture = 0;
    _MyListOID = [];
    var variable = '';
    if (_lastWords.contains(" à ")) {
      destination = _lastWords.split(" à ")[1];
    } else if (_lastWords.contains(" au ")) {
      destination = _lastWords.split(" au ")[1];
    } else if (_lastWords.contains(" aux ")) {
      destination = _lastWords.split(" aux ")[1];
    } else if (_lastWords.contains(" en ")) {
      destination = _lastWords.split(" en ")[1];
    }
    //const wait = ms => new Promise(resolve => setTimeout(resolve, ms));
    if (response.statusCode == 200) {
      //var wordShow = (convert.jsonDecode(response.body)as List)?.map((item) => item as String)?.toList();
      var wordShow = convert.jsonDecode(response.body);
      List<String> villes = [];
      villes.add(destination);
      if (wordShow.toString() != "[]") {
        for (var elem in wordShow) {
          elem = elem
              .toString()
              .replaceAll("[", "")
              .replaceAll("]", "")
              .split(", ");
          variable =
              "Vous avez un embouteillage sur l'axe: ${elem[1]} à ${elem[2]} dans la ville de ${elem[4]} précisément à ${elem[3]}";
          list.add(variable);
          _MyListOID.add(
              '${elem[0]};${elem[1]};${elem[2]};${elem[3]};${elem[4]}');

          debugPrint('$variable');
          if (villes.isEmpty) {
            villes.add(elem[4]);
          } else if (!villes.contains(elem[4])) {
            villes.add(elem[4]);
          }
        }
        var ensoleille = 1;
        if (villes != []) {
          ensoleille = 0;
          list.add("La météo des 5 prochains jours prévoit: ");
        }
        debugPrint(list.toString());
        debugPrint(villes.toString());
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
            debugPrint('$resultMeteo');
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
                var datebon = jma + " à " + date[1].split(":")[0] + " heures";
                //await Future.delayed(const Duration(seconds: 20));
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
          list.add("Pas de pluie les cinq prochains jours");
        }
      } else {
        var ensoleille = 1;
        if (villes != []) {
          ensoleille = 0;
          list.add("Vous n'avez pas d'embouteillage déclaré sur votre trajet");
          list.add("La météo des 5 prochains jours prévoit: ");
        } else {
          list.add(
              "Dites là où vous allez après avoir cliqué sur l'icone du micro et laissez le se désactiver puis, appuyez et ne dites rien ");
        }
        var ville = destination;
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
          debugPrint('$resultMeteo');
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
              var datebon = jma + " à " + date[1].split(":")[0] + " heures";
              //await Future.delayed(const Duration(seconds: 20));
              if (souslist["description"]
                  .toString()
                  .toLowerCase()
                  .contains("pluie")) {
                if (date[0] == stringSuiteDate &&
                    int.parse(date[1].split(":")[0]) - 3 == stringSuiteheure) {
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
        if (ensoleille == 0) {
          list.add("Pas de pluie les cinq prochains jours");
        }
      }
    }
    if (list.isEmpty && _lastWords.isNotEmpty) {
      list.add('Impossible de satisfaire votre demande');
    }
    debugPrint(list.toString());
    setState(() {
      _MyList = list;
    });
    for (var elem in _MyList) {
      if (stopLecture == 1) {
        break;
      }
      await Future.delayed(Duration(seconds: 8), () => _speak(elem));
    }
  }

  initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    if (isAndroid) {
      flutterTts.setInitHandler(() {
        setState(() {
          print("TTS Initialized");
        });
      });
    }

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> _getEngines() async => await flutterTts.getEngines;

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future _speak(String text) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (text != null) {
      if (text!.isNotEmpty) {
        await flutterTts.speak(text!);
      }
    }
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  /*Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }*/

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
                flex: 3,
                child: Container(
                  height: 9,
                  padding: EdgeInsets.all(16),
                  child: Text(
                    // If listening is active show the recognized words
                    _speechToText.isListening
                        ? '$_lastWords'
                        // If listening isn't active but could be tell the user
                        // how to start it, otherwise indicate that speech
                        // recognition is not yet ready or not supported on
                        // the target device
                        : _speechEnabled
                            ? "Touchez le microphone dites : 'je vais à...' et retouchez pour qu'il lise"
                            : 'Enrégistrement non valide',
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: ListView.builder(
                  shrinkWrap: true,
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
              new Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  Expanded(
                    child: FloatingActionButton(
                      onPressed:
                          // If not yet listening for speech start, otherwise stop
                          _speechToText.isNotListening
                              ? _startListening
                              : _stopListening,
                      tooltip: 'Listen',
                      child: Icon(_speechToText.isNotListening
                          ? Icons.mic_off
                          : Icons.mic),
                    ),
                  ),
                  Expanded(
                    child: FloatingActionButton(
                        tooltip: 'Stop',
                        child: Icon(Icons.stop_circle),
                        onPressed: () {
                          _stop();
                          stopLecture = 1;
                        }),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
