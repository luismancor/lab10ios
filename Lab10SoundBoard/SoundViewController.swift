//
//  SoundViewController.swift
//  Lab10SoundBoard
//
//  Created by Juan Mancilla on 6/21/20.
//  Copyright © 2020 Juan Mancilla. All rights reserved.
//

import UIKit
import AVFoundation


class SoundViewController: UIViewController {
    
    
    
    @IBOutlet weak var grabarButton: UIButton!
    
    @IBOutlet weak var reproducirButton: UIButton!
    
    @IBOutlet weak var nombreTextField: UITextField!
    
    @IBOutlet weak var agregarButton: UIButton!
    
    //Metodos testing tarea
    @IBOutlet weak var myTimer: UILabel!
    var timeMin = 0
    var timesec = 0
    var timer: Timer?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        myTimer.text = String(format: "%02d:%02d", timeMin, timesec)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        resetTimerToZero()
    }
    
    func resetTimerToZero(){
        timesec = 0
        timeMin = 0
        stopTimer()
    }
    func stopTimer(){
        timer?.invalidate()
    }
    func resetTimerAndLabel(){
        resetTimerToZero()
        myTimer.text = String(format: "%02d:%02d", timeMin, timesec)
    }
    func timerTick(){
        timesec += 1
        if timesec == 60{
            timesec = 0
            timeMin += 1
        }
        let timeNow = String(format: "%02d:%02d", timeMin, timesec)
        myTimer.text = timeNow
    }
    func startTimer(){
        let timeNow = String(format: "%02d:%02d", timeMin, timesec)
        myTimer.text = timeNow
        
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {[self] _ in self.timerTick()}
    }
    
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            //stop recording
            grabarAudio?.stop()
            stopTimer()
            //cambiar texto del boton grabar
            grabarButton.setTitle("Grabar", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
        }else{
            //start to record
            grabarAudio?.record()
            
            startTimer()
            //change text for button "record " to stop
            grabarButton.setTitle("Detener", for: .normal)
            reproducirButton.isEnabled = false
            
        }
        
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        }catch{
            
        }
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context:context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        grabacion.duracion = myTimer.text
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
        
    }
    
    
    //Functions for audio recording
    var grabarAudio:AVAudioRecorder?
    //Play recorded audio
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        
        reproducirButton.isEnabled = false
        agregarButton.isHidden = false

        // Do any additional setup after loading the view.
    }
    
    //funcion for audio recording configuration, including quality
    func configurarGrabacion(){
        do{
            //creating audio session
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            
            //creating direction to audio file
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            //cambio .38
            //let audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            
            //print of route where files are saved
            print("****************")
            print(audioURL!)
            print("****************")
            
            //create options for audio recording
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            //create object for audio recording
             grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            //grabarAudio = try AVAudioRecorder(url: audioURL, settings: settings)
            grabarAudio?.prepareToRecord()
            
            
        }catch let error as NSError {
            print(error)
        }
    }
    
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
