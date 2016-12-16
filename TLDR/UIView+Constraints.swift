//
//  UIView+Constraints.swift
//  TLDR
//
//  Created by Suraj Pathak on 16/12/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import UIKit

extension UIView {
    
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
    }
    
    func pinXY(_ subviews: [UIView], gap: CGFloat = 0) {
        pinX(subviews, gap: gap)
        pinY(subviews, gap: gap)
    }
    
    func pinX(_ subviews: [UIView], gap: CGFloat = 0) {
        subviews.forEach {
            $0.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: gap).isActive = true
            $0.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -gap).isActive = true
        }
    }
    
    func pinY(_ subviews: [UIView], gap: CGFloat = 0) {
        subviews.forEach {
            $0.topAnchor.constraint(equalTo: self.topAnchor, constant: gap).isActive = true
            $0.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -gap).isActive = true
        }
    }
    
    func pinCenterX(_ subviews: [UIView], gap: CGFloat = 0) {
        subviews.forEach {
            $0.pinCenterX(to: self)
        }
    }
    
    func pinCenterY(_ subviews: [UIView], gap: CGFloat = 0) {
        subviews.forEach {
            $0.pinCenterY(to: self)
        }
    }
    
    func pinBelow(_ view: UIView, gap: CGFloat = 0) {
        topAnchor.constraint(equalTo: view.bottomAnchor, constant: gap).isActive = true
    }
    
    func pinAbove(_ view: UIView, gap: CGFloat = 0) {
        bottomAnchor.constraint(equalTo: view.topAnchor, constant: gap).isActive = true
    }
    
    func pinToRight(of view: UIView, gap: CGFloat = 0) {
        leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: gap).isActive = true
    }
    
    func pinToLeft(of view: UIView, gap: CGFloat = 0) {
        trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: gap).isActive = true
    }
    
    func pinTrailing(to view: UIView, leading: Bool, gap: CGFloat = 0) {
        if leading {
            self.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: gap).isActive = true
        } else {
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: gap).isActive = true
        }
    }
    
    func pinLeading(to view: UIView, leading: Bool, gap: CGFloat = 0) {
        if leading {
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: gap).isActive = true
        } else {
            self.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: gap).isActive = true
        }
    }
    
    
    func pinBottom(to view: UIView, top: Bool, gap: CGFloat = 0) {
        if top {
            self.bottomAnchor.constraint(equalTo: view.topAnchor, constant: gap).isActive = true
        } else {
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: gap).isActive = true
        }
    }
    
    func pinTop(to view: UIView, top: Bool, gap: CGFloat = 0) {
        if top {
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: gap).isActive = true
        } else {
            self.topAnchor.constraint(equalTo: view.bottomAnchor, constant: gap).isActive = true
        }
    }
    
    func pinCenterX(to view: UIView, gap: CGFloat = 0) {
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: gap).isActive = true
    }
    
    func pinCenterY(to view: UIView, gap: CGFloat = 0) {
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: gap).isActive = true
    }
    
    func setHeight(_ height: CGFloat) {
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setWidth(_ width: CGFloat) {
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
}
