part of 'mqtt_cubit.dart';

abstract class MqttState extends Equatable {
  const MqttState();
}

class MqttInitial extends MqttState {
  @override
  List<Object> get props => [];
}
