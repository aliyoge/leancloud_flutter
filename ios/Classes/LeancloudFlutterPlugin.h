#import <Flutter/Flutter.h>
#import "ChatKitHeaders.h"

@interface LeancloudFlutterPlugin : NSObject<FlutterPlugin>
@end

@interface LeancloudFlutterEventHandler : NSObject<FlutterStreamHandler>

@end

@interface LeancloudFlutterOnMessageHandler : NSObject<FlutterStreamHandler>

@end
