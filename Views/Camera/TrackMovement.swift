//import AVFoundation
//import UIKit
//import Vision
//
//@MainActor
//class LiveFeedViewController: UIViewController {
//
//    private let captureSession = AVCaptureSession()
//    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//    private let videoDataOutput = AVCaptureVideoDataOutput()
//
//    private let faceLayer = CAShapeLayer()
//    private let eyesLayer = CAShapeLayer()
//    private var detectionOverlayLayer: CALayer?
//    
//    private var captureDeviceResolution: CGSize = CGSize()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupCamera()
//        setupLayers()
//        captureSession.startRunning()
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        previewLayer.frame = view.bounds
//        updateLayerGeometry()
//    }
//
//    private func setupCamera() {
//        let discovery = AVCaptureDevice.DiscoverySession(
//            deviceTypes: [.builtInWideAngleCamera],
//            mediaType: .video,
//            position: .front
//        )
//        guard let device = discovery.devices.first,
//              let input = try? AVCaptureDeviceInput(device: device),
//              captureSession.canAddInput(input) else { return }
//
//        captureSession.addInput(input)
//        
//        // Get the highest resolution format
//        if let highestResolution = highestResolution420Format(for: device) {
//            try? device.lockForConfiguration()
//            device.activeFormat = highestResolution.format
//            device.unlockForConfiguration()
//            captureDeviceResolution = highestResolution.resolution
//        }
//        
//        setupPreview()
//    }
//    
//    private func highestResolution420Format(for device: AVCaptureDevice) -> (format: AVCaptureDevice.Format, resolution: CGSize)? {
//        var highestResolutionFormat: AVCaptureDevice.Format? = nil
//        var highestResolutionDimensions = CMVideoDimensions(width: 0, height: 0)
//        
//        for format in device.formats {
//            let deviceFormat = format as AVCaptureDevice.Format
//            let deviceFormatDescription = deviceFormat.formatDescription
//            
//            if CMFormatDescriptionGetMediaSubType(deviceFormatDescription) == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange {
//                let candidateDimensions = CMVideoFormatDescriptionGetDimensions(deviceFormatDescription)
//                if (highestResolutionFormat == nil) || (candidateDimensions.width > highestResolutionDimensions.width) {
//                    highestResolutionFormat = deviceFormat
//                    highestResolutionDimensions = candidateDimensions
//                }
//            }
//        }
//        
//        if highestResolutionFormat != nil {
//            let resolution = CGSize(width: CGFloat(highestResolutionDimensions.width), height: CGFloat(highestResolutionDimensions.height))
//            return (highestResolutionFormat!, resolution)
//        }
//        
//        return nil
//    }
//
//    private func setupPreview() {
//        previewLayer.videoGravity = .resizeAspectFill
//        view.layer.addSublayer(previewLayer)
//        previewLayer.frame = view.bounds
//
//        videoDataOutput.videoSettings = [
//            (kCVPixelBufferPixelFormatTypeKey as NSString): NSNumber(value: kCVPixelFormatType_32BGRA)
//        ] as [String: Any]
//
//        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera.queue"))
//        captureSession.addOutput(videoDataOutput)
//
//        if let conn = videoDataOutput.connection(with: .video) {
//            conn.videoOrientation = .portrait
//            conn.isVideoMirrored = true
//        }
//    }
//
//    private func setupLayers() {
//        let captureDeviceBounds = CGRect(x: 0,
//                                         y: 0,
//                                         width: captureDeviceResolution.width,
//                                         height: captureDeviceResolution.height)
//        
//        let captureDeviceBoundsCenterPoint = CGPoint(x: captureDeviceBounds.midX,
//                                                     y: captureDeviceBounds.midY)
//        
//        let normalizedCenterPoint = CGPoint(x: 0.5, y: 0.5)
//        
//        let overlayLayer = CALayer()
//        overlayLayer.name = "DetectionOverlay"
//        overlayLayer.masksToBounds = true
//        overlayLayer.anchorPoint = normalizedCenterPoint
//        overlayLayer.bounds = captureDeviceBounds
//        overlayLayer.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
//        
//        faceLayer.name = "RectangleOutlineLayer"
//        faceLayer.bounds = captureDeviceBounds
//        faceLayer.anchorPoint = normalizedCenterPoint
//        faceLayer.position = captureDeviceBoundsCenterPoint
//        faceLayer.fillColor = nil
//        faceLayer.strokeColor = UIColor.green.withAlphaComponent(0.7).cgColor
//        faceLayer.lineWidth = 5
//        faceLayer.shadowOpacity = 0.7
//        faceLayer.shadowRadius = 5
//        
//        eyesLayer.name = "FaceLandmarksLayer"
//        eyesLayer.bounds = captureDeviceBounds
//        eyesLayer.anchorPoint = normalizedCenterPoint
//        eyesLayer.position = captureDeviceBoundsCenterPoint
//        eyesLayer.fillColor = nil
//        eyesLayer.strokeColor = UIColor.yellow.withAlphaComponent(0.7).cgColor
//        eyesLayer.lineWidth = 3
//        eyesLayer.shadowOpacity = 0.7
//        eyesLayer.shadowRadius = 5
//        
//        overlayLayer.addSublayer(faceLayer)
//        faceLayer.addSublayer(eyesLayer)
//        view.layer.addSublayer(overlayLayer)
//        
//        self.detectionOverlayLayer = overlayLayer
//        
//        updateLayerGeometry()
//    }
//    
//    private func updateLayerGeometry() {
//        guard let overlayLayer = self.detectionOverlayLayer else { return }
//        
//        CATransaction.setValue(NSNumber(value: true), forKey: kCATransactionDisableActions)
//        
//        let videoPreviewRect = previewLayer.layerRectConverted(fromMetadataOutputRect: CGRect(x: 0, y: 0, width: 1, height: 1))
//        
//        let rotation: CGFloat = 0
//        let scaleX = videoPreviewRect.width / captureDeviceResolution.width
//        let scaleY = videoPreviewRect.height / captureDeviceResolution.height
//        
//        // Scale and mirror the image to ensure upright presentation
//        // Negative scaleX to mirror horizontally for front camera
//        let affineTransform = CGAffineTransform(rotationAngle: 0)
//            .scaledBy(x: -scaleX, y: -scaleY)
//        overlayLayer.setAffineTransform(affineTransform)
//        
//        // Cover entire screen UI
//        overlayLayer.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
//    }
//
//    private func addIndicators(to faceRectanglePath: CGMutablePath, faceLandmarksPath: CGMutablePath, for observationData: ObservationData) {
//        let displaySize = self.captureDeviceResolution
//        
//        // Use Apple's conversion - let them handle the coordinate system
//        let faceBounds = VNImageRectForNormalizedRect(observationData.boundingBox, Int(displaySize.width), Int(displaySize.height))
//        faceRectanglePath.addRect(faceBounds)
//        
//        // Landmarks are relative to -- and normalized within -- face bounds
//        let affineTransform = CGAffineTransform(translationX: faceBounds.origin.x, y: faceBounds.origin.y)
//            .scaledBy(x: faceBounds.size.width, y: faceBounds.size.height)
//        
//        // Helper to draw points as closed region
//        func drawPoints(_ points: [CGPoint]?) {
//            guard let points = points, !points.isEmpty else { return }
//            faceLandmarksPath.move(to: points[0], transform: affineTransform)
//            faceLandmarksPath.addLines(between: points, transform: affineTransform)
//            faceLandmarksPath.addLine(to: points[0], transform: affineTransform)
//            faceLandmarksPath.closeSubpath()
//        }
//        
//        // Draw eyes, lips, and nose as closed regions
//        drawPoints(observationData.leftEye)
//        drawPoints(observationData.rightEye)
//        drawPoints(observationData.outerLips)
//        drawPoints(observationData.innerLips)
//        drawPoints(observationData.nose)
//    }
//    
//    @MainActor
//    private func drawFaceObservations(_ observationDataArray: [ObservationData]) {
//        CATransaction.begin()
//        CATransaction.setValue(NSNumber(value: true), forKey: kCATransactionDisableActions)
//        
//        let faceRectanglePath = CGMutablePath()
//        let faceLandmarksPath = CGMutablePath()
//        
//        for observationData in observationDataArray {
//            self.addIndicators(to: faceRectanglePath,
//                               faceLandmarksPath: faceLandmarksPath,
//                               for: observationData)
//        }
//        
//        faceLayer.path = faceRectanglePath
//        eyesLayer.path = faceLandmarksPath
//        
//        self.updateLayerGeometry()
//        
//        CATransaction.commit()
//    }
//}
//
//extension LiveFeedViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
//    nonisolated func captureOutput(
//        _ output: AVCaptureOutput,
//        didOutput sampleBuffer: CMSampleBuffer,
//        from connection: AVCaptureConnection
//    ) {
//        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//
//        let request = VNDetectFaceLandmarksRequest { [weak self] req, _ in
//            guard let self = self,
//                  let results = req.results as? [VNFaceObservation] else { return }
//
//            // Extract all needed data before crossing actor boundary
//            let observationData = results.map { obs -> ObservationData in
//                let boundingBox = obs.boundingBox
//                let leftEye = obs.landmarks?.leftEye?.normalizedPoints
//                let rightEye = obs.landmarks?.rightEye?.normalizedPoints
//                let outerLips = obs.landmarks?.outerLips?.normalizedPoints
//                let innerLips = obs.landmarks?.innerLips?.normalizedPoints
//                let nose = obs.landmarks?.nose?.normalizedPoints
//                
//                return ObservationData(
//                    boundingBox: boundingBox,
//                    leftEye: leftEye,
//                    rightEye: rightEye,
//                    outerLips: outerLips,
//                    innerLips: innerLips,
//                    nose: nose
//                )
//            }
//            
//            Task { @MainActor in
//                self.drawFaceObservations(observationData)
//            }
//        }
//
//        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: .upMirrored, options: [:])
//        try? handler.perform([request])
//    }
//    
//    struct ObservationData {
//        let boundingBox: CGRect
//        let leftEye: [CGPoint]?
//        let rightEye: [CGPoint]?
//        let outerLips: [CGPoint]?
//        let innerLips: [CGPoint]?
//        let nose: [CGPoint]?
//    }
//}
