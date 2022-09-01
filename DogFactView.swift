//
//  DogFactView.swift
//  API-TEST-APP
//
//  Created by Daniel Spalek on 01/09/2022.
//

import SwiftUI

let urlDogString: String = "https://dog-api.kinduff.com/api/facts"

struct DogFactResult: Codable {
    var facts: [String]
    var success: Bool
}

private func fetchDogFact(completionHandler: @escaping (String) -> Void) {
    // getting url object from string
    // first method (might not work on physical device)
//    var comps = URLComponents()
//    comps.scheme = "http"
//    comps.host = "dog-api.kinduff.com/api/facts"
//    let dogURL = comps.url
    // second method that works on physical device
    let dogURL = URL(string: urlDogString)
    
    // making api call
    let task = URLSession.shared.dataTask(with: dogURL!) { data, response, error in
        guard let data = data, error == nil else {
            print("Fetched data was either nil or there was an error: \(error?.localizedDescription)")
            return
        }
        // coding result data to DogFactResult
        var result: DogFactResult?
        do {
            result = try JSONDecoder().decode(DogFactResult.self, from: data)
        } catch {
            print("There was an error when trying to decode the data: \(error.localizedDescription)")
        }
        // checking that result is not nil and passing result to the escaping function
        guard let result = result else {
            print("Result data was nil after decoding")
            return
        }
        
//        completionHandler(result)
        // we can also pass in the dog fact immediately instead of the entire object by changing the completion handler to return a String instead of a DogFactResult.
        completionHandler(result.facts[0]) // this should give us the generated fact
    }
    task.resume()
}

struct DogFactView: View {
    
    @State var randomDogFact: String?
    var body: some View {
        VStack{
            Text("Dog Fact API Call demo. Generates random dog fact. used https://dog-api.kinduff.com/api/facts")
                .multilineTextAlignment(.center)
                .bold()
            Group {
                Text("____________________________________")
                Text(randomDogFact ?? "")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .padding(20)
                Text("____________________________________")
            }
            
            Button {
                fetchDogFact { fact in
                    randomDogFact = fact
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            Text("Press button to generate random dog fact.")
            

        }
        .padding()
    }
}

struct DogFactView_Previews: PreviewProvider {
    static var previews: some View {
        DogFactView()
    }
}
