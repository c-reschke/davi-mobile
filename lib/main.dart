import 'package:davi/mqtt/bloc/mqtt_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Davi',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (context) => MqttCubit(),
        child: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DAVI')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, children: [

          TextButton(onPressed: () {
            context.read<MqttCubit>().connect();
            
          }, child: Text('Connect')),

          TextButton(onPressed: () {
            context.read<MqttCubit>().disconnect();

          }, child: Text('Disconnect'))

        ],),
      ),
    );
  }
}
