//
//  ViewController.swift
//  camera
//
//  Created by Gavin Hung on 11/16/19.
//  Copyright © 2019 Gavin Hung. All rights reserved.
//

import UIKit
import AVKit
import Vision
import AVFoundation

class ObjDet: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var SearchButton: UIButton!
    @IBOutlet weak var textView: UILabel!
    
    var text: String = "Predictions"
    let generator = UINotificationFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // getting camera access
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        captureSession.startRunning()
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        // analyzing image
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    // called every frame
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // image recognition
        // using model
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            // check err
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
            self.text = firstObservation.identifier
            print(self.text)
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        // image recognitions
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        /*
        let utterance = AVSpeechUtterance(string: self.text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.1

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        */
        self.textView.text = self.text
         let utterance = AVSpeechUtterance(string: text)
               utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
               utterance.rate = 0.3

               let synthesizer = AVSpeechSynthesizer()
               synthesizer.speak(utterance)
               
               self.textView.text = self.text
    }
}

