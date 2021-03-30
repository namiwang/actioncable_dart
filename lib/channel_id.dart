//
// ActionCable's channel identifier is a bit annoying: it's a string of encoded JSON.
//
// Thus, we have to make sure we always provide same encoded String (as key when storing callback functions) from different inputs
// - "{\"channel\": \"ChatChannel\", id: \"1\"}"
// - "{id: \"1\", \"channel\": \"ChatChannel\"}"    // different order
// - "{\"channel\":    \"ChatChannel\", id: \"1\"}" // additional spaces
//
// Currently, we achieve that by encoding params Map into a SplayTreeMap before stringifying.

import 'dart:collection';
import 'dart:convert';

String encodeChannelId(String channelName, Map? channelParams) {
  final fullChannelName =
      channelName.endsWith('Channel') ? channelName : "${channelName}Channel";

  Map channelId = channelParams == null ? {} : Map.from(channelParams);
  channelId['channel'] ??= fullChannelName;

  final orderedMap = SplayTreeMap.from(channelId);
  return jsonEncode(orderedMap);
}

String parseChannelId(String channelId) {
  return jsonEncode(SplayTreeMap.from(jsonDecode(channelId)));
}
