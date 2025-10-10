//
//  LottieView.swift
//  BirdId
//
//  Created by ali bakhsha on 7/17/1404 AP.
//

import Foundation
import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var animationName: String
    var loopMode: LottieLoopMode = .loop
    var animationSpeed: CGFloat = 1.0
    var contentMode: UIView.ContentMode = .scaleAspectFit

    let animationView = LottieAnimationView()

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        animationView.animation = LottieAnimation.named(animationName, bundle: .main)
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        animationView.contentMode = contentMode
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Can handle updates here if needed
    }
}

