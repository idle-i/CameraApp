//
//  BottomView.swift
//  CameraApp
//
//  Created by Daniil Shchepkin on 30.01.2023.
//

import UIKit

protocol BottomViewDelegate {
    func captureButtonTapped()
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
    
    // MARK: - Public Methods
    
    func setLastCapturedImage(_ image: UIImage) {
        lastCapturedImage.image = image
    }
    
    // MARK: - Callbacks
    
    @objc private func didTapCaptureButton() {
        delegate?.captureButtonTapped()
    }
}

// MARK: - BaseView Implementation

extension BottomView: BaseView {
    
    func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        addSubview(captureButton)
        addSubview(lastCapturedImage)
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
            lastCapturedImage.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 32)
        ])
    }
}
