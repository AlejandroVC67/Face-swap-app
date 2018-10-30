//
//  ViewController.swift
//  FaceSwaping
//
//  Created by Diego Alejandro Villa Cardenas on 10/19/18.
//  Copyright © 2018 Diego Alejandro Villa Cardenas. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {
    var rect = CGRect()
    var croppedImage = UIImage(named: "man")?.cgImage
    var greenView = UIView()
    var redView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        //Variables necesarias
        let resizedImageWidth = view.frame.width / 2
        
        //cara mujer
        guard let womanImage = UIImage(named: "woman") else { return }
        let womanImageView = UIImageView(image: womanImage)
        let scaledHeightWoman = resizedImageWidth /  womanImage.size.width * womanImage.size.height
        womanImageView.contentMode = .scaleAspectFit
        womanImageView.frame = CGRect(x: 0, y: 0, width: resizedImageWidth , height: scaledHeightWoman)
        view.addSubview(womanImageView)

        //cara hombre
        guard let manImage = UIImage(named: "man") else { return }
        let manImageView = UIImageView(image: manImage)
        let scaledHeightMan = resizedImageWidth / manImage.size.width * manImage.size.height
        manImageView.contentMode = .scaleAspectFit
        manImageView.frame = CGRect(x: 0 + resizedImageWidth, y: 0, width: view.frame.width / 2, height: scaledHeightMan)
        view.addSubview(manImageView)
        
        //req cara hombre
        let requestMan = VNDetectFaceLandmarksRequest { (responsesMan, err) in
            if let err = err {
                print("Error", err)
                return
            }

            responsesMan.results?.forEach({ (responseMan) in
                guard let faceObservationMan = responseMan as? VNFaceObservation else { return }
                
                let x2  = resizedImageWidth + (resizedImageWidth * faceObservationMan.boundingBox.origin.x)
                let width2 = resizedImageWidth * faceObservationMan.boundingBox.width
                let height2 =  scaledHeightMan * faceObservationMan.boundingBox.height
                let y2 = scaledHeightMan * (1 - faceObservationMan.boundingBox.origin.y) - height2

                
                self.greenView.backgroundColor = .green
                self.greenView.alpha = 0.4
                self.greenView.frame = CGRect(x: x2, y: y2, width: width2, height: height2)
                self.view.addSubview(self.greenView)
            })
        }
        guard let cgManImage = manImage.cgImage else { return }
        let manHandler = VNImageRequestHandler(cgImage: cgManImage, options: [:])

        do {
            try manHandler.perform([requestMan])
            
        } catch let reqErr {
            print("failed", reqErr)
        }
        
        //MARK: req cara mujer
        let requestWoman = VNDetectFaceLandmarksRequest { (responsesWoman, err) in
            if let err = err {
                print("Error", err)
                return
            }
            
            responsesWoman.results?.forEach({ (res) in
                // Detect Woman face observation
                guard let faceObservationWoman = res as? VNFaceObservation else { return }
                let x  = resizedImageWidth * faceObservationWoman.boundingBox.origin.x
                let width = resizedImageWidth * faceObservationWoman.boundingBox.width
                let height =  scaledHeightWoman * faceObservationWoman.boundingBox.height
                let y  = scaledHeightWoman * (1 - faceObservationWoman.boundingBox.origin.y) - height
                let frameOfTheFace = CGRect(x: x, y: y, width: width, height: height)
                self.redView.backgroundColor = .red
                self.redView.alpha = 0.4
                self.redView.frame = frameOfTheFace
                //self.view.addSubview(self.redView)
                
                // Woman Face observation without resizing
                let womanFaceObsRect = CGRect(x: x,
                                              y: y + scaledHeightWoman,
                                              width: faceObservationWoman.boundingBox.width,
                                              height: faceObservationWoman.boundingBox.height)
                guard let cgWomanImage = womanImage.cgImage else { print("woman cgImage can't be created"); return }
                let womanFaceImage = UIImage(cgImage: cgWomanImage)
                let croppedFrame = CGRect(x: womanFaceObsRect.minX / resizedImageWidth * womanFaceImage.size.width,
                                          y: height,
                                          width: womanFaceObsRect.width * womanFaceImage.size.width,
                                          height: womanFaceObsRect.height * womanFaceImage.size.height)
                
                //Create Normal Size Woman Image with the blue face square
                let womanImageViewNormalSize = self.womanImageViewNormalSize(image: womanFaceImage)
                let womanBlueViewNormalSize = self.womanBlueViewNormalSize(faceFrame: croppedFrame)
                
                //self.view.addSubview(womanImageViewNormalSize)
                //self.view.addSubview(womanBlueViewNormalSize)
                
                self.croppedImage = cgWomanImage.cropping(to: croppedFrame)
                let croppedUIImage = UIImage(cgImage: self.croppedImage!)
                let croppedUIImageView = UIImageView(image: croppedUIImage)
                croppedUIImageView.layer.cornerRadius = width / 2
                croppedUIImageView.layer.masksToBounds = true
                croppedUIImageView.frame = self.greenView.frame
                self.view.addSubview(croppedUIImageView)
                
                guard let landmarks = faceObservationWoman.landmarks else { return }
                
                let womanImageSize = CGSize(width: resizedImageWidth, height: scaledHeightWoman)
                guard var womanFaceContourLandmarks = landmarks.faceContour?.pointsInImage(imageSize: womanImageSize) else { return }
            
                guard let womanLeftEyebrowLandmarks = landmarks.leftEyebrow?.pointsInImage(imageSize: womanImageSize) else { return }
                
                guard let womanRightEyebrowLandmarks = landmarks.rightEyebrow?.pointsInImage(imageSize: womanImageSize) else { return }
                
                womanFaceContourLandmarks.append(contentsOf: womanRightEyebrowLandmarks)
                womanFaceContourLandmarks.append(contentsOf: womanLeftEyebrowLandmarks)
                
                self.cropWomanImage(usingLandmarksOf: womanFaceContourLandmarks, scaledHeight: scaledHeightWoman)
                
            })
        }
        
        guard let cgImage = womanImage.cgImage else { return }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([requestWoman])
        } catch let reqErr {
            print("failed", reqErr)
        }
        
        
    }
    
    func cropWomanImage(usingLandmarksOf: [CGPoint], scaledHeight: CGFloat){
        print(usingLandmarksOf)
        var myFaceContourRect = CGRect()
        var myViewContourView = UIView()
        usingLandmarksOf.forEach { (point) in
//            print(point)
            let newPoint = CGPoint(x: point.x /* * resizedImageWidth */,
                y: (1 - point.y) + scaledHeight /* (scaledHeightWoman * (1 - point.y))*/ )
//            print("newPoint: \(newPoint)")
            myFaceContourRect = CGRect(origin: newPoint,
                            size: CGSize(width: 5, height: 5))
            myViewContourView = UIView(frame: myFaceContourRect)
            myViewContourView.backgroundColor = .red
            self.view.addSubview(myViewContourView)
        }
    }
    
    func womanImageViewNormalSize(image: UIImage) -> UIImageView {
//        pintando vista morada
        let imgviewx = UIImageView(image: image)
        imgviewx.frame = CGRect(x: 0,
                                y: 0,
                                width: image.size.width,
                                height: image.size.height) //Y debería probarse con 0 y no  con scaledHeight
        return imgviewx
    }
    
    func womanBlueViewNormalSize(faceFrame:CGRect) -> UIView {
        let blueView = UIView(frame: faceFrame)
        blueView.alpha = 0.4
        blueView.backgroundColor = .blue
        return blueView
    }
}
