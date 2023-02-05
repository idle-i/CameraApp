//
//  BottomView.swift
//  CameraApp
//
//  Created by Daniil Shchepkin on 30.01.2023.
//

import UIKit

protocol BottomViewDelegate {
    func captureButtonTapped()
    func lastCapturedImageTapped()
    func switchCameraButtonTapped()
}

final class BottomView: UIView {
    
    // MARK: - Public Properties
    
    var delegate: BottomViewDelegate?
    
    // MARK: - Views
    
    private lazy var captureButton: CaptureButton = {
        let view = CaptureButton()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(didTapCaptureButton), for: .touchUpInside)
        
        return view
    }()
    
    private lazy var lastCapturedImage: UIImageView = {
        let view = UIImageView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        view.contentMode = .scaleAspectFill
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapLastCapturedImage)))
        
        return view
    }()
    
    private lazy var lastCapturedImageLoading: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        
        view.color = UIColor.gray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.startAnimating()
        view.isHidden = true
        
        return view
    }()
    
    private lazy var switchCameraButton: UIButton = {
        let view = UIButton()
        
        let image = UIImage(systemName: "camera.rotate")
        view.setImage(image, for: .normal)
        
        view.tintColor = UIColor.white
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        view.addTarget(self, action: #selector(didTapSwitchCameraButton), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupView()
        setupConstraints()
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Making switch camera button circle
        let switchCameraButtonSize = switchCameraButton.frame.size
        switchCameraButton.layer.cornerRadius = max(switchCameraButtonSize.width, switchCameraButtonSize.height) / 2
    }
    
    // MARK: - Public Methods
    
    func setLastCapturedImage(_ image: UIImage) {
        lastCapturedImage.image = image
    }
    
    func setCapturingPhotoState(_ state: Bool) {
        lastCapturedImageLoading.isHidden = !state
        
        captureButton.isUserInteractionEnabled = !state
    }
    
    func setSwitchCameraButtonEnabled(_ enabled: Bool) {
        switchCameraButton.isEnabled = enabled
    }
    
    // MARK: - Callbacks
    
    @objc private func didTapCaptureButton() {
        delegate?.captureButtonTapped()
    }
    
    @objc private func didTapLastCapturedImage() {
        delegate?.lastCapturedImageTapped()
    }
    
    @objc private func didTapSwitchCameraButton() {
        delegate?.switchCameraButtonTapped()
    }
}

// MARK: - BaseView Implementation

extension BottomView: BaseView {
    
    func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        addSubview(captureButton)
        
        addSubview(lastCapturedImage)
        lastCapturedImage.addSubview(lastCapturedImageLoading)
        
        addSubview(switchCameraButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            captureButton.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4),
            captureButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4),
            captureButton.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            captureButton.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            
            lastCapturedImage.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3),
            lastCapturedImage.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3),
            lastCapturedImage.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            lastCapturedImage.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 32),
            
            lastCapturedImageLoading.topAnchor.constraint(equalTo: lastCapturedImage.topAnchor),
            lastCapturedImageLoading.bottomAnchor.constraint(equalTo: lastCapturedImage.bottomAnchor),
            lastCapturedImageLoading.leadingAnchor.constraint(equalTo: lastCapturedImage.leadingAnchor),
            lastCapturedImageLoading.trailingAnchor.constraint(equalTo: lastCapturedImage.trailingAnchor),
            
            switchCameraButton.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3),
            switchCameraButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3),
            switchCameraButton.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            switchCameraButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -32)
        ])
    }
}
