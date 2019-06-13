//
//  Bubble.swift
//  Bubbles
//
//  Created by Nicolás Miari on 2019/06/13.
//  Copyright © 2019 Nicolás Miari. All rights reserved.
//

import UIKit

public class Bubble: UIView {

    fileprivate var verticalConstraint: NSLayoutConstraint!

    /**
     */
    public static var globalBackgroundColor: UIColor = UIColor(white: 0, alpha: 0.5)

    /**
     */
    public static var globalTextColor: UIColor = .white

    /**
     */
    public static var globalFontFace: UIFont = UIFont.boldSystemFont(ofSize: 17)

    /**
     Padding (in points) around the text label.
     */
    public static var globalInsetMargin: CGFloat = 10

    /**
     Vertical space between consecutive bubbles.
     */
    public static var globalVerticalMargin: CGFloat = 10

    /**
     Minimum left and right margin between the bubble and the screen edges.
     The bubbles are always displayed centered, and fitted to enclose the width
     of the text label, plus inset margins. If the size is too long, the label
     gets compressed and the text truncated, but these horizontal margins are
     preserved (the bubble never clips horizontally off-screen).
     */
    public static var globalHorizontalMargin: CGFloat = 10

    /**
     Duration of the push-into-screen animation.
     */
    public static var globalPushDuration: TimeInterval = 0.5

    /**
     Lifetime of the bubble from appearance to beginning of fade-out.
     */
    public static var globalBubbleLifetime: TimeInterval = 3.0

    /**
     Duration of the fade-out animation that occurs after `globalBubbleLifetime` has ellasped.
     */
    public static var globalFadeOutDuration: TimeInterval = 0.5

    public init(title: String) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isUserInteractionEnabled = false
        self.layer.cornerRadius = 9
        self.clipsToBounds = true

        self.backgroundColor = Bubble.globalBackgroundColor
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        label.font = Bubble.globalFontFace
        label.textColor = Bubble.globalTextColor
        label.text = title
        label.sizeToFit()

        addSubview(label)
        let margin = Bubble.globalInsetMargin
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: margin).isActive = true
        label.rightAnchor.constraint(equalTo: rightAnchor, constant: -margin).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: margin).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin).isActive = true

        sizeToFit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Operation

    /**
     Pushes the receiver into the screen for display.
     */
    public func show() throws {
        try BubbleCoordinator.shared.show(self)
    }
}

enum BubbleError: LocalizedError {
    case noWindow
}

private class BubbleCoordinator: UIViewController {

    static let shared: BubbleCoordinator = BubbleCoordinator()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = false
    }

    func show(_ bubble: Bubble) throws {
        if view.superview == nil {
            guard let window = UIApplication.shared.windows.first else {
                throw BubbleError.noWindow
            }
            window.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.topAnchor.constraint(equalTo: window.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true
            view.leftAnchor.constraint(equalTo: window.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: window.rightAnchor).isActive = true
        }


        // Place the new view off screen, just below the edge:
        view.addSubview(bubble)

        // Constraint Center X:
        bubble.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        // Horizontal Margin:
        bubble.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor, constant: 10).isActive = true
        // (if text is too long, label gets compressed)
        
        // Constraint Bottom:
        let verticalConstraint = bubble.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: +(bubble.bounds.height + Bubble.globalVerticalMargin))
        verticalConstraint.isActive = true
        bubble.verticalConstraint = verticalConstraint
        bubble.alpha = 0.0

        // Update constraints
        view.layoutIfNeeded()

        /*
         Push all current views up to make room for the newest one:
         */
        let deltaY: CGFloat = Bubble.globalVerticalMargin + bubble.bounds.height
        view.subviews.forEach { (subview) in
            (subview as? Bubble)?.verticalConstraint.constant -= deltaY
        }
        UIView.animate(withDuration: Bubble.globalPushDuration) {
            bubble.alpha = 1.0
            self.view.layoutIfNeeded()
        }

        /*
         Schedule fade-out of the newest view:
         */
        DispatchQueue.main.asyncAfter(deadline: .now() + Bubble.globalBubbleLifetime) {
            UIView.animate(withDuration: Bubble.globalFadeOutDuration, animations: {
                bubble.alpha = 0.0
            }, completion: {(_) in
                bubble.removeFromSuperview()
            })
        }
    }
}
