//
//  SoundViewController.swift
//  Sound Board
//
//  Created by janusz jas on 28.02.2017.
//  Copyright © 2017 Janusz Pietkun. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    //record jako outlet, by zmieniał sie na stop
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    //można na końcu dodać = nil, ale kompolator domyśli się i w takiej postaci też ustawi wartośc na  nil
    var audioRecorder : AVAudioRecorder?
    var audioPlayer : AVAudioPlayer?
    var audioURL : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupRecorder()
        playButton.isEnabled = false
        addButton.isEnabled = false
    }

    func setupRecorder() {
        do {
        //create an audio session
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try session.overrideOutputAudioPort(.speaker)
        try session.setActive(true)
        
        //create URL for the audio file
            let basePath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
 
        //create setting for audio recorder
            var settings : [String:Any] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC)
            settings[AVSampleRateKey] = 44100.0
            settings[AVNumberOfChannelsKey] = 2
        
        //Create AudioRecorder object
            audioRecorder = try AVAudioRecorder(url: audioURL!, settings: settings)
            audioRecorder?.prepareToRecord()
            
        } catch  let error as NSError {
            print(error)
        }
    }
    
    
    @IBAction func recordTapped(_ sender: Any) {
        if audioRecorder!.isRecording {
            //stop the recording
            audioRecorder?.stop()
            
            //change button title to record
            recordButton.setTitle("Record", for: .normal)
            
            //pokazanie przyciskow
            playButton.isEnabled = true
            addButton.isEnabled = true
            
        } else {
            //start recording
            audioRecorder?.record()
            
            //change buttton title to stop
            recordButton.setTitle("STOP", for: .normal)
            
            
        }
        
    }
    
    @IBAction func playTapped(_ sender: Any) {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: audioURL!)
            audioPlayer!.play()
        } catch {}
    }

    @IBAction func addTapped(_ sender: Any) {
        //tworzymy context by zapisywac w core data nazwe oraz plik z zapisem audio
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       
        let sound = Sound(context: context)
        
        sound.name = textField.text
        sound.audio = NSData(contentsOf: audioURL!)
        //zapisanie
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        navigationController!.popViewController(animated: true)
        
        
    }
    
    
}
