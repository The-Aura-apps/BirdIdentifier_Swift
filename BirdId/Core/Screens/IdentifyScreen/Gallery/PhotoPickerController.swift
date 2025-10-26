//
//  PhotoPickerController.swift
//  BirdId
//
//  Created by ali bakhsha on 8/4/1404 AP.
//

import Foundation
import SwiftUI
import Combine
import PhotosUI

@MainActor
final class PhotoPickerController: ObservableObject {
 
    @Published private(set) var selectedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet{
            setImage(from: imageSelection)
        }
    }
    
    
    // MARK: set image
    private func setImage(from selection: PhotosPickerItem?) {
        guard let selection else {return}
        
        Task {
            if let data = try? await selection.loadTransferable(type: Data.self){
                if let uiImage = UIImage(data: data){
                    selectedImage = uiImage
                    return
                }
            }
        }
    }
    
    
}
