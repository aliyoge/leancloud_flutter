//
//  ChatKit.m
//  AVOSCloud
//
//  Created by WenjunHuang on 22/10/2018.
//

#import "ChatKit.h"
#import <YYModel/YYModel.h>

@interface ChatKit()
@property (nonatomic, strong) AVIMClient *client;
@property (nonatomic, copy , nullable) FlutterEventSink flutterOnMessageEvents;
@property (nonatomic, copy , nullable) FlutterEventSink flutterOtherEvents;
@end

@implementation ChatKit

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (instancetype)getInstance {
    static ChatKit *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)setClient:(AVIMClient *)client {
    _client = client;
    if (nil != client) {
        _client.delegate = self;
    }
}

- (void)setFlutterOnMessageEvents:(FlutterEventSink)flutterOnMessageEvents {
    _flutterOnMessageEvents = flutterOnMessageEvents;
}

- (void)setFlutterOtherEvents:(FlutterEventSink)flutterOtherEvents {
    _flutterOtherEvents = flutterOtherEvents;
}

- (void)setDelegate:(id<AVIMClientDelegate>)delegate {
    if (nil != self.client) {
        self.client.delegate = delegate;
    }
}

- (void)autoOpen:(AVIMClientCallback)callback {
    AVUser *curUser = [AVUser currentUser];
    if (nil == curUser) {
        NSError *error = [NSError errorWithDomain:ERROR_CHAT_NOT_LOGIN code:9999 userInfo:nil];
        callback(nil, error);
    }
    self.client = [[AVIMClient alloc] initWithUser:curUser];
    [self.client openWithCallback:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            self.curUserId = self.client.clientId;
            callback(self.curUserId, nil);
        } else {
            callback(nil, error);
        }
    }];
}

- (void)open:(NSString *)username password:(NSString *)password callback:(AVIMClientCallback)callback {
    [AVUser logInWithUsernameInBackground:username password:password block:^(AVUser * _Nullable user, NSError * _Nullable error) {
        if (nil == user) {
            callback(nil, error);
        } else {
            self.client = [[AVIMClient alloc] initWithUser:user];
            [self.client openWithCallback:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    self.curUserId = self.client.clientId;
                    callback(self.curUserId, nil);
                } else {
                    callback(nil, error);
                }
            }];
        }
    }];
}

// 关闭实时聊天
- (void)close:(AVIMBoolCallback)callback {
    [self.client closeWithCallback:^(BOOL succeeded, NSError * _Nullable error) {
        callback(succeeded, error);
    }];
}

- (NSString *)getCurrentUserId {
    return self.curUserId;
}

- (AVIMClient *)getClient {
    return self.client;
}

+ (NSString *)getConversationPeerId:(AVIMConversation*)conversation {
    if (nil != conversation && 2 == conversation.members.count) {
        NSString *firstMemberId = [conversation.members objectAtIndex:0];
        return [conversation.members objectAtIndex: firstMemberId == [ChatKit getInstance].curUserId ? 1 : 0];
    }
    return nil;
}

// AVIMClientDelegate
- (void)imClientClosed:(nonnull AVIMClient *)imClient error:(NSError * _Nullable)error {
    self.isConnect = NO;
}

- (void)imClientPaused:(nonnull AVIMClient *)imClient {
    self.isConnect = NO;
}

- (void)imClientResumed:(nonnull AVIMClient *)imClient {
    self.isConnect = YES;
}

- (void)imClientResuming:(nonnull AVIMClient *)imClient {
    
}

/*!
 客户端下线通知。
 @param client 已下线的 client。
 @param error 错误信息。
 */
- (void)client:(AVIMClient *)client didOfflineWithError:(NSError * _Nullable)error {
    
}

/*!
 接收到新的普通消息。
 @param conversation － 所属对话
 @param message - 具体的消息
 */
- (void)conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message {
    NSDictionary *reslutDict = @{
                                 @"event":EVENT_OnMessageReceived,
                                 @"conversation":[conversation yy_modelToJSONObject],
                                 @"message":[message yy_modelToJSONObject],
                                 };
    if (nil != self.flutterOnMessageEvents) {
        self.flutterOnMessageEvents(reslutDict);
    }
}

/*!
 接收到新的富媒体消息。
 @param conversation － 所属对话
 @param message - 具体的消息
 */
- (void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message {
    NSDictionary *reslutDict = @{
                                 @"event":EVENT_OnMessageReceived,
                                 @"conversation":[conversation yy_modelToJSONObject],
                                 @"message":[message yy_modelToJSONObject],
                                 };
    if (nil != self.flutterOnMessageEvents) {
        self.flutterOnMessageEvents(reslutDict);
    }
}

/*!
 未读消息更新
 Notification for conversation property update.
 You can use this method to handle the properties that will be updated dynamicly during conversation's lifetime,
 for example, unread message count, last message and receipt timestamp, etc.
 
 @param conversation The updated conversation.
 @param key          The property name of updated conversation.
 */
- (void)conversation:(AVIMConversation *)conversation didUpdateForKey:(AVIMConversationUpdatedKey)key {
    NSString *eventKey = @"";
    if (AVIMConversationUpdatedKeyLastReadAt == key) {
        eventKey = EVENT_OnLastReadAtUpdated;
    } else if (AVIMConversationUpdatedKeyLastMessage == key) {
        
    } else if (AVIMConversationUpdatedKeyLastMessageAt == key) {
        
    } else if (AVIMConversationUpdatedKeyLastDeliveredAt == key) {
        eventKey = EVENT_OnLastDeliveredAtUpdated;
    } else if (AVIMConversationUpdatedKeyUnreadMessagesCount == key) {
        eventKey = EVENT_OnUnreadMessagesCountUpdated;
    } else if (AVIMConversationUpdatedKeyUnreadMessagesMentioned == key) {
        
    }
    NSDictionary *resultDict = @{
                                 @"event":eventKey,
                                 @"message":[NSNull null],
                                 @"conversation":[conversation yy_modelToJSONObject]
                                 };
    if (self.flutterOtherEvents) {
        self.flutterOtherEvents(resultDict);
    }
}

/*
 消息状态更新
 */
- (void)conversation:(AVIMConversation *)conversation messageHasBeenUpdated:(AVIMMessage *)message {
    NSDictionary *resultDict = @{
                                 @"event":EVENT_OnMessageUpdated,
                                 @"message":[message yy_modelToJSONObject],
                                 @"conversation":[conversation yy_modelToJSONObject],
                                 };
    if (self.flutterOtherEvents) {
        self.flutterOtherEvents(resultDict);
    }
}
@end
