//: [Previous](@previous)

import UIKit

let randomGIF: URL = URL(string: "http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC")!
let iv = UIImageView(frame: .init(x: 0, y: 0, width: 320, height: 480))

// A value of Parse is always used in combination with a URL, so we can include that in the protocol:

protocol Parse {
    associatedtype Result
    func apply(_ data: Data) -> Result?
    var url: URL { get }
}

// We might just as well rewrite ParseData as a struct, there's only one case anyway
struct ParseData: Parse {
    var url: URL
    
    func apply(_ data: Data) -> URL? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let dict = json as? [String:Any],
            let data = dict["data"] as? [String:Any],
            let url = data["fixed_height_small_url"] as? String
            else { return nil }
        return URL(string: url)
    }
}

// Image results
struct ParseImage: Parse {
    var url: URL
    func apply(_ data: Data) -> UIImage? {
        return UIImage(data: data)
    }
}


func loadP<P, A>(_ p: P, callback: @escaping (A?) -> ()) where P: Parse, P.Result == A {
    URLSession.shared.dataTask(with: p.url) { (data, _, _) in
        callback(data.flatMap(p.apply))
        }.resume()
}

loadP(ParseData(url: randomGIF)) { url in
    guard let url = url else { return }
    loadP(ParseImage(url: url)) { image in
        DispatchQueue.main.async {
            iv.image = image
        }
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = iv

//: [Next](@next)
