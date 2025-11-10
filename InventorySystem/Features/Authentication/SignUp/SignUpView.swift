import SwiftUI

struct SignUpView: View {
    @State private var viewModel = SignUpViewModel()
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.system(size: 30, weight: .bold))
                .padding()
            
            VStack(alignment: .leading, spacing: 8) {
                InputField(
                    label: "Name",
                    text: $viewModel.name,
                    focusedField: $focusedField,
                    field: Field.name
                )
                
                if let error = viewModel.nameError {
                    Text("\(error)")
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
            
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
                viewModel.handleSignUp()
            } label: {
                Text("Sign Up")
                    .foregroundColor(Color.text)
            }
            .customStyle()
            
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

#Preview {
    SignUpView()
}
