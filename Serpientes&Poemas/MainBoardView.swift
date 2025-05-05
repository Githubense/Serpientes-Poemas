import SwiftUI
import Vortex
import AVFoundation

struct MainBoardView: View {
    @State private var showGameBoard = false
    
    var body: some View {
        ZStack {
            Image("background2")
                .resizable()
                .ignoresSafeArea()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            VortexView(createSnow()) {
                Image("leaf")
                    .frame(width: 1)
                    .tag("leaf")
            }
            .ignoresSafeArea()
            
            VStack() {
                Text("Serpientes")
                    .font(Font.custom("BagelFatOne-Regular", size: 60))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.lightGreen)
                    .padding(.bottom, -10)
                    .padding(.top, 0)
                Text("&")
                    .font(Font.custom("ChelseaMarket-Regular", size: 30))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.lightGreen)
                    .padding(.vertical,-10)
                Text("Poemas")
                    .font(Font.custom("FleurDeLeah-Regular", size: 80))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.lightGreen)
                    .padding(.top,-20)
                    .padding(.bottom, 30)
                
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0)) {
                        showGameBoard = true
                    }
                }) {
                    Text("Empezar")
                        .font(Font.custom("ChelseaMarket-Regular", size: 25))
                        .bold()
                        .padding()
                        .frame(width: 202, height: 79)
                        .background(
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 202, height: 79)
                                .background(Color(red: 0.51, green: 0.83, blue: 0.51))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .inset(by: 3.5)
                                        .stroke(Color(red: 0.31, green: 0.75, blue: 0.55), lineWidth: 7)
                                )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: .gray, radius: 4, x: 2, y: 2)
                }
                .padding(.bottom, -20)
            }
        }
        .fullScreenCover(isPresented: $showGameBoard) {
            GameBoardView()
                .transition(.scale(scale: 0.8, anchor: .center)) // Scale transition
        }
    }
}

struct GameBoardView: View {
    // MARK: - Layout Constants
    let rows = 6
    let columns = 8
    
    // MARK: - Verse Spaces
    let verseSpaces: [Int: String] = [
        4: "Verse 1: The journey begins.",
        10: "Verse 2: A twist in the path.",
        18: "Verse 3: Overcoming the climb.",
        25: "Verse 4: The calm before the storm.",
        34: "Verse 5: A shining horizon."
    ]
    let totalSpaces: Int
    
    // MARK: - State Properties
    @State private var playerPosition = 0 // Start position of the player
    @State private var collectedVerses: [String] = [] // List of collected verses
    @State private var showDetailView = false // Controls the detailed view
    @State private var showEndGameView = false // Controls the end-game view
    
    @AppStorage("playerPosition") private var savedPlayerPosition = 0
    @AppStorage("collectedVerses") private var savedCollectedVerses = ""

    @Namespace private var animationNamespace

    init() {
        totalSpaces = rows * columns
        playerPosition = savedPlayerPosition
        collectedVerses = savedCollectedVerses.isEmpty ? [] : savedCollectedVerses.components(separatedBy: "|")
    }
    
    private func resetGame() {
        playerPosition = 0
        collectedVerses = []
        saveGameState()
        showEndGameView = false
        showDetailView = false
    }
    var body: some View {
        ZStack {
            Color.teal.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                HStack {
                    boardGrid
                        .padding()
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        collectedVersesView
                        diceButton
                        Text("Posición actual: \(playerPosition)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showDetailView = true
                            }
                        }) {
                            Text("Show Detail")
                        }
                    }
                    .frame(width: 200)
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showDetailView) {
            if showEndGameView {
                EndGameView(collectedVerses: collectedVerses, dismissAction: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        resetGame()
                    }
                })
            } else {
                DetailView(position: playerPosition, verse: verseSpaces[playerPosition], totalSpaces: totalSpaces, dismissAction: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showDetailView = false
                    }
                })
                .matchedGeometryEffect(id: "detailView", in: animationNamespace)
            }
        }
    }
    
    // MARK: - Subviews
    private var boardGrid: some View {
        GeometryReader { geometry in
            let cellWidth = geometry.size.width / CGFloat(columns)
            
            VStack(spacing: 0) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<columns, id: \.self) { column in
                            let position = calculatePosition(row: row, column: column)
                            ZStack {
                                // Use specific images for the first and last spaces
                                if position == 0 {
                                    Image("start") // Image for the first space
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: cellWidth, height: cellWidth)
                                        .cornerRadius(10) // Add rounded corners
                                        .clipped()
                                } else if position == totalSpaces - 1 {
                                    Image("end") // Image for the last space
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: cellWidth, height: cellWidth)
                                        .cornerRadius(10) // Add rounded corners
                                        .clipped()
                                } else {
                                    // Display the image for the current position or fallback to default
                                    Image(UIImage(named: String(format: "%02d", position)) != nil ? String(format: "%02d", position) : "default_space")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: cellWidth, height: cellWidth)
                                        .cornerRadius(10) // Add rounded corners
                                        .clipped()
                                }
                                
                                // Highlight the player's current position
                                if position == playerPosition {
                                    Rectangle()
                                        .fill(Color.red.opacity(0.6))
                                        .frame(width: cellWidth / 2, height: cellWidth / 2)
                                        .cornerRadius(4)
                                        .matchedGeometryEffect(id: "playerPosition", in: animationNamespace)
                                }
                                
                                // Show an icon if the position contains a verse
                                if verseSpaces[position] != nil {
                                    Text("📜")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var collectedVersesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Versos Recogidos:")
                .font(.headline)
                .foregroundColor(.green)
            
            if collectedVerses.isEmpty {
                Text("Ningún verso recogido todavía.")
                    .font(.subheadline)
                    .foregroundColor(.white)
            } else {
                ForEach(collectedVerses, id: \.self) { verse in
                    Text(verse)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .transition(.opacity) // Fade in new verses
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: collectedVerses) // Animate changes to collectedVerses
    }
    
    private var diceButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)) {
                rollDice()
            }
        }) {
            Text("🎲")
                .font(.largeTitle)
                .padding()
                .background(Color.yellow)
                .cornerRadius(15)
                .scaleEffect(1.1) // Slightly larger button
                .shadow(color: .gray, radius: 4, x: 2, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0) // Reset scale after animation
    }
    
    // MARK: - Dice Roll Logic
    private func rollDice() {
        let diceRoll = Int.random(in: 1...6)
        let targetPosition = min(playerPosition + diceRoll, totalSpaces - 1)
        
        movePlayer(to: targetPosition)
    }

    private func movePlayer(to targetPosition: Int) {
        guard playerPosition < targetPosition else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let currentPosition = playerPosition // Store the current position before any updates
                
                if playerPosition == totalSpaces - 1 {
                    // Player has reached the end of the board
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showEndGameView = true
                        showDetailView = true // Show the EndGameView
                    }
                } else if let newPosition = checkSnakesAndStairs(at: playerPosition) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        playerPosition = newPosition
                    }
                    movePlayer(to: newPosition)
                } else {
                    if let verse = verseSpaces[currentPosition], !collectedVerses.contains(verse) {
                        collectedVerses.append(verse)
                        saveGameState()
                    }
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showDetailView = true
                    }
                }
            }
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                playerPosition += 1
            }
            movePlayer(to: targetPosition)
        }
    }

    private func checkSnakesAndStairs(at position: Int) -> Int? {
        let snakesAndStairs: [Int: Int] = [
            7: 23, 10: 27, 34: 44, // Stairs
            15: 3, 33: 18, 42: 22  // Snakes
        ]
        return snakesAndStairs[position]
    }
    
    private func saveGameState() {
        savedPlayerPosition = playerPosition
        savedCollectedVerses = collectedVerses.joined(separator: "|")
    }
    
    private func calculatePosition(row: Int, column: Int) -> Int {
        let reversedRow = rows - row - 1 // Reverse the row order
        if reversedRow % 2 == 0 {
            // Even row (from bottom): right-to-left
            return (reversedRow + 1) * columns - column - 1
        } else {
            // Odd row (from bottom): left-to-right
            return reversedRow * columns + column
        }
    }
}

struct DetailView: View {
    let position: Int
    let verse: String?
    let totalSpaces: Int
    let dismissAction: () -> Void
    
    @Namespace private var animationNamespace // Add this if not already present
    
    var body: some View {
        ZStack {
            Image("background2") // Background image
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Use specific images for the first and last spaces
                if position == 0 {
                    Image("start") // Image for the first space
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .cornerRadius(15)
                        .shadow(color: .gray, radius: 4, x: 2, y: 2)
                        .matchedGeometryEffect(id: "playerPosition", in: animationNamespace)
                } else if position == totalSpaces - 1 {
                    Image("end") // Image for the last space
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .cornerRadius(15)
                        .shadow(color: .gray, radius: 4, x: 2, y: 2)
                        .matchedGeometryEffect(id: "playerPosition", in: animationNamespace)
                } else {
                    // Display the image for the current position or fallback to default
                    Image(UIImage(named: String(format: "%02d", position)) != nil ? String(format: "%02d", position) : "default_space")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .cornerRadius(15)
                        .shadow(color: .gray, radius: 4, x: 2, y: 2)
                        .matchedGeometryEffect(id: "playerPosition", in: animationNamespace)
                }
                
                // Correct the position display to match the GameBoardView
                Text("Posición: \(position)") // Add +1 to match the 1-based index
                    .font(.largeTitle)
                    .foregroundColor(.green)
                
                if let verse = verse {
                    Text("Verso:")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(verse)
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.teal.opacity(0.8))
                        .cornerRadius(10)
                        .onAppear {
                            // Speak the verse
                            speakText(verse)
                            // Dismiss the view after the verse is read
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                dismissAction()
                            }
                        }
                } else {
                    Text("No hay verso aquí.")
                        .font(.body)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.teal.opacity(0.8))
                        .cornerRadius(10)
                        .onAppear {
                            // Dismiss the view after a short delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                dismissAction()
                            }
                        }
                }
            }
            .padding()
        }
    }
}

struct EndGameView: View {
    let collectedVerses: [String]
    let dismissAction: () -> Void

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("¡Felicidades!")
                    .font(.largeTitle)
                    .foregroundColor(.green)
                
                Text("Has terminado el juego. Aquí están los versos que recogiste:")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(collectedVerses, id: \.self) { verse in
                            Text(verse)
                                .font(.body)
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 300)
                .padding()
                .background(Color.teal.opacity(0.8))
                .cornerRadius(10)
                
                Button(action: {
                    collectedVerses.forEach { speakText($0) }
                    dismissAction()
                }) {
                    Text("Cerrar")
                        .font(.headline)
                        .foregroundColor(.teal)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .gray, radius: 4, x: 2, y: 2)
                }
                
                Button(action: {
                    dismissAction() // Reset the game and dismiss the view
                }) {
                    Text("Nueva Partida")
                        .font(.headline)
                        .foregroundColor(.teal)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .gray, radius: 4, x: 2, y: 2)
                }
            }
            .padding()
        }
    }
}

func createSnow() -> VortexSystem {
    let system = VortexSystem(tags: ["leaf"])
    system.birthRate = 1
    system.position = [0.5, 0]
    system.speed = 0.5
    system.speedVariation = 0.5
    system.lifespan = 3
    system.shape = .box(width: 1, height: 0)
    system.angle = .degrees(180)
    system.angleRange = .degrees(0)
    system.size = 0.01
    system.sizeVariation = 0.1
    system.angularSpeed = [0.5, 0.5, 0.5] // No rotation on any axis
    system.angularSpeedVariation = [0, 0, 0] // No variation in rotation
    
    return system
}

func speakText(_ text: String) {
    let synthesizer = AVSpeechSynthesizer()
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // Adjust language as needed
    synthesizer.speak(utterance)
}



// MARK: - Preview
struct MainBoardView_Previews: PreviewProvider {
    static var previews: some View {
        MainBoardView()
    }
}
