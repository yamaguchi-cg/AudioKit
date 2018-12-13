//
//  AKStereoDelay.hpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#include "AdjustableDelayLine.hpp"

namespace AudioKitCore
{
    class AKStereoDelay {
        double sampleRateHz;
        float feedbackFraction;
        float effectLevelFraction;
        bool pingPongMode;

        AdjustableDelayLine delayLine1, delayLine2;
        
    public:
        AKStereoDelay() : feedbackFraction(0.0f), effectLevelFraction(0.5f), pingPongMode(false) {}
        ~AKStereoDelay() { deinit(); }
        
        void init(double sampleRate, double maxDelayMs);
        void deinit();
        
        void setPingPongMode(bool pingPong);
        void setDelayMs(double delayMs);
        void setEffectLevel(float fraction) { effectLevelFraction = fraction; }
        void setFeedback(float fraction);

        void render(int sampleCount, const float *inBuffers[], float *outBuffers[]);
    };
    
}
