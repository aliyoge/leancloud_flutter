//
//  ChatKit.h
//  AVOSCloud
//
//  Created by WenjunHuang on 22/10/2018.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "ChatKitHeaders.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChatKit : NSObject<AVIMClientDelegate>
@property (nonatomic, copy) NSString *curUserId;
@property (nonatomic, assign) BOOL isConnect;

+ (instancetype)getInstance;

- (void)autoOpen:(AVIMClientCallback)callback;
- (void)open:(NSString *)username password:(NSString *)password callback:(AVIMClientCallback)callback;
- (void)close:(AVIMBoolCallback)callback;
- (NSString *)getCurrentUserId;
- (AVIMClient *)getClient;
- (void)setFlutterOnMessageEvents:(FlutterEventSink)flutterOnMessageEvents;
- (void)setFlutterOtherEvents:(FlutterEventSink)flutterOtherEvents;
@end

NS_ASSUME_NONNULL_END
