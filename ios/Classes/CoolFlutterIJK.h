//
// Created by Caijinglong on 2019-03-08.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import "CoolIjkNotifyChannel.h"
#import "CoolIjkOption.h"

@interface CoolFlutterIJK : NSObject<FlutterPlatformView>

@property(nonatomic, strong) NSArray<CoolIjkOption*> * _Nullable   options;

@property(nonatomic, assign) BOOL isDisposed;

@property(nonatomic)NSObject<FlutterBinaryMessenger>* _Nullable messenger;

- (instancetype _Nullable )initWithWithFrame:(CGRect)frame
viewIdentifier:(int64_t)viewId
     arguments:(id _Nullable)args
          binaryMessenger:(NSObject<FlutterBinaryMessenger>*_Nullable)messenger;

- (int64_t)id;

- (void)dispose;

- (void)setDegree:(int)degree;

@end
