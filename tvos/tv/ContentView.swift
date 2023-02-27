//
//  ContentView.swift
//  tv
//
//  Created by Antoine Gonthier on 10/02/2023.
//  Copyright © 2023 The Chromium Authors. All rights reserved.
//

import SwiftUI
import Foundation
import FirebaseDatabase

struct Bird: Identifiable, Codable {
    var id: String
    var description: String
    var imagePath: String
}

final class BirdViewModel: ObservableObject {
    @Published var birds: [Bird] = []
    
    private lazy var databasePath: DatabaseReference? = {
        let ref = Database.database().reference().child("kams")
        return ref
    }()
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func listentoRealtimeDatabase() {
        guard let databasePath = databasePath else {
            return
        }
        databasePath
            .observe(.childAdded) { [weak self] snapshot in
                guard
                    let self = self,
                    var json = snapshot.value as? [String: Any]
                else {
                    return
                }
                json["id"] = snapshot.key
                do {
                    let birdData = try JSONSerialization.data(withJSONObject: json)
                    let bird = try self.decoder.decode(Bird.self, from: birdData)
                    self.birds.append(bird)
                } catch {
                    print("an error occurred", error)
                }
            }
    }
    
    func stopListening() {
        databasePath?.removeAllObservers()
    }
}
struct ContentView: View {
@StateObject private var viewModel = BirdViewModel()
@State private var currentImage = ""
@State private var timer: Timer!
var body: some View {

ZStack {
    
if !currentImage.isEmpty {
AsyncImage(url: URL(string: currentImage)) { phase in
switch phase {
case .empty:
ProgressView()
case .success(let image):
image.resizable()
.aspectRatio(contentMode: .fill)
.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
.scaleEffect(1.5)
case .failure:
Color.gray
.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
@unknown default:
EmptyView()
}
}
.transition(.scale)
}
    Blur(style: .dark)
    if !currentImage.isEmpty {
        AsyncImage(url: URL(string: currentImage)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .scaleEffect(CGSize(width: 1.0, height: 1.0), anchor: .center)
                    .animation(Animation.linear(duration: 2))
            case .failure:
                Color.gray
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            @unknown default:
                EmptyView()
            }
        }
    }
}
.onAppear {
    viewModel.listentoRealtimeDatabase()
    self.timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) {_ in
self.currentImage = self.viewModel.birds.randomElement()?.imagePath ?? ""
}
}
.onDisappear {
viewModel.stopListening()
self.timer.invalidate()
}
.navigationTitle("Kams")
}
}

struct Blur: UIViewRepresentable {
let style: UIBlurEffect.Style

func makeUIView(context: UIViewRepresentableContext<Blur>) -> UIView {
    let view = UIView(frame: .zero)
    view.backgroundColor = .clear
    let blurEffect = UIBlurEffect(style: style)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.translatesAutoresizingMaskIntoConstraints = false
    view.insertSubview(blurView, at: 0)
    NSLayoutConstraint.activate([
        blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
        blurView.heightAnchor.constraint(equalTo: view.heightAnchor)
    ])
    return view
}

func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Blur>) {

}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
