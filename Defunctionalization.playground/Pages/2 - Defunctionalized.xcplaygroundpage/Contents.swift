//: [Previous](@previous)

import UIKit

let randomGIF: URL = URL(string: "http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC")!
let iv = UIImageView(frame: .init(x: 0, y: 0, width: 320, height: 480))

// Because Swift doesn't have GADTs, we need to split up our "Lam" enum based on the result type. We can then "unify" them using a protocol "Parse":

protocol Parse {
    associatedtype Result
    func apply(_ data: Data) -> Result?
}

// Data results
enum ParseData: Parse {
    case data
    
    func apply(_ data: Data) -> URL? {
        switch self {
        case .data:
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let dict = json as? [String:Any],
                let data = dict["data"] as? [String:Any],
                let url = data["fixed_height_small_url"] as? String
                else { return nil }
            return URL(string: url)
        }
    }
}

// Image results
enum ParseImage: Parse {
    case image
    func apply(_ data: Data) -> UIImage? {
        switch self {
        case .image:
            return UIImage(data: data)
        }
    }
}


func loadP<P, A>(_ url: URL, parse p: P, callback: @escaping (A?) -> ()) where P: Parse, P.Result == A {
    URLSession.shared.dataTask(with: url) { (data, _, _) in
        callback(data.flatMap(p.apply))
        }.resume()
}

loadP(randomGIF, parse: ParseData.data) { url in
    guard let url = url else { return }
    loadP(url, parse: ParseImage.image, callback: { image in
        DispatchQueue.main.async {            
            iv.image = image
        }
    })
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = iv

//: [Next](@next)
