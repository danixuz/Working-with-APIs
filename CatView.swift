//
//  CatView.swift
//  API-TEST-APP
//
//  Created by Daniel Spalek on 31/08/2022.
//

import SwiftUI

// Calling cat api and fetching random cat image:
let catAPIStringURL: String = "https://api.thecatapi.com/v1/images/search"
struct CatResponse: Codable {
    var id: String
    var url: String
    var width: Int
    var height: Int
}
var catArray: [Any] = []

// MARK: This code works.
func fetchCat(completionHandler: @escaping (CatResponse) -> Void) {
    // This function will return a CatResponse object, we can then load the image from it's url.
    // API url: (We should always use URLComponents instead of URL(string:)
    var comps = URLComponents()
    // this works in xcode simulator but not on physical iphone. the url is returned as "https" only:
    /*
     comps.scheme = "https"
     comps.host = "api.thecatapi.com/v1/images/search"
     let url: URL? = comps.url
     */
    // this works on physical iPhone:
    let url = URL(string: catAPIStringURL)
    
    // make the call
    let task = URLSession.shared.dataTask(with: url!) { data, response, error in
        guard let data = data, error == nil else {
            print("There was an error or nil data.: \(error?.localizedDescription)")
            return
        }
        // now we want to convert the data from Bytes to the struct. Also known as json decoding.
        var result: CatResponse?
        do {
            result = try JSONDecoder().decode([CatResponse].self, from: data)[0]
        } catch {
            print("error occured trying to convert data. \(error.localizedDescription)")
        }
        
        guard let json = result else {
            return
        }
        
        completionHandler(json) // passing the result to the escaping function. the escaping function is called after this function ends.
        
        
    }
    task.resume()
    
}

struct CatView: View {
    @State var catImageURL: URL?
    var body: some View {
        VStack{
            Text("Cat API Call demo. Generates a random cat image. used https://docs.thecatapi.com.")
                .multilineTextAlignment(.center)
                .bold()
            // best way for image from url. we want the option with url, image and placeholder. so we can modify the image.
            AsyncImage(url: catImageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 300)
                    .clipped() // so the image doesn't escape the frame.
            } placeholder: {
                // placeholder if nil or loading
                VStack{
                    Text("Image Placholder")
                    Text("Press the button to load image.")
                }
                .padding(100)
            }

            Button {
                fetchCat { cat in
                    catImageURL = URL(string: cat.url)
                }
            } label: {
                VStack{
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                }
            }
            .padding()
            Text("tap to Load new image.")
                .bold()
                .foregroundColor(.blue)

        }
    }
}

struct CatView_Previews: PreviewProvider {
    static var previews: some View {
        CatView()
    }
}
