import SwiftUI

struct LoginView: View {
    @Environment(SessionManager.self) private var sessionManager: SessionManager
    @State private var viewModel: LoginViewModel = LoginViewModel()
    @FocusState private var focusedField: Field?
    
    
    var body: some View {
        VStack {
            Text("Log In")
                .font(.system(size: 30, weight: .bold))
                .padding()
            
            VStack(alignment: .leading, spacing: 8) {
                InputField(
                    label: "Email",
                    text: $viewModel.email,
                    focusedField: $focusedField,
                    field: Field.email
                )
                
                if let error = viewModel.emailError {
                    Text("\(error)")
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                SecureInputField(
                    label: "Password",
                    text: $viewModel.password,
                    focusedField: $focusedField,
                    field: Field.password
                )
                
                if let error = viewModel.passwordError {
                    Text("\(error)")
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
            
            Button {
                if viewModel.isFormValid {
                    Task {
                        await viewModel.handleLogin(sessionManager: sessionManager)
                    }
                }
                
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Login")
                        .foregroundColor(Color.text)
                }
            }
            .customStyle()
            
            HStack {
                Text("Don't have an account? ")
                
                NavigationLink("Sign Up") {
                    SignUpView()
                }
            }
        }
        .padding()
        .onChange(of: viewModel.shouldFocusField) { _, newValue in
            focusedField = newValue
        }
        .onChange(of: focusedField) { _, newValue in
            viewModel.shouldFocusField = newValue
        }
        .alert(viewModel.alertMessage ?? "Message", isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel, action: {}) }
    }
}


struct InputField: View {
    let label: String
    @Binding var text: String
    @FocusState.Binding var focusedField: Field?
    let field: Field
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondaryText)
            
            VStack(spacing: 12) {
                TextField("Enter \(label.lowercased())", text: $text)
                    .focused($focusedField, equals: field)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .textContentType(field == .email ? .emailAddress : .none)
                    .keyboardType(field == .email ? .emailAddress : .default)
            }
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        focusedField == field
                        ? Color(red: 0.7, green: 0.75, blue: 1.0)
                        : Color.clear,
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
}

struct SecureInputField: View {
    let label: String
    @Binding var text: String
    @FocusState.Binding var focusedField: Field?
    let field: Field
    @State private var isSecure: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondaryText)
            
            HStack(spacing: 12) {
                Group {
                    if isSecure {
                        SecureField("Enter your \(label.lowercased())", text: $text)
                            .focused($focusedField, equals: field)
                    } else {
                        TextField("Enter your \(label.lowercased())", text: $text)
                            .focused($focusedField, equals: field)
                    }
                }
                .textContentType(.password)
                
                Button(action: { isSecure.toggle() }) {
                    Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        focusedField == field
                        ? Color(.primaryLight)
                        : Color.clear,
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
}


#Preview {
    LoginView() 
}
