//
//  TabBarCollectionCell.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class TabBarCollectionCell: UICollectionViewCell {
    
    // MARK: - Properties
    static let selectedColor: UIColor = .notifireMainColor
    static let deselectedColor: UIColor = .backgroundColor
    // MARK: Model
    // a viewmodel is omitted because the model is sufficient
    var model: Tab? {
        didSet {
            updateAppearance()
        }
    }
    
    // MARK: Views
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = TabBarCollectionCell.deselectedColor
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    // MARK: - Inherited
    override var isSelected: Bool {
        didSet {
            guard oldValue != isSelected else { return }
            UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                self.backgroundColor = self.isSelected ? TabBarCollectionCell.selectedColor : TabBarCollectionCell.deselectedColor
            }, completion: nil)
        }
    }
    
    // MARK: - Private
    private func layout() {
        contentView.add(subview: label)
        label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    private func updateAppearance() {
        guard let model = model else { return }
        switch model {
        case .notifications:
            label.text = "Notifications"
        case .services:
            label.text = "Services"
        case .settings:
            label.text = "Settings"
        }
    }
}
