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

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet weak var textView: UILabel!
    
    var text: String = "Predictions"
    var ciimage : CIImage = CIImage()
    let generator = UINotificationFeedbackGenerator()
    let letters = CharacterSet.letters
    let morseCodeLetters = [
        "A": [0, 1],
        "B": [1, 0, 0, 0],
        "C": [1, 0, 1, 0],
        "D": [1, 0, 0],
        "E": [0],
        "F": [0, 0, 1, 0],
        "G": [1, 1, 0],
        "H": [0, 0, 0, 0],
        "I": [0, 0],
        "J": [0, 1, 1, 1],
        "K": [1, 0, 1],
        "L": [0, 1, 0, 0],
        "M": [1, 1],
        "N": [1, 0],
        "O": [1, 1, 1],
        "P": [0, 1, 1, 0],
        "Q": [1, 1, 0, 1],
        "R": [0, 1, 0],
        "S": [0, 0, 0],
        "T": [1],
        "U": [0, 0, 1],
        "V": [0, 0, 0, 1],
        "W": [0, 1, 1],
        "X": [1, 0, 0, 1],
        "Y": [1, 0, 1, 1],
        "Z": [1, 1, 0, 0]
    ]
    
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
        /*
        // using model
        guard let model = try? VNCoreMLModel(for: RealSignLangauge1().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            // check err
            
            guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
            self.text = firstObservation.identifier
            print(self.text)
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        */
        // image recognitions
        
        
        // text to image
        ciimage = CIImage(cvPixelBuffer: pixelBuffer)
        // text to image
    }
    
    // text to image
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        if context != nil {
            return context.createCGImage(inputImage, from: inputImage.extent)
        }
        return nil
    }
    func handleDetectedText(request: VNRequest?, error: Error?) {
        if let error = error {
            print("ERROR: \(error)")
            return
        }
        guard let results = request?.results, results.count > 0 else {
            self.text = "No Text Detected"
            return
        }
        self.text = ""
        for result in results {
            if let observation = result as? VNRecognizedTextObservation {
                for text in observation.topCandidates(1) {
                    self.text += text.string + ""
                }
            }
        }
    }
    // text to images
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        let cgImage: CGImage = convertCIImageToCGImage(inputImage: ciimage)
        let requestText = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
        requestText.recognitionLevel = .accurate
        requestText.recognitionLanguages = ["en_GB"]
        let requests = [requestText]
        let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, orientation: .right, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try imageRequestHandler.perform(requests)
            } catch let error {
                print("Error: \(error)")
            }
        }
        generator.notificationOccurred(.error)
        
        
        let utterance = AVSpeechUtterance(string: self.text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.3

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        
        self.textView.text = self.text
        //print(self.text)
        
    }
    
    
    @IBAction func morseCodeButtonPressed(_ sender: UIButton) {
        var upper = self.text.uppercased()
        var temp = upper.startIndex;
        
        for letter in upper {
            var stringLetter = String(letter)
            if(morseCodeLetters[stringLetter] != nil){
                for sound in morseCodeLetters[stringLetter]!{
                    if(sound==0){
                        generator.notificationOccurred(.warning)
                    } else {
                        generator.notificationOccurred(.success)
                    }
                }
            }
        }
    }
    
}

