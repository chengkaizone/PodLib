/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Custom video composition instruction class implementing AVVideoCompositionInstruction protocol.
 */

import AVFoundation
import Foundation
import CoreMedia

/**
 * 自定义过度指令集
 * 可用于定义转场参数
 */
class APLCustomVideoCompositionInstruction: NSObject, AVVideoCompositionInstructionProtocol {
    
    /// ID used by subclasses to identify the foreground frame.
    var foregroundTrackID: CMPersistentTrackID = kCMPersistentTrackID_Invalid
    /// ID used by subclasses to identify the background frame.
    var backgroundTrackID: CMPersistentTrackID = kCMPersistentTrackID_Invalid
    
    /// The timeRange during which instructions will be effective.
    var overrideTimeRange: CMTimeRange = CMTimeRange()
    /// Indicates whether post-processing should be skipped for the duration of the instruction.
    var overrideEnablePostProcessing = false
    
    /// Indicates whether to avoid some duplicate processing when rendering a frame from the same source and destinatin at different times.
    var overrideContainsTweening = false
    /// The track IDs required to compose frames for the instruction.
    var overrideRequiredSourceTrackIDs: [NSValue]?
    /// Track ID of the source frame when passthrough is in effect.
    var overridePassthroughTrackID: CMPersistentTrackID = 0
    
    var transitionType: TransitionType = .none
    var passthroughTrackID: CMPersistentTrackID {
        get {
            return self.overridePassthroughTrackID
        }
        set {
            self.overridePassthroughTrackID = newValue
        }
    }
    
    var requiredSourceTrackIDs: [NSValue]? {
        get {
            return self.overrideRequiredSourceTrackIDs
        }
        set {
            self.overrideRequiredSourceTrackIDs = newValue
        }
    }
    
    // Indicates the timeRange during which the instruction is effective.
    var timeRange: CMTimeRange {
        get {
            return self.overrideTimeRange
        }
        set(newTimeRange) {
            self.overrideTimeRange = newTimeRange
        }
    }
    
    // If NO, indicates that post-processing should be skipped for the duration of this instruction.
    var enablePostProcessing: Bool {
        get {
            return self.overrideEnablePostProcessing
        }
        set(newPostProcessing) {
            self.overrideEnablePostProcessing = newPostProcessing
        }
    }
    
    /*
     If YES, rendering a frame from the same source buffers and the same composition instruction at 2 different
     compositionTime may yield different output frames. If NO, 2 such compositions would yield the
     same frame. The media pipeline may me able to avoid some duplicate processing when containsTweening is NO.
     */
    var containsTweening: Bool {
        get {
            return self.overrideContainsTweening
        }
        set(newContainsTweening) {
            self.overrideContainsTweening = newContainsTweening
        }
    }
    
    init(passthroughTrackID: CMPersistentTrackID, forTimeRange timeRange: CMTimeRange, transitionType: TransitionType? = nil) {
        super.init()
        self.passthroughTrackID = passthroughTrackID
        self.timeRange = timeRange
        self.requiredSourceTrackIDs = [NSValue]()
        self.containsTweening = false
        self.enablePostProcessing = false
        if transitionType == nil {
            self.transitionType = .none
        } else {
            self.transitionType = transitionType!
        }
    }
    
    init(sourceTrackIDs: [NSValue], forTimeRange timeRange: CMTimeRange, transitionType: TransitionType? = nil) {
        super.init()
        self.requiredSourceTrackIDs = sourceTrackIDs
        self.timeRange = timeRange
        self.passthroughTrackID = kCMPersistentTrackID_Invalid
        self.containsTweening = true
        self.enablePostProcessing = true
        if transitionType == nil {
            self.transitionType = .none
        } else {
            self.transitionType = transitionType!
        }
    }
    
}
