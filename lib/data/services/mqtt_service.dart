import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';
import 'package:satelite_peru_gps/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MqttService with ChangeNotifier {
  MqttServerClient client =
      MqttServerClient.withPort('satelitem2m.pe', 'flutter_client', 1883);

  final StreamController<Map<String, dynamic>> _autoDataController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get autoDataStream => _autoDataController.stream;

  bool _isTryingToConnect =
      false; // Indicador para evitar múltiples intentos de reconexión
  Timer? _reconnectTimer;

  bool _isConnected = false; // Nueva variable de estado de conexión
  final Set<String> _subscribedTopics = {}; // Almacenar temas suscritos

  MqttService() {
    client.logging(on: true);
    client.setProtocolV311();
    client.keepAlivePeriod = 60;
    client.connectTimeoutPeriod = 10;

    client.onDisconnected = () => onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;

    // Intentar reconectar periódicamente si no hay conexión
    // _startReconnectTimer();
  }

  Future<void> connect(BuildContext context) async {
    if (_isTryingToConnect ||
        client.connectionStatus?.state == MqttConnectionState.connected) {
      print('Ya estamos conectados o intentando conectar.');
      return; // Evitar múltiples intentos de conexión
    } else {
      final connMess = MqttConnectMessage()
          .authenticateAs('sistema', 'Sp@346rRU12')
          .withClientIdentifier('Mqtt_MyClientUniqueId')
          .withWillTopic('willtopic')
          .withWillMessage('My Will message')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      client.connectionMessage = connMess;

      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // String? idEmpresa = prefs.getString('idEmpresa');

      final authService = Provider.of<AuthService>(context, listen: false);
      final idEmpresa = authService.userSession?.idEmpresa;

      print('->idEmpresa: $idEmpresa');
      if (idEmpresa == null) {
        print('Error: idEmpresa no está disponible para suscribirse');
        return; // Detenemos la conexión si no hay datos válidos
      }

      try {
        await client.connect();
        print('🔥 MqttService: Connected to satelitem2m.pe');
        _isConnected = true;

        // Suscribirse al tema
        final topic = 'capturador/data-vehiculo/$idEmpresa';
        subscribe(topic);
        print('TE suscribiste a 🦀🦀 $topic');
        _reconnectTimer?.cancel();
      } catch (e) {
        print('Error al conectar MQTT: $e');
      }
    }
    // if (_isConnected) {
    //   print('Ya estás conectado. Suscripción adicional evitada.');
    //   return;
    // }
  }

  void subscribe(String topic) {
    if (_subscribedTopics.contains(topic)) {
      print('Ya estás suscrito al tema $topic');
      return; // Evitar suscripciones duplicadas
    }

    client.subscribe(topic, MqttQos.atMostOnce);
    _subscribedTopics.add(topic); // Añadir el tema a los suscritos
    print('TE suscribiste a 🦀🦀  $topic');
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      // Parse payload assuming it's JSON
      final data = Map<String, dynamic>.from(json.decode(payload));
      _autoDataController.add(data);
    });
  }

  void unsubscribe(String topic) {
    client.unsubscribe(topic);
    print('TE desuscribiste de 🦀🦀  $topic');
  }

  void onSubscribed(String topic) {
    print('MqttService: Subscription confirmed for topic $topic');
  }

  void onDisconnected(BuildContext context) {
    print('MqttService: Disconnected from server');
    _isConnected = false;
    _startReconnectTimer(context);
  }

  void onConnected() {
    print('MqttService: Connected to server');
  }

  void pong() {
    print('MqttService: Ping response received');
  }

  void dispose() {
    _autoDataController.close();
    client.disconnect();
    _reconnectTimer?.cancel();
  }

  void _startReconnectTimer(BuildContext context) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        print('Internet connection available. Trying to reconnect...');
        connect(context);
      } else {
        print('No internet connection. Will retry in 10 seconds...');
      }
    });
  }
}
