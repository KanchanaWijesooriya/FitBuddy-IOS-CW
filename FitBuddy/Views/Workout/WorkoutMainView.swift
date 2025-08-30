import SwiftUI

struct WorkoutMainView: View {
	// Example categories and workouts
	let categories = ["All", "ABS & Cardio", "Weights", "Yoga"]
	@State private var selectedCategory = "All"
	struct Workout: Identifiable {
		let id = UUID()
		let name: String
		let category: String
		let level: String
		let progress: Double
		let imageName: String
		let accent: Color
		let status: String
	}
	let workouts: [Workout] = [
		Workout(name: "ABS & Cardio", category: "ABS & Cardio", level: "Professional", progress: 0.72, imageName: "abs-placeholder", accent: Color(red: 0.7, green: 1.0, blue: 0.3), status: "Active"),
		Workout(name: "Weights", category: "Weights", level: "Intermediate", progress: 0.60, imageName: "weights-placeholder", accent: Color(red: 1.0, green: 0.8, blue: 0.3), status: "Active"),
		Workout(name: "Yoga", category: "Yoga", level: "Beginner", progress: 0.45, imageName: "yoga-placeholder", accent: Color(red: 0.3, green: 0.8, blue: 1.0), status: "Active")
	]

		var body: some View {
			NavigationView {
				VStack(spacing: 0) {
					// Header
					VStack(alignment: .leading, spacing: 0) {
						Button(action: {
							// Back action (handled by NavigationView automatically)
						}) {
							HStack(spacing: 4) {
								Image(systemName: "chevron.left")
									.font(.title2)
									.foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
								Text("Back")
									.font(.headline)
									.foregroundColor(Color(red: 0.7, green: 1.0, blue: 0.3))
							}
						}
						.padding(.top, 24)
						.padding(.leading, 24)
						HStack {
							Text("Workouts")
								.font(.system(.largeTitle, design: .default))
								.fontWeight(.bold)
								.foregroundColor(.black)
							Spacer()
							Image(systemName: "person.crop.circle")
								.resizable()
								.frame(width: 36, height: 36)
								.foregroundColor(Color(.systemGray3))
						}
						.padding(.horizontal, 24)
						.padding(.top, 8)
					}

			// Filter Bar
			ScrollView(.horizontal, showsIndicators: false) {
				HStack(spacing: 12) {
					ForEach(categories, id: \.self) { category in
						Button(action: { selectedCategory = category }) {
							Text(category)
								.font(.system(.subheadline, design: .default))
								.fontWeight(selectedCategory == category ? .bold : .regular)
								.foregroundColor(selectedCategory == category ? .white : .black)
								.padding(.horizontal, 16)
								.padding(.vertical, 8)
								.background(selectedCategory == category ? Color(red: 0.7, green: 1.0, blue: 0.3) : Color(.systemGray5))
								.cornerRadius(16)
						}
					}
				}
				.padding(.horizontal, 24)
				.padding(.vertical, 8)
			}

			// ...existing code...

			// Today Status Card
			ScrollView {
				VStack(spacing: 20) {
					ZStack(alignment: .leading) {
						RoundedRectangle(cornerRadius: 24)
							.fill(Color(red: 1.0, green: 0.95, blue: 0.85)) // Soft orange/yellow background
							.frame(height: 170)
							.shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
						VStack(alignment: .leading, spacing: 10) {
							Text("Today")
								.font(.headline)
								.foregroundColor(.black)
							HStack {
								Image(systemName: "flame.fill")
									.foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.0)) // Real fire color
								Text("2350 kcal")
									.font(.title2)
									.fontWeight(.bold)
									.foregroundColor(.black)
							}
							Text("Calories burned today")
								.font(.caption)
								.foregroundColor(.gray)
							Divider()
							HStack(spacing: 32) {
								HStack {
									Image(systemName: "figure.walk")
										.foregroundColor(Color.blue)
									VStack(alignment: .leading, spacing: 2) {
										Text("Steps")
											.font(.caption)
											.foregroundColor(.gray)
										Text("1230")
											.font(.subheadline)
											.foregroundColor(.black)
									}
								}
								HStack {
									Image(systemName: "drop.fill")
										.foregroundColor(Color.cyan)
									VStack(alignment: .leading, spacing: 2) {
										Text("Water")
											.font(.caption)
											.foregroundColor(.gray)
										Text("1.8 L")
											.font(.subheadline)
											.foregroundColor(.black)
									}
								}
							}
						}
						.padding(20)
					}
					.frame(height: 170)
					.padding(.horizontal, 24)
					// Workout Cards
					ForEach(workouts.filter { selectedCategory == "All" || $0.category == selectedCategory }) { workout in
						ZStack(alignment: .bottomLeading) {
							RoundedRectangle(cornerRadius: 24)
								.fill(
									LinearGradient(
										gradient: Gradient(colors: [workout.accent.opacity(0.35), Color.white.opacity(0.7)]),
										startPoint: .topLeading,
										endPoint: .bottomTrailing
									)
								)
								.frame(height: 120)
								.shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
							// Placeholder for workout image
							Image(workout.imageName)
								.resizable()
								.aspectRatio(contentMode: .fill)
								.frame(height: 120)
								.clipShape(RoundedRectangle(cornerRadius: 24))
							VStack(alignment: .leading, spacing: 8) {
								HStack {
									Text(workout.name)
										.font(.headline)
										.foregroundColor(.black)
									Spacer()
									Text(workout.level)
										.font(.caption2)
										.padding(.horizontal, 8)
										.padding(.vertical, 2)
										.background(Color.black)
										.foregroundColor(.white)
										.cornerRadius(8)
								}
								// Status
								Text(workout.status)
									.font(.caption)
									.foregroundColor(.gray)
								// Progress Bar
								ZStack(alignment: .leading) {
									RoundedRectangle(cornerRadius: 6)
										.fill(Color(.systemGray5))
										.frame(height: 10)
									RoundedRectangle(cornerRadius: 6)
										.fill(workout.accent)
										.frame(width: CGFloat(workout.progress) * 220, height: 10)
								}
								.frame(width: 220)
							}
							.padding(16)
						}
						.frame(height: 120)
						.padding(.horizontal, 24)
					}
				}
				.padding(.vertical, 8)
			}

			Spacer()
			// Bottom Navigation Bar
			BottomNavigationBar(selectedTab: "Explore")
		}
		.background(Color(.systemBackground))
		.navigationBarHidden(true)
	}
}
}

struct WorkoutMainView_Previews: PreviewProvider {
	static var previews: some View {
		WorkoutMainView()
	}
}
