//
// Created by Caijinglong on 2019-03-08.
//

#import "CoolFlutterIJK.h"
#import "CoolVideoInfo.h"
#import "CoolFlutterResult.h"
#import <AVFoundation/AVFoundation.h>
#import <libkern/OSAtomic.h>

@interface CoolFlutterIJK () <KKIjkNotifyDelegate>
@property(nonatomic)int64_t viewId;
@property(nonatomic, assign)CGRect viewRect;
@end

@implementation CoolFlutterIJK {
    //int64_t textureId;
    //CADisplayLink *displayLink;
    //NSObject <FlutterTextureRegistry> *textures;
    UIView *contentView;
    IJKFFMoviePlayerController *controller;
    //CVPixelBufferRef latestPixelBuffer;
    FlutterMethodChannel *channel;
    CoolIjkNotifyChannel *notifyChannel;
    int degree;
    CoolFlutterResult *prepareResult;
}

- (instancetype)initWithWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id)args binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger{
    if ([super init]) {
        NSDictionary *dic = args;
        NSLog(@"dic = %@", dic);
        self.viewRect = frame;
        self.viewId = viewId;
        self.messenger = messenger;
        NSString *channelName = [NSString stringWithFormat:@"top.kikt/ijkplayer/%lli", self.viewId];
        channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
        __weak typeof(&*self) weakSelf = self;
        [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
            [weakSelf handleMethodCall:call result:result];
        }];
        self.isDisposed = NO;
    }
    
    return self;
}

-(UIView *)view{
    if(!contentView){
        contentView = [[UIView alloc] initWithFrame:self.viewRect];
        contentView.backgroundColor = [UIColor lightGrayColor];
        contentView.autoresizesSubviews = YES;
    }
    return contentView;
}

- (void)dispose {
    if(self.isDisposed){
        return;
    }
    self.isDisposed = YES;
    [notifyChannel dispose];
    // [[self.registrar textures] unregisterTexture:self.id];
    channel = nil;
    [controller stop];
    [controller shutdown];
    [controller.view removeFromSuperview];
    controller = nil;
    // displayLink.paused = YES;
    // [displayLink invalidate];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSLog(@"call.method = %@", call.method);
    if(self.isDisposed){
        return;
    }
    if ([@"play" isEqualToString:call.method]) {
        [self play];
        result(@(YES));
    } else if ([@"pause" isEqualToString:call.method]) {
        [self pause];
        result(@(YES));
    } else if ([@"stop" isEqualToString:call.method]) {
        [self stop];
        result(@(YES));
    } else if ([@"setNetworkDataSource" isEqualToString:call.method]) {
        @try {
            NSDictionary *params = call.arguments;
            NSString *uri = params[@"uri"];
            NSDictionary *headers = params[@"headers"];
            [self setDataSourceWithUri:uri headers:headers result:[CoolFlutterResult resultWithResult:result]];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception occurred: %@, %@", exception, [exception userInfo]);
            result([FlutterError errorWithCode:@"1" message:@"设置失败" details:nil]);
        }
    } else if ([@"setAssetDataSource" isEqualToString:call.method]) {
        @try {
            NSDictionary *params = [call arguments];
            NSString *name = params[@"name"];
            NSString *pkg = params[@"package"];
            IJKFFMoviePlayerController *playerController = [self createControllerWithAssetName:name pkg:pkg];
            [self setDataSourceWithController:playerController result:[CoolFlutterResult resultWithResult:result]];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception occurred: %@, %@", exception, [exception userInfo]);
            result([FlutterError errorWithCode:@"1" message:@"设置失败" details:nil]);
        }
    } else if ([@"setFileDataSource" isEqualToString:call.method]) {
        NSDictionary *params = call.arguments;
        NSString *path = params[@"path"];
        IJKFFMoviePlayerController *playerController = [self createControllerWithPath:path];
        [self setDataSourceWithController:playerController result:[CoolFlutterResult resultWithResult:result]];
    } else if ([@"seekTo" isEqualToString:call.method]) {
        NSDictionary *params = call.arguments;
        double target = [params[@"target"] doubleValue];
        [self seekTo:target];
        result(@(YES));
    } else if ([@"getInfo" isEqualToString:call.method]) {
        CoolVideoInfo *info = [self getInfo];
        result([info toMap]);
    } else if ([@"setVolume" isEqualToString:call.method]) {
        NSDictionary *params = [self params:call];
        float v = [params[@"volume"] floatValue] / 100;
        controller.playbackVolume = v;
        result(@(YES));
    } else if ([@"screenShot" isEqualToString:call.method]) {
        __weak typeof(&*self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSData *data = [weakSelf screenShot];
            result(data);
        });
    } else if ([@"setSpeed" isEqualToString:call.method]) {
        float speedValue = [call.arguments floatValue];
        if (controller) {
            [controller setPlaybackRate:speedValue];
        }
        result(@YES);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (NSDictionary *)params:(FlutterMethodCall *)call {
    return call.arguments;
}

- (int64_t)id {
    return self.viewId;
}

- (void)play {
    [controller play];
    // if (displayLink) {
    //     displayLink.paused = NO;
    // }
}

- (void)pause {
    [controller pause];
    // if (displayLink) {
    //     displayLink.paused = YES;
    // }
}

- (void)stop {
    [controller stop];
    // if (displayLink) {
    //     displayLink.paused = NO;
    // }
}

- (void)setDataSourceWithController:(IJKFFMoviePlayerController *)ctl result:(CoolFlutterResult *)result {
    if (ctl) {
        controller = ctl;
        controller.view.backgroundColor = [UIColor blackColor];
        controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        controller.scalingMode = IJKMPMovieScalingModeAspectFit;

        NSArray *subviews =  [self view].subviews;
        for (UIView *view in subviews) {
            [view removeFromSuperview];
        }
        [contentView addSubview:controller.view];
        controller.view.frame = CGRectMake(0, 0, contentView.bounds.size.width, contentView.bounds.size.height);
        controller.shouldAutoplay = YES;
        [IJKFFMoviePlayerController setLogReport:NO];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_SILENT];
//        #ifdef DEBUG
//            [IJKFFMoviePlayerController setLogReport:YES];
//            [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
//        #else
//            [IJKFFMoviePlayerController setLogReport:NO];
//            [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
//        #endif
        [self prepare:result];
    }
}

- (IJKFFOptions *)createOption {
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];

    // see https://www.jianshu.com/p/843c86a9e9ad
//    [options setFormatOptionValue:@"fastseek" forKey:@"fflags"];
//    [options setFormatOptionIntValue:100 forKey:@"analyzemaxduration"];
//    [options setFormatOptionIntValue:1 forKey:@"analyzeduration"];
//    [options setFormatOptionIntValue:10240 forKey:@"probesize"];
//    [options setFormatOptionIntValue:1 forKey:@"flush_packets"];
//    [options setFormatOptionIntValue:5 forKey:@"reconnect"];
//    [options setFormatOptionIntValue:5 forKey:@"framedrop"];
//    [options setFormatOptionIntValue:1 forKey:@"enable-accurate-seek"];
    
//    [options setPlayerOptionIntValue:0      forKey:@"video-max-frame-width-default"];
//    [options setPlayerOptionIntValue:1      forKey:@"videotoolbox"];

    for (CoolIjkOption *opt in self.options) {
        if (opt) {
            NSString* key = opt.key;
            BOOL isString = [opt.value isKindOfClass:[NSString class]];
            BOOL isInt;
            if([opt.value isKindOfClass:[NSNumber class]]){
                isInt = strcmp([opt.value objCType], @encode(int)) == 0;
            }else{
                isInt = NO;
            }
            switch (opt.type) {
                case 0:
                    if(isString){
                        [options setFormatOptionValue:opt.value forKey:key];
                    }else if(isInt){
                        [options setFormatOptionIntValue:[opt.value intValue] forKey:key];
                    }
                    break;
                case 1:
                    if(isString){
                        [options setCodecOptionValue:opt.value forKey:key];
                    }else if(isInt){
                        [options setCodecOptionIntValue:[opt.value intValue] forKey:key];
                    }
                    break;
                case 2:
                    if(isString){
                        [options setSwsOptionValue:opt.value forKey:key];
                    }else if(isInt){
                        [options setSwsOptionIntValue:[opt.value intValue] forKey:key];
                    }
                    break;
                case 3:
                    if(isString){
                        [options setPlayerOptionValue:opt.value forKey:key];
                    }else if(isInt){
                        [options setPlayerOptionIntValue:[opt.value intValue] forKey:key];
                    }
                    break;
                default:
                    break;
            }
        }
    }
    
    return options;
}

- (void)setDataSourceWithUri:(NSString *)uri headers:(NSDictionary *)headers result:(CoolFlutterResult *)result {
    IJKFFOptions *options = [self createOption];
    if (headers) {
        NSMutableString *headerString = [NSMutableString new];
        for (NSString *key in headers.allKeys) {
            NSString *value = headers[key];
            [headerString appendFormat:@"%@:%@", key, value];
            [headerString appendString:@"\r\n"];
        }
        [options setFormatOptionValue:headerString forKey:@"headers"];
    }
    controller = [[IJKFFMoviePlayerController alloc] initWithContentURLString:uri withOptions:options];

    [self setDataSourceWithController:controller result:result];
}

- (void)setDegree:(int)d {
    degree = d;
}


- (void)prepare:(CoolFlutterResult *)result {
    prepareResult = result;
    [controller prepareToPlay];
    // if (displayLink) {
    //     displayLink.paused = YES;
    //     [displayLink invalidate];
    //     displayLink = nil;
    // }

    // displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onDisplayLink:)];
    // [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

     notifyChannel = [CoolIjkNotifyChannel channelWithController:controller textureId:[self id] messenger:self.messenger];
     notifyChannel.infoDelegate = self;
}

- (void)onLoadStateChange {
//    IJKMPMovieLoadState loadState = controller.loadState;
    if (prepareResult) {
        [prepareResult replyResult:@YES];
    }
    prepareResult = nil;
}


- (IJKFFMoviePlayerController *)createControllerWithAssetName:(NSString *)assetName pkg:(NSString *)pkg {
    // NSString *asset;
    // if (!pkg) {
    //     asset = [self.registrar lookupKeyForAsset:assetName];
    // } else {
    //     asset = [self.registrar lookupKeyForAsset:assetName fromPackage:pkg];
    // }
    // NSString *path = [[NSBundle mainBundle] pathForResource:asset ofType:nil];
    // NSURL *url = [NSURL fileURLWithPath:path];

    IJKFFOptions *options = [self createOption];

    return [[IJKFFMoviePlayerController alloc] initWithContentURL:nil withOptions:options];
}


- (IJKFFMoviePlayerController *)createControllerWithPath:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    IJKFFOptions *options = [self createOption];
    return [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:options];
}

- (void)seekTo:(double)target {
    [controller setCurrentPlaybackTime:target];
}

// - (void)onDisplayLink:(CADisplayLink *)link {
//     [textures textureFrameAvailable:textureId];
// }

- (CVPixelBufferRef _Nullable)copyPixelBuffer {
    // CVPixelBufferRef newBuffer = [controller framePixelbuffer];
    // if (newBuffer) {
    //     CFRetain(newBuffer);
    //     CVPixelBufferRef pixelBuffer = latestPixelBuffer;
    //     while (!OSAtomicCompareAndSwapPtrBarrier(pixelBuffer, newBuffer, (void **) &latestPixelBuffer)) {
    //         pixelBuffer = latestPixelBuffer;
    //     }

    //     return pixelBuffer;
    // }
    return NULL;
}

- (CoolVideoInfo *)getInfo {
    CoolVideoInfo *info = [CoolVideoInfo new];

    CGSize size = [controller naturalSize];
    NSTimeInterval duration = [controller duration];
    NSTimeInterval currentPlaybackTime = [controller currentPlaybackTime];

    info.size = size;
    info.duration = duration;
    info.currentPosition = currentPlaybackTime;
    info.isPlaying = [controller isPlaying];
    info.degree = degree;
    //info.tcpSpeed = [controller tcpSpeed];
    info.outputFps = [controller fpsAtOutput];

    return info;
}


- (NSUInteger)degreeFromVideoFileWithURL:(NSURL *)url {
    NSUInteger mDegree = 0;

    AVAsset *asset = [AVAsset assetWithURL:url];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if ([tracks count] > 0) {
        AVAssetTrack *videoTrack = tracks[0];
        CGAffineTransform t = videoTrack.preferredTransform;

        if (t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
            // Portrait
            mDegree = 90;
        } else if (t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {
            // PortraitUpsideDown
            mDegree = 270;
        } else if (t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0) {
            // LandscapeRight
            mDegree = 0;
        } else if (t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
            // LandscapeLeft
            mDegree = 180;
        }
    }

    return mDegree;
}

- (NSData*) screenShot{
    CVPixelBufferRef ref = [self copyPixelBuffer];
    if(!ref){
        return nil;
    }
    
    UIImage *img = [self convertPixeclBufferToUIImage:ref];
    return UIImageJPEGRepresentation(img, 1.0);
}

-(UIImage*)convertPixeclBufferToUIImage:(CVPixelBufferRef)pixelBuffer{
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext
                             createCGImage:ciImage
                             fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))];
    
    UIImage *uiImage = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    
    return uiImage;
}

@end
