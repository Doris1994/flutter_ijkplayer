//
// Created by Caijinglong on 2019-06-12.
//


#import <Flutter/Flutter.h>

@interface CoolFlutterResult : NSObject

@property(nonatomic, strong) FlutterResult _Nullable result;

@property(nonatomic, assign) BOOL isReply;

- (instancetype _Nullable )initWithResult:(FlutterResult _Nullable )result;

+ (instancetype _Nullable )resultWithResult:(FlutterResult _Nullable )result;

- (void)replyResult:(id _Nullable)result;

@end
