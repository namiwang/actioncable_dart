import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/io.dart';

import 'channel_id.dart';

typedef _OnConnectedFunction = void Function();
typedef _OnChannelSubscribedFunction = void Function();
typedef _OnChannelMessageFunction = void Function(Map message);

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
      // onError: _onError TODO
    );
  }

  void disconnect() {
    _socketChannel.sink.close();
    _listener.cancel();
  }

  // channelName being 'Chat' will be considered as 'ChatChannel',
  // 'Chat', { id: 1 } => { channel: 'ChatChannel', id: 1 }
  void subscribeToChannel(
    String channelName, {
      Map channelParams,
      _OnChannelSubscribedFunction onSubscribed,
      _OnChannelMessageFunction onMessage
    }
  ) {
    final channelId = encodeChannelId(channelName, channelParams);

    _onChannelSubscribedCallbacks[channelId] = onSubscribed;
    _onChannelMessageCallbacks[channelId] = onMessage;

    _send({
      'identifier': channelId,
      'command': 'subscribe'
    });
  }

  void unsubscribeToChannel(String channelName, { Map channelParams }) {
    final channelId = encodeChannelId(channelName, channelParams);

    _onChannelSubscribedCallbacks[channelId] = null;
    _onChannelMessageCallbacks[channelId] = null;

    _socketChannel.sink.add(jsonEncode({
      'identifier': channelId,
      'command': 'unsubscribe'
    }));
  }

  void performAction(
    String channelName,
    String actionName, {
      Map channelParams,
      Map actionParams
    }
  ) {
    final channelId = encodeChannelId(channelName, channelParams);

    actionParams ??= {};
    actionParams['action'] = actionName;

    _send({
      'identifier': channelId,
      'command': 'message',
      'data': jsonEncode(actionParams)
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
        // throw 'Unimplemented';
        break;
      case 'confirm_subscription':
        final channelId = decodeChannelId(payload['identifier']);
        final onSubscribed = _onChannelSubscribedCallbacks[channelId];
        if (onSubscribed != null) { onSubscribed(); }
        break;
      case 'reject_subscription':
        // throw 'Unimplemented';
        break;
      default:
        throw 'InvalidMessage';
    }
  }

  void _handleDataMsg(Map payload) {
    final channelId = decodeChannelId(payload['identifier']);
    final onMessage = _onChannelMessageCallbacks[channelId];
    if (onMessage != null) {
      onMessage(payload['message']);
    }
  }

  void _send(Map payload) {
    _socketChannel.sink.add(jsonEncode(payload));
  }

}
