//
//  AKBoosterAudioUnit.mm
//  AudioKit
//
//  Autogenerated by scripts by Aurelius Prochazka. Do not edit directly.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKBoosterAudioUnit.h"
#import "AKBoosterDSPKernel.hpp"

#import <AVFoundation/AVFoundation.h>
#import "AKBufferedAudioBus.hpp"

@interface AKBoosterAudioUnit()

@property AUAudioUnitBus *outputBus;
@property AUAudioUnitBusArray *inputBusArray;
@property AUAudioUnitBusArray *outputBusArray;

@property (nonatomic, readwrite) AUParameterTree *parameterTree;

@end

@implementation AKBoosterAudioUnit {
    // C++ members need to be ivars; they would be copied on access if they were properties.
    AKBoosterDSPKernel _kernel;

    BufferedInputBus _inputBus;
}
@synthesize parameterTree = _parameterTree;

- (void)setGain:(float)gain {
    _kernel.gain = gain;
}
- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription
                                     options:(AudioComponentInstantiationOptions)options
                                       error:(NSError **)outError {
    self = [super initWithComponentDescription:componentDescription options:options error:outError];

    if (self == nil) {
        return nil;
    }

    // Initialize a default format for the busses.
    AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100.
                                                                                  channels:2];

    // Create a DSP kernel to handle the signal processing.
    _kernel.init(defaultFormat.channelCount, defaultFormat.sampleRate);

        // Create a parameter object for the gain.
    AUParameter *gainAUParameter =
    [AUParameterTree createParameterWithIdentifier:@"gain"
                                              name:@"Gain"
                                           address:gainAddress
                                               min:0
                                               max:1000000.0
                                              unit:kAudioUnitParameterUnit_Generic
                                          unitName:nil
                                             flags:0
                                      valueStrings:nil
                               dependentParameters:nil];

    // Initialize the parameter values.
    gainAUParameter.value = 1.0;

    _kernel.setParameter(gainAddress,  gainAUParameter.value);

    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[
        gainAUParameter
    ]];

    // Create the input and output busses.
    _inputBus.init(defaultFormat, 8);
    _outputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];

    // Create the input and output bus arrays.
    _inputBusArray  = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeInput
                                                              busses: @[_inputBus.bus]];
    _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                             busType:AUAudioUnitBusTypeOutput
                                                              busses: @[_outputBus]];

    self.maximumFramesToRender = 512;

    return self;
}

#pragma mark - AUAudioUnit Overrides

- (AUAudioUnitBusArray *)inputBusses {
    return _inputBusArray;
}

- (AUAudioUnitBusArray *)outputBusses {
    return _outputBusArray;
}

- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) {
        return NO;
    }

    if (self.outputBus.format.channelCount != _inputBus.bus.format.channelCount) {
        if (outError) {
            *outError = [NSError errorWithDomain:NSOSStatusErrorDomain
                                            code:kAudioUnitErr_FailedInitialization
                                        userInfo:nil];
        }
        // Notify superclass that initialization was not successful
        self.renderResourcesAllocated = NO;

        return NO;
    }

    _inputBus.allocateRenderResources(self.maximumFramesToRender);

    _kernel.init(self.outputBus.format.channelCount, self.outputBus.format.sampleRate);
    _kernel.reset();

    /*
     While rendering, we want to schedule all parameter changes. Setting them
     off the render thread is not thread safe.
     */
    __block AUScheduleParameterBlock scheduleParameter = self.scheduleParameterBlock;

    // Ramp over 20 milliseconds.
    __block AUAudioFrameCount rampTime = AUAudioFrameCount(0.02 * self.outputBus.format.sampleRate);

    self.parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        scheduleParameter(AUEventSampleTimeImmediate, rampTime, param.address, value);
    };

    return YES;
}

- (void)deallocateRenderResources {
    [super deallocateRenderResources];
    _inputBus.deallocateRenderResources();
}

- (AUInternalRenderBlock)internalRenderBlock {
    /*
     Capture in locals to avoid ObjC member lookups. If "self" is captured in
     render, we're doing it wrong.
     */
    __block AKBoosterDSPKernel *state = &_kernel;
    __block BufferedInputBus *input = &_inputBus;

    return ^AUAudioUnitStatus(
                              AudioUnitRenderActionFlags *actionFlags,
                              const AudioTimeStamp       *timestamp,
                              AVAudioFrameCount           frameCount,
                              NSInteger                   outputBusNumber,
                              AudioBufferList            *outputData,
                              const AURenderEvent        *realtimeEventListHead,
                              AURenderPullInputBlock      pullInputBlock) {
        AudioUnitRenderActionFlags pullFlags = 0;

        AUAudioUnitStatus err = input->pullInput(&pullFlags, timestamp, frameCount, 0, pullInputBlock);

        if (err != 0) {
            return err;
        }

        AudioBufferList *inAudioBufferList = input->mutableAudioBufferList;

        /*
         If the caller passed non-nil output pointers, use those. Otherwise,
         process in-place in the input buffer. If your algorithm cannot process
         in-place, then you will need to preallocate an output buffer and use
         it here.
         */
        AudioBufferList *outAudioBufferList = outputData;
        if (outAudioBufferList->mBuffers[0].mData == nullptr) {
            for (UInt32 i = 0; i < outAudioBufferList->mNumberBuffers; ++i) {
                outAudioBufferList->mBuffers[i].mData = inAudioBufferList->mBuffers[i].mData;
            }
        }

        state->setBuffers(inAudioBufferList, outAudioBufferList);
        state->processWithEvents(timestamp, frameCount, realtimeEventListHead);

        return noErr;
    };
}


@end


