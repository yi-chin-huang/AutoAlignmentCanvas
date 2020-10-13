//
//  ViewController.swift
//  AutoAlignmentCanvas
//
//  Created by Yi-Chin on 2020/10/13.
//

import UIKit

class ViewController: UIViewController, UICollisionBehaviorDelegate {

    var dynamicAnimator = UIDynamicAnimator()
    var snapBheavior:UISnapBehavior?
    private let autoAlignDistance: CGFloat = 4
    private var auxilaryLines: [UIView] = []
    private var shapes: [UIView] = []
    
    private let addCircleButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 30, y: 50, width: 80, height: 40))
        button.backgroundColor = .lightGray
        button.setTitle("Add Circle", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.addTarget(self, action: #selector(addCircle), for: .touchUpInside)
        return button
    }()
    
    private let addTriangleButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 130, y: 50, width: 80, height: 40))
        button.backgroundColor = .lightGray
        button.setTitle("Add Triangle", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.addTarget(self, action: #selector(addTriangle), for: .touchUpInside)
        return button
    }()
    
    private let addRectangleButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 230, y: 50, width: 100, height: 40))
        button.backgroundColor = .lightGray
        button.setTitle("Add Rectangle", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.addTarget(self, action: #selector(addRectangle), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(addCircleButton)
        view.addSubview(addTriangleButton)
        view.addSubview(addRectangleButton)
    }
    
    @objc func detectPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        guard let gestureView = gesture.view else {
          return
        }
        
        view.bringSubviewToFront(gestureView)
        gestureView.center = CGPoint(
          x: gestureView.center.x + translation.x,
          y: gestureView.center.y + translation.y
        )
        gesture.setTranslation(.zero, in: view)
        
        for shape in shapes where shape != gestureView {
            autoAlign(aligningView: gestureView, alignedView: shape)
        }
    }
    
    private func autoAlign(aligningView: UIView, alignedView: UIView) {
        for aligningDirection in Direction.allCases {
            for alignedDirection in Direction.allCases {
                guard aligningDirection.isVertical() == alignedDirection.isVertical() else {
                    continue
                }
                
                if abs(aligningDirection.getFloat(from: aligningView) - alignedDirection.getFloat(from: alignedView)) <= autoAlignDistance {
                    showAuxilaryLine(aligningView: aligningView, alignedView: alignedView, aligningDirection: aligningDirection, alignedDirection: alignedDirection)
                    aligningView.center = CGPoint(
                        x: aligningView.center.x + (aligningDirection.isVertical() ? 0 : alignedDirection.getFloat(from: alignedView) - aligningDirection.getFloat(from: aligningView)),
                        y: aligningView.center.y + (aligningDirection.isVertical() ? alignedDirection.getFloat(from: alignedView) - aligningDirection.getFloat(from: aligningView) : 0)
                    )
                }
            }
        }
    }
    
    private func showAuxilaryLine(aligningView: UIView, alignedView: UIView, aligningDirection: Direction, alignedDirection: Direction) {
        var frame: CGRect
        if alignedDirection == .top || alignedDirection == .bottom {
            frame = CGRect(
                x: min(aligningView.left, alignedView.left),
                y: alignedDirection.getFloat(from: alignedView),
                width: max(abs(aligningView.left - alignedView.right), abs(aligningView.right - alignedView.left)),
                height: 1.0
            )
        } else {
            frame = CGRect(
                x: alignedDirection.getFloat(from: alignedView),
                y: min(aligningView.top, alignedView.top),
                width: 1.0,
                height: max(abs(aligningView.top - alignedView.bottom), abs(aligningView.bottom - alignedView.top))
            )
        }
        let lineView: UIView = {
            let view = UIView(frame: frame)
            view.backgroundColor = .red
            return view
        }()
        view.addSubview(lineView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            lineView.removeFromSuperview()
        }
    }

    // Create and add shapes
    func createCircle(frame: CGRect, color: UIColor) -> UIView{
        let view = UIView(frame: frame)
        view.backgroundColor = color
        view.layer.cornerRadius = frame.size.width/2
        view.layer.masksToBounds = true
        return view
    }
    
    func createTriangle(frame: CGRect, color: UIColor) -> UIView{
        let view = UIView(frame: frame)
        let layerHeight = view.layer.frame.height
        let layerWidth = view.layer.frame.width

        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0, y: layerHeight))
        bezierPath.addLine(to: CGPoint(x: layerWidth, y: layerHeight))
        bezierPath.addLine(to: CGPoint(x: layerWidth / 2, y: 0))
        bezierPath.addLine(to: CGPoint(x: 0, y: layerHeight))
        bezierPath.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bezierPath.cgPath
        view.layer.mask = shapeLayer
        
        view.backgroundColor = color
        view.layer.masksToBounds = true
        return view
    }
    
    func createRectangle(frame: CGRect, color: UIColor) -> UIView{
        let view = UIView(frame: frame)
        view.backgroundColor = color
        return view
    }
    
    @objc func addCircle() {
        let shape = createCircle(frame: CGRect(x: 30, y: 100, width: 75, height: 75),
                                 color: UIColor(hue: CGFloat(drand48()), saturation: 0.5, brightness: 0.8, alpha: 1))
        view.addSubview(shape)
        shapes.append(shape)
        
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(detectPan))
        shape.gestureRecognizers = [panRecognizer]
        shape.isUserInteractionEnabled = true
    }
    
    @objc func addTriangle() {
        let shape = createTriangle(frame: CGRect(x: 130, y: 100, width: 75, height: 75),
                                 color: UIColor(hue: CGFloat(drand48()), saturation: 0.5, brightness: 0.8, alpha: 1))
        view.addSubview(shape)
        shapes.append(shape)
        
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(detectPan))
        shape.gestureRecognizers = [panRecognizer]
        shape.isUserInteractionEnabled = true
    }
    
    @objc func addRectangle() {
        let shape = createRectangle(frame: CGRect(x:230, y: 100, width: 75, height: 75),
                                 color: UIColor(hue: CGFloat(drand48()), saturation: 0.5, brightness: 0.8, alpha: 1))
        view.addSubview(shape)
        shapes.append(shape)
        
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(detectPan))
        shape.gestureRecognizers = [panRecognizer]
        shape.isUserInteractionEnabled = true
    }
}

extension UIView {
    var top: CGFloat { return self.frame.origin.y }
    var left: CGFloat { return self.frame.origin.x }
    var right: CGFloat { return self.frame.origin.x + self.frame.size.width }
    var bottom: CGFloat { return self.frame.origin.y + self.frame.size.height }
}

enum Direction: CaseIterable {
    case top
    case left
    case right
    case bottom
    
    func getFloat(from view: UIView) -> CGFloat {
        if self == .top {
            return view.top
        } else if self == .left {
            return view.left
        } else if self == .right {
            return view.right
        } else {
            return view.bottom
        }
    }
    
    func isVertical() -> Bool {
        return self == .top || self == .bottom
    }
}
