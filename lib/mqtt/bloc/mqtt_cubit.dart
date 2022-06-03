import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_server_client.dart';

part 'mqtt_state.dart';

class MqttCubit extends Cubit<MqttState> {
  MqttCubit() : super(MqttInitial());

  late MqttServerClient _client;
  var pongCount = 0; // Pong counter
  Future connect() async {
    print('aqui');
    try {
      _client = MqttServerClient.withPort('201.21.207.212', 'davi', 1883);
      _client.logging(on: true);

      /// Set the correct MQTT protocol for mosquito
      _client.setProtocolV311();

      /// If you intend to use a keep alive you must set it here otherwise keep alive will be disabled.
      _client.keepAlivePeriod = 20;


      /// Add the unsolicited disconnection callback
      _client.onDisconnected = onDisconnected;

      /// Add the successful connection callback
      _client.onConnected = onConnected;

      /// Add a subscribed callback, there is also an unsubscribed callback if you need it.
      /// You can add these before connection or change them dynamically after connection if
      /// you wish. There is also an onSubscribeFail callback for failed subscriptions, these
      /// can fail either because you have tried to subscribe to an invalid topic or the broker
      /// rejects the subscribe request.
      _client.onSubscribed = onSubscribed;

      /// Set a ping received callback if needed, called whenever a ping response(pong) is received
      /// from the broker.
      _client.pongCallback = pong;

      /// Create a connection message to use or use the default one. The default one sets the
      /// _client identifier, any supplied username/password and clean session,
      /// an example of a specific one below.
      final connMess = MqttConnectMessage()
          .withClientIdentifier('Mqtt_My_clientUniqueId')
          .withWillTopic('willtopic') // If you set this you must set a will message
          .withWillMessage('My Will message')
          .startClean() // Non persistent session for testing
          .withWillQos(MqttQos.atLeastOnce);
      print('EXAMPLE::Mosquitto _client connecting....');
      _client.connectionMessage = connMess;

      /// Connect the _client, any errors here are communicated by raising of the appropriate exception. Note
      /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
      /// never send malformed messages.
      try {
        await _client.connect();
      } on NoConnectionException catch (e) {
        // Raised by the _client when connection fails.
        print('EXAMPLE::_client exception - $e');
        _client.disconnect();
      } on SocketException catch (e) {
        // Raised by the socket layer
        print('EXAMPLE::socket exception - $e');
        _client.disconnect();
      }

      /// Check we are connected
      if (_client.connectionStatus!.state == MqttConnectionState.connected) {
        print('EXAMPLE::Mosquitto _client connected');
      } else {
        /// Use status here rather than state if you also want the broker return code.
        print(
            'EXAMPLE::ERROR Mosquitto _client connection failed - disconnecting, status is ${_client.connectionStatus}');
        _client.disconnect();
        exit(-1);
      }


    } catch (e) {
      print(e);
    }
  }

  Future disconnect() async {
    if (_client != null) {
      _client.disconnect();
    }
  }


  /// The subscribed callback
  void onSubscribed(String topic) {
    print('EXAMPLE::Subscription confirmed for topic $topic');
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    print('EXAMPLE::OnDisconnected client callback - Client disconnection');
    if (_client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print('EXAMPLE::OnDisconnected callback is solicited, this is correct');
    } else {
      print(
          'EXAMPLE::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
      exit(-1);
    }
    if (pongCount == 3) {
      print('EXAMPLE:: Pong count is correct');
    } else {
      print('EXAMPLE:: Pong count is incorrect, expected 3. actual $pongCount');
    }
  }

  /// The successful connect callback
  void onConnected() {
    print(
        'EXAMPLE::OnConnected client callback - Client connection was successful');
  }

  /// Pong callback
  void pong() {
    print('EXAMPLE::Ping response client callback invoked');
    pongCount++;
  }
}
