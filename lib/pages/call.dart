import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:agora_video/utils/settings.dart';
import 'package:flutter/material.dart';

class CallPage extends StatefulWidget {
  final String channelName;
  final ClientRole role;
  const CallPage({
    Key? key,
    required this.channelName,
    required this.role,
  }) : super(key: key);

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final _users = <int>[];
  final _infoString = <String>[];
  bool muted = false;
  bool viewPannel = false;
  late RtcEngine rtcEngine;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  void dispose() {
    _users.clear();
    rtcEngine.leaveChannel();
    rtcEngine.destroy();
    super.dispose();
  }

  Future<void> initialize() async {
    if (appId.isEmpty) {
      _infoString
          .add('APP_ID Misssing, please add your app id in settings.dart');
      _infoString.add('Agora Engine is not starting.');
    }

    rtcEngine = await RtcEngine.create(appId);
    await rtcEngine.enableVideo();
    await rtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await rtcEngine.setClientRole(widget.role);
    addAgoraEventHandlers();
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(width: 1920, height: 1080);
    await rtcEngine.setVideoEncoderConfiguration(configuration);
    await rtcEngine.joinChannel(
      appToken,
      widget.channelName,
      null,
      0,
    );
  }

  addAgoraEventHandlers() async {
    rtcEngine.setEventHandler(
      RtcEngineEventHandler(
        error: (code) {
          setState(() {
            final info = 'Error: $code';
            _infoString.add(info);
          });
        },
        joinChannelSuccess: (channel, uid, elapsed) {
          setState(() {
            final info = 'Join Channel $channel, uid: $uid';
            _infoString.add(info);
          });
        },
        leaveChannel: (stats) {
          setState(() {
            final info = 'Leave Channel $stats';
            _infoString.add(info);
            _users.clear();
          });
        },
        userJoined: (uid, elapsed) {
          setState(() {
            final info = 'User joined Channel $uid';
            _infoString.add(info);
            _users.add(uid);
          });
        },
        userOffline: (uid, elapsed) {
          setState(
            () {
              final info = 'User is offline $uid';
              _infoString.add(info);
              _users.remove(uid);
            },
          );
        },
        firstRemoteVideoFrame: (uid, width, height, elapsed) {
          final info = 'First Remote Video Frame: $uid, ${width}x$height';
          _infoString.add(info);
        },
      ),
    );
  }

  Widget viewRows() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(const rtc_local_view.SurfaceView());
    }
    for (var uid in _users) {
      list.add(rtc_remote_view.SurfaceView(
        uid: uid,
        channelId: widget.channelName,
      ));
    }
    final views = list;
    return Column(
      children: List.generate(
        views.length,
        (index) => Expanded(
          child: views[index],
        ),
      ),
    );
  }

  Widget toolbar() {
    if (widget.role == ClientRole.Audience) return const SizedBox();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
            onPressed: () {
              setState(() {
                muted = !muted;
              });
              rtcEngine.muteLocalAudioStream(muted);
            },
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12),
          ),
          RawMaterialButton(
            onPressed: () => Navigator.pop(context),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15),
          ),
          RawMaterialButton(
            onPressed: () => Navigator.pop(context),
            child: const Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20,
            ),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12),
          )
        ],
      ),
    );
  }

  Widget panel() {
    return Visibility(
      visible: viewPannel,
      child: Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: ListView.builder(
              reverse: true,
              itemCount: _infoString.length,
              itemBuilder: (context, i) {
                if (_infoString.isEmpty) {
                  return const Text('null');
                }
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadiusDirectional.circular(5),
                          ),
                          child: Text(
                            _infoString[i],
                            style: const TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Agora'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                viewPannel = !viewPannel;
              });
            },
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Center(
        child: Stack(
          children: [
            viewRows(),
            panel(),
            toolbar(),
          ],
        ),
      ),
    );
  }
}
