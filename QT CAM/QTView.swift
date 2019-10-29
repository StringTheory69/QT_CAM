//
//  QTView.swift
//  QT CAM
//
//  Created by jason smellz on 10/27/19.
//  Copyright © 2019 jacob. All rights reserved.
//

import UIKit
import MediaPlayer

class QTView: UIView {
    
    var changeModeBorderColor: CGColor = UIColor.clear.cgColor
    var popUpBorderColor: CGColor = UIColor.clear.cgColor

    // UI
    var previewView: UIImageView = {
        let previewView = UIImageView()
        previewView.translatesAutoresizingMaskIntoConstraints = false
        return previewView
    }()
    
    var tutorialView: UIImageView = {
        let tutorialView = UIImageView()
        tutorialView.isHidden = true
        tutorialView.translatesAutoresizingMaskIntoConstraints = false
        return tutorialView
    }()
    
    var cameraImageView: UIImageView = {
        let cameraImageView = UIImageView()
        cameraImageView.image = #imageLiteral(resourceName: "FullSizeRenderMask")
        cameraImageView.translatesAutoresizingMaskIntoConstraints = false
        return cameraImageView
    }()
    
    var blackView: UIImageView = {
        let blackView = UIImageView()
        blackView.alpha = 1
        blackView.isHidden = true
        blackView.backgroundColor = .black
        blackView.translatesAutoresizingMaskIntoConstraints = false
        return blackView
    }()
    
    var leftLabel: UILabel = {
        let leftLabel = UILabel()
        leftLabel.textColor = .white
        leftLabel.font = UIFont(name: "Old-School-Adventures", size: 12)
        leftLabel.backgroundColor = .clear
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        return leftLabel
    }()
    
    var rightLabel: UILabel = {
        let rightLabel = UILabel()
        rightLabel.font = UIFont(name: "Old-School-Adventures", size: 12)
        rightLabel.textColor = .white
        rightLabel.backgroundColor = .clear
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        return rightLabel
    }()
    
    var changeModeButton: UIButton = {
        let changeModeButton = UIButton()
        changeModeButton.backgroundColor = .clear
        changeModeButton.translatesAutoresizingMaskIntoConstraints = false
        return changeModeButton
    }()
    
    var popUpButton: UIButton = {
        let popUpButton = UIButton()
        popUpButton.backgroundColor = .clear
        popUpButton.translatesAutoresizingMaskIntoConstraints = false
        return popUpButton
    }()
    
    lazy var attributes: [NSAttributedString.Key: Any] = {
        let font = UIFont(name: "Old-School-Adventures", size: 12)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white,
        ]
        return attributes
    }()
    
    lazy var saveButton: UIButton = {
        let saveButton = UIButton()
        saveButton.isHidden = true
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .clear
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        return saveButton
    }()
    
    lazy var deleteButton: UIButton = {
        let deleteButton = UIButton()
        deleteButton.isHidden = true
        deleteButton.backgroundColor = .clear
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        return deleteButton
    }()

    lazy var topConstraint:
        NSLayoutConstraint = {
            return blackView.topAnchor.constraint(equalTo: previewView.topAnchor, constant: 0)
    }()
    
    lazy var changeButtonTrailingConstraint:
           NSLayoutConstraint = {
               return changeModeButton.trailingAnchor.constraint(equalTo: cameraImageView.trailingAnchor, constant: 0)
    }()
    
    lazy var popUpButtonTrailingConstraint:
           NSLayoutConstraint = {
               return popUpButton.trailingAnchor.constraint(equalTo: cameraImageView.trailingAnchor, constant: 0)
    }()
    
    lazy var popUpButtonTopConstraint:
           NSLayoutConstraint = {
               return popUpButton.topAnchor.constraint(equalTo: cameraImageView.topAnchor, constant: 0)
    }()
    
    lazy var volumeView: MPVolumeView = {
        return MPVolumeView(frame: CGRect(x: -CGFloat.greatestFiniteMagnitude, y: 0.0, width: 0.0, height: 0.0))
    }()
    
    lazy var tutorialImages: [UIImage] = [#imageLiteral(resourceName: "TutorialSlide_1"),#imageLiteral(resourceName: "TutorialSlide_2"),#imageLiteral(resourceName: "TutorialSlide_3"),#imageLiteral(resourceName: "TutorialSlide_4"),#imageLiteral(resourceName: "TutorialSlide_5"),#imageLiteral(resourceName: "TutorialSlide_6"),#imageLiteral(resourceName: "TutorialSlide_7"),#imageLiteral(resourceName: "TutorialSlide_8")]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    fileprivate func setupViews() {
        
        backgroundColor = .black
        addSubview(volumeView)
        insertSubview(previewView, belowSubview: cameraImageView)
        insertSubview(leftLabel, belowSubview: blackView)
        insertSubview(rightLabel, belowSubview: blackView)
        insertSubview(saveButton, belowSubview: blackView)
        insertSubview(deleteButton, belowSubview: blackView)
        insertSubview(blackView, belowSubview: cameraImageView)
        insertSubview(tutorialView, belowSubview: cameraImageView)
        addSubview(cameraImageView)
        addSubview(changeModeButton)
        addSubview(popUpButton)

        saveButton.setAttributedTitle(NSAttributedString(string: "Save", attributes: self.attributes), for: .normal)
        deleteButton.setAttributedTitle(NSAttributedString(string: "Delete", attributes: attributes), for: .normal)
        
    }
    
    fileprivate func setupLayout() {
        
        NSLayoutConstraint.activate([
            
            cameraImageView.heightAnchor.constraint(equalTo: heightAnchor),
            cameraImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cameraImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            cameraImageView.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 1.78),
            
            previewView.heightAnchor.constraint(equalTo: cameraImageView.heightAnchor, multiplier: 0.39),
            previewView.leadingAnchor.constraint(equalTo: cameraImageView.leadingAnchor, constant: frame.height*1.78*0.32),
            previewView.topAnchor.constraint(equalTo: cameraImageView.topAnchor, constant: frame.height*0.27),
            previewView.widthAnchor.constraint(equalTo: previewView.heightAnchor, multiplier: 4/3),
            
            tutorialView.heightAnchor.constraint(equalTo: cameraImageView.heightAnchor, multiplier: 0.39),
            tutorialView.leadingAnchor.constraint(equalTo: cameraImageView.leadingAnchor, constant: frame.height*1.78*0.32),
            tutorialView.topAnchor.constraint(equalTo: cameraImageView.topAnchor, constant: frame.height*0.27),
            tutorialView.widthAnchor.constraint(equalTo: previewView.heightAnchor, multiplier: 4/3),
            
            topConstraint,
            blackView.leadingAnchor.constraint(equalTo: previewView.leadingAnchor),
            blackView.trailingAnchor.constraint(equalTo: previewView.trailingAnchor),
            blackView.bottomAnchor.constraint(equalTo: previewView.bottomAnchor),
            
            leftLabel.leadingAnchor.constraint(equalTo: previewView.leadingAnchor, constant: 20),
            leftLabel.topAnchor.constraint(equalTo: previewView.topAnchor, constant: 20),
            
            rightLabel.trailingAnchor.constraint(equalTo: previewView.trailingAnchor, constant: -20),
            rightLabel.topAnchor.constraint(equalTo: previewView.topAnchor, constant: 20),
            
            changeModeButton.widthAnchor.constraint(equalTo: cameraImageView.widthAnchor, multiplier: 4/25),
            changeModeButton.heightAnchor.constraint(equalTo: cameraImageView.heightAnchor, multiplier: 6/57),
            changeModeButton.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            changeButtonTrailingConstraint,
            
            popUpButton.widthAnchor.constraint(equalTo: cameraImageView.widthAnchor, multiplier: 4/25),
            popUpButton.heightAnchor.constraint(equalTo: cameraImageView.heightAnchor, multiplier: 5/57),
            popUpButtonTopConstraint,
            popUpButtonTrailingConstraint,
            saveButton.leadingAnchor.constraint(equalTo: previewView.leadingAnchor, constant: 20),
            saveButton.bottomAnchor.constraint(equalTo: previewView.bottomAnchor, constant: -20),
            
            deleteButton.trailingAnchor.constraint(equalTo: previewView.trailingAnchor, constant: -20),
            deleteButton.bottomAnchor.constraint(equalTo: previewView.bottomAnchor, constant: -20),
        ])
        print("WIDTH", cameraImageView.frame.width)

    }
    
    func bottomLabelsIsHidden(_ isHidden: Bool) {
        saveButton.isHidden = isHidden
        deleteButton.isHidden = isHidden
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        print("WIDTH", cameraImageView.frame.width)
        changeButtonTrailingConstraint.constant = -cameraImageView.frame.width/25
        changeModeButton.layer.borderWidth = 2
        changeModeButton.layer.borderColor = changeModeBorderColor
        changeModeButton.layer.cornerRadius = 10
        changeModeButton.layer.masksToBounds = true
        
        popUpButtonTopConstraint.constant = cameraImageView.frame.width*(4/50)
        popUpButtonTrailingConstraint.constant = -cameraImageView.frame.width*(29/100)
        popUpButton.layer.borderWidth = 2
        popUpButton.layer.borderColor = popUpBorderColor
        popUpButton.layer.cornerRadius = 10
        popUpButton.layer.masksToBounds = true
    }
    
    func changeModeButtonHighlight(_ highlighted: Bool) {
        
        if highlighted {
            changeModeBorderColor = UIColor.yellow.cgColor
            print("YELLOW")
        } else {
            changeModeBorderColor = UIColor.clear.cgColor
        }
        layoutSubviews()
    }
    
    func popUpButtonButtonHighlight(_ highlighted: Bool) {
        
        if highlighted {
            popUpBorderColor = UIColor.yellow.cgColor
            print("YELLOW")
        } else {
            popUpBorderColor = UIColor.clear.cgColor
        }
        layoutSubviews()
    }
    
    func tutorialSlide(_ number: Int) {
        
        tutorialView.isHidden = false
        
        switch number {
        case 1: do {
            tutorialView.image = tutorialImages[number - 1]
        }
        case 2: do {
            changeModeButtonHighlight(true)
            tutorialView.image = tutorialImages[number - 1]
        }
        case 3: do {
            tutorialView.image = tutorialImages[number - 1]
        }
        case 4: do {
            tutorialView.image = tutorialImages[number - 1]
        }
        case 5: do {
            tutorialView.image = tutorialImages[number - 1]
        }
        case 6: do {
            tutorialView.image = tutorialImages[number - 1]
        }
        case 7: do {
            tutorialView.image = tutorialImages[number - 1]
        }
        case 8: do {
            changeModeButtonHighlight(false)
            popUpButtonButtonHighlight(true)
            tutorialView.image = tutorialImages[number - 1]
        }
        default:
            popUpButtonButtonHighlight(false)
            tutorialView.isHidden = true
        }
    }
    
}
