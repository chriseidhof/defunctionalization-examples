//: [Previous](@previous)

import UIKit

enum Callback {
    case loadData(UIImageView)
    case loadImage(UIImageView)

    func apply(_ data: Data) {
        switch self {
        case .loadData(let imageView):
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let dict = json as? [String:Any],
                let data = dict["data"] as? [String:Any],
                let urlString = data["fixed_height_small_url"] as? String,
                let url = URL(string: urlString)
                else { return }
            load(url, .loadImage(imageView))
        case .loadImage(let iv):
            guard let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                iv.image = image
            }
        }
    }
}

func load(_ url: URL, _ callback: Callback) {
    URLSession.shared.dataTask(with: url) { (data, _, _) in
        guard let data = data else { return }
        callback.apply(data)
    }.resume()
}

let randomGIF: URL = URL(string: "http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC")!
let iv = UIImageView(frame: .init(x: 0, y: 0, width: 320, height: 480))

load(randomGIF, .loadData(iv))
