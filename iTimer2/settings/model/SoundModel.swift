import Foundation
import SwiftUI

class SoundModel: ObservableObject {
    @AppStorage("selectedSound") var selectedSound: String = "alarm"
    @AppStorage("uploadedSoundBookmarks") private var bookmarkStorage: String = ""

    @Published var uploadedSounds: [String: URL] = [:] {
        didSet { saveBookmarks() }
    }

    init() {
        loadBookmarks()
    }

    func addSound(from url: URL) {
        let name = url.deletingPathExtension().lastPathComponent
        uploadedSounds[name] = url
    }

    func removeSound(named name: String) {
        uploadedSounds.removeValue(forKey: name)
        if selectedSound == name {
            selectedSound = "none"
        }
    }

    private func saveBookmarks() {
        let bookmarks = uploadedSounds.compactMapValues { try? $0.bookmarkData() }
        let encoded = bookmarks.mapValues { $0.base64EncodedString() }
        if let json = try? JSONEncoder().encode(encoded),
           let jsonString = String(data: json, encoding: .utf8) {
            bookmarkStorage = jsonString
        }
    }

    private func loadBookmarks() {
        guard let data = bookmarkStorage.data(using: .utf8),
              let encoded = try? JSONDecoder().decode([String: String].self, from: data)
        else { return }

        for (name, base64) in encoded {
            if let bookmarkData = Data(base64Encoded: base64) {
                var isStale = false
                do {
                    let url = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
                    if !isStale {
                        uploadedSounds[name] = url
                    }
                } catch {
                    print("Failed to resolve bookmark for \(name): \(error.localizedDescription)")
                }
            }
        }
    }
}

struct ManageUploadedSoundsView: View {
    @EnvironmentObject var soundModel: SoundModel
    @Environment(\.dismiss) var dismiss

    @State private var soundToDelete: String? = nil
    @State private var showDeleteAlert = false

    var body: some View {
        VStack {
            Text("Uploaded Sounds")
                .font(.title3)
                .padding()

            List {
                ForEach(Array(soundModel.uploadedSounds.keys), id: \.self) { sound in
                    HStack {
                        Text(sound)
                        Spacer()
                        Button {
                            soundToDelete = sound
                            showDeleteAlert = true
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }

            Button("Done") {
                dismiss()
            }
            .padding()
        }
        .frame(width: 300, height: 400)
        .alert("Delete Sound?", isPresented: $showDeleteAlert, presenting: soundToDelete) { sound in
            Button("Delete", role: .destructive) {
                soundModel.removeSound(named: sound)
            }
            Button("Cancel", role: .cancel) { }
        } message: { sound in
            Text("Are you sure you want to delete '\(sound)'?")
        }
    }
}
