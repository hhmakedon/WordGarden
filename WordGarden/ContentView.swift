//
//  ContentView.swift
//  WordGarden
//
//  Created by Havee Makedon on 7/28/25.
//

import SwiftUI
import AVFAudio


struct ContentView: View {
    private static let maximumGuesses = 8
    //refer to as Self.maximumGuesses
    @State private var wordsGuessed = 0
    @State private var wordsMissed = 0
    private let wordsToGuess = ["SWIFT", "DOG", "CAT"]
    @State private var gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
    @State private var currentWordIndex = 0
    @State private var wordToGuess = ""
    @State private var revealedWord = ""
    @State private var letterGuessed = ""
    @State private var guessedLetter = ""
    @State private var imageName = "flower8"
    @State private var guessRemaining = maximumGuesses
    @State private var playAgainHidden = true
    @State private var playAgainButtonLabel = "Another Word?"
    @State private var audioPlayer: AVAudioPlayer!
    @FocusState private var textFieldIsFocused: Bool
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack {
                HStack {
                    VStack(alignment: .leading){
                        Text("Words Guessed: \(wordsGuessed)")
                        Text("Words Missed: \(wordsMissed)")
                    }
                    Spacer()
                    VStack(alignment: .trailing){
                        Text("Words to Guess: \(wordsToGuess.count - (wordsGuessed + wordsMissed))")
                        Text("Words in Game: \(wordsToGuess.count)")
                    }
                }
                .padding(.horizontal)
                Spacer()
                Text(gameStatusMessage)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .frame(height: 80)
                    .minimumScaleFactor(0.5)
                    .padding()
                Text(revealedWord)
                    .font(.title)
                if playAgainHidden {
                    HStack{
                        TextField("", text: $guessedLetter)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 30)
                            .colorScheme(.light)
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray, lineWidth: 2)
                            }
                            .keyboardType(.asciiCapable)
                            .submitLabel(.done)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.characters)
                            .onChange(of: guessedLetter) {
                                guessedLetter = guessedLetter.trimmingCharacters(in: .letters.inverted)
                                guard let lastChar = guessedLetter.last else { return }
                                guessedLetter = String(lastChar).uppercased()
                            }
                            .focused($textFieldIsFocused)
                            .onSubmit {
                                //as long as guessed letter isn't empty, guard will
                                //let us through
                                guard guessedLetter != "" else { return }
                                guessALetter()
                                updateGamePlay()
                            }
                        Button("Guess a Letter:") {
                            guessALetter()
                            updateGamePlay()
                        }
                        .buttonStyle(.bordered)
                        .colorScheme(.light)
                        .tint(.mint)
                        .disabled(guessedLetter.isEmpty)
                    }
                } else {
                    Button(playAgainButtonLabel) {
                        //if all the words have been guessed
                        if currentWordIndex == wordsToGuess.count {
                            currentWordIndex = 0
                            wordsGuessed = 0
                            wordsMissed = 0
                            playAgainButtonLabel = "Another Words?"
                        }
                        //reset game
                        wordToGuess = wordsToGuess[currentWordIndex]
                        revealedWord = "_" + String(repeating: " _", count: wordToGuess.count-1)
                        letterGuessed = ""
                        guessRemaining = Self.maximumGuesses
                        imageName = "flower\(guessRemaining)"
                        gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
                        playAgainHidden = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.mint)
                }
                Spacer()
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .animation(.easeInOut(duration: 0.75), value: imageName)
            }
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                wordToGuess = wordsToGuess[currentWordIndex]
                revealedWord = "_" + String(repeating: " _", count: wordToGuess.count-1)
            }
        }
        .foregroundStyle(.black)
        .preferredColorScheme(.light)
    }
    
    
    func guessALetter() {
        textFieldIsFocused = false
        letterGuessed = letterGuessed + guessedLetter
        revealedWord = wordToGuess.map{ letter in letterGuessed.contains(letter) ? "\(letter)" : "_"
        }.joined(separator: " ")
    }
    func updateGamePlay() {
        if !wordToGuess.contains(guessedLetter) {
            guessRemaining -= 1
            //animate leaf and play sound
            imageName = "wilt\(guessRemaining)"
            playSound(soundName: "incorrect")
            //delay change to flower image
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75){
                imageName = "flower\(guessRemaining)"
            }
        } else {
            playSound(soundName: "correct")
        }
        //when do we play another word
        if !revealedWord.contains("_"){
            gameStatusMessage = "You Guessed It! It Took You \(letterGuessed.count) Guesses To Guess The Word."
            wordsGuessed += 1
            currentWordIndex += 1
            playAgainHidden = false
            playSound(soundName: "word-guessed")
        } else if guessRemaining == 0 {
            gameStatusMessage = "So Sorry, You're All Out Of Guesses"
            wordsMissed += 1
            currentWordIndex += 1
            playAgainHidden = false
            playSound(soundName: "word-not-guessed")
        } else {
            gameStatusMessage = "You've Made \(letterGuessed.count) Guess\(letterGuessed.count == 1 ? "" : "es")"
        }
        
        if currentWordIndex == wordsToGuess.count {
            playAgainButtonLabel = "Restart Game?"
            gameStatusMessage = gameStatusMessage + "\nYou've Tried All the Words. Would You Like to Restart?"
        }
        
        guessedLetter = ""
    }
    func playSound(soundName: String) {
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("😡 ERROR: Could not read file named \(soundName).")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            print("😡 ERROR: \(error.localizedDescription) when trying to create audioPlayer.")
        }
    }
}

#Preview {
    ContentView()
}
