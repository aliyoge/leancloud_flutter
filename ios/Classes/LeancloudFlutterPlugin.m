#import "LeancloudFlutterPlugin.h"
#import "ChatKit.h"
#import <YYModel/YYModel.h>

#import "AVIMConversation+Model.h"
#import "AVIMTypedMessage+Model.h"

@implementation LeancloudFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* methodChannel = [FlutterMethodChannel
      methodChannelWithName:@"leancloud_flutter"
            binaryMessenger:[registrar messenger]];
    LeancloudFlutterPlugin* instance = [[LeancloudFlutterPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:methodChannel];
    
    FlutterEventChannel* eventChannel = [FlutterEventChannel eventChannelWithName:@"leancloud_flutter/events" binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:[[LeancloudFlutterEventHandler alloc] init]];
    
    FlutterEventChannel* onmessageChannel = [FlutterEventChannel eventChannelWithName:@"leancloud_flutter/onmessage" binaryMessenger:[registrar messenger]];
    [onmessageChannel setStreamHandler:[[LeancloudFlutterOnMessageHandler alloc] init]];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([METHOD_INITIALIZE isEqualToString:call.method]) {
        [self handleInitialize:call result:result];
    } else if ([METHOD_LOGIN isEqualToString:call.method]) {
        [self handleLogin:call result:result];
    } else if ([METHOD_AUTO_LOGIN isEqualToString:call.method]) {
        [self handleAutoLogin:call result:result];
    } else if ([METHOD_GET_CLIENT_ID isEqualToString:call.method]) {
        [self handleGetClientId:call result:result];
    } else if ([METHOD_QUERY_CONVERSATIONS isEqualToString:call.method]) {
        [self handleQueryConversations:call result:result];
    } else if ([METHOD_QUERY_MESSAGES isEqualToString:call.method]) {
        [self handleQueryMessage:call result:result];
    } else if ([METHOD_START_SINGLE_CHAT isEqualToString:call.method]) {
        [self handleStartSingleChat:call result:result];
    } else if ([METHOD_STOP_SINGLE_CHAT isEqualToString:call.method]) {
        [self handleStopSingleChat:call result:result];
    } else if ([METHOD_START_GROUP_CHAT isEqualToString:call.method]) {
        [self handleStartGroupChat:call result:result];
    } else if ([METHOD_STOP_GROUP_CHAT isEqualToString:call.method]) {
        [self handleStopGroupChat:call result:result];
    } else if ([METHOD_SEND_MESSAGE isEqualToString:call.method]) {
        [self handleSendMessage:call result:result];
    } else if ([METHOD_GET_CONVERSATION_INFO isEqualToString:call.method]) {
        
    } else if ([METHOD_SET_CONVERSATION_READ isEqualToString:call.method]) {
        [self handleSetConversationRead:call result:result];
    } else if ([METHOD_GET_NETWORK_STATE isEqualToString:call.method]) {
        [self handleGetNetworkState:call result:result];
    } else if ([METHOD_GET_USER_INFO isEqualToString:call.method]) {
        [self handleGetUserInfo:call result:result];
    } else if ([METHOD_REMOVE_CONVERSATION isEqualToString:call.method]) {
        [self handleRemoveConversation:call result:result];
    } else {
        result(@{@"code":@"9999", @"message": @"FlutterMethodNotImplemented"});
    }
}

- (void)handleInitialize:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *APP_ID = [[call arguments] objectForKey:@"appId"];
    NSString *APP_KEY = [[call arguments] objectForKey:@"appKey"];
    
    [AVOSCloud setApplicationId:APP_ID clientKey:APP_KEY];
    [AVOSCloud setAllLogsEnabled:YES];
    [AVIMClient setUnreadNotificationEnabled:YES];
    result(@{@"code":@"0000", @"result": @"success"});
}

- (void)handleLogin:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *username = [[call arguments] objectForKey:@"username"];
    NSString *password = [[call arguments] objectForKey:@"password"];
    [[ChatKit getInstance] open:username password:password callback:^(NSString *clientId, NSError * _Nullable error) {
        if (nil == clientId) {
            result(@{@"code":@"9999", @"message": error.domain});
        } else {
            result(@{@"code":@"0000", @"result": clientId});
        }
    }];
}

- (void)handleAutoLogin:(FlutterMethodCall*)call result:(FlutterResult)result {
    [[ChatKit getInstance] autoOpen:^(NSString *clientId, NSError * _Nullable error) {
        if (nil == clientId) {
            result(@{@"code":@"9999", @"message": error.domain});
        } else {
            result(@{@"code":@"0000", @"result": clientId});
        }
    }];
}

- (void)handleGetClientId:(FlutterMethodCall*)call result:(FlutterResult)result {
    result(@{@"code":@"0000", @"result": [[ChatKit getInstance] getCurrentUserId]});
}

- (void)handleQueryConversations:(FlutterMethodCall*)call result:(FlutterResult)result {
    AVIMConversationQuery *query = [[[ChatKit getInstance] getClient] conversationQuery];
    [query setCachePolicy:kAVIMCachePolicyNetworkElseCache];
    [query setLimit:20];
    [query findConversationsWithCallback:^(NSArray<AVIMConversation *> * _Nullable conversations, NSError * _Nullable error) {
        if (nil != error) {
            result(@{@"code":@"9999", @"message": error.domain});
        } else {
            NSMutableArray *dictArray = [NSMutableArray arrayWithCapacity:20];
            for (AVIMConversation *convs in conversations) {
                NSDictionary *dic = [convs yy_modelToJSONObject];
                [dictArray addObject:dic];
            }
            result(@{@"code":@"0000", @"result": dictArray});
        }
    }];
}

- (void)handleRemoveConversation:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *conversationId = [[call arguments] objectForKey:@"conversationId"];
    AVIMConversation *conversation = [[[ChatKit getInstance] getClient] conversationForId:conversationId];
    [[[ChatKit getInstance] getClient] removeConversationsInMemoryWith:[NSArray arrayWithObject:conversationId] callback:^{
        [conversation quitWithCallback:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                result(@{@"code":@"0000", @"result": @YES});
            } else {
                result(@{@"code":@"9999", @"message": error.domain});
            }
        }];
    }];
}

- (void)handleQueryMessage:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *conversationId = [[call arguments] objectForKey:@"conversationId"];
    NSString *messageId = [[call arguments] objectForKey:@"messageId"];
    NSNumber *messageTimestamp = [[call arguments] objectForKey:@"messageTimestamp"];
    NSNumber *limit = [[call arguments] objectForKey:@"limit"];
    if (nil == limit) {limit = @20;}
    
    AVIMConversation *conversation = [[[ChatKit getInstance] getClient] conversationForId:conversationId];
    if (!messageId || [messageId isKindOfClass:[NSNull class]]) {
        [conversation queryMessagesWithLimit:limit.intValue callback:^(NSArray<AVIMMessage *> * _Nullable messages, NSError * _Nullable error) {
            if (nil != error) {
                result(@{@"code":@"9999", @"message": error.domain});
            } else {
                NSMutableArray *dictArray = [NSMutableArray arrayWithCapacity:20];
                for (AVIMMessage *msg in messages) {
                    NSDictionary *dic;
                    if (msg.mediaType == kAVIMMessageMediaTypeText) {
                        dic = [(AVIMTextMessage *)msg yy_modelToJSONObject];
                    } else if (msg.mediaType == kAVIMMessageMediaTypeImage) {
                        dic = [(AVIMImageMessage *)msg yy_modelToJSONObject];
                    } else {
                        dic = [msg yy_modelToJSONObject];
                    }
                    [dictArray addObject:dic];
                }
                result(@{@"code":@"0000", @"result": dictArray});
            }
        }];
    } else {
        [conversation queryMessagesBeforeId:messageId timestamp:messageTimestamp.longLongValue limit:limit.intValue callback:^(NSArray<AVIMMessage *> * _Nullable messages, NSError * _Nullable error) {
            if (nil != error) {
                result(@{@"code":@"9999", @"message": error.domain});
            } else {
                NSMutableArray *dictArray = [NSMutableArray arrayWithCapacity:20];
                for (AVIMMessage *msg in messages) {
                    NSDictionary *dic;
                    if (msg.mediaType == kAVIMMessageMediaTypeText) {
                        dic = [(AVIMTextMessage *)msg yy_modelToJSONObject];
                    } else if (msg.mediaType == kAVIMMessageMediaTypeImage) {
                        dic = [(AVIMImageMessage *)msg yy_modelToJSONObject];
                    } else {
                        dic = [msg yy_modelToJSONObject];
                    }
                    [dictArray addObject:dic];
                }
                result(@{@"code":@"0000", @"result": dictArray});
            }
        }];
    }
}

- (void)handleStartSingleChat:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *memberId = [[call arguments] objectForKey:@"memberId"];
    NSString *name = [[call arguments] objectForKey:@"name"];
    [[[ChatKit getInstance] getClient] createConversationWithName:name clientIds:[NSArray arrayWithObject:memberId] attributes:nil options:AVIMConversationOptionUnique callback:^(AVIMConversation * _Nullable conversation, NSError * _Nullable error) {
        if (nil != error) {
            result(@{@"code":@"9999", @"message": error.domain});
        } else {
            result(@{@"code":@"0000", @"result": conversation.conversationId});
        }
    }];
}

- (void)handleStopSingleChat:(FlutterMethodCall*)call result:(FlutterResult)result {
}

- (void)handleStartGroupChat:(FlutterMethodCall*)call result:(FlutterResult)result {
    
}

- (void)handleStopGroupChat:(FlutterMethodCall*)call result:(FlutterResult)result {
    
}

- (void)handleSendMessage:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *conversationId = [[call arguments] objectForKey:@"conversationId"];
    NSNumber *type = [[call arguments] objectForKey:@"type"];
    
    AVIMConversation *conversation = [[[ChatKit getInstance] getClient] conversationForId:conversationId];
    
    AVIMMessageOption *option = [[AVIMMessageOption alloc] init];
    option.receipt = YES;
    
    switch (type.intValue) {
        case -1:{
            NSString *text = [[call arguments] objectForKey:@"message"];
            AVIMTextMessage *msg = [AVIMTextMessage messageWithText:text attributes:nil];
            
            [conversation sendMessage:msg callback:^(BOOL succeeded, NSError * _Nullable error) {
                if (!succeeded) {
                    result(@{@"code":@"9999", @"message": error.domain});
                } else {
                    result(@{@"code":@"0000", @"result": [msg yy_modelToJSONObject]});
                }
            }];
            break;
        }
        case -2:{
            NSString *imagePath = [[call arguments] objectForKey:@"message"];
            AVIMImageMessage *msg = [AVIMImageMessage messageWithText:nil attachedFilePath:imagePath attributes:nil];
            
            [conversation sendMessage:msg callback:^(BOOL succeeded, NSError * _Nullable error) {
                if (!succeeded) {
                    result(@{@"code":@"9999", @"message": error.domain});
                } else {
                    result(@{@"code":@"0000", @"result": [msg yy_modelToJSONObject]});
                }
            }];
            break;
        }
        default:
            break;
    }
}

- (void)handleSetConversationRead:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *conversationId = [[call arguments] objectForKey:@"conversationId"];
    AVIMConversation *conversation = [[[ChatKit getInstance] getClient] conversationForId:conversationId];
    if (nil != conversation && !([conversationId isKindOfClass:[NSNull class]])) {
        [conversation readInBackground];
        result(@{@"code":@"0000", @"result": @"0000"});
    } else {
        result(@{@"code":@"9999", @"message": @""});
    }
}

- (void)handleGetNetworkState:(FlutterMethodCall*)call result:(FlutterResult)result {
    
}

- (void)handleGetUserInfo:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *userId = [[call arguments] objectForKey:@"userId"];
    AVQuery *userQuery = [AVQuery queryWithClassName:@"_User"];
    [userQuery whereKey:@"objectId" equalTo:userId];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (nil != error) {
            result(@{@"code":@"9999", @"message": error.domain});
        } else {
            if (objects && objects.count > 0) {
                AVUser *user = [objects objectAtIndex:0];
                result(@{@"code":@"0000",
                         @"result":@{
                                 @"nickname":[user objectForKey:@"nickname"] ? [user objectForKey:@"nickname"] : [NSNull null],
                                 @"avatarUrl": [user objectForKey:@"avatarUrl"] ? [user objectForKey:@"avatarUrl"] : [NSNull null]}});
            } else {
                result(@{@"code":@"9999", @"message": @"找不到此用户"});
            }
        }
    }];
}

@end


@implementation LeancloudFlutterEventHandler

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    [[ChatKit getInstance] setFlutterOtherEvents:events];
    return nil;
}

@end

@implementation LeancloudFlutterOnMessageHandler

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    [[ChatKit getInstance] setFlutterOnMessageEvents:events];
    return nil;
}

@end
