//
//  SearchForGifsView.swift
//  API-TEST-APP
//
//  Created by Daniel Spalek on 04/09/2022.
//

import SwiftUI

struct GiphySearchResultData: Codable {
    let data: [GiphySearchResult]
}

struct GiphySearchResult: Codable, Identifiable {
    var id: String
    let url: String
}

struct SearchForGifsView: View {
    @State var searchTerm: String = ""
    @State var results: Array<String> = [String]()
    var body: some View {
        VStack {
            // Search form and button
            HStack(spacing: 7){
                TextField(text: $searchTerm) {
                    Text("Search for gif...")
                }
                .padding(6)
                .padding(.horizontal, 4)
                .background {
                    Color(.systemGray6)
                        .cornerRadius(6.6)
                }
                Button {
                    searchGifsWith(searchTerm: searchTerm)
                } label: {
                    Text("Search")
                }
                .buttonStyle(.bordered)

            }
            .padding()
            ScrollView(.vertical) {
                VStack(spacing: 20) {
                    // content
                    ForEach(results, id: \.self) { urlString in
                        Button {
                            guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
                                print("Error: URL Could not be created from urlString. or URL Could not be opened")
                                return
                            }
                            UIApplication.shared.open(url) // open in browser
                            
                        } label: {
                            Text(urlString)
                                .underline(true, pattern: .solid, color: .blue)
                        }

                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func searchGifsWith(searchTerm term: String) {
        // first reset the search results
        results = Array<String>()
        let urlString: String = "https://api.giphy.com/v1/gifs/search?api_key=\(giphyApiKey)&q=\(term)&limit=25&offset=0&rating=g&lang=en"
        
        let task = URLSession.shared.dataTask(with: URL(string: urlString)!) { data, response, error in
            guard let data = data, error == nil else {
                print("data was nil or we got an error.")
                return
            }
            var allResults: GiphySearchResultData?
            do {
                allResults = try JSONDecoder().decode(GiphySearchResultData.self, from: data)
            } catch {
                print("Decoding error: \(error.localizedDescription)")
            }
            
            guard let allResults = allResults else {return}
            
            for giphyObject in allResults.data {
                /* a GiphySearchResult is identifiable because the api url returns an id property too for each object */
                results.append(giphyObject.url)
            }
            
        }
        task.resume()
    }
}

struct SearchForGifsView_Previews: PreviewProvider {
    static var previews: some View {
        SearchForGifsView()
    }
}
