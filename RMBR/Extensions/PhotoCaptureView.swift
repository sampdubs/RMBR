//
//  PhotoCaptureView.swift
//  RMBR
//
//  Created by Sam Prausnitz-Weinbaum on 9/1/19.
//  Copyright © 2019 Sam Prausnitz-Weinbaum. All rights reserved.
//

import SwiftUI

struct PhotoCaptureView: View {
    
    @Binding var showImagePicker: Bool
    @Binding var images: [UIImage]
    @Binding var capture: Bool
    
    var body: some View {
        ImagePicker(isShown: $showImagePicker, images: self.$images, capture: $capture)
    }
}

#if DEBUG
struct PhotoCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoCaptureView(showImagePicker: .constant(false), images: .constant([]), capture: .constant(false))
    }
}
#endif

