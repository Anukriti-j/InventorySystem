import SwiftUI

struct LoginView: View {
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
                    systemImage: "envelope.fill",
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
                    systemImage: "lock.fill",
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
                Task {
                    await viewModel.handleLogin()
                }
               
            } label: {
                Text("Login")
                    .foregroundColor(Color.text)
            }
            .customStyle()
            
            HStack {
                Text("Don't have an account? ")
                
                NavigationLink("Sign Up") {
                    SignUpView()
                }
            }
            
            //MARK: Remove this mock api response
            ForEach(viewModel.response ?? []) { loginResponse in
                Text("\(loginResponse.name)")
            }
            
        }
        .onChange(of: viewModel.shouldFocusField) { _, newValue in
            focusedField = newValue
        }
        .onChange(of: focusedField) { _, newValue in
            viewModel.shouldFocusField = newValue
        }
        .padding()
    }
}

struct InputField: View {
    let label: String
    let systemImage: String
    @Binding var text: String
    @FocusState.Binding var focusedField: Field?
    let field: Field
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.6))
            
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.8))
                    .frame(width: 20)
                
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
    let systemImage: String
    @Binding var text: String
    @FocusState.Binding var focusedField: Field?
    let field: Field
    @State private var isSecure: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundColor(.primary)
                    .frame(width: 20)
                
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
