# leancloud_flutter
[![pub package](https://img.shields.io/pub/v/leancloud_flutter.svg)](https://pub.dartlang.org/packages/leancloud_flutter)

供Flutter使用的LeanCloud SDK。

目前仅供测试使用。

## 使用方法

```dart
// (1) 先初始化
LeancloudFlutter.initialize(APP_ID, APP_KEY);

// (2) 使用平台账号登陆
var result = await LeancloudFlutter.login(username, password);

//(3) 监听消息通知
StreamSubscription _onMsgListener;
_onMsgListener = LeancloudFlutter.instance.handleOnMessage().listen((data) {
    updateConversations();
});
```



