//
// Created by Caijinglong on 2019-03-15.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <IJKMediaFramework/IJKMediaFramework.h>

@class CoolVideoInfo;

@protocol KKIjkNotifyDelegate
- (CoolVideoInfo *_Nullable)getInfo;

- (void)setDegree:(int)newDegree;

- (void)onLoadStateChange;
@end

@interface CoolIjkNotifyChannel : NSObject

@property(nonatomic, strong) IJKFFMoviePlayerController * _Nullable controller;

@property(nonatomic, assign) int64_t textureId;

@property(nonatomic)NSObject<FlutterBinaryMessenger>* _Nullable messenger;

@property(nonatomic, weak) NSObject <KKIjkNotifyDelegate> * _Nullable infoDelegate;

- (instancetype _Nullable )initWithController:(IJKFFMoviePlayerController *_Nullable)controller textureId:(int64_t)textureId messenger:(NSObject<FlutterBinaryMessenger>*_Nonnull)messenger;

+ (instancetype _Nullable )channelWithController:(IJKFFMoviePlayerController *_Nullable)controller textureId:(int64_t)textureId messenger:(NSObject<FlutterBinaryMessenger>*_Nullable)messenger;


- (void)dispose;

@end
