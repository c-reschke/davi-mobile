import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:async';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

part 'mqtt_state.dart';

class MqttCubit extends Cubit<MqttState> {
  MqttCubit() : super(MqttInitial());

  late MqttServerClient _client;

  Future connect() async {
    try {
      _client = MqttServerClient('127.0.0.1:1883', 'davi');
      _client.logging(on: true);

      /// Set the correct MQTT protocol for mosquito
      _client.setProtocolV311();

      /// If you intend to use a keep alive you must set it here otherwise keep alive will be disabled.
      _client.keepAlivePeriod = 20;
    } catch (e) {
      print(e);
    }
  }

  Future disconnect() async {
    if (_client != null) {
      _client.disconnect();
    }
  }
}
