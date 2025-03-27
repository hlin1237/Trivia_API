//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by Huimin Lin on 3/26/25.
//

import Foundation

class TriviaQuestionService {
    static let shared = TriviaQuestionService()

    func fetchQuestions(amount: Int = 10, completion: @escaping ([TriviaQuestion]) -> Void) {
        // Mix of multiple choice and True/False
        guard let url = URL(string: "https://opentdb.com/api.php?amount=\(amount)&type=any") else {
            print("❌ Invalid URL")
            completion([])
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching questions: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let data = data else {
                print("❌ No data returned from API")
                completion([])
                return
            }

            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(TriviaAPIResponse.self, from: data)
                completion(apiResponse.results)
            } catch {
                print("❌ Decoding error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 Raw JSON: \(jsonString)")
                }
                completion([])
            }
        }

        task.resume()
    }
}
