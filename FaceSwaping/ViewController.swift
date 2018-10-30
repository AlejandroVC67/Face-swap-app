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
    var croppedImage = UIImage(named: "img2")?.cgImage
    var greenView = UIView()
    var redView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        //Variables necesarias
        let imageWidth = view.frame.width / 2
        
        //cara mujer
        guard let image = UIImage(named: "img1") else { return }
        let imageView = UIImageView(image: image)
        let scaledHeight = imageWidth /  image.size.width * image.size.height
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: imageWidth , height: scaledHeight)
        view.addSubview(imageView)

        //cara hombre
        guard let image2 = UIImage(named: "img2") else { return }
        let imageView2 = UIImageView(image: image2)
        let scaledHeight2 = imageWidth / image2.size.width * image2.size.height
        imageView2.contentMode = .scaleAspectFit
        imageView2.frame = CGRect(x: 0 + imageWidth, y: 0, width: view.frame.width / 2, height: scaledHeight2)
        view.addSubview(imageView2)
        
        //req cara hombre
        let request2 = VNDetectFaceLandmarksRequest { (req2, err) in
            if let err2 = err {
                print("Error", err2)
                return
            }

            req2.results?.forEach({ (res2) in
                guard let faceObservation2 = res2 as? VNFaceObservation else { return }
                
                let x2  = imageWidth + (imageWidth * faceObservation2.boundingBox.origin.x)
                let width2 = imageWidth * faceObservation2.boundingBox.width
                let height2 =  scaledHeight2 * faceObservation2.boundingBox.height
                let y2 = scaledHeight2 * (1 - faceObservation2.boundingBox.origin.y) - height2

                
                self.greenView.backgroundColor = .green
                self.greenView.alpha = 0.4
                self.greenView.frame = CGRect(x: x2, y: y2, width: width2, height: height2)
                //self.view.addSubview(self.greenView)
            })
        }
        guard let cgImage2 = image2.cgImage else { return }
        let handler2 = VNImageRequestHandler(cgImage: cgImage2, options: [:])

        do {
            try handler2.perform([request2])
            
        } catch let reqErr {
            print("failed", reqErr)
        }
        
        //MARK: req cara mujer
        let request = VNDetectFaceLandmarksRequest { (req, err) in
            if let err = err {
                print("Error", err)
                return
            }
            
            req.results?.forEach({ (res) in
                guard let faceObservation = res as? VNFaceObservation else { return }
                let x  = imageWidth * faceObservation.boundingBox.origin.x
                let width = imageWidth * faceObservation.boundingBox.width
                let height =  scaledHeight * faceObservation.boundingBox.height
                let y  = scaledHeight * (1 - faceObservation.boundingBox.origin.y) - height
                let frameOfTheFace = CGRect(x: x, y: y, width: width, height: height)
                self.redView.backgroundColor = .red
                self.redView.alpha = 0.4
                self.redView.frame = frameOfTheFace
                //self.view.addSubview(self.redView)
                
                self.rect = CGRect(x: x, y: y + scaledHeight, width: width / imageWidth, height: height / scaledHeight)
                guard let cgimage = image.cgImage else { return }
                let face = UIImage(cgImage: cgimage)
                let croppedFrame = CGRect(x: self.rect.minX / imageWidth * face.size.width,
                                          y: height,
                                          width: self.rect.width * face.size.width,
                                          height: self.rect.height * face.size.height)
                self.croppedImage = cgimage.cropping(to: croppedFrame)
                let croppedUIImage = UIImage(cgImage: self.croppedImage!)
                let croppedUIImageView = UIImageView(image: croppedUIImage)
                croppedUIImageView.layer.cornerRadius = width / 2
                croppedUIImageView.layer.masksToBounds = true
                croppedUIImageView.frame = self.greenView.frame
                self.view.addSubview(croppedUIImageView)
                
                
                guard let landmarks = faceObservation.landmarks else { return }
                let faceContour = landmarks.faceContour?.normalizedPoints
                var myRect = CGRect()
                var myView = UIView()
                faceContour?.forEach({ (point) in
                    print(point)
                    let newPoint = CGPoint(x: point.x * imageWidth, y: (scaledHeight * (1 - point.y)))
                    myRect = CGRect(origin: newPoint, size: CGSize(width: 5, height: 5))
                    myView = UIView(frame: myRect)
                    myView.backgroundColor = .red

                    self.view.addSubview(myView)
                })
                
                //pintando vista morada
//                let imgviewx = UIImageView(image: face)
//                imgviewx.frame = CGRect(x: 0, y: 0, width: face.size.width, height: face.size.height) //Y debería probarse con 0 y no  con scaledHeight
//                let blueView = UIView(frame: croppedFrame)
//                blueView.alpha = 0.4
//                blueView.backgroundColor = .blue
//                self.view.addSubview(imgviewx)
//                self.view.addSubview(blueView)
                
            })
        }
        
        guard let cgImage = image.cgImage else { return }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch let reqErr {
            print("failed", reqErr)
        }
        
        
    }
    
    fileprivate func addPoints(in landmarkRegion: VNFaceLandmarkRegion2D, to path: CGMutablePath, applying affineTransform: CGAffineTransform, closingWhenComplete closePath: Bool) {
        let pointCount = landmarkRegion.pointCount
        if pointCount > 1 {
            let points: [CGPoint] = landmarkRegion.normalizedPoints
            path.move(to: points[0], transform: affineTransform)
            path.addLines(between: points, transform: affineTransform)
            if closePath {
                path.addLine(to: points[0], transform: affineTransform)
                path.closeSubpath()
            }
        }
    }
}
