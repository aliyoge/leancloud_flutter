package com.langnal.leancloudflutter.utils;

public class Constants {
    public static final String METHOD_GET_VERSION = "getPlatformVersion";
    public static final String METHOD_INITIALIZE = "initialize";
    public static final String METHOD_LOGIN = "login";
    public static final String METHOD_AUTO_LOGIN = "autoLogin";
    public static final String METHOD_GET_CLIENT_ID = "getClientId";
    public static final String METHOD_QUERY_CONVERSATIONS = "queryConversations";
    public static final String METHOD_SET_CONVERSATION_READ = "setConversationRead";
    public static final String METHOD_QUERY_MESSAGES = "queryMessages";
    public static final String METHOD_START_SINGLE_CHAT= "startSingleChat";
    public static final String METHOD_STOP_SINGLE_CHAT= "stopSingleChat";
    public static final String METHOD_START_GROUP_CHAT = "startGroupChat";
    public static final String METHOD_STOP_GROUP_CHAT = "stopGroupChat";
    public static final String METHOD_SEND_MESSAGE = "sendMessage";
    public static final String METHOD_GET_NETWORK_STATE = "getNetworkState";
    public static final String METHOD_GET_CONVERSATION_INFO = "getConversationInfo";
    public static final String METHOD_GET_USER_INFO = "getUserInfo";
    public static final String METHOD_REMOVE_CONVERSATION = "removeConversation";

    public static final String EVENT_OnMessageReceived = "OnMessageReceived";
    public static final String EVENT_OnUnreadMessagesCountUpdated = "onUnreadMessagesCountUpdated";
    public static final String EVENT_OnLastDeliveredAtUpdated = "onLastDeliveredAtUpdated";
    public static final String EVENT_OnLastReadAtUpdated = "onLastReadAtUpdated";
    public static final String EVENT_OnMessageUpdated = "onMessageUpdated";
    public static final String EVENT_OnMessageRecalled = "onMessageRecalled";

    public static final String CODE_ERROR_NORMAL = "9999";
    public static final String CODE_SUCCESS = "0000";
    public static final String CODE_ERROR_NATIVE = "9000"; /// 原生平台返回错误
    public static final String CODE_ERROR_NEED_LOGIN = "9998"; /// 没有登陆错误
}