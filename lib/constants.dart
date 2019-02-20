/// ************************************
/// @Description:  constants.dart
/// @Author:  wenjunhuang
/// @Time:  2018/10/18 11:36 AM
/// @Email: kongkonghwj@gmail.com
/// ************************************

class ChatCode {
  static const String SUCCESS = "0000";
  static const String ERROR_COMMON = "9999"; /// 通用错误
  static const String ERROR_NATIVE = "9000"; /// 原生平台返回错误
  static const String ERROR_NEED_LOGIN = "9998"; /// 没有登陆错误
}

class ChatEvents {
  static const String EVENT_OnMessageReceived = "OnMessageReceived";
  static const String EVENT_OnUnreadMessagesCountUpdated = "onUnreadMessagesCountUpdated";
  static const String EVENT_OnLastDeliveredAtUpdated = "onLastDeliveredAtUpdated";
  static const String EVENT_OnLastReadAtUpdated = "onLastReadAtUpdated";
  static const String EVENT_OnMessageUpdated = "onMessageUpdated";
  static const String EVENT_OnMessageRecalled = "onMessageRecalled";
}

class MessageStatus {
  static const String None = "AVIMMessageStatusNone"; //（未知）
  static const String Sending = "AVIMMessageStatusSending"; //（发送中）
  static const String Sent = "AVIMMessageStatusSent"; //（发送成功）
  static const String Receipt = "AVIMMessageStatusReceipt"; //（被接收）
  static const String Failed = "AVIMMessageStatusFailed"; //（失败）
}

class MessageIOType {
  static const String In = "AVIMMessageIOTypeIn"; //发给当前用户
  static const String Out = "AVIMMessageIOTypeOut"; //由当前用户发出
}

class ChatMethods {
  static const String METHOD_GET_VERSION = "getPlatformVersion";
  static const String METHOD_INITIALIZE = "initialize";
  static const String METHOD_LOGIN = "login";
  static const String METHOD_AUTO_LOGIN = "autoLogin";
  static const String METHOD_GET_CLIENT_ID = "getClientId";
  static const String METHOD_QUERY_CONVERSATIONS = "queryConversations";
  static const String METHOD_SET_CONVERSATION_READ = "setConversationRead";
  static const String METHOD_QUERY_MESSAGES = "queryMessages";
  static const String METHOD_START_SINGLE_CHAT= "startSingleChat";
  static const String METHOD_STOP_SINGLE_CHAT= "stopSingleChat";
  static const String METHOD_START_GROUP_CHAT = "startGroupChat";
  static const String METHOD_STOP_GROUP_CHAT = "stopGroupChat";
  static const String METHOD_SEND_MESSAGE = "sendMessage";
  static const String METHOD_GET_NETWORK_STATE = "getNetworkState";
  static const String METHOD_GET_USER_INFO = "getUserInfo";
  static const String METHOD_REMOVE_CONVERSATION = "removeConversation";
}