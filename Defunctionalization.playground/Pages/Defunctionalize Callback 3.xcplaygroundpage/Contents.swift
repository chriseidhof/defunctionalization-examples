//: [Previous](@previous)

import UIKit

enum Effect {
    case load(Callback)
    case setImage(UIImage)
}

struct Callback {
    enum CType { case data, image }
    let imageView: UIImageView
    let type: CType
    let url: URL



    func apply(_ data: Data) -> Effect? {
        switch type {
        case .data:
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let dict = json as? [String:Any],
                let data = dict["data"] as? [String:Any],
                let urlString = data["fixed_height_small_url"] as? String,
                let url = URL(string: urlString)
                else { return nil }
            return .load(Callback(imageView: imageView, type: .image, url: url))
        case .image:
            guard let image = UIImage(data: data) else { return nil }
            return .setImage(image)
        }
    }
}

func interpret(effect: Effect) {
    switch effect {
    case .load(let cb):
        load(cb)
    case .setImage(let i):
        iv.image = i
    }
}

func load(_ callback: Callback) {
    URLSession.shared.dataTask(with: callback.url) { (data, _, _) in
        guard let data = data else { return }
        if let e = callback.apply(data) {
            interpret(effect: e)
        }
    }.resume()
}

let randomGIF: URL = URL(string: "http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC")!
let iv = UIImageView(frame: .init(x: 0, y: 0, width: 320, height: 480))

load(Callback(imageView: iv, type: .data, url: randomGIF))
