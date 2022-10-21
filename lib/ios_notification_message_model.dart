class IOSNotificationMessageModel {
  Aps? aps;
  String fromUserId;
  String toUserId;
  String? groupId;
  String messageId;

  IOSNotificationMessageModel.fromJson(Map<String, dynamic> json)
      : aps = json['aps'] != null ? Aps.fromJson(json['aps']) : null,
        fromUserId = json['f'],
        toUserId = json['t'],
        groupId = json['g'],
        messageId = json['m'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (aps != null) {
      data['aps'] = aps!.toJson();
    }
    data['f'] = fromUserId;
    data['t'] = toUserId;
    data['g'] = groupId;
    data['m'] = messageId;
    return data;
  }
}

class Aps {
  final Alert? alert;
  final int badge;
  final String sound;

  Aps.fromJson(Map<String, dynamic> json)
      : alert = json['alert'] != null ? Alert.fromJson(json['alert']) : null,
        badge = json['badge'],
        sound = json['sound'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      if (alert != null) 'alert': alert!.toJson(),
      'badge': badge,
      'sound': sound,
    };
    return data;
  }
}

class Alert {
  final String body;

  Alert.fromJson(Map<String, dynamic> json) : body = json['body'] ?? "";

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['body'] = body;
    return data;
  }
}

/*
[AnyHashable("EPush"): {
    origin = push;
    provider = APNS;
    report =     {
        "task_id" = 1033053269066931937;
    };
    timestamp = 1666340693174;
}, AnyHashable("aps"): {
    alert =     {
        body = "\U54c8\U54c8\U54c8\U54c8";
        title = "\U63a8\U9001";
    };
    "mutable-content" = 1;
    sound = default;
}]
 */

/*
{
    "aps":{
        "alert":{
            "body":"你有一条新消息"
        },
        "badge":1,
        "sound":"default"
    },
    "f":"6001",
    "t":"6006",
    "g":"1421300621769",
    "m":"373360335316321408"
}
 */
