package com.langnal.leancloudflutter;

import android.app.Activity;
import android.content.Context;
import android.util.JsonReader;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.alibaba.fastjson.JSON;
import com.avos.avoscloud.*;
import com.avos.avoscloud.im.v2.*;
import com.avos.avoscloud.im.v2.callback.AVIMConversationCallback;
import com.avos.avoscloud.im.v2.callback.AVIMConversationCreatedCallback;
import com.avos.avoscloud.im.v2.callback.AVIMConversationQueryCallback;
import com.avos.avoscloud.im.v2.callback.AVIMMessagesQueryCallback;
import com.avos.avoscloud.im.v2.messages.*;
import com.avos.avoscloud.im.v2.AVIMClient;
import com.avos.avoscloud.im.v2.AVIMException;
import com.avos.avoscloud.im.v2.callback.AVIMClientCallback;
import com.avos.avoscloud.im.v2.AVIMMessage;
import com.avos.avoscloud.im.v2.AVIMMessageHandler;
import com.avos.avoscloud.im.v2.AVIMTypedMessage;
import com.avos.avoscloud.im.v2.AVIMTypedMessageHandler;

import com.langnal.leancloudflutter.utils.ChatKit;
import com.langnal.leancloudflutter.utils.Constants;

public class LeancloudFlutterPlugin {
    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        Context mainContext = registrar.context();
        Activity mainActivity = registrar.activity();
        final MethodChannel methodChannel = new MethodChannel(registrar.messenger(), "leancloud_flutter");
        methodChannel.setMethodCallHandler(new LeancloudFlutterMethodHandler(mainContext, mainActivity));

        final EventChannel eventChannel = new EventChannel(registrar.view(), "leancloud_flutter/events");
        eventChannel.setStreamHandler(new LeancloudFlutterEventHandler(mainContext, mainActivity));

        final EventChannel onmessageChannel = new EventChannel(registrar.view(), "leancloud_flutter/onmessage");
        onmessageChannel.setStreamHandler(new LeancloudOnMessageHandler(mainContext, mainActivity));
    }
}

/**
 * 客户端其他事件回调
 */
class LeancloudFlutterEventHandler implements EventChannel.StreamHandler {

    LeancloudFlutterEventHandler(Context context, Activity activity) {
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        // 注册会话事件回调
        CustomConversationEventHandler.getInstance().setFlutterEvents(eventSink);
        // 注册网络连接状态回调
        CustomClientEventHandler.getInstance().setFlutterEvents(eventSink);
    }

    @Override
    public void onCancel(Object o) {
        CustomConversationEventHandler.getInstance().setFlutterEvents(null);
        CustomClientEventHandler.getInstance().setFlutterEvents(null);
    }
}

/**
 * 客户端收到消息回调
 */
class LeancloudOnMessageHandler implements EventChannel.StreamHandler {

    LeancloudOnMessageHandler(Context context, Activity activity) {
    }

    @Override
    public void onListen(Object o, EventChannel.EventSink eventSink) {
        CustomMessageHandler.getInstance().setFlutterEvents(eventSink);
        // 注册消息通知回调
        AVIMMessageManager.registerMessageHandler(AVIMTypedMessage.class, CustomMessageHandler.getInstance());
    }

    @Override
    public void onCancel(Object o) {
        CustomMessageHandler.getInstance().setFlutterEvents(null);
        AVIMMessageManager.unregisterMessageHandler(AVIMTypedMessage.class, CustomMessageHandler.getInstance());
    }
}

/**
 * LeancloudFlutterPlugin
 */
class LeancloudFlutterMethodHandler implements MethodCallHandler {
    private Context mainContext;

    LeancloudFlutterMethodHandler(Context context, Activity activity) {
        this.mainContext = context;
    }

    private static Logger logger = Logger.getLogger("LeancloudFLutter");

    @Override
    public void onMethodCall(MethodCall call, final Result result) {
        switch (call.method) {
            case Constants.METHOD_INITIALIZE:{
                String APP_ID = call.argument("appId");
                String APP_KEY = call.argument("appKey");
                // Init LeanCloud
                AVOSCloud.initialize(mainContext, APP_ID, APP_KEY);
                // 放在 SDK 初始化语句 AVOSCloud.initialize() 后面，只需要调用一次即可
                AVOSCloud.setDebugLogEnabled(true);
                // 要开启未读消息
                AVIMClient.setUnreadNotificationEnabled(true);
                // 注册默认的消息处理逻辑
                AVIMMessageManager.registerDefaultMessageHandler(new DefaultMessageHandler());
                // 注册未读消息变更通知
                AVIMMessageManager.setConversationEventHandler(CustomConversationEventHandler.getInstance());
                // 客户端网络状态监控
                AVIMClient.setClientEventHandler(CustomClientEventHandler.getInstance());
                break;
            }
            case Constants.METHOD_GET_VERSION:{
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                // 测试 SDK 是否正常工作的代码
                AVObject testObject = new AVObject("TestObject");
                testObject.put("words", "Hello World!");
                testObject.saveInBackground(new SaveCallback() {
                    @Override
                    public void done(AVException e) {
                        if (e == null) {
                            logger.log(Level.INFO, "success-leancloud");
                        }
                    }
                });
                break;
            }
            case Constants.METHOD_LOGIN: {
                String username = call.argument("username");
                String password = call.argument("password");
                ChatKit.getInstance().open(username, password, new AVIMClientCallback() {
                    @Override
                    public void done(AVIMClient avimClient, AVIMException e) {
                        if (null != e) {
                            result.success(ChatKit.setErrorData(Constants.CODE_ERROR_NORMAL, e.getMessage()));
                        } else {
                            // 全局通讯对象
                            String curClientId = avimClient.getClientId();
                            result.success(ChatKit.setResultData(curClientId));
                        }
                    }
                });
                break;
            }
            case Constants.METHOD_AUTO_LOGIN: {
                ChatKit.getInstance().autoOpen(new AVIMClientCallback() {
                    @Override
                    public void done(AVIMClient avimClient, AVIMException e) {
                        if (null != e) {
                            result.success(ChatKit.setErrorData(Constants.CODE_ERROR_NORMAL, e.getMessage()));
                        } else {
                            // 全局通讯对象
                            String curClientId = avimClient.getClientId();
                            result.success(ChatKit.setResultData(curClientId));
                        }
                    }
                });
                break;
            }
            case Constants.METHOD_GET_CLIENT_ID:{
                result.success(ChatKit.setResultData(ChatKit.getInstance().getCurrentUserId()));
                break;
            }
            case Constants.METHOD_QUERY_CONVERSATIONS: {
                handleQueryConversation(call, result);
                break;
            }
            case Constants.METHOD_QUERY_MESSAGES:{
                handleQueryMessages(call, result);
                break;
            }
            case Constants.METHOD_START_SINGLE_CHAT:{
                String memberId = call.argument("memberId");
                // 与memberId用户建立连接
                ChatKit.getInstance().getClient().createConversation(
                        Collections.singletonList(memberId), "", null, false, true, new AVIMConversationCreatedCallback() {
                            @Override
                            public void done(AVIMConversation avimConversation, AVIMException e) {
                                if (null != e) {
                                    result.success(ChatKit.setErrorData(Constants.CODE_ERROR_NORMAL, e.getMessage()));
                                } else {
                                    result.success(ChatKit.setResultData(avimConversation.getConversationId()));
                                }
                            }
                        });
                break;
            }
            case Constants.METHOD_STOP_SINGLE_CHAT:{
                break;
            }
            case Constants.METHOD_START_GROUP_CHAT: {
                break;
            }
            case Constants.METHOD_STOP_GROUP_CHAT: {
                break;
            }
            case Constants.METHOD_SEND_MESSAGE: {
                handleSendMessages(call, result);
                break;
            }
            case Constants.METHOD_GET_CONVERSATION_INFO:{
                handleGetConversationInfo(call, result);
                break;
            }
            case Constants.METHOD_SET_CONVERSATION_READ:{
                handleSetConversationRead(call, result);
                break;
            }
            case Constants.METHOD_GET_NETWORK_STATE:{
                boolean isConnected = CustomClientEventHandler.getInstance().isConnect();
                result.success(ChatKit.setResultData(isConnected));
                break;
            }
            case Constants.METHOD_GET_USER_INFO: {
                handleGetUserInfo(call, result);
                break;
            }
            default:
                result.notImplemented();
                break;
        }
    }

    private void handleGetUserInfo(MethodCall call, final Result result) {
        String userId = call.argument("userId");
        AVQuery<AVUser> userQuery = new AVQuery<>("_User");
        userQuery.whereEqualTo( "objectId", userId);
        userQuery.findInBackground(new FindCallback<AVUser>() {
            @Override
            public void done(List<AVUser> list, AVException e) {
                if (e != null || list.size() == 0) {
                    result.success(ChatKit.setErrorData(Constants.CODE_ERROR_NORMAL, e != null ? e.getMessage() : ""));
                } else {
                    AVUser user = list.get(0);
                    Map<String, Object> userinfo = new HashMap<>();
                    userinfo.put("nickname", user.get("nickname"));
                    userinfo.put("avatarUrl", user.get("avatarUrl"));
                    result.success(ChatKit.setResultData(userinfo));
                }
            }
        });
    }

    /*
     * 获取会话列表
     */
    private void handleQueryConversation(MethodCall call, final Result result){
        AVIMConversationsQuery query = ChatKit.getInstance().getClient().getConversationsQuery();
        query.setQueryPolicy(AVQuery.CachePolicy.NETWORK_ELSE_CACHE);
        query.limit(20); // 一次查询20个最近会话
        query.setWithLastMessagesRefreshed(true); // 查询结果带最后一条消息
        query.findInBackground(new AVIMConversationQueryCallback() {
            @Override
            public void done(List<AVIMConversation> list, AVIMException e) {
                if (e != null) {
                    result.success(ChatKit.setErrorData(Constants.CODE_ERROR_NORMAL, e.getMessage()));
                }
                List mapList = JSON.parseArray(JSON.toJSONString(list));
                result.success(ChatKit.setResultData(mapList));
            }
        });
    }

    /*
     * 发送消息
     */
    private void handleSendMessages(MethodCall call, final Result result) {
        int type = call.argument("type") != null ? (int) call.argument("type") : 0;
        String conversationId = call.argument("conversationId");
        AVIMConversation conversation = ChatKit.getInstance().getClient().getConversation(conversationId);
        switch (type) {
            case -1: {
                String text = call.argument("message");
                final AVIMTextMessage msg = new AVIMTextMessage();
                msg.setText(text);
                AVIMMessageOption option = new AVIMMessageOption();
                option.setReceipt(true);
                conversation.sendMessage(msg, option, new AVIMConversationCallback() {
                    @Override
                    public void done(AVIMException e) {
                        // SDK在发送消息时会生成id等数据，等生产完毕再转换Json
                        Map mapOjbect = JSON.parseObject(JSON.toJSONString(msg));
                        result.success(ChatKit.setResultData(mapOjbect));
                    }
                });
                break;
            }
            case -2:{
                String imagePath = call.argument("message");
                AVFile image = new AVFile("",imagePath,null);
                final AVIMImageMessage msg = new AVIMImageMessage(image);
                AVIMMessageOption option = new AVIMMessageOption();
                option.setReceipt(true);
                conversation.sendMessage(msg, option, new AVIMConversationCallback() {
                    @Override
                    public void done(AVIMException e) {
                        // SDK在发送消息时会生成id等数据，等生产完毕再转换Json
                        String jsonStr = JSON.toJSONString(msg);
                        Map mapObject = JSON.parseObject(jsonStr);
                        result.success(ChatKit.setResultData(mapObject));
                    }
                });
                break;
            }
            case -3:
                break;
            case -4:
                break;
            case -5:
                break;
            case -6:
                break;
            default:
                break;
        }
    }

    // 查询某个会话中的历史消息
    private void handleQueryMessages(MethodCall call, final Result result) {
        final String conversationId = call.argument("conversationId");
        Integer limit = call.argument("limit"); if (null == limit) {limit = 20;}
        final String messageId = call.argument("messageId");
        long messageTimestamp = call.argument("messageTimestamp") != null ? (long) call.argument("messageTimestamp") : 0;

        AVIMConversation conversation = ChatKit.getInstance().getClient().getConversation(conversationId);
        if (null == messageId) {
            conversation.queryMessages(limit, new AVIMMessagesQueryCallback() {
                @Override
                public void done(List<AVIMMessage> list, AVIMException e) {
                    if (null != e) {
                        result.success(ChatKit.setErrorData(Constants.CODE_ERROR_NORMAL, e.getMessage()));
                    } else {
                        String jsonStr = JSON.toJSONString(list);
                        List mapList = JSON.parseArray(jsonStr);
                        result.success(ChatKit.setResultData(mapList));
                    }
                }
            });
        } else {
            // 根据最后一条信息，往前查找所指定的 N 条消息。
            conversation.queryMessages(messageId, messageTimestamp, limit, new AVIMMessagesQueryCallback() {
                @Override
                public void done(List<AVIMMessage> list, AVIMException e) {
                    if (null != e) {
                        result.success(ChatKit.setErrorData(Constants.CODE_ERROR_NORMAL, e.getMessage()));
                    } else {
                        String jsonStr = JSON.toJSONString(list);
                        List mapList = JSON.parseArray(jsonStr);
                        result.success(ChatKit.setResultData(mapList));
                    }
                }
            });
        }
    }

    // 查询会话列表信息，如姓名，icon，最后一条信息。
    private void handleGetConversationInfo(MethodCall call, final Result result) {
        final String method = call.argument("method");
        String conversationId = call.argument("id");
        AVIMConversation conversation = ChatKit.getInstance().getClient().getConversation(conversationId);
        if (null == conversation || null == method) {
            result.success(ChatKit.setErrorData(Constants.CODE_ERROR_NORMAL, "conversation is null"));
            return;
        }
        switch (method) {
            case "getName":{
                // 聊天室
                if (conversation.isTemporary() || conversation.isTransient()) {
                    result.success(ChatKit.setResultData(conversation.getName()));
                } else if (2 == conversation.getMembers().size()){
                    String peerId = ChatKit.getConversationPeerId(conversation);
                }
                break;
            }
            case "getIcon":{
                break;
            }
            case "getTime":{
                break;
            }
            default:
                break;
        }
    }

    private void handleSetConversationRead(MethodCall call, final Result result) {
        final String conversationId = call.argument("conversationId");
        AVIMConversation conversation = ChatKit.getInstance().getClient().getConversation(conversationId);
        if (null != conversation) {
            conversation.read();
            result.success(ChatKit.setResultData(""));
        } else {
            result.success(ChatKit.setErrorData(Constants.CODE_ERROR_NORMAL, ""));
        }
    }
}

class DefaultMessageHandler extends AVIMMessageHandler {
    private Logger logger = Logger.getLogger("LeancloudFLutter");
    //接收到消息后的处理逻辑
    @Override
    public void onMessage(AVIMMessage message, AVIMConversation conversation, AVIMClient client) {
        if (message instanceof AVIMTextMessage) {
            logger.log(Level.INFO, "leancloudmessage", ((AVIMTextMessage) message).getText());
        }
    }

    public void onMessageReceipt(AVIMMessage message, AVIMConversation conversation, AVIMClient client) {

    }
}

/**
 * 收到消息信息回调
 */
class CustomMessageHandler extends AVIMTypedMessageHandler<AVIMTypedMessage> {
    private static CustomMessageHandler messageHandler;
    private EventChannel.EventSink events;

    static synchronized CustomMessageHandler getInstance() {
        if (null == messageHandler) {
            messageHandler = new CustomMessageHandler();
        }
        return messageHandler;
    }

    void setFlutterEvents(EventChannel.EventSink events) {
        this.events = events;
    }

    //接收到消息后的处理逻辑
    @Override
    public void onMessage(AVIMTypedMessage message, AVIMConversation conversation, AVIMClient client) {
        super.onMessage(message, conversation, client);
        String msgStr = JSON.toJSONString(message);
        String conversationStr = JSON.toJSONString(conversation);
        Map<String, String> result = new HashMap<>();
        result.put("event", Constants.EVENT_OnMessageReceived);
        result.put("message", msgStr);
        result.put("conversation", conversationStr);
        if (null != events) events.success(result);
    }

    @Override
    public void onMessageReceipt(AVIMTypedMessage message, AVIMConversation conversation, AVIMClient client) {
        super.onMessageReceipt(message, conversation, client);
    }
}

/**
 * 和 Conversation 相关的事件的 handler
 * 需要应用主动调用  AVIMMessageManager.setConversationEventHandler
 */
class CustomConversationEventHandler extends AVIMConversationEventHandler {
    private EventChannel.EventSink events;
    private static CustomConversationEventHandler eventHandler;
    private Logger logger = Logger.getLogger("LeancloudFLutter");

    static synchronized CustomConversationEventHandler getInstance() {
        if (null == eventHandler) {
            eventHandler = new CustomConversationEventHandler();
        }
        return eventHandler;
    }

    private CustomConversationEventHandler() {
    }

    void setFlutterEvents(EventChannel.EventSink events) {
        this.events = events;
    }

    private void setResult(String event, AVIMConversation conversation, AVIMMessage message) {
        String msgStr = null != message ? JSON.toJSONString(message) : null;
        String conversationStr = null != conversation ? JSON.toJSONString(conversation) : null;
        Map<String, String> result = new HashMap<>();
        result.put("event", event);
        if (null != msgStr) result.put("message", msgStr);
        if (null != conversationStr) result.put("conversation", conversationStr);
        if (null != events) events.success(result);
    }

    @Override
    public void onUnreadMessagesCountUpdated(AVIMClient client, AVIMConversation conversation) {
        setResult(Constants.EVENT_OnUnreadMessagesCountUpdated, conversation, null);
        logger.log(Level.INFO,conversation.getConversationId() + "unreadMessagesCount=" + conversation.getUnreadMessagesCount());
    }

    /**
     * 更新消息送达
     */
    @Override
    public void onLastDeliveredAtUpdated(AVIMClient client, AVIMConversation conversation) {
        setResult(Constants.EVENT_OnLastDeliveredAtUpdated, conversation, null);
    }

    /**
     * 更新对方已读的位置事件
     */
    @Override
    public void onLastReadAtUpdated(AVIMClient client, AVIMConversation conversation) {
        setResult(Constants.EVENT_OnLastReadAtUpdated, conversation, null);
    }

    @Override
    public void onMessageRecalled(AVIMClient client, AVIMConversation conversation, AVIMMessage message) {
        setResult(Constants.EVENT_OnMessageRecalled, conversation, message);
    }

    /**
     * 消息状态更新
     */
    @Override
    public void onMessageUpdated(AVIMClient client, AVIMConversation conversation, AVIMMessage message) {
        setResult(Constants.EVENT_OnMessageUpdated, conversation, message);
    }

    @Override
    public void onMemberLeft(AVIMClient client, AVIMConversation conversation, List<String> members,
                             String kickedBy) {
        // 有其他成员离开时，执行此处逻辑
    }

    @Override
    public void onMemberJoined(AVIMClient client, AVIMConversation conversation,
                               List<String> members, String invitedBy) {
        // 手机屏幕上会显示一小段文字：Tom 加入到 551260efe4b01608686c3e0f ；操作者为：Tom
//        Toast.makeText(AVOSCloud.applicationContext,
//                members + "加入到" + conversation.getConversationId() + "；操作者为： "
//                        + invitedBy, Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onKicked(AVIMClient client, AVIMConversation conversation, String kickedBy) {
        // 当前 ClientId(Bob) 被踢出对话，执行此处逻辑
    }

    @Override
    public void onInvited(AVIMClient client, AVIMConversation conversation, String invitedBy) {
        // 当前 ClientId(Bob) 被邀请到对话，执行此处逻辑
    }
}

/**
 *  与网络相关的 handler
 *  注意，此 handler 并不是网络状态通知，而是当前 client 的连接状态
 */
class CustomClientEventHandler extends AVIMClientEventHandler {
    private static EventChannel.EventSink events;
    private static CustomClientEventHandler eventHandler;
    private volatile boolean connect = false;

    static synchronized CustomClientEventHandler getInstance() {
        if (null == eventHandler) {
            eventHandler = new CustomClientEventHandler();
        }
        return eventHandler;
    }

    private CustomClientEventHandler() {
    }

    void setFlutterEvents(EventChannel.EventSink events) {
        this.events = events;
    }

    boolean isConnect() {
        return this.connect;
    }

    void setConnectAndNotify(boolean isConnect) {
        this.connect = isConnect;
    }

    //  指网络连接断开事件发生，此时聊天服务不可用。
    public void onConnectionPaused(AVIMClient avimClient) {
        this.setConnectAndNotify(false);
    }

    // 指网络连接恢复正常，此时聊天服务变得可用。
    public void onConnectionResume(AVIMClient avimClient) {
        this.setConnectAndNotify(true);
    }

    // 指单点登录被踢下线的事件。
    public void onClientOffline(AVIMClient avimClient, int i) {
    }
}


