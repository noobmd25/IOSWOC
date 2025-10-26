//
//  LoginView.swift
//  WhosOnCall
//
//  Login screen with email/password authentication
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Logo/Title
                VStack(spacing: 10) {
                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("WOC")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Who's On Call")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 30)
                
                // Login Form
                VStack(spacing: 15) {
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(.roundedBorder)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.password)
                        .textFieldStyle(.roundedBorder)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.signIn()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign In")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(viewModel.isLoading)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Sign In")
        }
    }
}

#Preview {
    LoginView()
}
