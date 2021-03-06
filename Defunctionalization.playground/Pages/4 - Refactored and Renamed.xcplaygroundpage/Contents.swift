//: [Previous](@previous)

import UIKit

let randomGIF: URL = URL(string: "http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC")!
let iv = UIImageView(frame: .init(x: 0, y: 0, width: 320, height: 480))

// This is just renaming things:

protocol Resource {
    associatedtype Result
    func parse(_ data: Data) -> Result?
    var url: URL { get }
}

struct DataResource: Resource {
    var url: URL
    
    func parse(_ data: Data) -> URL? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let dict = json as? [String:Any],
            let data = dict["data"] as? [String:Any],
            let url = data["fixed_height_small_url"] as? String
            else { return nil }
        return URL(string: url)
    }
}

struct ImageResource: Resource {
    var url: URL
    func parse(_ data: Data) -> UIImage? {
        return UIImage(data: data)
    }
}


func loadP<R, A>(_ resource: R, callback: @escaping (A?) -> ()) where R: Resource, R.Result == A {
    URLSession.shared.dataTask(with: resource.url) { (data, _, _) in
        callback(data.flatMap(resource.parse))
        }.resume()
}

loadP(DataResource(url: randomGIF)) { url in
    guard let url = url else { return }
    loadP(ImageResource(url: url)) { image in
        DispatchQueue.main.async {
            iv.image = image
        }
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = iv

//: [Next](@next)
