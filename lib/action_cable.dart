import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/io.dart';
import 'channel_id.dart';

typedef OnConnectedFunction = void Function();
typedef OnConnectionLostFunction = void Function();
typedef OnCannotConnectFunction = void Function();
typedef OnChannelSubscribedFunction = void Function();
typedef OnChannelDisconnectedFunction = void Function();
typedef OnChannelMessageFunction = void Function(Map message);

class ActionCable {
  DateTime? _lastPing;
  Timer? _timer;
  IOWebSocketChannel? _socketChannel;
  StreamSubscription? _listener;

  final OnConnectedFunction? onConnected;
  final OnConnectionLostFunction? onConnectionLost;
  final OnCannotConnectFunction? onCannotConnect;

  final Map<String, OnChannelSubscribedFunction?>
      _onChannelSubscribedCallbacks = {};
  final Map<String, OnChannelDisconnectedFunction?>
      _onChannelDisconnectedCallbacks = {};
  final Map<String, OnChannelMessageFunction?> _onChannelMessageCallbacks = {};

  ActionCable.connect(
    String url, {
    Map<String, String> headers = const {},
    this.onConnected,
    this.onConnectionLost,
    this.onCannotConnect,
  }) {
    _connect(url, headers);
  }

  void _connect(String url, Map<String, String> headers) {
    _socketChannel = IOWebSocketChannel.connect(
      url,
      headers: headers,
      pingInterval: const Duration(seconds: 3),
    );

    _listener = _socketChannel?.stream.listen(
      _onData,
      onError: (error) {
        _handleError();
      },
      onDone: () {
        _handleDone();
      },
    );

    _timer = Timer.periodic(const Duration(seconds: 3), _healthCheck);
  }

  void disconnect() {
    _timer?.cancel();
    _listener?.cancel();
    _socketChannel?.sink.close();
    _socketChannel = null;
  }

  void _handleError() {
    disconnect();
    onCannotConnect?.call();
  }

  void _handleDone() {
    disconnect();
    onConnectionLost?.call();
  }

  void _healthCheck(Timer timer) {
    if (_lastPing == null) return;
    if (DateTime.now().difference(_lastPing!) > const Duration(seconds: 6)) {
      disconnect();
      onConnectionLost?.call();
    }
  }

  void subscribe(
    String channelName, {
    Map? channelParams,
    OnChannelSubscribedFunction? onSubscribed,
    OnChannelDisconnectedFunction? onDisconnected,
    OnChannelMessageFunction? onMessage,
  }) {
    final channelId = encodeChannelId(channelName, channelParams);

    _onChannelSubscribedCallbacks[channelId] = onSubscribed;
    _onChannelDisconnectedCallbacks[channelId] = onDisconnected;
    _onChannelMessageCallbacks[channelId] = onMessage;

    _send({
      'identifier': channelId,
      'command': 'subscribe',
    });
  }

  void unsubscribe(String channelName, {Map? channelParams}) {
    final channelId = encodeChannelId(channelName, channelParams);

    _onChannelSubscribedCallbacks.remove(channelId);
    _onChannelDisconnectedCallbacks.remove(channelId);
    _onChannelMessageCallbacks.remove(channelId);

    _send({
      'identifier': channelId,
      'command': 'unsubscribe',
    });
  }

  void performAction(
    String channelName, {
    String? action,
    Map? channelParams,
    Map? actionParams,
  }) {
    final channelId = encodeChannelId(channelName, channelParams);

    actionParams ??= {};
    actionParams['action'] = action;

    _send({
      'identifier': channelId,
      'command': 'message',
      'data': jsonEncode(actionParams),
    });
  }

  void _onData(dynamic payload) {
    try {
      final data = jsonDecode(payload);
      if (data['type'] != null) {
        _handleProtocolMessage(data);
      } else {
        _handleDataMessage(data);
      }
    } catch (error) {
      throw 'InvalidPayload';
    }
  }

  void _handleProtocolMessage(Map<String, dynamic> payload) {
    switch (payload['type']) {
      case 'ping':
        _lastPing =
            DateTime.fromMillisecondsSinceEpoch(payload['message'] * 1000);
        break;
      case 'welcome':
        onConnected?.call();
        break;
      case 'disconnect':
        final identifier = payload['identifier'];
        if (identifier != null) {
          final channelId = parseChannelId(payload['identifier']);
          final onDisconnected = _onChannelDisconnectedCallbacks[channelId];
          onDisconnected?.call();
        } else {
          final reason = payload['reason'];
          if (reason != null && reason == 'unauthorized') {
            this.onCannotConnect?.call();
          }
        }
        break;
      case 'confirm_subscription':
        final channelId = parseChannelId(payload['identifier']);
        _onChannelSubscribedCallbacks[channelId]?.call();
        break;
      case 'reject_subscription':
        // throw 'Unimplemented';
        break;
      default:
        throw 'InvalidMessage';
    }
  }

  void _handleDataMessage(Map<String, dynamic> payload) {
    final channelId = parseChannelId(payload['identifier']);
    _onChannelMessageCallbacks[channelId]?.call(payload['message']);
  }

  void _send(Map<String, dynamic> payload) {
    if (_socketChannel != null) {
      _socketChannel!.sink.add(jsonEncode(payload));
    }
  }
}
