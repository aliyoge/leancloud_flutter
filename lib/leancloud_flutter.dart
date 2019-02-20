/// ************************************
/// @Description:  leancloud_flutter.dart
/// @Author:  wenjunhuang
/// @Time:  2018/10/18 11:36 AM
/// @Email: kongkonghwj@gmail.com
/// ************************************

import 'dart:async';
import 'package:flutter/services.dart';
import './constants.dart';

export './constants.dart';

/// ***
/// 负责Native和Flutter端通讯的全局单例
///
///
/// Example：
///
/// (1) 先初始化
///     LeancloudFlutter.initialize(APP_ID, APP_KEY);
/// (2) 使用平台账号登陆
///     var result = await LeancloudFlutter.login(username, password);
/// (3) 监听消息通知
///     StreamSubscription _onMsgListener;
///     _onMsgListener = LeancloudFlutter.instance.handleOnMessage().listen((data) {
///        updateConversations();
///     });
/// ***
class LeancloudFlutter {

  /// ***
  /// Public
  /// ***

  /// ***
  /// [instance] 用于获取全局单例
  /// ***
  static final LeancloudFlutter instance = new LeancloudFlutter();

  /// ***
  /// [curConversationId] 记录正在通讯中的conversion
  /// ***
  String curConversationId;

  /// ***
  /// 通过[handleOnMessage] 来监听消息到达通知，使用方法如下：
  ///    StreamSubscription _onMsgListener;
  ///    _onMsgListener = LeancloudFlutter.instance.handleOnMessage().listen((data) {
  ///       updateConversations();
  ///    });
  ///   // 使用完后要取消
  ///   if (null != _onMsgListener) _onMsgListener.cancel();
  /// 
  /// result -> Object 
  /// {
  ///   "event": String // 事件类型
  ///   "conversation": Object<conversation>,
  ///   "message" : Object<message>
  /// }
  /// ***
  Stream handleOnMessage() {
    return _msgctrl.stream;
  }

  /// ***
  /// 通过[handleEvents] 监听关于会话的其他通知。
  /// 目前有：
  /// (1) ChatEvents.EVENT_OnMessageUpdated //会话中消息状态更新
  /// 使用方法如[handleOnMessage]
  /// 
  /// result -> Object
  /// {
  ///   "event": String // 事件类型 
  ///   "conversation": Object<conversation>,
  ///   "message" : Object<message>
  /// }
  /// ***
  Stream handleEvents() {
    return _otherctrl.stream;
  }

  /// ***
  /// 必须在软件初始化的地方调用[initialize]来初始化消息系统，并且只需要调用一次。
  /// ***
  static Future<Null> initialize(String appId, String appKey) async {
    if (_runned) return;
     _defaultMC.invokeMethod(ChatMethods.METHOD_INITIALIZE, {"appId": appId, "appKey": appKey});
    LeancloudFlutter.instance._run();
  }

  /// ***
  /// 使用消息系统账号登陆
  /// ***
  static Future<ChatResponse> login(String username, String password) async {
    var result = await _defaultMC.invokeMethod(ChatMethods.METHOD_LOGIN, {"username": username,"password": password});
    ChatResponse response;
    if (ChatCode.SUCCESS == result["code"]) {
      _clientId = result["result"];
      response = ChatResponse.success(_clientId);
    } else {
      response = ChatResponse.commonError(result["message"]);
    }
    return response;
  }

  /// ***
  /// 在[initialize]之后判断如果登陆过后，可以调用[autoLogin]。
  ///   UserInfo userInfo = await Settings.instance.getUserInfo();
  ///   if (null == userInfo) {
  ///     Navigator.pushReplacement(
  ///        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  ///   } else {
  ///     var result = await LeancloudFlutter.autoLogin();
  ///     if ("0000" == result["code"]) {
  ///     StoreProvider.of<AppState>(context).dispatch(GetUserInfoSuccessAction(userInfo));
  ///       Navigator.pushReplacement(
  ///          context, MaterialPageRoute(builder: (context) => MainScreen()));
  ///      } else {
  ///        Navigator.pushReplacement(
  ///       context, MaterialPageRoute(builder: (context) => LoginScreen()));
  ///      }
  ///   }
  ///
  /// ***
  static Future<ChatResponse> autoLogin() async {
    var result = await _defaultMC.invokeMethod(ChatMethods.METHOD_AUTO_LOGIN);
    ChatResponse response;
    if (ChatCode.SUCCESS == result["code"]) {
      _clientId = result["result"];
      response = ChatResponse.success(_clientId);
    } else {
      response = ChatResponse.commonError(result["message"]);
    }
    return response;
  }

  /// ***
  /// 获取clientId
  /// ***
  static Future<String> getClientId() async {
    return _clientId;
  }

  /// ***
  /// 获取会话列表
  /// result -> List<conversion>
  /// Object<conversion> -> 
  /// {
  ///     "system" -> false
  ///     "conversationId" -> "5bd41e0060d9007f7ba7cf73"
  ///     "members" -> ["5bc701b9808ca4007240662c", "5bc702460b6160006f05ba5e"]
  ///     "createAt" -> 1540627968905
  ///     "transient" -> false
  ///     "unreadMessagesCount" -> 0
  ///     "creator" -> "5bc701b9808ca4007240662c"
  ///     "updateAt" -> 1540639250534
  ///     "muted" -> false
  ///     "lastDeliveredAt" -> 0
  ///     "unreadMessagesMentioned" -> false
  ///     "lastReadAt" -> 0
  /// }
  /// ***
  static Future<ChatResponse> queryConversations() async {
    var result = await _defaultMC.invokeMethod(ChatMethods.METHOD_QUERY_CONVERSATIONS);
    ChatResponse response;
    if (result != null && ChatCode.SUCCESS == result["code"] && result["result"] != null) {
      response = ChatResponse.success(result["result"]);
    } else {
      response = ChatResponse.error(result["code"], result["messsage"]);
    }
    return response;
  }

  /// ***
  /// 根据会话id获取会话列表。
  /// result -> List<message>
  /// Object<message> ->
  /// {
  ///  breakpoint = 1;
  ///  clientId = 5bc701b9808ca4007240662c;
  ///  content = "{\"_lctype\":-2,\"_lcfile\":{\"url\":\"http:\\/\\/lc-IDtIKfTa.cn-n1.lcfile.com\\/NsWKAOQBXJo3YAAFBPceLED.jpg\",\"objId\":\"5bd41e14ee920a0068f91d37\",\"metaData\":{\"size\":1615640,\"width\":1080,\"height\":1920,\"format\":\"jpg\"}}}";
  ///  conversationId = 5bd41e0060d9007f7ba7cf73;
  ///  deliveredTimestamp = 0;
  ///  file =     {
  ///      metaData =         {
  ///          format = jpg;
  ///          height = 1920;
  ///          size = 1615640;
  ///          width = 1080;
  ///      };
  ///  };
  ///  fileId = 5bd41e14ee920a0068f91d37;
  ///  fileSize = 1615640;
  ///  fileUrl = "http://lc-IDtIKfTa.cn-n1.lcfile.com/NsWKAOQBXJo3YAAFBPceLED.jpg";
  ///  format = jpg;
  ///  from = 5bc701b9808ca4007240662c;
  ///  hasMore = 0;
  ///  height = 1920;
  ///  ioType = AVIMMessageIOTypeOut;
  ///  localClientId = 5bc701b9808ca4007240662c;
  ///  mediaType = "-2";
  ///  mentionAll = 0;
  ///  mentionList =     (
  ///  );
  ///  messageId = "+W4UMKXMSqCN33J2CM7n4g";
  ///  messageObject =     {
  ///      "_lcfile" =         {
  ///          metaData =             {
  ///              format = jpg;
  ///              height = 1920;
  ///              size = 1615640;
  ///              width = 1080;
  ///          };
  ///          objId = 5bd41e14ee920a0068f91d37;
  ///          url = "http://lc-IDtIKfTa.cn-n1.lcfile.com/NsWKAOQBXJo3YAAFBPceLED.jpg";
  ///      };
  ///      "_lctype" = "-2";
  ///  };
  ///  messageType = "-2";
  ///  offline = 0;
  ///  readTimestamp = 0;
  ///  sendTimestamp = 1540627989665;
  ///  seq = 55;
  ///  status = AVIMMessageStatusSent;
  ///  timestamp = 1540627989665;
  ///  transient = 0;
  ///  width = 1080;
  /// }
  /// ***
  static Future<ChatResponse> queryMessages(String id, {int limit = 20, String messageId, int messageTimestamp}) async {
    var result = await _defaultMC.invokeMethod(ChatMethods.METHOD_QUERY_MESSAGES, {"conversationId": id, "limit": limit, "messageId": messageId, "messageTimestamp": messageTimestamp});
    ChatResponse response;
    if (result != null && ChatCode.SUCCESS == result["code"] && result["result"] != null) {
      response = ChatResponse.success(result["result"]);
    } else {
      response = ChatResponse.error(result["code"], result["messsage"]);
    }
    return response;
  }

  /// ***
  /// 开启一个单聊
  /// ***
  static Future<ChatResponse> startSingleChat(String memberId) async {
    var result = await _defaultMC.invokeMethod(ChatMethods.METHOD_START_SINGLE_CHAT, {"memberId": memberId});
    ChatResponse response;
    if (result != null && ChatCode.SUCCESS == result["code"] && result["result"] != null) {
      response = ChatResponse.success(result["result"]);
    } else {
      response = ChatResponse.error(result["code"], result["messsage"]);
    }
    return response;
  }

  /// ***
  /// 停止一个单聊
  /// ***
  static Future<ChatResponse> stopSingleChat() async {
    var result = await _defaultMC.invokeMethod(ChatMethods.METHOD_STOP_SINGLE_CHAT);
    ChatResponse response;
    if (result != null && ChatCode.SUCCESS == result["code"] && result["result"] != null) {
      response = ChatResponse.success(result["result"]);
    } else {
      response = ChatResponse.error(result["code"], result["messsage"]);
    }
    return response;
  }

  /// ***
  /// 发送消息，发送成功返回message。
  /// 消息类型：{
  ///           文本消息	-1  // 发送文本string
  ///           图像消息	-2  // 发送图片path
  ///           音频消息	-3
  ///           视频消息	-4
  ///           位置消息	-5
  ///           文件消息	-6
  ///          }
  /// result -> Object<message>
  /// ***
  static Future<ChatResponse> sendMessage(String conversationId, int type, dynamic message) async {
    var result = await _defaultMC.invokeMethod(ChatMethods.METHOD_SEND_MESSAGE, {"conversationId": conversationId,"type": type, "message": message});
    ChatResponse response;
    if (result != null && ChatCode.SUCCESS == result["code"] && result["result"] != null) {
      response = ChatResponse.success(result["result"]);
    } else {
      response = ChatResponse.error(result["code"], result["messsage"]);
    }
    return response;
  }

  /// ***
  /// 设置会话已读
  /// ***
  static Future<ChatResponse> setConversationRead(String conversationId) async {
    var result = await _defaultMC.invokeMethod(ChatMethods.METHOD_SET_CONVERSATION_READ, {"conversationId": conversationId});
    ChatResponse response;
    if (result != null && ChatCode.SUCCESS == result["code"] && result["result"] != null) {
      response = ChatResponse.success(result["result"]);
    } else {
      response = ChatResponse.error(result["code"], result["messsage"]);
    }
    return response;
  }

  /// ***
  /// 获取用户信息
  /// result -> Object
  /// {
  ///   "nickname": String,
  ///   "avatarUrl": String,
  /// }
  /// ***
  static Future<ChatResponse> getUserInfo(String userId) async {
    var result = await _defaultMC.invokeMethod(ChatMethods.METHOD_GET_USER_INFO, {"userId": userId});
    ChatResponse response;
    if (result != null && ChatCode.SUCCESS == result["code"] && result["result"] != null) {
      response = ChatResponse.success(result["result"]);
    } else {
      response = ChatResponse.error(result["code"], result["messsage"]);
    }
    return response;
  }

  /// ***
  /// 移除会话
  /// ***
  static Future<ChatResponse> removeConversation(String conversationId) async {
    var result = await _defaultMC.invokeMethod(ChatMethods.METHOD_REMOVE_CONVERSATION, {"conversationId": conversationId});
    ChatResponse response;
    if (result != null && ChatCode.SUCCESS == result["code"] && result["result"] != null) {
      response = ChatResponse.success(result["result"]);
    } else {
      response = ChatResponse.error(result["code"], result["messsage"]);
    }
    return response;
  }

  /// ***
  /// Tools
  /// ***
  // 获取 “对方” 的用户 id，只对单聊有效，群聊返回空字符串
  static String getConversationPeerId(conversation) {
    List members = conversation["members"];
    if (null != conversation && null != members && 2 == members.length) {
      String firstMemeberId = members[0];
      return members[firstMemeberId == LeancloudFlutter._clientId ? 1 : 0];
    }
    return "";
  }

  // 最后一条消息简短显示
  static String getMessageeShorthand(message) {
    if (null == message) return "[未知消息]";
    int type = message["messageType"];
    switch (type) {
      case -1:{
        String text = message ["text"];
        return text.substring(0, text.length < 16 ? text.length : 16) + (text.length < 16 ? '' : '...');
      }
      case -2:{
        return "[图片]";
      }
      case -3:{
        return "[语音]";
      }
      case -4:{
        return "[视频]";
      }
      case -5:{
        return "[位置]";
      }
      case -6:{
        return "[文件]";
      }
      default:
        return "[未知消息]";
    }
  }

  /// ***
  /// Private
  /// ***
  // 收到消息事件Handler
  static const EventChannel _onMessageEC = const EventChannel("leancloud_flutter/onmessage");
  // 聊天系统其他事件通知
  static const EventChannel _onOtherEC = const EventChannel("leancloud_flutter/events");
  // 静态方法Handler
  static const MethodChannel _defaultMC = const MethodChannel('leancloud_flutter');

  static String _clientId;
  // 是否初始化
  static bool _runned = false;
  // 消息控制流
  StreamController _msgctrl;
  // 其他消息控制流
  StreamController _otherctrl;

  // 初始化单例，监听消息通知
  void _run() {
    _msgctrl = StreamController.broadcast();
    _otherctrl = StreamController.broadcast();

    // 监听收到消息事件
    _onMessageEC.receiveBroadcastStream().listen((data) {
      // String msgStr = data["message"];
      // String conversationStr = data["conversation"];
      // String clientStr = data["client"];
      // var message = json.decode(msgStr);
      // var conversation = json.decode(conversationStr);
      // var client = json.decode(clientStr);
      var message = data["message"];
      var conversation = data["conversation"];
      var client = data["client"];
      Map ssData = {"message":message, "conversation": conversation, "client": client, "lastMessageShort": getMessageeShorthand(message)};
      _msgctrl.add(ssData);
    }, onDone: () {
      print("Task Done");
    }, onError: (error) {
      print("Some Error");
    });

    // 监听聊天系统其他通知
    _onOtherEC.receiveBroadcastStream().listen((data) {
      // String eventStr = data["event"];
      // String msgStr = data["message"];
      // String conversationStr = data["conversation"];
      // String lastMessageShort = data["lastMessageShort"];
      // var message = null != msgStr ? json.decode(msgStr) : null;
      // var conversation = null != conversationStr ? json.decode(conversationStr) : null;
      String eventStr = data["event"];
      var message = data["message"];
      var conversation = data["messsage"];
      String lastMessageShort = getMessageeShorthand(message);
      Map ssData = {"event":eventStr, "message":message, "conversation": conversation, "lastMessageShort": lastMessageShort};
      _otherctrl.add(ssData);
    });

    _runned = true;
  }

  /// ***
  /// Test
  /// ***
  static Future<String> get platformVersion async {
    final String version = await _defaultMC.invokeMethod(ChatMethods.METHOD_GET_VERSION);
    return version;
  }

  static Future<String> getPlatformVersion() async {
    final String version = await _defaultMC.invokeMethod(ChatMethods.METHOD_GET_VERSION);
    return version;
  }

}

class ChatResponse {
  /// 状态码
  String code;
  /// 结果
  dynamic result;
  /// 提示信息
  String message;

  /// 普通构造方法
  ChatResponse(this.code, this.result, this.message);

  ChatResponse.success(this.result) : code = ChatCode.SUCCESS, message = "";

  ChatResponse.error(this.code, this.message) : result = null;

  ChatResponse.commonError(this.message) : code = ChatCode.ERROR_COMMON, result = null;
}
