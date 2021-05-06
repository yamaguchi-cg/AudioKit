// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AVFoundation
import CAudioKit

/// A 2nd order tunable equalization filter that provides a
/// peak/notch filter for building parametric/graphic equalizers.
/// With gain above 1, there will be a peak at the center frequency
/// with a width dependent on bandwidth. If gain is less than 1, a notch is
/// formed around the center frequency.
/// 
public class EqualizerFilter: Node, AudioUnitContainer, Toggleable {

    /// Unique four-letter identifier "eqfl"
    public static let ComponentDescription = AudioComponentDescription(effect: "eqfl")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = AudioUnitBase

    /// Internal audio unit 
    public private(set) var internalAU: AudioUnitType?

    // MARK: - Parameters

    /// Specification details for centerFrequency
    public static let centerFrequencyDef = NodeParameterDef(
        identifier: "centerFrequency",
        name: "Center Frequency (Hz)",
        address: akGetParameterAddress("EqualizerFilterParameterCenterFrequency"),
        range: 12.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// Center frequency. (in Hertz)
    @Parameter2(centerFrequencyDef) public var centerFrequency: AUValue

    /// Specification details for bandwidth
    public static let bandwidthDef = NodeParameterDef(
        identifier: "bandwidth",
        name: "Bandwidth (Hz)",
        address: akGetParameterAddress("EqualizerFilterParameterBandwidth"),
        range: 0.0 ... 20_000.0,
        unit: .hertz,
        flags: .default)

    /// The peak/notch bandwidth in Hertz
    @Parameter2(bandwidthDef) public var bandwidth: AUValue

    /// Specification details for gain
    public static let gainDef = NodeParameterDef(
        identifier: "gain",
        name: "Gain (%)",
        address: akGetParameterAddress("EqualizerFilterParameterGain"),
        range: -100.0 ... 100.0,
        unit: .percent,
        flags: .default)

    /// The peak/notch gain
    @Parameter2(gainDef) public var gain: AUValue

    // MARK: - Initialization

    /// Initialize this filter node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - centerFrequency: Center frequency. (in Hertz)
    ///   - bandwidth: The peak/notch bandwidth in Hertz
    ///   - gain: The peak/notch gain
    ///
    public init(
        _ input: Node,
        centerFrequency: AUValue = 1_000.0,
        bandwidth: AUValue = 100.0,
        gain: AUValue = 10.0
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit2 { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            guard let audioUnit = avAudioUnit.auAudioUnit as? AudioUnitType else {
                fatalError("Couldn't create audio unit")
            }
            self.internalAU = audioUnit

            self.centerFrequency = centerFrequency
            self.bandwidth = bandwidth
            self.gain = gain
        }
        connections.append(input)
    }
}
