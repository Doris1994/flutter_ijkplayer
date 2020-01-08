#import <Flutter/Flutter.h>
@interface CoolIjkViewFactory : NSObject<FlutterPlatformViewFactory>
@property(nonatomic, strong) NSObject<FlutterPlatformView> *platformView;
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
@end
