//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by Klebert Manuel Layme Arapa on 5/20/22.
//  Copyright © 2022 empresa. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {
    
    
    @IBOutlet weak var tiempoP: UILabel!
    @IBOutlet weak var grabarButton: UIButton!
    
    @IBOutlet weak var reproducirButton: UIButton!
    
    @IBOutlet weak var nombreTextField: UITextField!
    
    @IBOutlet weak var agregarButton: UIButton!
  
    
    @IBOutlet weak var Slider: UISlider!
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var tiempo:Timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    @IBAction func grabarrTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            grabarAudio?.stop()
            tiempo.invalidate()
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
        }else{
            grabarAudio?.record()
            grabarButton.setTitle("DETENER", for: .normal)
            tiempo = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(tiempotranscurrido), userInfo: nil, repeats: true)
            reproducirButton.isEnabled = false
        }
    }
    

    @IBAction func reproducirTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            
            reproducirAudio!.prepareToPlay()
            reproducirAudio!.currentTime = 0
            
            Slider.maximumValue = Float(reproducirAudio!.duration)
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: Selector(("updateSlider")),userInfo: nil, repeats: true)
            tiempoP.text = "\(reproducirAudio!.currentTime)"
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {
                (timer) in
                self.tiempoP.text = "\(round(self.reproducirAudio!.currentTime*10)/10)"
            })
            reproducirAudio!.play()
            print("Reproduciendo")
        }catch{}
    }
    
    
    @objc func tiempotranscurrido()-> Void{
        let tiempodu = Int(grabarAudio!.currentTime)
        let minuto = (tiempodu % 3600)  / 60
        let segundo = (tiempodu % 3600) % 60
        var tiempo = ""
        tiempo += String(format:"%02d",minuto)
        tiempo += ":"
        tiempo += String(format:"%02d ",segundo)
        tiempo += ""
        print(tiempo)
        tiempoP.text = tiempo
    
       
    }
    
    @IBAction func controlVolumen(_ sender: UISlider) {
        reproducirAudio!.volume = sender.value
        print(sender.value)
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.grabacion = tiempoP.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    @objc func updateSlider(){
        Slider.value = Float(reproducirAudio!.currentTime)
    }
    
    @IBAction func Volumen(_ sender: UISlider) {
        reproducirAudio!.volume = sender.value
        print(sender.value)
    }
    
    func configurarGrabacion(){
        do{
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord,mode: AVAudioSession.Mode.default, options:[])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath,"audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents )
            
            print("************")
            print(audioURL)
            print("************")
            
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        }catch let error as NSError{
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
