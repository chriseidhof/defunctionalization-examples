//: [Previous](@previous)

import UIKit

let randomGIF: URL = URL(string: "http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC")!
let iv = UIImageView(frame: .init(x: 0, y: 0, width: 320, height: 480))

struct Resource<Result> {
    var url: URL
    var parse: (Data) -> Result?
}

let dataResource = Resource<URL>(url: randomGIF) { data in
    guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
        let dict = json as? [String:Any],
        let data = dict["data"] as? [String:Any],
        let url = data["fixed_height_small_url"] as? String
        else { return nil }
    return URL(string: url)
}

func imageResource(url: URL) -> Resource<UIImage> {
    return Resource(url: url, parse: UIImage.init(data:))
}

func loadP<A>(_ resource: Resource<A>, callback: @escaping (A?) -> ()) {
    URLSession.shared.dataTask(with: resource.url) { (data, _, _) in
        callback(data.flatMap(resource.parse))
        }.resume()
}

loadP(dataResource) { url in
    guard let url = url else { return }
    loadP(imageResource(url: url)) { image in
        DispatchQueue.main.async {
            iv.image = image
        }
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = iv

//: [Next](@next)
