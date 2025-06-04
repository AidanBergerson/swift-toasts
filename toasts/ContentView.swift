//
//  ContentView.swift
//  toast-mastery
//
//  Created by Aidan Bergerson on 6/4/25.
//

import SwiftUI

// MARK: Toast Model
struct Toast: Identifiable, Equatable {
    // Unique identifier for each toast instance (required)
    let id = UUID()
    let type: ToastType
    let title: String
    let message: String?
    let duration: TimeInterval
    
    init(type: ToastType, title: String, message: String, duration: TimeInterval) {
        self.type = type
        self.title = title
        self.message = message
        self.duration = duration
    }
}

// MARK: Toast Type
enum ToastType: CaseIterable {
    case success
    case error
    case warning
    case info
    case loading
    
    var iconName: String {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .info:
            return "info.circle.fill"
        case .loading:
            return "arrow.clockwise"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .success:
            return .green
        case .error:
            return .red
        case .warning:
            return .orange
        case .info:
            return .blue
        case .loading:
            return .gray
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .success:
            return Color.green.opacity(0.1)
        case .error:
            return Color.red.opacity(0.1)
        case .warning:
            return Color.orange.opacity(0.1)
        case .info:
            return Color.blue.opacity(0.1)
        case .loading:
            return Color.gray.opacity(0.1)
        }
    }
}

// MARK: - Toast View
struct ToastView: View {
    let toast: Toast
    @State private var isVisible = false
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        HStack {
            Group {
                if toast.type == .loading {
                    Image(systemName: toast.type.iconName)
                        .foregroundStyle(toast.type.primaryColor)
                        .rotationEffect(.degrees(rotationAngle))
                        .onAppear {
                            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                                rotationAngle = 360
                            }
                        }
                } else {
                    Image(systemName: toast.type.iconName)
                        .foregroundStyle(toast.type.primaryColor)
                }
            }
            .font(.system(size: 20, weight: .semibold))
            
            VStack {
                Text(toast.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(toast.type.primaryColor)
                
                if let message = toast.message {
                    Text(message)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
            
            Spacer()
            
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(toast.type.backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(toast.type.primaryColor.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .scaleEffect(isVisible ? 1 : 0.0)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
    }
}


// MARK: - Toast Manager
class ToastManager: ObservableObject {
    @Published var toasts: [Toast] = []
    
    func show(_ toast: Toast) {
        toasts.append(toast)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration) {
            self.dismiss(toast)
        }
    }
    
    func dismiss(_ toast: Toast) {
        withAnimation(.easeInOut(duration: 0.3)) {
            toasts.removeAll { $0.id == toast.id }
        }
    }
    
    func dismissAll() {
        withAnimation(.easeInOut(duration: 0.3)) {
            toasts.removeAll()
        }
    }
}


// MARK: - Toast Container View
struct ToastContainer: View {
    @EnvironmentObject var toastManager: ToastManager
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 8) {
                ForEach(toastManager.toasts) { toast in
                ToastView(toast: toast)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                        .onTapGesture {
                            toastManager.dismiss(toast)
                        }
                    
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 50)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - View Extension for Toast
extension View {
    func toast() -> some View {
        ZStack {
            self
            ToastContainer()
        }
    }
}


// MARK: - Demo Content View
struct ContentView: View {
    @EnvironmentObject var toastManager: ToastManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Toast Message System")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Text("Tap buttons below to test different toast types")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ToastButton(
                            title: "Success",
                            color: .green,
                            icon: "checkmark.circle.fill"
                        ) {
                            toastManager.show(
                                Toast(type: .success,
                                     title: "Success!",
                                     message: "Your action was completed successfully.",
                                     duration: 3.0)
                            )
                        }
                        
                        ToastButton(
                            title: "Error",
                            color: .red,
                            icon: "xmark.circle.fill"
                        ) {
                            toastManager.show(
                                Toast(type: .error,
                                     title: "Error!",
                                     message: "Something went wrong. Please try again.",
                                     duration: 4.0)
                            )
                        }
                        
                        ToastButton(
                            title: "Warning",
                            color: .orange,
                            icon: "exclamationmark.triangle.fill"
                        ) {
                            toastManager.show(
                                Toast(type: .warning,
                                     title: "Warning",
                                     message: "Please check your input and try again.",
                                     duration: 3.5)
                            )
                        }
                        
                        ToastButton(
                            title: "Info",
                            color: .blue,
                            icon: "info.circle.fill"
                        ) {
                            toastManager.show(
                                Toast(type: .info,
                                     title: "Information",
                                     message: "Here's some helpful information for you.",
                                     duration: 3.0)
                            )
                        }
                        
                        ToastButton(
                            title: "Loading",
                            color: .gray,
                            icon: "arrow.clockwise"
                        ) {
                            toastManager.show(
                                Toast(type: .loading,
                                     title: "Loading",
                                     message: "Please wait while we process your request.",
                                     duration: 5.0)
                            )
                        }
                        
                        // Clear all toasts
                        ToastButton(
                            title: "Clear All",
                            color: .purple,
                            icon: "trash.fill"
                        ) {
                            toastManager.dismissAll()
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 200)
                    
                }
            }
        }
        .navigationBarHidden(true)
        .toast()
    }
}

// MARK: - Toast Button Component
struct ToastButton: View {
    let title: String
    let color: Color
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
            
        }
        .buttonStyle(PlainButtonStyle())
    }
}
