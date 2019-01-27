//
//  SecondViewController.swift
//  Geomaitrise
//
//  Copyright © 2019 Nicolas Zinovieff. MIT Licence.
//

import UIKit

class SecondViewController: UIViewController, FingerPaintedViewDelegate {

    @IBOutlet weak var hitTestLbl: UILabel!
    @IBOutlet weak var paintingView: FingerPaintedView!
    @IBOutlet weak var speedLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        hitTestLbl.text = "-"
        paintingView.hitDelegate = self
        speedLbl.text = nil
  }

    override func viewWillAppear(_ animated: Bool) {
        paintingView.points = []
        paintingView.simplified = nil
        paintingView.setNeedsDisplay()
    }
    
    func didTouchInside(_ view: FingerPaintedView, isInside: Bool) {
        if isInside {
            hitTestLbl.text = "✅"
        } else {
            hitTestLbl.text = "❌"
        }
    }
    
    @IBAction func calculateSpeed(_ sender: Any) {
        // repeat simplification 1000 times, average the time
        let start = Date()
        if let lt = paintingView.lastTouchUp {
            for _ in 0..<100000 {
                _ = evenOdd((Double(lt.x), Double(lt.y)), in: paintingView.points)
            }
            let end = Date()
            var ti = (end.timeIntervalSinceReferenceDate-start.timeIntervalSinceReferenceDate)/100000 // average time
            print("supposedly \(ti)s between \(start) and \(end)")
            ti = round(ti*1000000)
            DispatchQueue.main.async {
                self.speedLbl.text = "\(ti)µs over 100000 iterations"
            }
        }
    }
}

protocol FingerPaintedViewDelegate {
    func didTouchInside(_ view: FingerPaintedView, isInside: Bool)
}

class FingerPaintedView : FingerPaintingView {
    var hitDelegate : FingerPaintedViewDelegate?
    var lastTouchUp : CGPoint? = nil
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // to avoid painting
        lastTouchUp = nil
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // to avoid painting
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // draw hit and update hit test
        lastTouchUp = touches.first?.location(in: self)
        setNeedsDisplay()
        
        if let lt = lastTouchUp {
            DispatchQueue.main.async {
                self.hitDelegate?.didTouchInside(self, isInside: evenOdd((Double(lt.x), Double(lt.y)), in: self.points))
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        if points.count < 2 && FingerPaintingView.savedPoints != nil {
            points = FingerPaintingView.savedPoints!
            simplified = nil
        }
        super.draw(rect)
        
        if let lt = lastTouchUp {
            let touch = UIBezierPath(ovalIn: CGRect(x: lt.x - 4, y: lt.y - 4, width: 8, height: 8))
            UIColor.blue.set()
            touch.fill()
        }
    }
}
