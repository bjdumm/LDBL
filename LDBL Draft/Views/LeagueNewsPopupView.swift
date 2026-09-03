import SwiftUI

struct LeagueNewsPopupView: View {

    let news: LeagueNewsItem
    let onDismiss: () -> Void

    @State private var showYear = false
    @State private var showPhoto = false
    @State private var showCrown = false
    @State private var showChampion = false
    @State private var showDetails = false
    @State private var glow = false

    var body: some View {
        ZStack {
            Color.black
                .opacity(news.type == .beerGamesChampion ? 1.0 : 0.55)
                .ignoresSafeArea()
                .onTapGesture { }

            if news.type == .beerGamesChampion {
                championView
                    .onAppear { beginChampionReveal() }
                    .onDisappear { ChampionMusicPlayer.shared.stop() }
            } else {
                standardView
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var standardView: some View {
        VStack(spacing: 18) {
            if news.type == .beerGameEventWinner {
                ManagerAvatarView(managerName: news.player, size: 132)
                    .overlay { Circle().stroke(.white.opacity(0.9), lineWidth: 4) }
                    .shadow(radius: 8, y: 4)

                Text("🍺 EVENT WINNER! 🥇")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
            } else {
                Text(icon).font(.system(size: 72))
                Text(news.title)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .multilineTextAlignment(.center)
            }

            Text(news.message)
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)

            if let result = news.result, news.type != .beerGameEventWinner {
                Text(result)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .padding(.top, 2)
            }

            Text(footer).font(.title2)
            acknowledgeButton(title: "Awesome!")
        }
        .padding(28)
        .frame(maxWidth: 360)
        .background(RoundedRectangle(cornerRadius: 28).fill(Color(uiColor: .systemBackground)))
        .padding(20)
    }

    // Timed for the opening of the supplied Also sprach Zarathustra recording.
    // The major CHAMPION reveal lands around the first large orchestral hit.
    private var championView: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()

                RadialGradient(
                    colors: [Color.orange.opacity(glow ? 0.52 : 0.08), .black],
                    center: .center,
                    startRadius: 20,
                    endRadius: max(geometry.size.width, geometry.size.height) * 0.75
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 2.8), value: glow)

                if showChampion {
                    championCelebrationBackground(size: geometry.size)
                        .transition(.opacity)
                }

                VStack(spacing: 14) {
                    Spacer(minLength: 22)

                    if showYear {
                        Text("\(news.year) BEER GAMES")
                            .font(.system(size: 19, weight: .heavy, design: .rounded))
                            .tracking(3)
                            .foregroundStyle(.white.opacity(0.88))
                            .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    }

                    if showCrown {
                        Text("👑")
                            .font(.system(size: 76))
                            .shadow(color: .yellow.opacity(0.8), radius: 20)
                            .transition(.scale(scale: 0.15).combined(with: .opacity))
                    } else {
                        Spacer().frame(height: 82)
                    }

                    if showPhoto {
                        ManagerAvatarView(managerName: news.player, size: showChampion ? 184 : 164)
                            .padding(8)
                            .background(Circle().fill(.white.opacity(showChampion ? 0.18 : 0.06)))
                            .overlay {
                                Circle().stroke(
                                    showChampion ? Color.yellow : Color.white.opacity(0.45),
                                    lineWidth: showChampion ? 7 : 3
                                )
                            }
                            .shadow(color: showChampion ? .yellow.opacity(0.55) : .black.opacity(0.5), radius: showChampion ? 25 : 10)
                            .transition(.opacity.combined(with: .scale(scale: 0.82)))
                            .animation(.spring(response: 0.55, dampingFraction: 0.72), value: showChampion)
                    }

                    if showChampion {
                        Text("BEER GAMES CHAMPION")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .minimumScaleFactor(0.62)
                            .lineLimit(1)
                            .foregroundStyle(.white)
                            .shadow(color: .orange, radius: 12)
                            .padding(.top, 8)
                            .transition(.scale(scale: 1.8).combined(with: .opacity))
                    }

                    if showDetails {
                        VStack(spacing: 10) {
                            Text(news.player)
                                .font(.system(size: 40, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)

                            Text("has won the \(news.year) Beer Games!")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.92))
                                .multilineTextAlignment(.center)

                            if let result = news.result {
                                Text(result)
                                    .font(.system(size: 29, weight: .black, design: .rounded))
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, 22)
                                    .padding(.vertical, 9)
                                    .background(Capsule().fill(.white.opacity(0.94)))
                            }

                            Text("🏆  🍺  👑  🍺  🏆")
                                .font(.title2)

                            Button {
                                ChampionMusicPlayer.shared.stop()
                                onDismiss()
                            } label: {
                                Text("Crown the Champion")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 13)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.white)
                            .foregroundStyle(.black)
                            .padding(.top, 4)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer(minLength: 22)
                }
                .padding(.horizontal, 24)
            }
        }
        .ignoresSafeArea()
    }

    private func beginChampionReveal() {
        showYear = false
        showPhoto = false
        showCrown = false
        showChampion = false
        showDetails = false
        glow = false

        ChampionMusicPlayer.shared.play()

        // 1.0s: recording comes out of its opening silence.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeIn(duration: 1.8)) { showYear = true }
        }

        // 5.6s: after the first musical phrase, reveal the champion portrait.
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.6) {
            glow = true
            withAnimation(.easeInOut(duration: 2.5)) { showPhoto = true }
        }

        // 13.9s: crown appears during the final buildup.
        DispatchQueue.main.asyncAfter(deadline: .now() + 13.9) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.62)) { showCrown = true }
        }

        // 16.8s: major reveal at the first large orchestral climax.
        DispatchQueue.main.asyncAfter(deadline: .now() + 16.8) {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.58)) { showChampion = true }
        }

        // Let the hit breathe, then show name, points, and acknowledgement.
        DispatchQueue.main.asyncAfter(deadline: .now() + 18.3) {
            withAnimation(.easeOut(duration: 0.8)) { showDetails = true }
        }
    }

    @ViewBuilder
    private func championCelebrationBackground(size: CGSize) -> some View {
        ZStack {
            celebrationDot(x: 0.08, y: 0.10, size: 18, canvas: size)
            celebrationDot(x: 0.20, y: 0.28, size: 10, canvas: size)
            celebrationDot(x: 0.88, y: 0.16, size: 15, canvas: size)
            celebrationDot(x: 0.78, y: 0.34, size: 9, canvas: size)
            celebrationDot(x: 0.12, y: 0.58, size: 12, canvas: size)
            celebrationDot(x: 0.91, y: 0.61, size: 18, canvas: size)
            celebrationDot(x: 0.26, y: 0.82, size: 14, canvas: size)
            celebrationDot(x: 0.76, y: 0.86, size: 11, canvas: size)

            Text("★")
                .font(.system(size: 52, weight: .black))
                .foregroundStyle(.yellow.opacity(0.38))
                .position(x: size.width * 0.12, y: size.height * 0.40)

            Text("★")
                .font(.system(size: 70, weight: .black))
                .foregroundStyle(.orange.opacity(0.30))
                .position(x: size.width * 0.88, y: size.height * 0.47)
        }
        .allowsHitTesting(false)
    }

    private func celebrationDot(x: CGFloat, y: CGFloat, size dotSize: CGFloat, canvas: CGSize) -> some View {
        Circle()
            .fill(.white.opacity(0.35))
            .frame(width: dotSize, height: dotSize)
            .position(x: canvas.width * x, y: canvas.height * y)
    }

    private func acknowledgeButton(title: String) -> some View {
        Button(action: onDismiss) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
        }
        .buttonStyle(.borderedProminent)
    }

    private var icon: String {
        switch news.type {
        case .beerGameRecord: return "🏆"
        case .beerGameEventWinner: return "🍺"
        case .beerGamesChampion: return "👑"
        }
    }

    private var footer: String {
        switch news.type {
        case .beerGameRecord: return "🎉 🔥 🍺"
        case .beerGameEventWinner: return "🍺 🥇 🎉"
        case .beerGamesChampion: return "👑 🍺 🏆"
        }
    }
}
