//
//  CameraClickModel.swift
//  CameraClick
//
//  Created by Nar Rasaily on 12/23/25.
//

import Foundation
import SwiftUI
import CoreData
import Photos
import Combine

@MainActor
final class CameraClickModel: ObservableObject {
    func saveEditedImage(
        image: UIImage,
        filterName: String,
        intensity: Double,
        context: NSManagedObjectContext
    ) {
        saveToPhotos(image: image)
            saveToCoreData(
            image: image,
            filter: filterName,
            intensity: intensity,
            ctx: context
        )
    }
    private func saveToPhotos(image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else { return }

            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    private func saveToCoreData(
        image: UIImage,
        filter: String,
        intensity: Double,
        ctx: NSManagedObjectContext
    ) {
        let item = EditedPhoto(context: ctx)
        item.id = UUID()
        item.createdAt = Date()
        item.filter = filter
        item.intensity = intensity
        item.imageData = image.jpegData(compressionQuality: 0.9)

        do {
            try ctx.save()
        } catch {
            print("❌ Core Data save error:", error.localizedDescription)
        }
    }
}
