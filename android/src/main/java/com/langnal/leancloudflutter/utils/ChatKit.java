package com.langnal.leancloudflutter.utils;

import android.support.annotation.Nullable;
import android.text.TextUtils;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.avos.avoscloud.AVException;
import com.avos.avoscloud.AVUser;
import com.avos.avoscloud.LogInCallback;
import com.avos.avoscloud.im.v2.AVIMClient;
import com.avos.avoscloud.im.v2.AVIMConversation;
import com.avos.avoscloud.im.v2.AVIMException;
import com.avos.avoscloud.im.v2.AVIMMessage;
import com.avos.avoscloud.im.v2.AVIMReservedMessageType;
import com.avos.avoscloud.im.v2.AVIMTypedMessage;
import com.avos.avoscloud.im.v2.callback.AVIMClientCallback;
import com.avos.avoscloud.im.v2.messages.AVIMTextMessage;

import java.util.HashMap;
import java.util.Map;
import com.langnal.leancloudflutter.utils.Constants;

public class ChatKit {
    private static ChatKit chatkit;
    private String curUserId; // 保存当前登录的用户Id，避免重复传参。

    public static synchronized ChatKit getInstance() {
        if (null == chatkit) {
            chatkit = new ChatKit();
        }
        return chatkit;
    }

    public void autoOpen(final AVIMClientCallback callback) {
        AVUser curUser = AVUser.getCurrentUser();
        if (null == curUser) {
            callback.internalDone(new AVException(AVException.SESSION_MISSING, "还没有登录"));
            return;
        }
        AVIMClient.getInstance(curUser).open(new AVIMClientCallback() {
            @Override
            public void done(AVIMClient avimClient, AVIMException e) {
                if (null != e) {
                    callback.internalDone(avimClient, e);
                } else {
                    // 保存全局通讯对象
                    curUserId = avimClient.getClientId();
                    callback.internalDone(avimClient, null);
                }
            }
        });
    }

    public void open(final String username, final String password, final AVIMClientCallback callback) {
        AVUser.logInInBackground(username, password, new LogInCallback<AVUser>() {
            @Override
            public void done(AVUser avUser, AVException e) {
                if (null != e) {
                    callback.internalDone(null, e);
                } else {
                    // 与服务器连接
                    AVIMClient userClient = AVIMClient.getInstance(avUser);
                    userClient.open(new AVIMClientCallback() {
                        @Override
                        public void done(AVIMClient avimClient, AVIMException e) {
                            if (null != e) {
                                callback.internalDone(avimClient, e);
                            } else {
                                // 保存全局通讯对象
                                curUserId = avimClient.getClientId();
                                callback.internalDone(avimClient, null);
                            }
                        }
                    });
                }
            }
        });
    }

    /**
     * 关闭实时聊天
     *
     * @param callback 回调
     */
    public void close(final AVIMClientCallback callback) {
        AVIMClient.getInstance(curUserId).close(new AVIMClientCallback() {
            @Override
            public void done(AVIMClient avimClient, AVIMException e) {
                curUserId = null;
                if (null != callback) {
                    callback.internalDone(avimClient, e);
                }
            }
        });
    }

    /**
     * 获取当前的实时聊天的用户
     *
     * @return 返回id
     */
    public String getCurrentUserId() {
        return curUserId;
    }

    /**
     * 获取当前的 AVIMClient 实例
     *
     * @return 返回id
     */
    public AVIMClient getClient() {
        if (!TextUtils.isEmpty(curUserId)) {
            return AVIMClient.getInstance(curUserId);
        }
        return null;
    }

    /**
     * 获取 “对方” 的用户 id，只对单聊有效，群聊返回空字符串
     *
     * @param conversation -
     * @return -
     */
    public static String getConversationPeerId(AVIMConversation conversation) {
        if (null != conversation && 2 == conversation.getMembers().size()) {
            String firstMemeberId = conversation.getMembers().get(0);
            return conversation.getMembers().get(firstMemeberId.equals(ChatKit.getInstance().getCurrentUserId()) ? 1 : 0);
        }
        return "";
    }

    /**
     * 最后一条消息简短显示
     *
     * @param message -
     * @return -
     */
    public static String getMessageeShorthand(AVIMMessage message) {
        if (message instanceof AVIMTypedMessage) {
            AVIMReservedMessageType type = AVIMReservedMessageType.getAVIMReservedMessageType(
                    ((AVIMTypedMessage) message).getMessageType());
            switch (type) {
                case TextMessageType:
                    return ((AVIMTextMessage) message).getText();
                case ImageMessageType:
                    return "[图片]";
                case LocationMessageType:
                    return "[位置]";
                case AudioMessageType:
                    return "[语音]";
                default:
                    return "[未知消息]";
            }
        } else {
            try {
                JSONObject jobj;
                jobj = JSON.parseObject(message.getContent());
                int type = jobj.getIntValue("_lctype");
                switch (type) {
                    case -1:{
                        return jobj.getString("_lctext");
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
                        return "[未知]";
                }
            } catch (Exception e) {
                return message.getContent();
            }
        }
    }

    public static Map setErrorData(@Nullable String code, @Nullable String message) {
        Map<String, String> error = new HashMap<>();
        error.put("code", code != null ? code : Constants.CODE_ERROR_NORMAL);
        error.put("message", message != null ? message : "");
        return error;
    }

    public static <T> Map setResultData(T result) {
        Map<String, Object> data = new HashMap<>();
        data.put("code", Constants.CODE_SUCCESS);
        data.put("result", result);
        return data;
    }

}
