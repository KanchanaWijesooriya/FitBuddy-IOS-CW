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
		VStack(spacing: 0) {
			// Header
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
			.padding(.top, 24)

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

			// Quick Stats
			HStack {
				VStack(alignment: .leading) {
					Text("Today")
						.font(.caption)
						.foregroundColor(.gray)
					Text("2350 kcal")
						.font(.title2)
						.fontWeight(.bold)
						.foregroundColor(.black)
				}
				Spacer()
				VStack(alignment: .trailing) {
					Text("Steps")
						.font(.caption)
						.foregroundColor(.gray)
					Text("1230")
						.font(.title3)
						.fontWeight(.semibold)
						.foregroundColor(.black)
				}
				VStack(alignment: .trailing) {
					Text("Waters")
						.font(.caption)
						.foregroundColor(.gray)
					Text("1.8 L")
						.font(.title3)
						.fontWeight(.semibold)
						.foregroundColor(.black)
				}
			}
			.padding(.horizontal, 24)
			.padding(.vertical, 8)

			// Today Status Card
			ScrollView {
				VStack(spacing: 20) {
					ZStack(alignment: .leading) {
						RoundedRectangle(cornerRadius: 24)
							.fill(Color(red: 1.0, green: 0.95, blue: 0.85)) // Soft orange/yellow background
							.frame(height: 120)
							.shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
						VStack(alignment: .leading, spacing: 12) {
							Text("Today")
								.font(.headline)
								.foregroundColor(.black)
							HStack {
								Image(systemName: "flame.fill")
									.foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.0)) // Real fire color
								Text("2350 kcal")
									.font(.title)
									.fontWeight(.bold)
									.foregroundColor(.black)
							}
							Text("Calories burned today")
								.font(.caption)
								.foregroundColor(.gray)
						}
						.padding(20)
					}
					.frame(height: 120)
					.padding(.horizontal, 24)
					// Workout Cards
					ForEach(workouts.filter { selectedCategory == "All" || $0.category == selectedCategory }) { workout in
						ZStack(alignment: .bottomLeading) {
							RoundedRectangle(cornerRadius: 24)
								.fill(workout.accent.opacity(0.18))
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
			HStack {
				Spacer()
				navBarItem(icon: "house.fill", label: "Home", isActive: false)
				Spacer()
				navBarItem(icon: "figure.walk", label: "Workouts", isActive: true) // Workout logo and option after Home
				Spacer()
				navBarItem(icon: "bolt.fill", label: "Challenges", isActive: false)
				Spacer()
				navBarItem(icon: "chart.bar.fill", label: "Progress", isActive: false)
				Spacer()
				navBarItem(icon: "person.fill", label: "Profile", isActive: false)
				Spacer()
			}
			.frame(height: 64)
			.background(RoundedRectangle(cornerRadius: 24).fill(Color(.black)))
			.padding(.horizontal, 24)
			.padding(.bottom, 12)
		}
		.background(Color(.systemBackground))
	}
}

@ViewBuilder
func navBarItem(icon: String, label: String, isActive: Bool) -> some View {
	VStack(spacing: 4) {
		Image(systemName: icon)
			.font(.title2)
			.foregroundColor(isActive ? Color(red: 0.7, green: 1.0, blue: 0.3) : .white)
		Text(label)
			.font(.caption2)
			.foregroundColor(isActive ? Color(red: 0.7, green: 1.0, blue: 0.3) : .white)
	}
	.padding(.vertical, 4)
}

struct WorkoutMainView_Previews: PreviewProvider {
	static var previews: some View {
		WorkoutMainView()
	}
}
