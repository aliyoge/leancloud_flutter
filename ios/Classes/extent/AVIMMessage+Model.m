//
//  AVIMMessage+Model.m
//  AVOSCloud
//
//  Created by wmmac on 25/10/2018.
//

#import "AVIMMessage+Model.h"
#import "ChatKitHeaders.h"
#import <YYModel/YYModel.h>

@implementation AVIMMessage (Model)
// 当 Model 转为 JSON 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    dic[@"content"] = self.content;
    dic[@"from"] = self.clientId;
    dic[@"conversationId"] = self.conversationId;
    dic[@"messageId"] = self.messageId;
    dic[@"timestamp"] = @(self.sendTimestamp);
    dic[@"sendTimestamp"] = @(self.sendTimestamp);
    // 转换出错的地方
//    dic[@"mentionList"] = self.mentionList && self.mentionList.count > 0 ? self.mentionList : [NSNull null];
    
    NSString *status = @"AVIMMessageStatusNone";
    switch (self.status) {
        case AVIMMessageStatusRead:{
            status = @"AVIMMessageStatusRead";
            break;
        }
        case AVIMMessageStatusSent:{
            status = @"AVIMMessageStatusSent";
            break;
        }
        case AVIMMessageStatusFailed:{
            status = @"AVIMMessageStatusFailed";
            break;
        }
        case AVIMMessageStatusSending:{
            status = @"AVIMMessageStatusSending";
            break;
        }
        case AVIMMessageStatusDelivered:{
            status = @"AVIMMessageStatusDelivered";
            break;
        }
        default:
            break;
    }
    dic[@"status"] = status;
    dic[@"ioType"] = AVIMMessageIOTypeIn == self.ioType ? @"AVIMMessageIOTypeIn" : @"AVIMMessageIOTypeOut";
    dic[@"transient"] = @(self.transient);
    switch (self.mediaType) {
        case kAVIMMessageMediaTypeNone:{
            dic[@"messageType"] = @(0);
            break;
        }
        case kAVIMMessageMediaTypeText:{
            dic[@"messageType"] = @(-1);
            break;
        }
        case kAVIMMessageMediaTypeImage:{
            dic[@"messageType"] = @(-2);
            break;
        }
        case kAVIMMessageMediaTypeAudio:{
            dic[@"messageType"] = @(-3);
            break;
        }
        case kAVIMMessageMediaTypeVideo:{
            dic[@"messageType"] = @(-4);
            break;
        }
        case kAVIMMessageMediaTypeLocation:{
            dic[@"messageType"] = @(-5);
            break;
        }
        case kAVIMMessageMediaTypeFile:{
            dic[@"messageType"] = @(-6);
            break;
        }
        case kAVIMMessageMediaTypeRecalled:{
            dic[@"messageType"] = @(-127);
            break;
        }
        default:
            break;
    }
    return YES;
}

//// 返回容器类中的所需要存放的数据类型 (以 Class 或 Class Name 的形式)。
//+ (NSDictionary *)modelContainerPropertyGenericClass {
//    return @{@"size" : [NSNumber class],};
//}
// 如果实现了该方法，则处理过程中会忽略该列表内的所有属性
+ (NSArray *)modelPropertyBlacklist {
    return @[
             @"size",
//             @"mentionList",
//             @"deliveredTimestamp",
//             @"mediaType",
//             @"seq",
             ];
}
//// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
//+ (NSArray *)modelPropertyWhitelist {
//    return @[@"name"];
//}

@end
