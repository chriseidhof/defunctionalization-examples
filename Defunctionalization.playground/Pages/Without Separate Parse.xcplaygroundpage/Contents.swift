//: [Previous](@previous)

import UIKit

func load(_ url: URL, callback: @escaping (Data?) -> ()) {
    URLSession.shared.dataTask(with: url) { (data, _, _) in
        callback(data)
        }.resume()
}

let randomGIF: URL = URL(string: "http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC")!
let iv = UIImageView(frame: .init(x: 0, y: 0, width: 320, height: 480))

load(randomGIF, callback: { data in
    guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
        let dict = json as? [String:Any],
        let data = dict["data"] as? [String:Any],
        let urlString = data["fixed_height_small_url"] as? String,
        let url = URL(string: urlString)
        else { return }
    load(url) { imageData in
        guard let image = UIImage(data: imageData) else { return }
        DispatchQueue.main.async {
            iv.image = image
        }
    }
})
