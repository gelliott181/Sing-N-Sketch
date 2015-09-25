import UIKit

@objc
protocol ViewControllerDelegate {
    optional func toggleLeftPanel()
    optional func toggleRightPanel()
    optional func collapseSidePanels()
}

class ViewController: UIViewController {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    var delegate: ViewControllerDelegate?
    
    var userBrush: Brush = Brush()
    var swiped = false
    var lastPoint = CGPoint.zeroPoint
    
    var audio: AudioInterface = AudioInterface()
    
    // Basic pitch mappings. Do not re-use, we have a framework for this.
    let noteFrequencies = [16.35,17.32,18.35,19.45,20.6,21.83,23.12,24.5,25.96,27.5,29.14,30.87]
    let noteNamesWithSharps = ["C", "C♯","D","D♯","E","F","F♯","G","G♯","A","A♯","B"]
    let noteNamesWithFlats = ["C", "D♭","D","E♭","E","F","G♭","G","A♭","A","B♭","B"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        audio.start()
        audio.update()
    }
    
    override func viewWillDisappear(animated: Bool) {
        audio.stop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Touches Starting Action
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        swiped = false
        if let touch = touches.first as? UITouch {
            lastPoint = touch.locationInView(self.view)
        }
    }
    
    // Draw Line Helper
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        // Update audio
        audio.update()
        
        // DEMO CODE - Changes Blue value based on frequency
        if (audio.amplitude > 0.005) {
            var frequency: Float = audio.frequency
            while (frequency > Float(noteFrequencies[noteFrequencies.count-1])) {
                frequency = frequency / 2.0
            }
            while (frequency < Float(noteFrequencies[0])) {
                frequency = frequency * 2.0
            }
            
            // Set red color
            let b = CGFloat((frequency - 16) / 16)
            userBrush.blue = b
        }
        
        
        // Draw into tempImageView to handle the line being drawn
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        // Create the line from the last point
        // TODO: Bezier curves? Current version
        //       produces a bunch of straight lines.
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        // Set line endcap (End shape),
        // width, color, and blend mode
        CGContextSetLineCap(context, kCGLineCapRound)
        CGContextSetLineWidth(context, userBrush.brushWidth)
        CGContextSetRGBStrokeColor(context, userBrush.red, userBrush.green, userBrush.blue, 1.0)
        CGContextSetBlendMode(context, kCGBlendModeNormal)
        
        // Draw the line
        CGContextStrokePath(context)
        
        // End the drawing context
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = userBrush.opacity
        UIGraphicsEndImageContext()
    }
    
    // Swiped Touch Action
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        // Call the draw function as the touch
        // point moves around the view
        swiped = true
        if let touch = touches.first as? UITouch {
            let currentPoint = touch.locationInView(view)
            drawLineFrom(lastPoint, toPoint: currentPoint)
        
            lastPoint = currentPoint
        }
    }
    
    // Touch Ends Action
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if !swiped {
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: kCGBlendModeNormal, alpha: 1.0)
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: kCGBlendModeNormal, alpha: userBrush.opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }
    
    // New Drawing Action
    @IBAction func newDrawing(sender: UIButton) {
        self.mainImageView.image = nil
    }
    
    
    
    @IBAction func showMenu(sender: UIButton) {
        self.performSegueWithIdentifier("menuSegue", sender: self)
    }



}
