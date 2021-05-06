// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/
// This file was auto-autogenerated by scripts and templates at http://github.com/AudioKit/AudioKitDevTools/

import AVFoundation
import CAudioKit

/// Clips a signal to a predefined limit, in a "soft" manner, using one of three methods.
public class Clipper: Node, AudioUnitContainer, Toggleable {

    /// Unique four-letter identifier "clip"
    public static let ComponentDescription = AudioComponentDescription(effect: "clip")

    /// Internal type of audio unit for this node
    public typealias AudioUnitType = AudioUnitBase

    /// Internal audio unit 
    public private(set) var internalAU: AudioUnitType?

    // MARK: - Parameters

    /// Specification details for limit
    public static let limitDef = NodeParameterDef(
        identifier: "limit",
        name: "Threshold",
        address: akGetParameterAddress("ClipperParameterLimit"),
        range: 0.0 ... 1.0,
        unit: .generic,
        flags: .default)

    /// Threshold / limiting value.
    @Parameter2(limitDef) public var limit: AUValue

    // MARK: - Initialization

    /// Initialize this clipper node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - limit: Threshold / limiting value.
    ///
    public init(
        _ input: Node,
        limit: AUValue = 1.0
        ) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit2 { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit

            guard let audioUnit = avAudioUnit.auAudioUnit as? AudioUnitType else {
                fatalError("Couldn't create audio unit")
            }
            self.internalAU = audioUnit

            self.limit = limit
        }
        connections.append(input)
    }
}
