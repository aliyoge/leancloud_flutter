//
//  ChatMethods.h
//  AVOSCloud
//
//  Created by WenjunHuang on 22/10/2018.
//

#import <Foundation/Foundation.h>

// EVENT
static NSString *const EVENT_OnMessageReceived = @"OnMessageReceived";
static NSString *const EVENT_OnUnreadMessagesCountUpdated = @"onUnreadMessagesCountUpdated";
static NSString *const EVENT_OnLastDeliveredAtUpdated = @"onLastDeliveredAtUpdated";
static NSString *const EVENT_OnLastReadAtUpdated = @"onLastReadAtUpdated";
static NSString *const EVENT_OnMessageUpdated = @"onMessageUpdated";
static NSString *const EVENT_OnMessageRecalled = @"onMessageRecalled";

// METHOD
static NSString *const METHOD_GET_VERSION = @"getPlatformVersion";
static NSString *const METHOD_INITIALIZE = @"initialize";
static NSString *const METHOD_LOGIN = @"login";
static NSString *const METHOD_AUTO_LOGIN = @"autoLogin";
static NSString *const METHOD_GET_CLIENT_ID = @"getClientId";
static NSString *const METHOD_QUERY_CONVERSATIONS = @"queryConversations";
static NSString *const METHOD_SET_CONVERSATION_READ = @"setConversationRead";
static NSString *const METHOD_QUERY_MESSAGES = @"queryMessages";
static NSString *const METHOD_START_SINGLE_CHAT= @"startSingleChat";
static NSString *const METHOD_STOP_SINGLE_CHAT= @"stopSingleChat";
static NSString *const METHOD_START_GROUP_CHAT = @"startGroupChat";
static NSString *const METHOD_STOP_GROUP_CHAT = @"stopGroupChat";
static NSString *const METHOD_SEND_MESSAGE = @"sendMessage";
static NSString *const METHOD_GET_NETWORK_STATE = @"getNetworkState";
static NSString *const METHOD_GET_CONVERSATION_INFO = @"getConversationInfo";
static NSString *const METHOD_GET_USER_INFO = @"getUserInfo";
static NSString *const METHOD_REMOVE_CONVERSATION = @"removeConversation";

// Error String
static NSString *const ERROR_CHAT_NOT_LOGIN = @"chatNotLogin";
static NSString *const ERROR_CHAT_ARGUMENTS_ERROR = @"chatArgumentsError";
static NSString *const ERROR_CHAT_NET_ERROR = @"chatNetError";

// Code
static NSString *const CODE_SUCCESS = @"0000";
static NSString *const CODE_ERROR_COMMON = @"9999"; /// 通用错误
static NSString *const CODE_ERROR_NATIVE = @"9000"; /// 原生平台返回错误
static NSString *const CODE_ERROR_NEED_LOGIN = @"9998"; /// 没有登陆错误

// 返回是否成功回调
typedef void (^AVIMBoolCallback) (BOOL successed, NSError * _Nullable error);
// 返回clientId回调
typedef void (^AVIMClientCallback) (NSString *clientId, NSError * _Nullable error);
