import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:vservesafe/src/controllers/user_controller.dart';
import 'package:vservesafe/src/controllers/settings_controller.dart';
import 'package:vservesafe/src/services/api_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class IotDashboardView extends StatefulWidget {
  const IotDashboardView({
    super.key,
    required this.settingsController,
    required this.userController,
  });

  final SettingsController settingsController;
  final UserController userController;

  static const routeName = '/iot';
  @override
  State<IotDashboardView> createState() => _IotDashboardViewState();
}

class _IotDashboardViewState extends State<IotDashboardView> {
  late io.Socket _socket;
  final Map<String, String> _iotData = {};

  @override
  void initState() {
    super.initState();

    _socketIO();
    _loadIoTData();
  }

  void _socketIO() {
    final uri = Uri.parse(ApiService.socketIoPath);
    final host = uri.hasPort
        ? "${uri.scheme}://${uri.host}:${uri.port}"
        : "${uri.scheme}://${uri.host}";
    final subpath = "${uri.path}/socket.io";

    developer.log("SIO Host: $host", name: "SocketIO");
    developer.log("SIO Path: $subpath", name: "SocketIO");

    _socket = io.io(
      host,
      io.OptionBuilder().setTransports(['websocket']).setPath(subpath).build(),
    );
    _socket.onConnect((_) {
      developer.log("Connected", name: "SocketIO");
    });
    _socket.onError((err) {
      developer.log(err.toString(), name: "SocketIO");
    });

    _socket.on('vsafe-iot-set', (data) {
      if (_iotData.containsKey(data["key"])) {
        _iotData[data["key"]] = data["value"].toString();
        setState(() {});
      }
    });
  }

  @override
  void reassemble() {
    super.reassemble();

    _socket.dispose();
    _socketIO();
    _loadIoTData();
  }

  void _loadIoTData() async {
    try {
      final response = await ApiService.dio.get(
        "${ApiService.baseUrlPath}/iot/lists",
      );
      final listData = response.data["lists"] as Map<String, dynamic>;
      for (final entry in listData.entries) {
        _iotData[entry.key] = entry.value.toString();
      }

      if (mounted) {
        setState(() {});
      }
    } catch (err) {
      developer.log(err.toString(), name: "IoT");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<MapEntry<String, String>> iotDataList = _iotData.entries.toList();
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      primary: false,
      itemCount: iotDataList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Text(
            "Iot Device Monitor",
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          );
        } else {
          MapEntry<String, String> data = iotDataList[index - 1];
          return ListTile(
            title: Text(data.key),
            subtitle: Text(data.value),
            trailing: Container(
              width: 21,
              height: 21,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _socket.dispose();

    super.dispose();
  }
}
