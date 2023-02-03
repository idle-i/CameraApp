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
}

final class CameraService: NSObject {
    
    // MARK: - Public Properties
    
    var delegate: CameraServiceDelegate?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - Private Properties

    private var captureSession: AVCaptureSession!
    
    private var backCamera: AVCaptureDevice?
    private var backInput: AVCaptureInput?
    
    private var frontCamera: AVCaptureDevice?
    private var frontInput: AVCaptureInput?
    
    private var videoOutput: AVCaptureVideoDataOutput?
    
    private var captureFromBackCamera: Bool = true
    private var shouldCaptureNextFrame: Bool = false
    
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
            
            captureSession.commitConfiguration()
            
            completion()
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
