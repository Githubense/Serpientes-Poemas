import SwiftUI
import Vortex
import AVFoundation

struct MainBoardView: View {
    @State private var showGameBoard = false
    @State private var isMuted = false // State to control audio muting
    @State private var isSoundtrackMuted = false // State to control soundtrack muting
    @State private var showSettingsMenu = false // Controls the settings menu visibility
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass // Detect device type
    @Environment(\.scenePhase) private var scenePhase // Monitor app lifecycle

    private let snowSystem = createSnow()

    var body: some View {
        ZStack {
            // Dynamically load the background image based on the device type
            Image(horizontalSizeClass == .compact ? "mainScreen-iphone" : "mainScreen-ipad")
                .resizable()
                .ignoresSafeArea()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            VortexView(snowSystem) {
                Image("leaf")
                    .frame(width: 1)
                    .tag("leaf")
            }
            .ignoresSafeArea()
            
            VStack {
                Text("Serpientes")
                    .font(Font.custom("BagelFatOne-Regular", size: 60))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.lightGreen)
                    .padding(.bottom, -10)
                Text("&")
                    .font(Font.custom("ChelseaMarket-Regular", size: 30))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.lightGreen)
                    .padding(.vertical, -10)
                Text("Poemas")
                    .font(Font.custom("FleurDeLeah-Regular", size: 80))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.lightGreen)
                    .padding(.top, -20)
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
            
            // Settings Button in the lower-right corner
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showSettingsMenu.toggle()
                        }
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 50)) // Smaller for iPhone, larger for iPad
                            .foregroundColor(.gray)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(color: .gray, radius: 4, x: 2, y: 2)
                    }
                    .padding()
                }
            }
            
            // Settings menu
            if showSettingsMenu {
                ZStack {
                    // Semi-transparent overlay to block interaction with the background
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            // Close the settings menu if the overlay is tapped
                            showSettingsMenu = false
                        }

                    // Settings menu content
                    VStack(spacing: 20) {
                        Text("Settings")
                            .font(.headline)
                            .foregroundColor(.white)

                        Button(action: {
                            isSoundtrackMuted.toggle()
                            if isSoundtrackMuted {
                                AudioManager.shared.pauseSoundtrack()
                            } else {
                                AudioManager.shared.playSoundtrack()
                            }
                        }) {
                            Text(isSoundtrackMuted ? "Unmute Soundtrack" : "Mute Soundtrack")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.8))
                                .cornerRadius(10)
                        }

                        Button(action: {
                            isMuted.toggle()
                        }) {
                            Text(isMuted ? "Unmute Voice" : "Mute Voice")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.8))
                                .cornerRadius(10)
                        }

                        Button(action: {
                            showSettingsMenu = false
                        }) {
                            Text("Close")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.9))
                    .cornerRadius(15)
                    .shadow(radius: 10)
                }
            }
        }
        .onAppear {
            // Start the soundtrack when the view appears
            if !isSoundtrackMuted {
                DispatchQueue.main.async {
                    AudioManager.shared.playSoundtrack()
                }
            }
        }
        .onDisappear {
            // Stop the soundtrack when the view disappears
            AudioManager.shared.stopSoundtrack()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background || newPhase == .inactive {
                // Stop the soundtrack when the app goes to the background or becomes inactive
                AudioManager.shared.stopSoundtrack()
            } else if newPhase == .active {
                // Resume the soundtrack when the app becomes active
                if !isSoundtrackMuted {
                    AudioManager.shared.playSoundtrack()
                }
            }
        }
        .fullScreenCover(isPresented: $showGameBoard) {
            GameBoardView(isMuted: $isMuted, horizontalSizeClass: horizontalSizeClass, isSoundtrackMuted: $isSoundtrackMuted)
                .transition(.scale(scale: 0.8, anchor: .center)) // Scale transition
        }
    }
}

struct GameBoardView: View {
    let horizontalSizeClass: UserInterfaceSizeClass?
    @Binding var isMuted: Bool // Binding to control audio muting
    @Binding var isSoundtrackMuted: Bool // Binding to control soundtrack muting

    @State private var showSettingsMenu = false // Controls the settings menu

    // MARK: - Layout Constants
    let rows = 6
    let columns = 8
    
    // MARK: - Verse Spaces
    let verseSpaces: [Int: String] = [
        1: "Estas al inicio formado",
        4: "Los dados ruedan y escapan a tu mano",
        7: "Avanzas sin ningún atraso",
        10: "Entre casillas buscas el atajo",
        13: "No ves los dientes del engaño",
        15: "Y la boca de serpiente te lleva hacia abajo",
        18: "Se acerca mordiendo el fracaso",
        22: "Ganar parece algo lejano",
        25: "Tiras dados, que siga el relajo",
        28: "Atrás medio tablero ha quedado",
        31: "Entre risas pegas brincos y saltos",
        34: "Subes la escalera, peldaño a peldaño",
        37: "A la meta estás más cercano",
        40: "Avanzas, cuidando cada paso",
        43: "Escalas hasta lo más alto",
        46: "En la meta estás, has ganado"
    ]
    let totalSpaces: Int
    
    // MARK: - State Properties
    @State private var playerPosition = 0 // Start position of the player
    @State private var collectedVerses: [String] = [] // List of collected verses
    @State private var showDetailView = false // Controls the detailed view
    @State private var showEndGameView = false // Controls the end-game view
    @State private var isVoiceMuted = false // Mute state for voice
    
    @AppStorage("playerPosition") private var savedPlayerPosition = 0
    @AppStorage("collectedVerses") private var savedCollectedVerses = ""
    
    @Namespace private var animationNamespace
    
    @State private var currentDiceImage = "noDice" // Default dice image before any roll
    @State private var isRolling = false // Prevent multiple rolls at the same time
    @State private var hasRolledDice = false // Track if the dice has been rolled
    
    // MARK: - Background Soundtrack
    private var soundtrackPlayer: AVAudioPlayer? = {
        guard let url = Bundle.main.url(forResource: "Jungle Trip - Quincas Moreira", withExtension: "mp3") else { return nil }
        return try? AVAudioPlayer(contentsOf: url)
    }()
    
    // Explicit initializer for @Binding property
    init(isMuted: Binding<Bool>, horizontalSizeClass: UserInterfaceSizeClass?, isSoundtrackMuted: Binding<Bool>) {
        self._isMuted = isMuted
        self.horizontalSizeClass = horizontalSizeClass // Initialize the property
        self._isSoundtrackMuted = isSoundtrackMuted
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
            Image(horizontalSizeClass == .compact ? "background-iphone" : "background-ipad")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                HStack {
                    boardGrid
                        .padding()
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        collectedVersesView
                        diceButton

                    }
                    .frame(width: 200)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .disabled(showSettingsMenu) // Disable interaction with the background when the menu is active
            .blur(radius: showSettingsMenu ? 5 : 0) // Optional: Add a blur effect when the menu is active

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showSettingsMenu.toggle()
                        }
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: horizontalSizeClass == .compact ? 30 : 50)) // Smaller for iPhone, larger for iPad
                            .foregroundColor(.gray)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(color: .gray, radius: 4, x: 2, y: 2)
                    }
                    .padding()
                }
            }
            .ignoresSafeArea(.all) // Ignore safe area for the settings button
            // Settings menu
            if showSettingsMenu {
                ZStack {
                    // Semi-transparent overlay to block interaction with the background
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            // Close the settings menu if the overlay is tapped
                            showSettingsMenu = false
                        }

                    // Settings menu content
                    VStack(spacing: 20) {
                        Text("Settings")
                            .font(.headline)
                            .foregroundColor(.white)

                        Button(action: {
                            isSoundtrackMuted.toggle()
                            if isSoundtrackMuted {
                                AudioManager.shared.pauseSoundtrack()
                            } else {
                                AudioManager.shared.playSoundtrack()
                            }
                        }) {
                            Text(isSoundtrackMuted ? "Unmute Soundtrack" : "Mute Soundtrack")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.8))
                                .cornerRadius(10)
                        }

                        Button(action: {
                            isMuted.toggle()
                        }) {
                            Text(isMuted ? "Unmute Voice" : "Mute Voice")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.8))
                                .cornerRadius(10)
                        }

                        Button(action: {
                            showSettingsMenu = false
                        }) {
                            Text("Close")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.9))
                    .cornerRadius(15)
                    .shadow(radius: 10)
                }
            }
        }
        .onAppear {
            // Start the soundtrack when the view appears
            if !isSoundtrackMuted {
                soundtrackPlayer?.numberOfLoops = -1 // Loop indefinitely
                AudioManager.shared.setVolume(to: 0.5, duration: 1.0) // Smoothly lower volume to 50%
            }
        }
        .onDisappear {
            if !isSoundtrackMuted {
                AudioManager.shared.setVolume(to: 1.0, duration: 1.0) // Restore volume to 100% when leaving
            }
        }
        .fullScreenCover(isPresented: $showDetailView) {
            if showEndGameView {
                EndGameView(collectedVerses: collectedVerses, dismissAction: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        resetGame()
                    }
                }, isMuted: $isMuted)
            } else {
                DetailView(position: playerPosition,
                           verse: verseSpaces[playerPosition],
                           totalSpaces: totalSpaces,
                           dismissAction: {
                               withAnimation(.easeInOut(duration: 0.5)) {
                                   showDetailView = false
                               }
                           },
                           isMuted: $isMuted,
                           horizontalSizeClass: horizontalSizeClass) // Pass horizontalSizeClass
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
                                if position == 0 || position == totalSpaces - 1 {
                                    Image("blankSpace") // Image for the first space
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: cellWidth, height: cellWidth)
                                        .cornerRadius(10) // Add rounded corners
                                        .clipped()
                                } else {
                                    // Display the image for the current position or fallback to default
                                    imageForPosition(position)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: cellWidth, height: cellWidth)
                                        .cornerRadius(10) // Add rounded corners
                                        .clipped()
//                                        .overlay(
//                                            RoundedRectangle(cornerRadius: 10)
//                                                .stroke(Color.lightDarkGreen, lineWidth: 5)
//                                        )
                                }
                                
                                // Highlight the player's current position
                                if position == playerPosition {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: horizontalSizeClass == .compact ? cellWidth / 2 : cellWidth / 1.5, 
                                               height: horizontalSizeClass == .compact ? cellWidth / 2 : cellWidth / 1.5) // Smaller for iPhone
                                        .background(Color(red: 0.69, green: 0.16, blue: 0.19))
                                        .cornerRadius(20)
                                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .inset(by: 2)
                                                .stroke(Color(red: 0.66, green: 0.22, blue: 0), lineWidth: 4)
                                        )
                                        .rotationEffect(Angle(degrees: -90))
                                        .matchedGeometryEffect(id: "playerPosition", in: animationNamespace)
                                }
                                

                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle()) // Make the entire grid tappable
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.5)) {
                    if playerPosition != 0 {
                        showDetailView = true
                    }
                }
            }
        }
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
            rollDiceWithAnimation()
        }) {
            Image(currentDiceImage)
                .resizable()
                .frame(width: horizontalSizeClass == .compact ? 100 : 150, 
                       height: horizontalSizeClass == .compact ? 100 : 150) // Smaller for iPhone
                .cornerRadius(15)
                .shadow(color: .gray, radius: 4, x: 2, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Dice Roll Animation Logic
    private func rollDiceWithAnimation() {
        guard !isRolling else { return } // Prevent multiple rolls
        isRolling = true

        let diceRoll = Int.random(in: 1...6) // Final dice result
        var currentRoll = 1 // Start from dice1
        let animationDuration: TimeInterval = 1.0 // Total animation duration in seconds
        let interval: TimeInterval = 0.1 // Interval between dice image updates
        var elapsedTime: TimeInterval = 0 // Track elapsed time

        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            elapsedTime += interval // Increment elapsed time
            currentDiceImage = "dice\(currentRoll)" // Update dice image
            currentRoll = currentRoll % 6 + 1 // Cycle through dice1 to dice6

            if elapsedTime >= animationDuration {
                timer.invalidate() // Stop the timer after the animation duration
                currentDiceImage = "dice\(diceRoll)" // Set the final dice result
                isRolling = false // Allow new rolls
                movePlayer(to: min(playerPosition + diceRoll, totalSpaces - 1)) // Move the player
            }
        }
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

    private func imageForPosition(_ position: Int) -> Image {
        if let uiImage = UIImage(named: String(format: "%02d", position)) {
            return Image(uiImage: uiImage)
        } else {
            return Image("default_space")
        }
    }
}

struct DetailView: View {
    let position: Int
    let verse: String?
    let totalSpaces: Int
    let dismissAction: () -> Void
    @Binding var isMuted: Bool // Binding to control audio muting
    let horizontalSizeClass: UserInterfaceSizeClass?

    var body: some View {
        ZStack {
            // Dynamically load the background image based on the device type
            Image(horizontalSizeClass == .compact ? "background-iphone" : "background-ipad")
                .resizable()
                .ignoresSafeArea()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)


            // Foreground content of the DetailView
            HStack(spacing: 20) {
                // Left square for the position image
                ZStack {
                    if position == 0 || position == totalSpaces - 1 {
                        Image("blankSpace") // Image for the first or last space
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(15)
                            .shadow(color: .gray, radius: 4, x: 2, y: 2)
                    } else {
                        Image(UIImage(named: String(format: "%02d", position)) != nil ? String(format: "%02d", position) : "default_space")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(15)
                            .shadow(color: .gray, radius: 4, x: 2, y: 2)
                    }
                }
                .padding()
                // Right text for the verse
                VStack(alignment: .leading, spacing: 10) {
                    if let verse = verse {
                        Text("Verso:")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(verse)
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .background(Color.teal.opacity(0.8))
                            .cornerRadius(10)
                            .onAppear {
                                // Lower soundtrack volume to 20%
                                AudioManager.shared.setVolume(to: 0.2, duration: 1.0)

                                // Speak the verse at full volume
                                speakText(verse, isMuted: isMuted)

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
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    dismissAction()
                                }
                            }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            if !isMuted {
                // Lower soundtrack volume to 20%
                AudioManager.shared.setVolume(to: 0.2, duration: 1.0)
            }
        }
        .onDisappear {
            if !isMuted {
                // Restore soundtrack volume to 50% when leaving
                AudioManager.shared.setVolume(to: 0.5, duration: 1.0)
            }
        }
    }
}

struct EndGameView: View {
    let collectedVerses: [String]
    let dismissAction: () -> Void
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Binding var isMuted: Bool // Binding to control audio muting

    var body: some View {
        ZStack {
            // Dynamically load the background image based on the device type
            Image(horizontalSizeClass == .compact ? "background-iphone" : "background-ipad")
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
                    dismissAction() // Only dismiss the view
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
        .onAppear {
            // Automatically read the collected verses when the view appears
            if !isMuted {
                collectedVerses.forEach { speakText($0, isMuted: isMuted) }
            }
            AudioManager.shared.setVolume(to: 0.2, duration: 1.0) // Smoothly lower volume to 20%
        }
        .onDisappear {
            AudioManager.shared.setVolume(to: 0.5, duration: 1.0) // Restore volume to 50% when leaving
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

func speakText(_ text: String, isMuted: Bool) {
    guard !isMuted else { return } // Do not speak if muted
    let synthesizer = AudioManager.shared.speechSynthesizer
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(language: "es-MX") // Set to Spanish (Mexico)
    synthesizer.speak(utterance)
}



// MARK: - Preview
struct MainBoardView_Previews: PreviewProvider {
    static var previews: some View {
        MainBoardView()
    }
}
