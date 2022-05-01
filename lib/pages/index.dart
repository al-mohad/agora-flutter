import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'call.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final channelController = TextEditingController();
  bool validateError = false;
  ClientRole role = ClientRole.Broadcaster;

  @override
  void dispose() {
    channelController.dispose();
    super.dispose();
  }

  Future<void> onJoin() async {
    setState(() {
      channelController.text.isEmpty
          ? validateError = true
          : validateError = false;
    });
    if (channelController.text.isNotEmpty) {
      await handleCameraAndMic(Permission.camera);
      await handleCameraAndMic(Permission.microphone);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallPage(
            channelName: channelController.text,
            role: role,
          ),
        ),
      );
    }
  }

  Future<void> handleCameraAndMic(Permission permission) async {
    final status = await permission.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.network(
                'https://tinyurl.com/2p889y4k',
                width: 200,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: channelController,
                decoration: InputDecoration(
                  errorText: validateError ? 'Channel name is mandatory' : null,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.purple,
                      width: 1,
                    ),
                  ),
                  hintText: 'Channel name',
                ),
              ),
              RadioListTile(
                title: const Text('Broadcaster'),
                value: ClientRole.Broadcaster,
                groupValue: role,
                onChanged: (ClientRole? value) {
                  setState(() {
                    role = value!;
                  });
                },
              ),
              RadioListTile(
                title: const Text('Audience'),
                value: ClientRole.Audience,
                groupValue: role,
                onChanged: (ClientRole? value) {
                  setState(() {
                    role = value!;
                  });
                },
              ),
              ElevatedButton(
                onPressed: onJoin,
                child: const Text('Join'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
