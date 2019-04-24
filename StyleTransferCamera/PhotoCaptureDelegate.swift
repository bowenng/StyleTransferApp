//
//  PhotoCaptureDelegate.swift
//  StyleTransferApp
//
//  Created by 吴博闻 on 4/23/19.
//  Copyright © 2019 None. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class PhotoCaptureProcessor: NSObject, AVCapturePhotoCaptureDelegate{
    var previewPhoto: UIImage?
    var photo: Data?
    
    let willCaptureAnimation:  () -> Void?
    let finishCaptureSegue: () -> Void?
    
    init(willCaptureAnimation:  @escaping () -> Void,
         finishCaptureSegue: @escaping () -> Void){
        self.willCaptureAnimation = willCaptureAnimation
        self.finishCaptureSegue = finishCaptureSegue
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("animated")
        self.willCaptureAnimation()
    }
    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let e = error{
            print("\(e.localizedDescription)")
        }
        
        if let previewBuffer = photo.previewPixelBuffer{
            let previewCIImage = CIImage(cvPixelBuffer: previewBuffer)
            self.previewPhoto = UIImage(ciImage: previewCIImage)
            
            print("Did finish processing preview")
        }
        self.photo = photo.fileDataRepresentation()
        print("Did finish processsing photo")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        self.finishCaptureSegue()
    }
    
    
    
    
    
}
