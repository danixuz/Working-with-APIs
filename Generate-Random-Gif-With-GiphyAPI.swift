//
//  GiphyView.swift
//  API-TEST-APP
//
//  Created by Daniel Spalek on 04/09/2022.
//

import SwiftUI

// MARK: This is a different approach to fetching and using API Key.

/* In a real app, we would need to keep the apiKey in a seperate secure file. */
let giphyApiKey: String = "*****************"

struct GIPHYStructure: Decodable {
    let data: GIPHYDataStructure
}

struct GIPHYDataStructure: Decodable {
    let url: String
}

struct GiphyView: View {
    @State var gifUrl: String?
    
    var body: some View {
        VStack(spacing: 20) {
            if let gifUrl = gifUrl {
                Button {
                    let url = URL(string: gifUrl)
                    guard let GiphyURL = url, UIApplication.shared.canOpenURL(GiphyURL) else {return}
                    UIApplication.shared.open(GiphyURL) // this should open in safari
                } label: {
                    Text("\(gifUrl)")
                        .underline(true, pattern: .solid, color: .blue)
                }
            } else {
                Text("Loading...")
                    .onAppear {
                        fetchAPI()
                    }
            }

            // refresh
            Button {
                fetchAPI()
            } label: {
                Text("get random gif")
            }
        }


    }
    
    // Different approach
    func fetchAPI() {
        let url = URL(string: "https://api.giphy.com/v1/gifs/random?api_key=\(giphyApiKey)&tag=&rating=g") // This generates random gif
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription)")
                return
            }
            
            var allData: GIPHYStructure?
            do {
                try allData = JSONDecoder().decode(GIPHYStructure.self, from: data)
            } catch {
                print(error.localizedDescription)
            }
            
            if let allData = allData {
                /* because we defined the function in the GiphyView struct we can access the variables of the struct: */
                self.gifUrl = allData.data.url
            } else {
                print("Could not fetch data")
            }
            /* We are getting more data from the API call but we only want the gif url (not the username, source, type...) so we only create the url variable in the GIPHYDataStructure. It still decodes fine and this way it saves only the info we want.*/
        }
        task.resume()
    }
}

struct GiphyView_Previews: PreviewProvider {
    static var previews: some View {
        GiphyView()
    }
}
