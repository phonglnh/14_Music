//
//  ViewController.swift
//  14_Music
//
//  Created by PhongLe on 9/14/16.
//  Copyright © 2016 PhongLe. All rights reserved.
//

import UIKit
import AVFoundation
var arrSongTiTle: Array<String> = []
class ViewController: UIViewController, AVAudioPlayerDelegate, UIPopoverPresentationControllerDelegate, popoverSongDelegate {
    
    var arrSong: Array<String> = ["WeDont","Work","WorkFromHome","OutSide","Y","IReallyLikeYou","IntoYou",
                                  "NewRomantics","ThisIsWhatYouCameFor","IWillNeverLetYouDown"]
    var player = AVAudioPlayer()
    var url:URL!
    var index = 0
    var timer = Timer()
    var timerNavi = Timer()
    var lblTitle: UILabel!
    var screenWidth = UIScreen.main.bounds.width
    
    var repeatStatus: Bool = false
    var shuffleStatus: Bool = false
    var isPaused = false
    var rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
    
    @IBOutlet weak var sldTimer: UISlider!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnRepeat: UIButton!
    @IBOutlet weak var btnShuffle: UIButton!
    @IBOutlet weak var btnPause: UIButton!
    @IBOutlet weak var lblRealTime: UILabel!
    @IBOutlet weak var lblFullTime: UILabel!
    @IBOutlet weak var imgArtwork: UIImageView!
    @IBOutlet weak var imgBlurBackgroud: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getAllSongTitle()
        
        
        if let path = Bundle.main.path(forResource: arrSong[index], ofType: "mp3"){
            url = URL(fileURLWithPath: path)
            do {
                player = try AVAudioPlayer(contentsOf: url)
                let playerItem = AVPlayerItem(url: url)
                getArtWorkSong(playerItem)
                sldTimer.minimumValue = 0
                sldTimer.maximumValue = Float(player.duration)
                sldTimer.value = 0
                player.delegate = self
                lblFullTime.text = getTimeString(playerTime: player.duration)
            }catch {
                
            }
            
        }
        
        let image = UIImage(named: "sliderthumb")
        sldTimer.setThumbImage(image, for: UIControlState())
        sldTimer.tintColor = UIColor(red: 0, green: 1, blue: 0.5, alpha: 1)
        
        imgBlurBackgroud.contentMode = .scaleAspectFill
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = imgBlurBackgroud.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imgBlurBackgroud.addSubview(blurEffectView)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        

        let btnSelectSong:UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "list")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(ViewController.aBtnSelectSong))
        self.navigationItem.rightBarButtonItem = btnSelectSong
        
        
        
    }
    
    func getAllSongTitle(){
        for i in 0..<arrSong.count {
            if let path = Bundle.main.path(forResource: arrSong[i], ofType: "mp3"){
                let url = URL(fileURLWithPath: path)
                let playerItem = AVPlayerItem(url: url)
                let metadataList = playerItem.asset.commonMetadata
                for item in metadataList {
                    if let key = item.commonKey, let value = item.value {
                        if key == "title" {
                            arrSongTiTle.append((value as? String)!)
                        }
                    }
                }
            }
        }
    }
    func getIndexOfSelectedSongFromPopover(index: Int) {
        self.presentedViewController?.dismiss(animated: true, completion: nil)
        
        if isPaused {
            imgArtwork.resumeLayer()
        }
        imgArtwork.layer.removeAllAnimations()
        imgArtwork.rotateView(rotateDuration: 8, rotationAnimation: &rotationAnimation)
        
        playSongWithIndex(index)
        let playerItem = AVPlayerItem(url: url)
        getArtWorkSong(playerItem)
        
        btnPlay.isHidden = true
        btnPause.isHidden = false
        updateTimeInfo()

    }
    
    func aBtnSelectSong(sender: UIBarButtonItem){
      let popover = storyboard?.instantiateViewController(withIdentifier: "PopoverListSong") as! PopoverListSongTableViewController
        
        popover.modalPresentationStyle = UIModalPresentationStyle.popover
        popover.popoverPresentationController?.barButtonItem = sender
        popover.popoverPresentationController?.delegate = self
        popover.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        
        //set delegate to get index selected in tableview popover
        popover.mDelegate = self
        //
        
        present(popover, animated: true, completion: nil)
        
        
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
        
    override func viewDidAppear(_ animated: Bool) {
        imgArtwork.makeCircleImageView()
        
    }
    func getArtWorkSong(_ playerItem: AVPlayerItem){
        let metadataList = playerItem.asset.commonMetadata
        var artWorkStatus = false
        for item in metadataList {
            if let key = item.commonKey, let value = item.value {
                if key == "artwork" {
                    artWorkStatus = true
                    if let audioImage = UIImage(data: value as! Data) {
                        imgArtwork.image = audioImage
                        imgBlurBackgroud.image = audioImage
                    }
                }
                if key == "title" {
                    if lblTitle != nil { lblTitle.text = ""}
                    lblTitle = UILabel(frame: CGRect(x: self.screenWidth, y: 30, width: self.screenWidth, height: 100))
                    lblTitle.adjustsFontSizeToFitWidth = true
                    lblTitle.text = value as? String
                    lblTitle.textColor = UIColor.white
                    self.navigationController?.navigationBar.addSubview(lblTitle)
                    animateLabel()
                }
            }
        }
        if !artWorkStatus {
            imgArtwork.image = UIImage(named: "NoneArtwork")
            imgBlurBackgroud.image = UIImage(named: "NoneArtwork")
        }
        
    }
    func animateLabel() {
        UIView.animate(withDuration: 8.0, delay: 0.0, options: [.repeat], animations: {
            self.lblTitle.frame = CGRect(x: -self.screenWidth - 30, y: 30, width: self.screenWidth, height: 60)
        }) { (success) in
            self.lblTitle.frame = CGRect(x: self.screenWidth - 30, y: 30, width: self.screenWidth, height: 60)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        if repeatStatus {
            imgArtwork.layer.removeAllAnimations()
            imgArtwork.rotateView(rotateDuration: 8, rotationAnimation: &rotationAnimation)
            
            player.play()
            updateTimeInfo()
            
        } else {
            index = (index + 1) % arrSong.count
            playSongWithIndex(index)
            
            let playerItem = AVPlayerItem(url: url)
            getArtWorkSong(playerItem)
            
            imgArtwork.layer.removeAllAnimations()
            imgArtwork.rotateView(rotateDuration: 8, rotationAnimation: &rotationAnimation)
            
            updateTimeInfo()
        }
        
        
    }
    
    func playSongWithIndex(_ index: Int){
        if let path = Bundle.main.path(forResource: arrSong[index], ofType: "mp3"){
            url = URL(fileURLWithPath: path)
            do {
                player = try AVAudioPlayer(contentsOf: url)
                let playerItem = AVPlayerItem(url: url)
                getArtWorkSong(playerItem)
                
                sldTimer.minimumValue = 0
                sldTimer.maximumValue = Float(player.duration)
                sldTimer.value = 0
                
                player.delegate = self
                player.prepareToPlay()
                player.play()
                
            }catch {
                
            }
        }
        
        
        
    }
    @IBAction func aBtnSliderTime(_ sender: AnyObject) {
        player.currentTime = TimeInterval(sldTimer.value)
    }
    
    @IBAction func aBtnPlay(_ sender: AnyObject) {
        if isPaused {
            imgArtwork.resumeLayer()
        } else {
            imgArtwork.rotateView(rotateDuration: 8, rotationAnimation: &rotationAnimation)
        }
        player.play()
        btnPlay.isHidden = true
        btnPause.isHidden = false
        updateTimeInfo()
    }
    func updateTimeInfo(){
        lblFullTime.text = getTimeString(playerTime: player.duration)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
        
    }
    func getTimeString(playerTime time: TimeInterval) -> String{
        //        let minute = (Int(time / 60) < 10) ? ("0" + String(Int(time / 60))) : (String(Int(time / 60)))
        //        let second = (Int(time % 60) < 10) ? ("0" + String(Int(time % 60))) : (String(Int(time % 60)))
        //
        //        return minute + ":" + second
        
        let minutes = Int(time / 60)
        let seconds = Int(time.truncatingRemainder(dividingBy: 60))
        return NSString(format: "%02d:%02d", minutes,seconds) as String
    }
    func updateTimer(){
        sldTimer.value = Float(player.currentTime)
        lblRealTime.text = getTimeString(playerTime: player.currentTime)
        
    }
    @IBAction func aBtnPause(_ sender: AnyObject) {
        isPaused = true
        imgArtwork.pauseLayer()
        player.pause()
        btnPlay.isHidden = false
        btnPause.isHidden = true
    }
    
    @IBAction func aBtnNext(_ sender: AnyObject) {
        if isPaused {
            imgArtwork.resumeLayer()
        }
        imgArtwork.layer.removeAllAnimations()
        imgArtwork.rotateView(rotateDuration: 8, rotationAnimation: &rotationAnimation)
        if shuffleStatus {
            randomIndex()
        } else {
            index = (index + 1) % arrSong.count
        }
        playSongWithIndex(index)
        let playerItem = AVPlayerItem(url: url)
        getArtWorkSong(playerItem)
        
        btnPlay.isHidden = true
        btnPause.isHidden = false
        updateTimeInfo()
        
    }
    func randomIndex(){
        let newIndex = Int(arc4random()) % arrSong.count
        if newIndex != index {
            index = newIndex
        } else {
            randomIndex()
        }
    }
    @IBAction func aBtnBack(_ sender: AnyObject) {
        if isPaused {
            imgArtwork.resumeLayer()
        }
        imgArtwork.layer.removeAllAnimations()
        imgArtwork.rotateView(rotateDuration: 8, rotationAnimation: &rotationAnimation)
        
        if shuffleStatus {
            randomIndex()
        } else {
            index = (index >= 1) ? index - 1 : (arrSong.count - 1)
        }
        playSongWithIndex(index)
        let playerItem = AVPlayerItem(url: url)
        getArtWorkSong(playerItem)
        
        player.play()
        btnPlay.isHidden = true
        btnPause.isHidden = false
        updateTimeInfo()
    }
    
    @IBAction func aBtnRepeat(_ sender: UIButton) {
        let image = UIImage(named: "repeat")?.withRenderingMode(.alwaysTemplate)
        if !repeatStatus {
            btnRepeat.setImage(image, for: UIControlState())
            btnRepeat.tintColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
            repeatStatus = true
        } else {
            btnRepeat.tintColor = UIColor.clear
            repeatStatus = false
        }
        
    }
    
    @IBAction func aBtnShuffle(_ sender: AnyObject) {
        let image = UIImage(named: "shuffle")?.withRenderingMode(.alwaysTemplate)
        if !shuffleStatus {
            btnShuffle.setImage(image, for: UIControlState())
            btnShuffle.tintColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
            shuffleStatus = true
        } else {
            btnShuffle.tintColor = UIColor.clear
            shuffleStatus = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

