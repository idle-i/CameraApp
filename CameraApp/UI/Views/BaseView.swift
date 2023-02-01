//
//  BaseView.swift
//  CameraApp
//
//  Created by Daniil Shchepkin on 30.01.2023.
//

import UIKit

protocol BaseView: UIView {
    func setupView()
    func setupConstraints()
}

extension BaseView {
    func setupView() {}
    func setupConstraints() {}
}
