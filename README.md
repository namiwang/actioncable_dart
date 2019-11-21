# ActionCable in Dart

ActionCable is the default realtime websocket framework and protocol in Rails.

This is a dart port of the client and protocol implementation, which is available in web, dartVM and flutter.

## Usage

### connect

```dart
cable = ActionCable.Connect(
  'ws://10.0.2.2:3000/cable',
  headers: {
    'Authorization': 'Some Token',
  },

  onConnected: (){
    // do something here
  },
);
```

### subscribe to channel

```dart
cable.subscribeToChannel(
  'Chat', // either 'Chat' and 'ChatChannel' is fine
  onSubscribed: (){}, // `confirm_subscription` received
  onMessage: (Map message) {} // any other message received
);
```

### unsubscribe to channel

```dart
cable.unsubscribeToChannel(
  'Chat', // either 'Chat' and 'ChatChannel' is fine
);
```

### perform action

```dart
cable.performAction('Chat', 'send', { 'message': 'Hello' });
```

## ActionCable protocol

Anycable has [a great doc](https://docs.anycable.io/#/misc/action_cable_protocol) on that topic.
