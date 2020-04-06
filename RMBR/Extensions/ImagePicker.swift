//
//  ImagePicker.swift
//  CapturingPhotoSwiftUI
//
//  Created by Mohammad Azam on 8/9/19.
//  Copyright © 2019 Mohammad Azam. All rights reserved.
//  Edited and adjusted by Sam Prausnitz-Weinbaum
//

import Foundation
import SwiftUI

class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Binding var isShown: Bool
    @Binding var images: [UIImage]
    
    init(isShown: Binding<Bool>, images: Binding<[UIImage]>) {
        _isShown = isShown
        _images = images
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let uiImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        images.append(uiImage)
        isShown = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isShown = false
    }
    
}

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var isShown: Bool
    @Binding var images: [UIImage]
    @Binding var capture: Bool
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> ImagePickerCoordinator {
        return
            ImagePickerCoordinator(isShown: $isShown,  images: $images)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        if self.capture {
            picker.sourceType = .camera
        }
        picker.delegate = context.coordinator
        return picker
    }
    
}
