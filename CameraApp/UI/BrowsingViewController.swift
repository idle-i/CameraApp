//
//  BrowsingViewController.swift
//  CameraApp
//
//  Created by Daniil Shchepkin on 01.02.2023.
//

import UIKit

final class BrowsingViewController: UIViewController {
    
    // MARK: - Views
    
    private lazy var photoImage: UIImageView = {
        let view = UIImageView()
        
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraints()
    }
    
    // MARK: - Public Methods
    
    func setImage(_ image: UIImage) {
        photoImage.image = image
    }
}

extension BrowsingViewController {
    
    func setupView() {
        view.backgroundColor = UIColor.black
        
        view.addSubview(photoImage)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            photoImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoImage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            photoImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            photoImage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}
