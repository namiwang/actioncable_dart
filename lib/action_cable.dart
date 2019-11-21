// TODO ping mechanic

// TODO
// so at this time there's no way to
// a) `cancel` the _listener and b) `close` the _socketChannel
// since dart lacking a `dispose` callback
// not sure if this will cause a memory issue

import 'dart:async';
import 'dart:convert';
import 'dart:collection';
// import 'package:meta/meta.dart';
import 'package:web_socket_channel/io.dart';

typedef _OnConnectedFunction = void Function();
typedef _OnChannelSubscribedFunction = void Function();
typedef _OnChannelMessageFunction = void Function(Map message);

String encodeChannelId(Map channelId) {
  final orderedMap = SplayTreeMap.from(channelId);
  return jsonEncode(orderedMap);
}

String decodeChannelId(String receivedChannelId) {
  return encodeChannelId(jsonDecode(receivedChannelId));
}

class ActionCable {
  IOWebSocketChannel _socketChannel;
  StreamSubscription _listener;

  _OnConnectedFunction onConnected;

  Map<String, _OnChannelSubscribedFunction> _onChannelSubscribedCallbacks = {};
  Map<String, _OnChannelMessageFunction> _onChannelMessageCallbacks = {};

  ActionCable.Connect(
    String url, {
    Map<String, String> headers: const {},

    this.onConnected,
  }) {
    _socketChannel = IOWebSocketChannel.connect( url, headers: headers );
    _listener = _socketChannel.stream.listen(
      _onData,
      // onError: onError TODO so if give an onError, onData would not be invoked?
    );
  }

  // TODO complex channel identifier
  // assert either name or identifier is not null
  void subscribeToChannel(String name, {
    _OnChannelSubscribedFunction onSubscribed,
    _OnChannelMessageFunction onMessage,
  }) {
    final channelName = name.endsWith('Channel') ? name : "${name}Channel";
    final channelId = { 'channel': channelName };
    final encodedChannelId = encodeChannelId(channelId);

    _onChannelSubscribedCallbacks[encodedChannelId] = onSubscribed;
    _onChannelMessageCallbacks[encodedChannelId] = onMessage;

    _send({
      'identifier': encodedChannelId,
      'command': 'subscribe'
    });
  }

  // TODO complex channel identifier
  // assert either name or identifier is not null
  void unsubscribeToChannel(String name) {
    final channelName = name.endsWith('Channel') ? name : "${name}Channel";
    final channelId = { 'channel': channelName };
    final encodedChannelId = encodeChannelId(channelId);

    _socketChannel.sink.add(jsonEncode({
      'identifier': encodedChannelId,
      'command': 'unsubscribe'
    }));
  }

  // TODO complex channel identifier
  // assert either name or identifier is not null
  void performAction(String channelName, String action, {Map params: const {}}) {
    final actualChannelName = channelName.endsWith('Channel') ? channelName : "${channelName}Channel";
    final channelId = { 'channel': actualChannelName };
    final encodedChannelId = encodeChannelId(channelId);

    Map data = Map.from(params);
    data['action'] = action;

    _send({
      'identifier': encodedChannelId,
      'command': 'message',
      'data': jsonEncode(data)
    });
  }

  void _onData(dynamic payload) {
    payload = jsonDecode(payload);

    if (payload['type'] != null) {
      _handleProtocolMsg(payload);
    } else {
      _handleDataMsg(payload);
    }
  }

  void _handleProtocolMsg(Map payload) {
    switch (payload['type']) {
      case 'ping': break;
      case 'welcome':
        if (onConnected != null) { onConnected(); }
        break;
      case 'disconnect':
        throw 'Unimplemented';
        break;
      case 'confirm_subscription':
        final channelId = decodeChannelId(payload['identifier']);
        final onSubscribed = _onChannelSubscribedCallbacks[channelId];
        if (onSubscribed != null) { onSubscribed(); }
        break;
      case 'reject_subscription':
        throw 'Unimplemented';
        break;
      default:
        throw 'Invalid message';
    }
  }

  void _handleDataMsg(Map payload) {
    final channelId = decodeChannelId(payload['identifier']);
    final onMessage = _onChannelMessageCallbacks[channelId];
    if (onMessage != null) {
      onMessage(payload['message']);
    }
  }

  // TODO
  // void onError(Error error) {
  //   print("GameContext.onError: $error");
  // 
  //   // cancel on error
  //   listener.cancel();
  // }

  void _send(Map payload) {
    _socketChannel.sink.add(jsonEncode(payload));
  }

}
