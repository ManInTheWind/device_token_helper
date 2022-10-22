class IOSNotificationMessageModel {
  final Aps? aps;
  final String? fromUserId;
  final String? toUserId;
  final String? groupId;
  final String? messageId;
  final ExtensionContent? extensionContent;
  final String? actionIdentifier;

  const IOSNotificationMessageModel()
      : aps = null,
        extensionContent = null,
        fromUserId = null,
        toUserId = null,
        groupId = null,
        messageId = null,
        actionIdentifier = null;

  IOSNotificationMessageModel.fromJson(Map<dynamic, dynamic> json)
      : aps = json['aps'] != null ? Aps.fromJson(json['aps']) : null,
        extensionContent =
            json['ext'] != null ? ExtensionContent.fromJson(json['ext']) : null,
        fromUserId = json['f'],
        toUserId = json['t'],
        groupId = json['g'],
        messageId = json['m'],
        actionIdentifier = json['actionIdentifier'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (aps != null) 'aps': aps!.toJson(),
        if (extensionContent != null)
          'extensionContent': extensionContent!.toJson(),
        'f': fromUserId,
        't': toUserId,
        'g': groupId,
        'messageId': messageId,
        'actionIdentifier': actionIdentifier,
      };
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

class ExtensionContent {
  final int? notificationType;
  final int? userId;

  ExtensionContent.fromJson(Map<String, dynamic> json)
      : notificationType = json['notificationType'],
        userId = json['userId'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'notificationType': notificationType,
        'userId': userId,
      };
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
