//
//  ViewController.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import UIKit

class TriviaViewController: UIViewController {
  
  @IBOutlet weak var currentQuestionNumberLabel: UILabel!
  @IBOutlet weak var questionContainerView: UIView!
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var answerButton0: UIButton!
  @IBOutlet weak var answerButton1: UIButton!
  @IBOutlet weak var answerButton2: UIButton!
  @IBOutlet weak var answerButton3: UIButton!
  
  private var questions = [TriviaQuestion]()
  private var currQuestionIndex = 0
  private var numCorrectQuestions = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addGradient()
    questionContainerView.layer.cornerRadius = 8.0
    fetchQuestions()
    // TODO: FETCH TRIVIA QUESTIONS HERE
  }
    private func fetchQuestions() {
        guard let url = URL(string: "https://opentdb.com/api.php?amount=10&type=multiple") else {
            print("❌ Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching questions: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data returned from API")
                return
            }

            do {
                let decoder = JSONDecoder()
                // Removed .convertFromSnakeCase to allow custom CodingKeys to work properly
                let apiResponse = try decoder.decode(TriviaAPIResponse.self, from: data)

                DispatchQueue.main.async {
                    self.questions = apiResponse.results
                    self.currQuestionIndex = 0
                    self.numCorrectQuestions = 0

                    print("✅ Successfully fetched \(self.questions.count) questions")
                    if let first = self.questions.first {
                        print("🔍 First question: \(first.question)")
                    }

                    self.updateQuestion(withQuestionIndex: self.currQuestionIndex)
                }
            } catch {
                print("❌ Failed to decode: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🔍 Raw JSON: \(jsonString)")
                }
            }
        }

        task.resume()
    }
    private func updateQuestion(withQuestionIndex questionIndex: Int) {
        currentQuestionNumberLabel.text = "Question: \(questionIndex + 1)/\(questions.count)"
        
        let question = questions[questionIndex]
        questionLabel.text = question.question.decoded
        categoryLabel.text = question.category.decoded
        
        let answers = ([question.correctAnswer] + question.incorrectAnswers).shuffled()
        let buttons = [answerButton0, answerButton1, answerButton2, answerButton3]
        
        for (index, button) in buttons.enumerated() {
            if index < answers.count {
                button?.setTitle(answers[index].decoded, for: .normal)
                button?.isHidden = false
            } else {
                button?.isHidden = true
            }
        }
    }
  
    private func updateToNextQuestion(answer: String, selectedButton: UIButton) {
        let isCorrect = isCorrectAnswer(answer)

        // Change color of selected button
        selectedButton.backgroundColor = isCorrect ? UIColor.systemGreen : UIColor.systemRed

        // Disable all answer buttons temporarily
        let buttons = [answerButton0, answerButton1, answerButton2, answerButton3]
        buttons.forEach { $0?.isEnabled = false }

        if isCorrect {
            numCorrectQuestions += 1
        }

        // Wait for 1 second, then move on
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Reset button colors
            buttons.forEach {
                $0?.backgroundColor = UIColor.systemBlue
                $0?.isEnabled = true
            }

            self.currQuestionIndex += 1
            guard self.currQuestionIndex < self.questions.count else {
                self.showFinalScore()
                return
            }

            self.updateQuestion(withQuestionIndex: self.currQuestionIndex)
        }
    }
  
  private func isCorrectAnswer(_ answer: String) -> Bool {
    return answer == questions[currQuestionIndex].correctAnswer
  }
  
  private func showFinalScore() {
    let alertController = UIAlertController(title: "Game over!",
                                            message: "Final score: \(numCorrectQuestions)/\(questions.count)",
                                            preferredStyle: .alert)
    let resetAction = UIAlertAction(title: "Restart", style: .default) { [unowned self] _ in
      currQuestionIndex = 0
      numCorrectQuestions = 0
      updateQuestion(withQuestionIndex: currQuestionIndex)
     fetchQuestions()
    }
    alertController.addAction(resetAction)
    present(alertController, animated: true, completion: nil)
  }
  
  private func addGradient() {
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = view.bounds
    gradientLayer.colors = [UIColor(red: 0.54, green: 0.88, blue: 0.99, alpha: 1.00).cgColor,
                            UIColor(red: 0.51, green: 0.81, blue: 0.97, alpha: 1.00).cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
    view.layer.insertSublayer(gradientLayer, at: 0)
  }
  
  @IBAction func didTapAnswerButton0(_ sender: UIButton) {
      updateToNextQuestion(answer: sender.titleLabel?.text ?? "", selectedButton: sender)
  }
  
  @IBAction func didTapAnswerButton1(_ sender: UIButton) {
      updateToNextQuestion(answer: sender.titleLabel?.text ?? "", selectedButton: sender)
  }
  
  @IBAction func didTapAnswerButton2(_ sender: UIButton) {
      updateToNextQuestion(answer: sender.titleLabel?.text ?? "", selectedButton: sender)
  }
  
  @IBAction func didTapAnswerButton3(_ sender: UIButton) {
      updateToNextQuestion(answer: sender.titleLabel?.text ?? "", selectedButton: sender)
  }
}

extension String {
    var decoded: String {
        let encodedData = Data(self.utf8)
        let attributed = try? NSAttributedString(
            data: encodedData,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        return attributed?.string ?? self
    }
}
