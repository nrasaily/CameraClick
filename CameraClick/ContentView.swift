//
//  ContentView.swift
//  CameraClick
//
//  Created by Nar Rasaily on 12/23/25.
//

import SwiftUI
import CoreImage
import UIKit
import CoreImage.CIFilterBuiltins
import Photos

struct ContentView: View {
    @State private var image: UIImage? = nil
    @State private var intensity: Double = 0.7
    
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showPicker: Bool = false
    
    private let context = CIContext()
    private let filter = CIFilter.sepiaTone()
    var body: some View {
        NavigationStack {
            VStack {
                if let img = image {
                    // image exists -> show it
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                } else {
                    // image is nil -> show placeholder
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 300)
                        .overlay(Text("No Image Selected")
                        .foregroundStyle(Color.secondary)
                        .cornerRadius(12)
                    )
                }
                Slider(value: $intensity, in: 0...1)
                    .disabled(image == nil)
                    .onChange(of: intensity) { _ in
                        applyFilter()
                        
                    }
                
                
                HStack {
                    
                    
                    Button("Take Photo"){
                        sourceType = .camera
                        showPicker = true
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                    Button("Photo Library") {
                        sourceType = .photoLibrary
                        showPicker = true
                    }
                    .buttonStyle(.bordered)
                }
                HStack {
                    Button("Save"){
                        saveImage()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(image == nil)
                }
                Spacer()
            }
            .padding()
            .navigationTitle(Text("Camera Plus"))
            
        }
        .sheet(isPresented: $showPicker) {
            ImagePicker(image: $image, sourceType: sourceType)
                .onDisappear {
                    if image != nil {
                        applyFilter()
                    }
                }
        }
    }
    
    // This fixes "cannot find applyFilter() in scope"
    private func applyFilter() {
        guard let input = image else { return }
        filter.inputImage = CIImage(image: input)
        filter.intensity = Float(intensity)
        
        guard let output = filter.outputImage,
              let cgimg = context.createCGImage(output, from: output.extent) else { return }
        image = UIImage(cgImage: cgimg)
    }
    private func saveImage() {
        guard let img = image else { return }
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
            }
        }
    }
}

#Preview {
    ContentView()
}
