import SwiftUI
import NaturalLanguage

struct ContentView: View {
    @State private var inputText = ""
    @State private var moodText = "Type something to analyze your mood!"
    @State private var backgroundGradient = [Color.gray, Color.gray.opacity(0.5)]
    @State private var emoji = "😐"
    @State private var showEmoji = false

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(gradient: Gradient(colors: backgroundGradient),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.0), value: backgroundGradient)

            VStack(spacing: 25) {
                Text("🧠 Mood Detector")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding(.top, 40)

                Spacer()

                VStack(spacing: 15) {
                    TextField("💭 What's on your mind?", text: $inputText)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .shadow(radius: 3)
                        .padding(.horizontal, 30)

                    Button(action: detectMood) {
                        Text("Analyze Mood")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(radius: 3)
                            .padding(.horizontal, 30)
                    }

                    VStack(spacing: 8) {
                        Text(emoji)
                            .font(.system(size: 60))
                            .padding(.bottom, 5)

                        Text(moodText)
                            .font(.title3)
                            .foregroundColor(.white)
                            .bold()
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                    .transition(.opacity)
                }

                Spacer()

                // Floating Emoji Animation
                if showEmoji {
                    FloatingEmoji(emoji: emoji)
                        .transition(.scale)
                }

                Spacer()
            }
        }
    }

    // MARK: - Mood Detection
    func detectMood() {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = inputText

        let (sentiment, _) = tagger.tag(at: inputText.startIndex, unit: .paragraph, scheme: .sentimentScore)
        guard let score = sentiment?.rawValue, let sentimentScore = Double(score) else {
            updateMood(mood: "😐", text: "Couldn't understand. Try again!", colors: [.gray, .gray.opacity(0.4)])
            return
        }

        if sentimentScore > 0.25 {
            updateMood(mood: "😊", text: "You seem happy and positive!", colors: [.yellow, .orange])
        } else if sentimentScore < -0.25 {
            updateMood(mood: "😢", text: "Feeling down? Take a deep breath 🌧️", colors: [.blue, .purple])
        } else {
            updateMood(mood: "😐", text: "You’re feeling neutral today.", colors: [.gray, .black.opacity(0.6)])
        }
    }

    // MARK: - Update Mood State
    func updateMood(mood: String, text: String, colors: [Color]) {
        withAnimation(.easeInOut(duration: 0.7)) {
            self.emoji = mood
            self.moodText = text
            self.backgroundGradient = colors
            self.showEmoji = true
        }

        // Hide floating emoji after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                self.showEmoji = false
            }
        }
    }
}

// MARK: - Floating Emoji Animation
struct FloatingEmoji: View {
    let emoji: String
    @State private var floatUp = false

    var body: some View {
        Text(emoji)
            .font(.system(size: 80))
            .opacity(0.8)
            .offset(y: floatUp ? -300 : 100)
            .animation(Animation.easeOut(duration: 2.5).repeatCount(1, autoreverses: false), value: floatUp)
            .onAppear {
                floatUp = true
            }
    }
}
