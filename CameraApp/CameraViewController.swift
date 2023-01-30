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
        
        view.backgroundColor = .white
        view.addSubview(bottomView)
        
        NSLayoutConstraint.activate([
            bottomView.heightAnchor.constraint(equalToConstant: 160),
            bottomView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Private Methods
    
    private func generateVibration() {
        let generator = UIImpactFeedbackGenerator(style: Constants.vibrationType)
        generator.prepare()
        generator.impactOccurred()
    }
}

extension CameraViewController: BottomViewDelegate {
    
    func captureButtonTapped() {
        generateVibration()
    }
}
