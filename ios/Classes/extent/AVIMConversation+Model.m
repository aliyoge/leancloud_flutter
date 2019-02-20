//
//  AVIMConversation+Model.m
//  AVOSCloud
//
//  Created by wmmac on 25/10/2018.
//

#import "AVIMConversation+Model.h"
#import <YYModel/YYModel.h>

@implementation AVIMConversation (Model)
// 当 Model 转为 JSON 完成后，该方法会被调用。
// 你可以在这里对数据进行校验，如果校验不通过，可以返回 NO，则该 Model 会被忽略。
// 你也可以在这里做一些自动转换不能完成的工作。
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic {
    dic[@"conversationId"] = self.conversationId;
    dic[@"name"] = self.name;
    dic[@"members"] = self.members;
    dic[@"creator"] = self.creator;
    dic[@"attributes"] = self.attributes;
    dic[@"transient"] = [NSNumber numberWithBool: self.transient];
    dic[@"createAt"] = @((long)([self.createAt timeIntervalSince1970] * 1000.0));
    dic[@"updateAt"] = @((long)([self.updateAt timeIntervalSince1970] * 1000.0));
    dic[@"system"] = [NSNumber numberWithBool: self.system];
    dic[@"lastReadAt"] = @((long)([self.lastReadAt timeIntervalSince1970] * 1000.0));
    dic[@"lastMessage"] = [self.lastMessage yy_modelToJSONObject];
    dic[@"muted"] = [NSNumber numberWithBool: self.muted];
    dic[@"unreadMessagesCount"] = [NSNumber numberWithUnsignedInteger: self.unreadMessagesCount];
    dic[@"lastDeliveredAt"] = @((long)([self.lastDeliveredAt timeIntervalSince1970] * 1000.0));
    dic[@"lastReadAt"] = @((long)([self.lastReadAt timeIntervalSince1970] * 1000.0));
    return YES;
}
@end
