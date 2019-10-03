

import UIKit
import AVFoundation

class ViewController: UIViewController {
    let timeScale = CMTimeScale(NSEC_PER_SEC)
    var isPlaying:Bool = true
    var position:CMTime = CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var myTextView: UILabel!
    @IBOutlet weak var sliderTime: UISlider!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var myWebView: UIWebView!

    
    @IBAction func playPauseAction(_ sender: Any) {
        isPlaying = !isPlaying
        if (isPlaying) {
            playPauseButton.setTitle("pause", for: UIControl.State.normal)
            player!.play()
        } else {
            playPauseButton.setTitle("play", for: UIControl.State.normal)
            player!.pause()
        }
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerWillAppear),
            name: NSNotification.Name(rawValue: "AVPlayerItemBecameCurrentNotification"),
            object: nil)
    }

    
    @IBAction func sliderTimeChanged(_ sender: UISlider) {
        let myFloat = sender.value / sender.maximumValue
        let myTime = Double(myFloat) * playerItem!.duration.seconds
        player!.seek(to: CMTime(seconds: myTime, preferredTimescale: timeScale))
    }
    
    
    @IBAction func volumeChanged(_ sender: UISlider) {
        player!.volume = sender.value / sender.maximumValue
    }
    
    @objc private func playerWillAppear(notification: NSNotification){
        print("hello")
        NotificationCenter.default.removeObserver(self)

        playerItem = (notification.object as! AVPlayerItem)
        player = (playerItem!.value(forKey: "player") as! AVPlayer)
        player!.volume = 0.03
        print("seconds: \(self.position.seconds)")
        player!.seek(to: self.position, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.positiveInfinity)
        print("seconds in player: \(player!.currentTime().seconds)")

        self.addPeriodicTimeObserver()
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        position = CMTime(seconds:0, preferredTimescale: timeScale)

        myWebView.allowsInlineMediaPlayback = true
        myWebView.mediaPlaybackRequiresUserAction = false
        
        let path:String = Bundle.main.path(forResource: "ok", ofType: "html")!
        let embedHTML = try! String(contentsOfFile: path, encoding: String.Encoding.utf8) //try? String()

        myWebView.loadHTMLString(embedHTML, baseURL:Bundle.main.resourceURL!)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerWillAppear),
            name: NSNotification.Name(rawValue: "AVPlayerItemBecameCurrentNotification"),
            object: nil)
    }
    
//    deinit {
//        print("Remove NotificationCenter Deinit")
//        NotificationCenter.default.removeObserver(self)
//    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        print("Remove NotificationCenter Deinit")
        
//        player!.removeTimeObserver(timeObserverToken!)
//        player = nil
//        playerItem = nil
//        NotificationCenter.default.removeObserver(self)

        performSegue(withIdentifier: "nextoutou", sender: self)
        
    }
    
    
    var timeObserverToken: Any?
    
    func addPeriodicTimeObserver() {
        // Notify every half second
        
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        
        timeObserverToken = player!.addPeriodicTimeObserver(forInterval: time, queue: .main) {
            [weak self] time in
//            if(self!.position <= self!.player!.currentTime()){
                self!.position = self!.player!.currentTime();
                let coucou = self!.position.seconds
                self!.myTextView.text = String(Int(coucou))
                self!.sliderTime.value = Float(
                    coucou / self!.playerItem!.duration.seconds)
//            } else {
//                print("wtf man")
//            }
        }
    }
    
    func removePeriodicTimeObserver() {
        if let timeObserverToken = timeObserverToken {
            player!.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    

}



