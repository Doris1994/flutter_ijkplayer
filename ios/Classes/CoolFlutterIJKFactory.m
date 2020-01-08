#import "CoolFlutterIJKFactory.h"
#import "CoolFlutterIJK.h"

@interface CoolIjkViewFactory ()
@property(nonatomic)NSObject<FlutterBinaryMessenger>* messenger;
@end

@implementation CoolIjkViewFactory

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
    self = [super init];
    if (self) {
        self.messenger = messenger;
    }
    return self;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
    return [FlutterStandardMessageCodec sharedInstance];
}

- (nonnull NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                            viewIdentifier:(int64_t)viewId
                                                 arguments:(id _Nullable)args {
    CoolFlutterIJK *controller = [[CoolFlutterIJK alloc] initWithWithFrame:frame viewIdentifier:viewId arguments:args binaryMessenger:_messenger];
    _platformView = controller;
    return controller;
}

@end
