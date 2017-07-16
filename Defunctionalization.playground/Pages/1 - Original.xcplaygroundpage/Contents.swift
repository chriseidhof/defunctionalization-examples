//: [Previous](@previous)

import UIKit

func load<A>(_ url: URL, parse: @escaping (Data) -> A?, callback: @escaping (A?) -> ()) {
    URLSession.shared.dataTask(with: url) { (data, _, _) in
        callback(data.flatMap(parse))
    }.resume()
}

let randomGIF: URL = URL(string: "http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC")!
let iv = UIImageView(frame: .init(x: 0, y: 0, width: 320, height: 480))

load(randomGIF, parse: { data -> URL? in
    guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
        let dict = json as? [String:Any],
    let data = dict["data"] as? [String:Any],
    let url = data["fixed_height_small_url"] as? String
        else { return nil }
    return URL(string: url)
}, callback: { imageURL in
    guard let url = imageURL else { return }
    load(url, parse: { UIImage(data: $0) }) { image in
        DispatchQueue.main.async {
            iv.image = image
        }
    }
})



// We cannot defunctionalize parse, because it's return type is polymorphic?
// Can this be done with a protocol + associated type?
