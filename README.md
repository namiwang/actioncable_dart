![Pub](https://img.shields.io/pub/v/action_cable)
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-1-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

# ActionCable in Dart

ActionCable is the default realtime websocket framework and protocol in Rails.

This is a dart port of the client and protocol implementation which is available in web, dartVM and flutter.

## Usage

### Connecting to a channel 🙌

```dart
cable = ActionCable.Connect(
  "ws://10.0.2.2:3000/cable",
  headers: {
    "Authorization": "Some Token",
  },
  onConnected: (){
    print("connected");
  },
);
```

### Subscribing to channel 🎉

```dart
cable.subscribe(
  "Chat", // either "Chat" and "ChatChannel" is fine
  channelParams: { "room": "private" },
  onSubscribed: (){}, // `confirm_subscription` received
  onDisconnected: (){} // `disconnect` received
  onMessage: (Map message) {} // any other message received
);
```

### Unsubscribing from a channel 🎃

```dart
cable.unsubscribe(
  "Chat", // either "Chat" and "ChatChannel" is fine
  {"room": "private"}
);
```

### Perform an action on your ActionCable server 🎇

Requires that you have a method defined in your Rails Action Cable channel whose name matches the action property passed in.

```dart
cable.performAction(
  "Chat",
  action: "send_message",
  channelParams: { "room": "private" },
  actionParams: { "message": "Hello private peeps! 😜" }
);
```

### Disconnect from the ActionCable server

```dart
cable.disconnect();
```

## ActionCable protocol

Anycable has [a great doc](https://docs.anycable.io/#/misc/action_cable_protocol) on that topic.

## Contributors ✨

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://clintonmbah.com"><img src="https://avatars1.githubusercontent.com/u/18232142?v=4" width="100px;" alt=""/><br /><sub><b>Clinton</b></sub></a><br /><a href="https://github.com/namiwang/actioncable_dart/commits?author=mclintprojects" title="Code">💻</a> <a href="https://github.com/namiwang/actioncable_dart/commits?author=mclintprojects" title="Tests">⚠️</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!