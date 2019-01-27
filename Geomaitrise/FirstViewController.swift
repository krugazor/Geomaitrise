//
//  FirstViewController.swift
//  Geomaitrise
//
//  Copyright © 2019 Nicolas Zinovieff. MIT Licence.
//

import UIKit

class FirstViewController: UIViewController, FingerPaintingDelegate {
    @IBOutlet weak var topLbl: UILabel!
    @IBOutlet weak var speedLbl: UILabel!
    @IBOutlet weak var bottomLbl: UILabel!
    @IBOutlet weak var bottomSlider: UISlider!
    @IBOutlet weak var fingerPaintingView: FingerPaintingView!
    
    private var lastSliderValue : Float = 0 // to avoid updating too often
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        fingerPaintingView.delegate = self
        sliderChanged(fingerPaintingView)
        topLbl.text = "Drawing 0 points"
        speedLbl.text = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        fingerPaintingView.save()
    }
    
    func changedPointCount(_ c: Int) {
        topLbl.text = "Drawing \(c) points"
        if speedLbl.text != nil { speedLbl.text = nil }
    }
    
    func changedSimplification(_ c: Int, _ s: Int) {
        let st = (s == -1) ? "N/A" : "\(s)"
        let sp : String
        if s == -1 { sp = "N/A" }
        else { sp = "\(round((Double(s)*100)/Double(c)))%"}
        topLbl.text = "Simplified \(c) to \(st) (\(sp))"
        if speedLbl.text != nil { speedLbl.text = nil }
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        let vl = bottomSlider.value
        if abs(vl - lastSliderValue) < 0.1 { return }
        let ne = round(Double(vl)*10)/10
        bottomLbl.text = "ε = \(ne)"
        if speedLbl.text != nil { speedLbl.text = nil }
    }
    @IBAction func sliderFinished(_ sender: Any) {
        let ne = round(Double(bottomSlider.value)*10)/10
        fingerPaintingView.epsilon = ne
    }
    
    @IBAction func calculateSpeed(_ sender: Any) {
        // repeat simplification 1000 times, average the time
        let start = Date()
        for _ in 0..<10000 {
            fingerPaintingView.simplify(false)
        }
        let end = Date()
        fingerPaintingView.simplify() // do it "properly"
        var ti = (end.timeIntervalSinceReferenceDate-start.timeIntervalSinceReferenceDate)/10000 // average time
        print("supposedly \(ti)s between \(start) and \(end)")
        ti = round(ti*1000000)
        DispatchQueue.main.async {
            self.speedLbl.text = "\(ti)µs over 10000 iterations"
        }
    }
}

protocol FingerPaintingDelegate {
    func changedPointCount(_ c: Int)
    func changedSimplification(_ c: Int, _ s: Int) // count/simplified
}

class FingerPaintingView : UIView {
    static var savedPoints : [Point]?
    var points = [Point]()
    var simplified : [Point]? = nil
    private var drawing = false
    
    public var epsilon : Double = 3 {
        didSet {
            simplify()
            self.setNeedsDisplay()
        }
    }
    public var delegate : FingerPaintingDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        points = [] // reset
        simplified = nil
        if let t = touches.first {
            let p = t.location(in: self)
            points.append((Double(p.x),Double(p.y)))
        }
        drawing = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let t = touches.first {
            let p = t.location(in: self)
            points.append((Double(p.x),Double(p.y)))
        }
        DispatchQueue.main.async {
            self.setNeedsDisplay(self.frame)
            self.delegate?.changedPointCount(self.points.count)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        drawing = false
        DispatchQueue.main.async {
            self.setNeedsDisplay(self.frame)
            self.simplify()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let br = UIBezierPath(rect: rect)
        br.lineWidth = 2
        UIColor.darkGray.set()
        br.stroke()
        
        if points.count < 2 { return }
        let path = UIBezierPath()
        path.lineWidth = 6
        
        let f = points.first!
        path.move(to: CGPoint(x: f.x, y: f.y))
        for pIdx in 1..<points.count {
            let p = points[pIdx]
            path.addLine(to: CGPoint(x: p.x, y: p.y))
        }
        
        // close path, because why not
        if !drawing { path.addLine(to: CGPoint(x: f.x, y: f.y)) }
        
        UIColor.red.set()
        path.stroke()
        
        if let s = simplified {
            let simplePath = UIBezierPath()
            simplePath.lineWidth = 2
            if s.count >= 2 {
                let sf = s.first!
                simplePath.move(to: CGPoint(x: sf.x,y: sf.y))
                for pIdx in 1..<s.count {
                    let p = s[pIdx]
                    simplePath.addLine(to: CGPoint(x: p.x, y: p.y))
                }
                
                simplePath.addLine(to: CGPoint(x: sf.x,y: sf.y))
                UIColor.yellow.set()
                simplePath.stroke()
            }
        }
    }
    
    func simplify(_ report: Bool = true) {
        if points.count <= 2 { return }
        simplified = douglaspeuckerSimplification(line: points, epsilon: epsilon)
        if report {
            DispatchQueue.main.async {
                self.delegate?.changedSimplification(self.points.count, self.simplified?.count ?? -1)
            }
        }
    }
    
    func save() {
        simplify(false) // just in case
        FingerPaintingView.savedPoints = simplified
    }
}
