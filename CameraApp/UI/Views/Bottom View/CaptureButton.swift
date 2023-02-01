//
//  CaptureButton.swift
//  CameraApp
//
//  Created by Daniil Shchepkin on 30.01.2023.
//

import UIKit

fileprivate struct Constants {
    static let borderWidth: CGFloat = 3
    
    static let circleDefaultInset: CGFloat = 12
    static let circleScale: CGFloat = 8
    static let circleScaleDuration: Double = 0.2
}

final class CaptureButton: UIButton {
    
    // MARK: - Overrides
    
    override var isHighlighted: Bool {
        didSet {
            self.circleScaleAnimation()
        }
    }
    
    // MARK: - Private variables
    
    private var circleWidthConstraint: NSLayoutConstraint?
    private var circleHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Views
    
    private lazy var circleView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.isUserInteractionEnabled = false
        
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
        
        // Making views circle
        layer.cornerRadius = max(frame.width, frame.height) / 2
        circleView.layer.cornerRadius = max(circleView.frame.width, circleView.frame.height) / 2
    }
    
    // MARK: - Private Methods
    
    private func circleScaleAnimation() {
        let constant = isHighlighted ? -Constants.circleDefaultInset-Constants.circleScale : -Constants.circleDefaultInset
        circleWidthConstraint?.constant = constant
        circleHeightConstraint?.constant = constant
        
        UIView.animate(withDuration: Constants.circleScaleDuration) { [weak self] in
            guard let self = self else { return }
            
            self.layoutIfNeeded()
        }
    }
}

extension CaptureButton: BaseView {
    
    func setupView() {
        backgroundColor = UIColor.clear
        
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = UIColor.white.cgColor
        
        addSubview(circleView)
    }
    
    func setupConstraints() {
        circleWidthConstraint = circleView.widthAnchor.constraint(equalTo: widthAnchor, constant: -Constants.circleDefaultInset)
        circleHeightConstraint = circleView.heightAnchor.constraint(equalTo: heightAnchor, constant: -Constants.circleDefaultInset)
        
        NSLayoutConstraint.activate([
            circleWidthConstraint!,
            circleHeightConstraint!,
            circleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
