//
//  VideoRecordVC.swift
//  famouschat
//
//  Created by angel oni on 2019/6/25.
//  Copyright © 2019 Oni Angel. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import AVFoundation
import Alamofire


class VideoRecordVC: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var camPreview: UIView!
    @IBOutlet weak var record_btn: UIButton!
    @IBOutlet weak var switch_btn: UIButton!
    
    
    let progressDlg = ShareData.progressDlgs[ShareData.progress_index]
    
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    
    var assetWriter:AVAssetWriter?
    var assetReader:AVAssetReader?
    let bitrate:NSNumber = NSNumber(value:250000)
    
    var record_status = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        record_btn.setImage(UIImage.init(named: "video_record_start"), for: .normal)
        record_status = false
        
        switch_btn.setImage(UIImage.init(named: "camera_switch")?.withRenderingMode(.alwaysTemplate), for: .normal)
        switch_btn.tintColor = UIColor.lightGray
        
        if setupSession() {
            setupPreview()
            startSession()
        }
        
    
        
    }
    
    @IBAction func switchAction(_ sender: Any) {
        
        captureSession.beginConfiguration()
        let currentInput = captureSession.inputs.first as! AVCaptureDeviceInput
        captureSession.removeInput(currentInput)
        
        let newCameraDevice = currentInput.device.position == .back ? getCamera(with: .front) : getCamera(with: .back)
        let newVideoInput = try? AVCaptureDeviceInput(device: newCameraDevice!)
        captureSession.addInput(newVideoInput!)
        captureSession.commitConfiguration()
        
    }
    
    
    @IBAction func recordAction(_ sender: Any) {
        
        if record_status
        {
            record_status = false
            record_btn.setImage(UIImage.init(named: "video_record_start"), for: .normal)
            
            stopRecording()
        }
        else
        {
            record_status = true
            record_btn.setImage(UIImage.init(named: "video_record_stop"), for: .normal)
            
            startRecording()
        }
    }
    
}

extension VideoRecordVC
{
    func getCamera(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        guard let devices = AVCaptureDevice.devices(for: AVMediaType.video) as? [AVCaptureDevice] else {
            return nil
        }
        
        return devices.filter {
            $0.position == position
            }.first
    }
    
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = camPreview.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        camPreview.layer.addSublayer(previewLayer)
    }
    
    //MARK:- Setup Camera
    
    func setupSession() -> Bool {
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        // Setup Camera
        let camera = AVCaptureDevice.default(for: AVMediaType.video)!
        
        do {
            
            let input = try AVCaptureDeviceInput(device: camera)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        // Setup Microphone
        let microphone = AVCaptureDevice.default(for: AVMediaType.audio)!
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
        
        
        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        return true
    }
    
    func setupCaptureMode(_ mode: Int) {
        // Video Mode
        
    }
    
    //MARK:- Camera Session
    func startSession() {
        
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    
    @objc func startCapture() {
        
        startRecording()
        
    }
    
    //EDIT 1: I FORGOT THIS AT FIRST
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    
    
    func startRecording() {
        
        if movieOutput.isRecording == false {
            
            let connection = movieOutput.connection(with: AVMediaType.video)
            
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            let device = activeInput.device
            
            if (device.isSmoothAutoFocusSupported) {
                
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
                
            }
            
            //EDIT2: And I forgot this
            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            
        }
        else {
            stopRecording()
        }
        
    }
    
    func stopRecording() {
        
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
        }
    }
    
    @objc func retakeVideo(_ sender: UIButton) {
        
        record_status = false
        record_btn.setImage(UIImage.init(named: "video_record_start"), for: .normal)
        
//        startRecording()
    }
    
    @objc func sendVideo(_ sender: UIButton) {
        
//        var audioFinished = false
//        var videoFinished = false
//
//        let asset = AVAsset(url: self.outputURL);
//
//        let duration = asset.duration
//        let durationTime = CMTimeGetSeconds(duration)
//
//        print("Video Actual Duration -- \(durationTime)")
//
//        //create asset reader
//        do{
//            assetReader = try AVAssetReader(asset: asset)
//        } catch{
//            assetReader = nil
//        }
//
//        guard let reader = assetReader else{
//            fatalError("Could not initalize asset reader probably failed its try catch")
//        }
//
//        let videoTrack = asset.tracks(withMediaType: AVMediaType.video).first!
//        let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first!
//
//        let videoReaderSettings: [String:Any] =  [(kCVPixelBufferPixelFormatTypeKey as String?)!:kCVPixelFormatType_32ARGB ]
//
//        // ADJUST BIT RATE OF VIDEO HERE
//
//        if #available(iOS 11.0, *) {
//            let videoSettings:[String:Any] = [
//                AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey:self.bitrate],
//                AVVideoCodecKey: AVVideoCodecType.h264,
//                AVVideoHeightKey: videoTrack.naturalSize.height,
//                AVVideoWidthKey: videoTrack.naturalSize.width
//            ]
//        } else {
//            // Fallback on earlier versions
//        }
//
//
//        let assetReaderVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: videoReaderSettings)
//        let assetReaderAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
//
//
//        if reader.canAdd(assetReaderVideoOutput){
//            reader.add(assetReaderVideoOutput)
//        }else{
//            fatalError("Couldn't add video output reader")
//        }
//
//        if reader.canAdd(assetReaderAudioOutput){
//            reader.add(assetReaderAudioOutput)
//        }else{
//            fatalError("Couldn't add audio output reader")
//        }
//
//        let audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil)
//        let videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoReaderSettings)
//        videoInput.transform = videoTrack.preferredTransform
//        //we need to add samples to the video input
//
//        let videoInputQueue = DispatchQueue(label: "videoQueue")
//        let audioInputQueue = DispatchQueue(label: "audioQueue")
//
//        do{
//            assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mov)
//        }catch{
//            assetWriter = nil
//        }
//        guard let writer = assetWriter else{
//            fatalError("assetWriter was nil")
//        }
//
//        writer.shouldOptimizeForNetworkUse = true
//        writer.add(videoInput)
//        writer.add(audioInput)
//
//
//        writer.startWriting()
//        reader.startReading()
//        writer.startSession(atSourceTime: kCMTimeZero)
//
//
//        let closeWriter:()->Void = {
//            if (audioFinished && videoFinished){
//                self.assetWriter?.finishWriting(completionHandler: {
//                    print("------ Finish Video Compressing")
//                    //                    self.checkFileSize(sizeUrl: (self.assetWriter?.outputURL)!, message: "The file size of the compressed file is: ")
//                    //
//                    //                    completion((self.assetWriter?.outputURL)!)
//                    ///////
//
//                    do
//                    {
//                        let movieData = try Data(contentsOf:  self.assetWriter?.outputURL as! URL, options: Data.ReadingOptions.alwaysMapped)
//
//                        self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: self.progressDlg, color: .darkGray, fadeInAnimation: nil)
//                        let parameter = ["normal_id": ShareData.user_info.id!, "influencer_id": ShareData.selected_influencer.id!, "time": CommonFuncs().currentTime(), "time_zone": ShareData.user_info.time_zone!] as [String: String]
//
//                        let url = URL(string: "\(ShareData.main_url)book/video_sent.php")!
//
//                        self.record_btn.isUserInteractionEnabled = false
//                        self.switch_btn.isUserInteractionEnabled = false
//
//                        Alamofire.upload(multipartFormData: { (multiPartFormData: MultipartFormData) in
//                            for (key, value) in parameter as! [String: String] {
//                                multiPartFormData.append((value as String).data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
//                            }
//
//                            multiPartFormData.append(movieData as Data, withName: "upload", fileName: "upload", mimeType: "video/mov")
//
//                        }, to: url) { (result: SessionManager.MultipartFormDataEncodingResult) in
//                            switch result {
//                            case .success(request: let uploadRequest, _, _ ):
//
//
//                                uploadRequest.uploadProgress(closure: { (progress) in
//
//                                    print("===== \(progress)")
//                                })
//
//
//                                uploadRequest.responseJSON(completionHandler: {response in
//
//                                    if let JSON = response.result.value
//                                    {
//                                        let dictData = JSON as! NSDictionary
//                                        let status = dictData["status"] as! Bool
//                                        let message = dictData["message"] as! String
//
//                                        do {
//                                            try FileManager.default.removeItem(at: self.outputURL as URL)
//                                        } catch {
//                                            print("Could not delete file: \(error)")
//                                        }
//
//                                        self.stopAnimating(nil)
//
//
//                                        CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {self.record_btn.isUserInteractionEnabled = true
//                                            self.switch_btn.isUserInteractionEnabled = true
//                                            self.navigationController?.popViewController(animated: true)})
//
//                                    }
//
//                                })
//
//                            case .failure(let error):
//                                print(error.localizedDescription)
//                            }
//                        }
//                    } catch _ {
//
//                        CommonFuncs().doneAlert(ShareData.appTitle, "Failed Video Record", "CLOSE", {})
//                    }
//
//                    ///////
//
//                })
//
//                self.assetReader?.cancelReading()
//            }
//        }
//
//
//        audioInput.requestMediaDataWhenReady(on: audioInputQueue) {
//            while(audioInput.isReadyForMoreMediaData){
//                let sample = assetReaderAudioOutput.copyNextSampleBuffer()
//                if (sample != nil){
//                    audioInput.append(sample!)
//                }else{
//                    audioInput.markAsFinished()
//                    DispatchQueue.main.async {
//                        audioFinished = true
//                        closeWriter()
//                    }
//                    break;
//                }
//            }
//        }
//
//        videoInput.requestMediaDataWhenReady(on: videoInputQueue) {
//            //request data here
//            while(videoInput.isReadyForMoreMediaData){
//                let sample = assetReaderVideoOutput.copyNextSampleBuffer()
//                if (sample != nil){
//                    let timeStamp = CMSampleBufferGetPresentationTimeStamp(sample!)
//                    let timeSecond = CMTimeGetSeconds(timeStamp)
//                    let per = timeSecond / durationTime
//                    print("Duration --- \(per)")
//                    DispatchQueue.main.async {
//                        //                        self.progress.progress = Float(per)
//                    }
//                    videoInput.append(sample!)
//                }else{
//                    videoInput.markAsFinished()
//                    DispatchQueue.main.async {
//                        videoFinished = true
//                        //                        self.progress.progress = 1.0
//                        closeWriter()
//                    }
//                    break;
//                }
//            }
//        }
        
        do
        {
            let movieData = try Data(contentsOf:  outputURL! as URL, options: Data.ReadingOptions.alwaysMapped)

            self.startAnimating(CGSize(width: 40, height: 40), message: nil, type: progressDlg, color: .darkGray, fadeInAnimation: nil)
            let parameter = ["normal_id": ShareData.user_info.id!, "influencer_id": ShareData.selected_influencer.id!, "time": CommonFuncs().currentTime(), "time_zone": ShareData.user_info.time_zone!] as [String: String]

            let url = URL(string: "\(ShareData.main_url)book/video_sent.php")!

            record_btn.isUserInteractionEnabled = false
            switch_btn.isUserInteractionEnabled = false

            Alamofire.upload(multipartFormData: { (multiPartFormData: MultipartFormData) in
                for (key, value) in parameter as! [String: String] {
                    multiPartFormData.append((value as String).data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
                }

                multiPartFormData.append(movieData as Data, withName: "upload", fileName: "upload", mimeType: "video/mov")

            }, to: url) { (result: SessionManager.MultipartFormDataEncodingResult) in
                switch result {
                case .success(request: let uploadRequest, _, _ ):


                    uploadRequest.uploadProgress(closure: { (progress) in

                        print("===== \(progress)")
                    })


                    uploadRequest.responseJSON(completionHandler: {response in

                        if let JSON = response.result.value
                        {
                            let dictData = JSON as! NSDictionary
                            let status = dictData["status"] as! Bool
                            let message = dictData["message"] as! String

                            do {
                                try FileManager.default.removeItem(at: self.outputURL as URL)
                            } catch {
                                print("Could not delete file: \(error)")
                            }

                            self.stopAnimating(nil)


                            CommonFuncs().doneAlert(ShareData.appTitle, message, "CLOSE", {self.record_btn.isUserInteractionEnabled = true
                                self.switch_btn.isUserInteractionEnabled = true
                                self.navigationController?.popViewController(animated: true)})

                        }

                    })

                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } catch _ {

            CommonFuncs().doneAlert(ShareData.appTitle, "Failed Video Record", "CLOSE", {})
        }
    }
    
}


extension VideoRecordVC: AVCaptureFileOutputRecordingDelegate
{
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        if (error != nil) {
            
            CommonFuncs().doneAlert(ShareData.appTitle, "Failed Video Record", "CLOSE", {})
            
        } else {
            
            
            CommonFuncs().selectAlert(ShareData.appTitle, "Press send if your video is ready. Press retake if you would like to re-record.", 2, ["Retake", "Send"], [Utility.color(withHexString: ShareData.btn_color), UIColor.gray], [UIColor.white, UIColor.white], self, [#selector(retakeVideo(_:)), #selector(sendVideo(_:))])
            
            
            
            
        }
        
    }
    
}





