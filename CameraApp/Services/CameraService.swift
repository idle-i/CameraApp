//
//  CameraService.swift
//  CameraApp
//
//  Created by Daniil Shchepkin on 01.02.2023.
//

import Foundation
import AVFoundation
import CoreImage
import UIKit

protocol CameraServiceDelegate {
    func previewLayerDidLoad()
    func didCapturePhoto(image: UIImage)
    func didChangeZoom()
}

fileprivate struct Constants {
    static let defaultZoom: CGFloat = 1.0
    static let zoomRange: ClosedRange<CGFloat> = 1...20
}

final class CameraService: NSObject {
    
    // MARK: - Public Properties
    
    var delegate: CameraServiceDelegate?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var displayZoom: String { "x\(Int(currentDevice?.videoZoomFactor.rounded() ?? currentZoom))" }
    
    // MARK: - Private Properties

    private var captureSession: AVCaptureSession!

    private var currentDevice: AVCaptureDevice? { captureFromBackCamera ? backCamera : frontCamera }

    private var backCamera: AVCaptureDevice?
    private var backInput: AVCaptureInput?
    
    private var frontCamera: AVCaptureDevice?
    private var frontInput: AVCaptureInput?
    
    private var videoOutput: AVCaptureVideoDataOutput?
    
    private var captureFromBackCamera: Bool = true
    private var shouldCaptureNextFrame: Bool = false
    
    private var currentZoom: CGFloat = Constants.defaultZoom {
        didSet { delegate?.didChangeZoom() }
    }
    
    private var cameraQueue = DispatchQueue(
        label: "com.idle-i.CameraApp.CameraService",
        qos: .userInitiated
    )
    
    // MARK: - Initializer
    
    override init() {
        super.init()
        
        cameraQueue.async {
            self.captureSession = AVCaptureSession()
            self.captureSession.beginConfiguration()
            
            if self.captureSession.canSetSessionPreset(.photo) {
                self.captureSession.sessionPreset = .photo
            }
            self.captureSession.automaticallyConfiguresCaptureDeviceForWideColor = true
            
            self.setupInputs()
            self.setupOutputs()
            
            self.captureSession.commitConfiguration()
            self.captureSession.startRunning()
            
            self.setupPreviewLayer()
        }
    }
    
    // MARK: - Public Methods
    
    func capturePicture() {
        shouldCaptureNextFrame = true
    }
    
    func switchCamera(_ completion: () -> Void) {
        cameraQueue.sync {
            captureSession.beginConfiguration()
            
            if let backInput = backInput, let frontInput = frontInput {
                captureSession.removeInput(captureFromBackCamera ? backInput : frontInput)
                captureSession.addInput(captureFromBackCamera ? frontInput : backInput)
            }
            
            captureFromBackCamera = !captureFromBackCamera
            
            videoOutput?.connections.forEach { $0.isVideoMirrored = !captureFromBackCamera }
            setVideoOutputOrientation(.portrait)
            
            currentZoom = Constants.defaultZoom
            
            captureSession.commitConfiguration()
            
            completion()
        }
    }
    
    func setZoom(_ zoom: CGFloat, isFirstState: Bool) {
        if isFirstState {
            currentZoom = currentDevice?.videoZoomFactor ?? currentZoom
        } else {
            let newZoom = currentZoom * zoom
            if Constants.zoomRange.contains(newZoom) {
                do {
                    try currentDevice?.lockForConfiguration()
                    currentDevice?.videoZoomFactor = newZoom
                    currentDevice?.unlockForConfiguration()
                } catch {
                    debugPrint(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupInputs() {
        if let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            self.backCamera = backCamera
            
            do {
                backInput = try AVCaptureDeviceInput(device: backCamera)
                
                captureSession.addInput(backInput!)
            } catch {
                debugPrint(error.localizedDescription)
            }
        } else {
            debugPrint("Error while creating back camera intance")
        }
        
        if let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            self.frontCamera = frontCamera
            
            do {
                frontInput = try AVCaptureDeviceInput(device: frontCamera)
            } catch {
                debugPrint(error.localizedDescription)
            }
        } else {
            debugPrint("Error while creating front camera intance")
        }
    }
    
    private func setupOutputs() {
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput?.setSampleBufferDelegate(self, queue: cameraQueue)
        
        captureSession.addOutput(videoOutput!)
        
        setVideoOutputOrientation(.portrait)
    }
    
    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.previewLayerDidLoad()
        }
    }
    
    private func setVideoOutputOrientation(_ orientation: AVCaptureVideoOrientation) {
        videoOutput?.connections.forEach { $0.videoOrientation = .portrait }
    }
}

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard shouldCaptureNextFrame else { return }
        
        if let imageBuffer = sampleBuffer.imageBuffer {
            let image = UIImage(ciImage: CIImage(cvImageBuffer: imageBuffer))
            
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didCapturePhoto(image: image)
            }
        }
        
        shouldCaptureNextFrame = false
    }
}
