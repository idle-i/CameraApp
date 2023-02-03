//
//  ViewController.swift
//  CameraApp
//
//  Created by Daniil Shchepkin on 30.01.2023.
//

import UIKit

fileprivate struct Constants {
    static let vibrationType: UIImpactFeedbackGenerator.FeedbackStyle = .medium
}

final class CameraViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let cameraService = CameraService()
    
    private var lastCapturedImage: UIImage?
    
    // MARK: - Views
    
    private lazy var bottomView: BottomView = {
        let view = BottomView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        
        return view
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraints()
        
        cameraService.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cameraService.previewLayer?.frame = view.layer.frame
    }
    
    // MARK: - Private Methods
    
    private func setupPreview() {
        if let previewLayer = cameraService.previewLayer {
            view.layer.insertSublayer(previewLayer, below: bottomView.layer)
            
            view.setNeedsLayout()
        }
    }
    
    private func generateVibration() {
        let generator = UIImpactFeedbackGenerator(style: Constants.vibrationType)
        generator.prepare()
        generator.impactOccurred()
    }
}

extension CameraViewController {
    
    func setupView() {
        view.addSubview(bottomView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            bottomView.heightAnchor.constraint(equalToConstant: 160),
            bottomView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension CameraViewController: BottomViewDelegate {
    
    func captureButtonTapped() {
        bottomView.setCapturingPhotoState(true)
        
        generateVibration()
        
        cameraService.capturePicture()
    }
    
    func lastCapturedImageTapped() {
        let controller = BrowsingViewController()
        
        if let lastCapturedImage = self.lastCapturedImage {
            controller.setImage(lastCapturedImage)
        }

        present(controller, animated: true)
    }
    
    func switchCameraButtonTapped() {
        bottomView.setSwitchCameraButtonEnabled(false)
        
        cameraService.switchCamera {
            bottomView.setSwitchCameraButtonEnabled(true)
        }
    }
}

extension CameraViewController: CameraServiceDelegate {
    
    func previewLayerDidLoad() {
        setupPreview()
    }
    
    func didCapturePhoto(image: UIImage) {
        lastCapturedImage = image
        
        bottomView.setLastCapturedImage(image)
        bottomView.setCapturingPhotoState(false)
    }
}
