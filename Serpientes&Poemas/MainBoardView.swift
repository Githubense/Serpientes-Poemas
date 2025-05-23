import SwiftUI
import Vortex
import AVFoundation

// MARK: - Main View

/// Main view for the Serpientes & Poemas game.
struct MainBoardView: View {
    // MARK: - State Properties

    @State private var showGameBoard = false // Controls the visibility of the game board.
    @State private var isMuted = false // Controls whether voice narration is muted.
    @State private var isSoundtrackMuted = false // Controls whether the soundtrack is muted.
    @State private var showSettingsMenu = false // Controls the visibility of the settings menu.

    // MARK: - Environment Properties

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass // Detects the device type (iPhone or iPad).
    @Environment(\.scenePhase) private var scenePhase // Monitors the app's lifecycle.

    // MARK: - Particle System

    private let snowSystem = createSnow() // Creates the particle system for the background effect.

    // MARK: - Body

    var body: some View {
        ZStack {
            // Background image based on device type.
            BackgroundView(horizontalSizeClass: horizontalSizeClass)

            // Particle system for visual effects.
            VortexView(snowSystem) {
                Image("leaf")
                    .frame(width: 1)
                    .tag("leaf")
            }
            .ignoresSafeArea()

            // Main content: Title and Start Button.
            VStack {
                TitleView() // Displays the title of the game.
                StartButton(showGameBoard: $showGameBoard) // Displays the "Start Game" button.
            }

            // Settings button in the lower-right corner.
            SettingsButton(showSettingsMenu: $showSettingsMenu, horizontalSizeClass: horizontalSizeClass)

            // Settings menu overlay.
            if showSettingsMenu {
                SettingsMenu(isMuted: $isMuted, isSoundtrackMuted: $isSoundtrackMuted, showSettingsMenu: $showSettingsMenu)
            }
        }
        .onAppear {
            // Start the soundtrack when the view appears.
            if !isSoundtrackMuted {
                AudioManager.shared.playSoundtrack()
            }
        }
        .onDisappear {
            // Stop the soundtrack when the view disappears.
            AudioManager.shared.stopSoundtrack()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background || newPhase == .inactive {
                // Stop the soundtrack when the app goes to the background or becomes inactive.
                AudioManager.shared.stopSoundtrack()
            } else if newPhase == .active, !isSoundtrackMuted {
                // Resume the soundtrack when the app becomes active.
                AudioManager.shared.playSoundtrack()
            }
        }
        .fullScreenCover(isPresented: $showGameBoard) {
            GameBoardView(isMuted: $isMuted, horizontalSizeClass: horizontalSizeClass, isSoundtrackMuted: $isSoundtrackMuted)
        }
    }

    // MARK: - Scene Phase Handling

    /// Handles changes to the app's scene phase (active, inactive, background).
    /// - Parameter newPhase: The new scene phase.
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        if newPhase == .background || newPhase == .inactive {
            // Stop the soundtrack when the app goes to the background or becomes inactive.
            AudioManager.shared.stopSoundtrack()
        } else if newPhase == .active, !isSoundtrackMuted {
            // Resume the soundtrack when the app becomes active.
            AudioManager.shared.playSoundtrack()
        }
    }
}

// MARK: - Subviews

/// Displays the title of the game with custom fonts and colors.
struct TitleView: View {
    var body: some View {
        VStack {
            Text("Serpientes") // Displays the first part of the title.
                .font(Font.custom("BagelFatOne-Regular", size: 60)) // Custom font for the title.
                .foregroundColor(.lightGreen) // Light green color for the text.
                .padding(.bottom, -10) // Adjusts spacing between text elements.
            Text("&") // Displays the ampersand.
                .font(Font.custom("ChelseaMarket-Regular", size: 30)) // Custom font for the ampersand.
                .foregroundColor(.lightGreen) // Light green color for the text.
                .padding(.vertical, -10) // Adjusts vertical spacing.
            Text("Poemas") // Displays the second part of the title.
                .font(Font.custom("FleurDeLeah-Regular", size: 80)) // Custom font for the title.
                .foregroundColor(.lightGreen) // Light green color for the text.
                .padding(.top, -20) // Adjusts spacing above the text.
                .padding(.bottom, 30) // Adjusts spacing below the text.
        }
    }
}

/// Displays the "Start Game" button with animations and custom styling.
struct StartButton: View {
    @Binding var showGameBoard: Bool // Binding to control the visibility of the game board.

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                showGameBoard = true // Triggers the game board to appear.
            }
        }) {
            Text("Empezar") // Button label.
                .font(Font.custom("ChelseaMarket-Regular", size: 25)) // Custom font for the button text.
                .bold() // Makes the text bold.
                .padding() // Adds padding around the text.
                .frame(width: 202, height: 79) // Sets the button's size.
                .background(
                    RoundedRectangle(cornerRadius: 20) // Rounded rectangle background.
                        .fill(Color(red: 0.51, green: 0.83, blue: 0.51)) // Green fill color.
                        .overlay(
                            RoundedRectangle(cornerRadius: 20) // Border overlay.
                                .stroke(Color(red: 0.31, green: 0.75, blue: 0.55), lineWidth: 7) // Green border.
                        )
                )
                .foregroundColor(.white) // White text color.
                .shadow(color: .gray, radius: 4, x: 2, y: 2) // Adds a shadow effect.
        }
        .padding(.bottom, -20) // Adjusts spacing below the button.
    }
}

/// Displays the settings button in the lower-right corner with animations and styling.
struct SettingsButton: View {
    @Binding var showSettingsMenu: Bool // Binding to control the visibility of the settings menu.
    let horizontalSizeClass: UserInterfaceSizeClass? // Detects the device type (iPhone or iPad).

    @State private var animateGear = false // State to control gear animation.

    var body: some View {
        VStack {
            Spacer() // Pushes the button to the bottom.
            HStack {
                Spacer() // Pushes the button to the right.
                Button(action: {
                    withAnimation {
                        animateGear = true // Trigger the gear animation.
                        showSettingsMenu.toggle() // Toggles the visibility of the settings menu.
                    }
                }) {
                    Image(systemName: "gearshape.fill") // Gear icon for the button.
                        .font(.system(size: horizontalSizeClass == .compact ? 30 : 50)) // Adjusts size based on device type.
                        .foregroundColor(.gray) // Gray color for the icon.
                        .padding() // Adds padding around the icon.
                        .background(Color.white.opacity(0.8)) // Semi-transparent white background.
                        .clipShape(Circle()) // Circular shape for the button.
                        .shadow(color: .gray, radius: 4, x: 2, y: 2) // Adds a shadow effect.
                        .modifier(WiggleEffectModifier(animate: animateGear)) // Apply wiggle animation conditionally.
                }
                .padding() // Adds padding around the button.
                .onChange(of: animateGear) { _, newValue in
                    // Reset animation state after it runs once.
                    if newValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            animateGear = false
                        }
                    }
                }
            }
        }
    }
}

/// A custom view modifier to apply the wiggle animation conditionally.
struct WiggleEffectModifier: ViewModifier {
    let animate: Bool

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *), animate {
            content.symbolEffect(.wiggle) // Apply wiggle animation on iOS 17 or later.
        } else {
            content // Return the original content for earlier iOS versions.
        }
    }
}

extension View {
    /// Applies a modifier conditionally.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The modifier to apply if the condition is true.
    /// - Returns: The modified view if the condition is true, otherwise the original view.
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            return AnyView(transform(self))
        } else {
            return AnyView(self) // Return the original view if the condition is false.
        }
    }
}

/// Displays the settings menu overlay with options to mute/unmute audio and close the menu.
struct SettingsMenu: View {
    @Binding var isMuted: Bool // Binding to control voice muting.
    @Binding var isSoundtrackMuted: Bool // Binding to control soundtrack muting.
    @Binding var showSettingsMenu: Bool // Binding to control the visibility of the settings menu.

    var body: some View {
        ZStack {
            // Semi-transparent overlay to block interaction with the background.
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    showSettingsMenu = false // Close the settings menu when the overlay is tapped.
                }
                .accessibilityHidden(true) // Mark as decorative

            // Settings menu content.
            VStack(spacing: 20) {
                Text("Configuración") // Title of the settings menu.
                    .font(.headline)
                    .foregroundColor(.white)
                    .accessibilityLabel("Configuración")

                // Toggle button to mute/unmute the soundtrack.
                Button(action: {
                    isSoundtrackMuted.toggle() // Toggle the soundtrack mute state.
                    if isSoundtrackMuted {
                        AudioManager.shared.pauseSoundtrack() // Pause the soundtrack.
                    } else {
                        AudioManager.shared.playSoundtrack() // Resume the soundtrack.
                    }
                }) {
                    HStack {
                        Image(systemName: isSoundtrackMuted ? "speaker.slash.circle.fill" : "speaker.wave.2.circle.fill")
                            .font(.system(size: 30)) // Icon size
                            .foregroundColor(.white) // Icon color
                        Text("Música: \(isSoundtrackMuted ? "Apagada" : "Encendida")") // Description in Spanish
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                }
                .accessibilityLabel("Música")
                .accessibilityValue(isSoundtrackMuted ? "Apagada" : "Encendida")
                .accessibilityHint("Activa o desactiva la música de fondo.")

                // Toggle button to mute/unmute the voice narration.
                Button(action: {
                    isMuted.toggle() // Toggle the voice mute state.
                }) {
                    HStack {
                        Image(systemName: isMuted ? "speaker.slash.circle.fill" : "speaker.wave.2.circle.fill")
                            .font(.system(size: 30)) // Icon size
                            .foregroundColor(.white) // Icon color
                        Text("Voz: \(isMuted ? "Apagada" : "Encendida")") // Description in Spanish
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                }
                .accessibilityLabel("Voz")
                .accessibilityValue(isMuted ? "Apagada" : "Encendida")
                .accessibilityHint("Activa o desactiva la narración de voz.")

                // Button to close the settings menu.
                Button(action: {
                    showSettingsMenu = false // Close the settings menu.
                }) {
                    Text("Cerrar") // Button label in Spanish.
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red.opacity(0.8)) // Red background for the button.
                        .cornerRadius(10) // Rounded corners for the button.
                }
                .accessibilityLabel("Cerrar")
                .accessibilityHint("Cierra el menú de configuración.")
            }
            .padding()
            .background(Color.black.opacity(0.9)) // Background color for the settings menu.
            .cornerRadius(15) // Rounded corners for the settings menu.
            .shadow(radius: 10) // Adds a shadow effect.
        }
    }
}

/// A reusable toggle button for settings with a label and an action.
struct ToggleButton: View {
    let label: String // The label displayed on the button.
    let action: () -> Void // The action to perform when the button is tapped.

    var body: some View {
        Button(action: action) {
            Text(label) // Display the button label.
                .foregroundColor(.white) // White text color.
                .padding() // Adds padding around the text.
                .background(Color.gray.opacity(0.8)) // Gray background for the button.
                .cornerRadius(10) // Rounded corners for the button.
        }
    }
}

/// Displays the background image based on the device type.
struct BackgroundView: View {
    let horizontalSizeClass: UserInterfaceSizeClass?

    var body: some View {
        Image(horizontalSizeClass == .compact ? "mainScreen-iphone" : "mainScreen-ipad")
            .resizable()
            .ignoresSafeArea()
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
            // Background image
            Image(horizontalSizeClass == .compact ? "background-iphone" : "background-ipad")
                .resizable()
                .ignoresSafeArea()
                .accessibilityHidden(true) // Mark as decorative

            VStack {
                Spacer()

                HStack {
                    boardGrid
                        .padding()
                        .accessibilityLabel("Tablero de juego")
                        .accessibilityHint("Contiene las casillas del juego. Toca una casilla para interactuar.")

                    Spacer()

                    VStack(spacing: 20) {
                        collectedVersesView
                            .accessibilityLabel("Versos recogidos")
                            .accessibilityHint("Lista de versos que has recogido durante el juego.")

                        diceButton
                            .accessibilityLabel("Botón de dado")
                            .accessibilityHint("Lanza el dado para avanzar en el tablero.")

                    }
                    .frame(width: 200)
                }
                .padding(.horizontal)

                Spacer()
            }
            .disabled(showSettingsMenu) // Disable interaction with the background when the menu is active
            .blur(radius: showSettingsMenu ? 5 : 0) // Optional: Add a blur effect when the menu is active

                        // Settings button in the lower-right corner
            SettingsButton(showSettingsMenu: $showSettingsMenu, horizontalSizeClass: horizontalSizeClass)
                .accessibilityLabel("Botón de configuración")
                .accessibilityHint("Abre el menú de configuración.")

            // Settings menu overlay
            if showSettingsMenu {
                SettingsMenu(isMuted: $isMuted, isSoundtrackMuted: $isSoundtrackMuted, showSettingsMenu: $showSettingsMenu)
                    .accessibilityLabel("Menú de configuración")
                    .accessibilityHint("Ajusta la música y la voz del juego.")
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
                .accessibilityLabel("Versos recogidos")

            if collectedVerses.isEmpty {
                Text("Ningún verso recogido todavía.")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .accessibilityLabel("No has recogido ningún verso todavía.")
            } else {
                ForEach(collectedVerses, id: \.self) { verse in
                    Text(verse)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .transition(.opacity) // Fade in new verses
                        .accessibilityLabel("Verso: \(verse)")
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: collectedVerses) // Animate changes to collectedVerses
        .accessibilityElement(children: .combine) // Combine all verses into one VoiceOver element
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
        .accessibilityLabel("Dado")
        .accessibilityValue("Resultado actual: \(currentDiceImage.replacingOccurrences(of: "dice", with: ""))")
        .accessibilityHint("Lanza el dado para avanzar en el tablero.")
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

/// Displays detailed information about the current position on the board.
struct DetailView: View {
    let position: Int // The player's current position on the board.
    let verse: String? // The verse associated with the current position, if any.
    let totalSpaces: Int // The total number of spaces on the board.
    let dismissAction: () -> Void // Action to dismiss the detail view.
    @Binding var isMuted: Bool // Binding to control audio muting.
    let horizontalSizeClass: UserInterfaceSizeClass? // Detects the device type (iPhone or iPad).

    var body: some View {
        ZStack {
            // Dynamically load the background image based on the device type.
            Image(horizontalSizeClass == .compact ? "background-iphone" : "background-ipad")
                .resizable()
                .ignoresSafeArea()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

            // Foreground content of the DetailView.
            HStack(spacing: 20) {
                // Left square for the position image.
                ZStack {
                    if position == 0 || position == totalSpaces - 1 {
                        Image("blankSpace") // Image for the first or last space.
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(15) // Rounded corners for the image.
                            .shadow(color: .gray, radius: 4, x: 2, y: 2) // Adds a shadow effect.
                    } else {
                        Image(UIImage(named: String(format: "%02d", position)) != nil ? String(format: "%02d", position) : "default_space")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(15) // Rounded corners for the image.
                            .shadow(color: .gray, radius: 4, x: 2, y: 2) // Adds a shadow effect.
                    }
                }
                .padding()

                // Right text for the verse.
                VStack(alignment: .leading, spacing: 10) {
                    if let verse = verse {
                        Text("Verso:") // Label for the verse.
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(verse) // Displays the verse text.
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .background(Color.teal.opacity(0.8)) // Background color for the verse.
                            .cornerRadius(10) // Rounded corners for the background.
                            .onAppear {
                                // Lower soundtrack volume to 20%.
                                AudioManager.shared.setVolume(to: 0.2, duration: 1.0)

                                // Speak the verse at full volume.
                                speakText(verse, isMuted: isMuted)

                                // Automatically dismiss the view after 3 seconds.
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                    dismissAction()
                                }
                            }
                    } else {
                        Text("No hay verso aquí.") // Message for empty spaces.
                            .font(.body)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.teal.opacity(0.8)) // Background color for the message.
                            .cornerRadius(10) // Rounded corners for the background.
                            .onAppear {
                                // Automatically dismiss the view after 1.5 seconds.
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
                // Lower soundtrack volume to 20% when the view appears.
                AudioManager.shared.setVolume(to: 0.2, duration: 1.0)
            }
        }
        .onDisappear {
            if !isMuted {
                // Restore soundtrack volume to 50% when the view disappears.
                AudioManager.shared.setVolume(to: 0.5, duration: 1.0)
            }
        }
    }
}

/// Displays the end-game screen with collected verses and a restart option.
struct EndGameView: View {
    let collectedVerses: [String] // List of verses collected during the game.
    let dismissAction: () -> Void // Action to dismiss the end-game view.
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass // Detects the device type (iPhone or iPad).
    @Binding var isMuted: Bool // Binding to control audio muting.

    var body: some View {
        ZStack {
            // Dynamically load the background image based on the device type.
            Image(horizontalSizeClass == .compact ? "background-iphone" : "background-ipad")
                .resizable()
                .ignoresSafeArea()

            // Foreground content of the end-game view.
            VStack(spacing: 20) {
                Text("¡Felicidades!") // Congratulatory message.
                    .font(.largeTitle)
                    .foregroundColor(.green)

                Text("Has terminado el juego. Aquí están los versos que recogiste:")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)

                // Scrollable list of collected verses.
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(collectedVerses, id: \.self) { verse in
                            Text(verse) // Display each collected verse.
                                .font(.body)
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 300) // Limit the scroll view's size.
                .padding()
                .background(Color.teal.opacity(0.8)) // Background color for the scroll view.
                .cornerRadius(10) // Rounded corners for the scroll view.

                // Button to start a new game.
                Button(action: {
                    dismissAction() // Trigger the dismiss action.
                }) {
                    Text("Nueva Partida") // Button label.
                        .font(.headline)
                        .foregroundColor(.teal)
                        .padding()
                        .background(Color.white) // White background for the button.
                        .cornerRadius(10) // Rounded corners for the button.
                        .shadow(color: .gray, radius: 4, x: 2, y: 2) // Adds a shadow effect.
                }
            }
            .padding()
        }
        .onAppear {
            // Automatically read the collected verses when the view appears.
            if !isMuted {
                collectedVerses.forEach { speakText($0, isMuted: isMuted) }
            }
            AudioManager.shared.setVolume(to: 0.2, duration: 1.0) // Smoothly lower volume to 20%.
        }
        .onDisappear {
            AudioManager.shared.setVolume(to: 0.5, duration: 1.0) // Restore volume to 50% when leaving.
        }
    }
}

/// Creates a particle system for the background effect.
/// - Returns: A configured `VortexSystem` for the snow effect.
func createSnow() -> VortexSystem {
    let system = VortexSystem(tags: ["leaf"]) // Tags for identifying the particle system.
    system.birthRate = 1 // Number of particles generated per second.
    system.position = [0.5, 0] // Starting position of the particles.
    system.speed = 0.5 // Base speed of the particles.
    system.speedVariation = 0.5 // Variation in particle speed.
    system.lifespan = 3 // Lifespan of each particle in seconds.
    system.shape = .box(width: 1, height: 0) // Shape of the particle emitter.
    system.angle = .degrees(180) // Direction of particle emission.
    system.angleRange = .degrees(0) // Range of angles for particle emission.
    system.size = 0.01 // Base size of the particles.
    system.sizeVariation = 0.1 // Variation in particle size.
    system.angularSpeed = [0.5, 0.5, 0.5] // No rotation on any axis.
    system.angularSpeedVariation = [0, 0, 0] // No variation in rotation.

    return system
}

/// Speaks the provided text using text-to-speech functionality.
/// - Parameters:
///   - text: The text to be spoken.
///   - isMuted: A flag indicating whether the voice narration is muted.
func speakText(_ text: String, isMuted: Bool) {
    guard !isMuted else { return } // Do not speak if muted.
    let synthesizer = AudioManager.shared.speechSynthesizer // Shared speech synthesizer instance.
    let utterance = AVSpeechUtterance(string: text) // Create an utterance with the provided text.
    utterance.voice = AVSpeechSynthesisVoice(language: "es-MX") // Set the voice to Spanish (Mexico).
    synthesizer.speak(utterance) // Speak the utterance.
}

// MARK: - Preview
struct MainBoardView_Previews: PreviewProvider {
    static var previews: some View {
        MainBoardView()
    }
}
