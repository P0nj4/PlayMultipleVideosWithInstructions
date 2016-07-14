//
//  ViewController.m
//  VideoPlayerTest
//
//  Created by German Pereyra on 14/Jul/16.
//  Copyright © 2016 Neon Roots. All rights reserved.
//

#import "ViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"tennisTall" ofType:@"mov"];
    AVAsset *asset1 = [AVAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
    NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"instatall" ofType:@"mov"];
    AVAsset *asset2 = [AVAsset assetWithURL:[NSURL fileURLWithPath:filePath2]];
    NSString *filePath3 = [[NSBundle mainBundle] pathForResource:@"sportTall" ofType:@"mov"];
    AVAsset *asset3 = [AVAsset assetWithURL:[NSURL fileURLWithPath:filePath3]];
    
    NSArray *assets = @[asset1, asset2, asset3];
    
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                       preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                       preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSMutableArray *instructions = [NSMutableArray new];
    CGSize size = CGSizeZero;
    
    CMTime time = kCMTimeZero;
    for (AVAsset *asset in assets) {
        AVAssetTrack *assetTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        AVAssetTrack *audioAssetTrack = [asset tracksWithMediaType:AVMediaTypeAudio].firstObject;
        
        NSError *error;
        [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetTrack.timeRange.duration)
                                       ofTrack:assetTrack
                                        atTime:time
                                         error:&error];
        if (error) {
            NSLog(@"Error - %@", error.debugDescription);
        }
        
        [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetTrack.timeRange.duration)
                                       ofTrack:audioAssetTrack
                                        atTime:time
                                         error:&error];
        if (error) {
            NSLog(@"Error - %@", error.debugDescription);
        }
        
        AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        videoCompositionInstruction.timeRange = CMTimeRangeMake(time, assetTrack.timeRange.duration);
        AVMutableVideoCompositionLayerInstruction *inst = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
        if (instructions.count == 0) {
            [inst setOpacity:0.7 atTime:time];
            [inst setTransform:CGAffineTransformMakeRotation((M_PI_4)) atTime:time];
        }
        videoCompositionInstruction.layerInstructions = @[inst];
        [instructions addObject:videoCompositionInstruction];
        
        time = CMTimeAdd(time, assetTrack.timeRange.duration);
        
        if (CGSizeEqualToSize(size, CGSizeZero)) {
            size = assetTrack.naturalSize;;
        }
    }
    
    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    mutableVideoComposition.instructions = instructions;
    
    // Set the frame duration to an appropriate value (i.e. 30 frames per second for video).
    mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
    mutableVideoComposition.renderSize = size;
    
    AVPlayerItem *pi = [AVPlayerItem playerItemWithAsset:mutableComposition];
    pi.videoComposition = mutableVideoComposition;
    
    AVPlayer *player = [AVPlayer playerWithPlayerItem:pi];
    
    AVPlayerLayer *playerLayer = [[AVPlayerLayer alloc] init];
    playerLayer.frame = self.view.bounds;
    playerLayer.player = player;
    
    [self.view.layer addSublayer:playerLayer];
    
    [player play];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
