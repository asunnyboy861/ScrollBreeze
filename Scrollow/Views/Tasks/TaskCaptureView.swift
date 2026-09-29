import SwiftUI
import UIKit

struct TaskCaptureView: UIViewControllerRepresentable {
    let task: ReclaimTask
    @ObservedObject var model: TaskModel
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: TaskCaptureView

        init(_ parent: TaskCaptureView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            guard let image = info[.originalImage] as? UIImage,
                  let jpeg = image.jpegData(compressionQuality: 0.55) else {
                parent.model.stage = .failed(reason: "We couldn't read that photo. Try again.")
                parent.dismiss()
                return
            }
            let task = parent.task
            let model = parent.model
            parent.dismiss()
            Task { @MainActor in
                await model.verify(task: task, imageData: jpeg)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
