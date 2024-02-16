/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Custom video compositor class implementing the AVVideoCompositing protocol.
 */

import Foundation
import AVFoundation
import CoreVideo

class APLCustomVideoCompositor: NSObject, AVVideoCompositing {
    
    /// The pixel buffer attributes of pixel buffers that will be vended by the adaptor’s CVPixelBufferPool.
    lazy var sourcePixelBufferAttributes: [String : Any]? = {
        var settings = [String: Any]()
        settings[kCVPixelBufferPixelFormatTypeKey as String] = NSNumber(integerLiteral: Int(kCVPixelFormatType_32BGRA))
        settings[kCVPixelBufferOpenGLESCompatibilityKey as String] = NSNumber(booleanLiteral: true)
        return settings
    }()
    
    /// Returns the pixel buffer attributes required by the video compositor for new buffers created for processing.
    lazy var requiredPixelBufferAttributesForRenderContext: [String : Any] = {
        var settings = [String: Any]()
        settings[kCVPixelBufferPixelFormatTypeKey as String] = NSNumber(integerLiteral: Int(kCVPixelFormatType_32BGRA))
        settings[kCVPixelBufferOpenGLESCompatibilityKey as String] = NSNumber(booleanLiteral: true)
        return settings
    }()
    
    /// Set if all pending requests have been cancelled.
    var shouldCancelAllRequests = false
    
    /// Dispatch Queue used to issue custom compositor rendering work requests.
    private var renderingQueue = DispatchQueue(label: "com.apple.aplcustomvideocompositor.renderingqueue")
    /// Dispatch Queue used to synchronize notifications that the composition will switch to a different render context.
    private var renderContextQueue = DispatchQueue(label: "com.apple.aplcustomvideocompositor.rendercontextqueue")
    
    /// The current render context within which the custom compositor will render new output pixels buffers.
    private var renderContext: AVVideoCompositionRenderContext?
    
    /// Maintain the state of render context changes.
    private var internalRenderContextDidChange = false
    /// Actual state of render context changes.
    private var renderContextDidChange: Bool {
        get {
            return renderContextQueue.sync { internalRenderContextDidChange }
        }
        set (newRenderContextDidChange) {
            renderContextQueue.sync { internalRenderContextDidChange = newRenderContextDidChange }
        }
    }
    
    override init() {
        
    }
    
    // MARK: AVVideoCompositing protocol functions
    
    func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {
        renderContextQueue.sync { renderContext = newRenderContext }
        renderContextDidChange = true
    }
    
    struct PixelBufferRequestError: Error {
        let failure: String
    }
    
    func startRequest(_ request: AVAsynchronousVideoCompositionRequest) {
        autoreleasepool {
            renderingQueue.async {
                // Check if all pending requests have been cancelled.
                if self.shouldCancelAllRequests {
                    request.finishCancelledRequest()
                } else {
                    guard let resultPixels =
                        self.newRenderedPixelBufferForRequest(request) else {
                            request.finish(with: PixelBufferRequestError(failure: "new pixels error"))
                            return
                    }
                    // The resulting pixelbuffer from Metal renderer is passed along to the request.
                    request.finish(withComposedVideoFrame: resultPixels)
                }
            }
        }
    }
    
    func cancelAllPendingVideoCompositionRequests() {
        
        /*
         Pending requests will call finishCancelledRequest, those already rendering will call
         finishWithComposedVideoFrame.
         */
        renderingQueue.sync { shouldCancelAllRequests = true }
        renderingQueue.async {
            // Start accepting requests again.
            self.shouldCancelAllRequests = false
        }
    }
    
    // MARK: Utilities
    
    func factorForTimeInRange( _ time: CMTime, range: CMTimeRange) -> Float64 { /* 0.0 -> 1.0 */
        
        let elapsed = CMTimeSubtract(time, range.start)
        
        return CMTimeGetSeconds(elapsed) / CMTimeGetSeconds(range.duration)
    }
    
    func newRenderedPixelBufferForRequest(_ request: AVAsynchronousVideoCompositionRequest) -> CVPixelBuffer? {
        guard let currentInstruction =
            request.videoCompositionInstruction as? APLCustomVideoCompositionInstruction else {
                return nil
        }
        // Source pixel buffers are used as inputs while rendering the transition.
        guard let foregroundSourceBuffer = request.sourceFrame(byTrackID: currentInstruction.foregroundTrackID) else {
            return nil
        }
        guard let backgroundSourceBuffer = request.sourceFrame(byTrackID: currentInstruction.backgroundTrackID) else {
            return nil
        }
        // Destination pixel buffer into which we render the output.
        guard let dstPixels = renderContext?.newPixelBuffer() else { return nil }
        
        if renderContextDidChange { renderContextDidChange = false }
        
        let tweenFactor =
            factorForTimeInRange(request.compositionTime, range: request.videoCompositionInstruction.timeRange)
        
        APLOpenGLRenderer.shared().renderPixelBuffer(destinationPixelBuffer: dstPixels, foregroundPixelBuffer: foregroundSourceBuffer, backgroundPixelBuffer: backgroundSourceBuffer, tweenFactor: Float(tweenFactor), transitionType: currentInstruction.transitionType)
        return dstPixels
    }
}

