## Functional
- **User Flow**: Usuario abre la app -> ve la Vista 1 -> toca "Continuar con Google" -> se autentica -> ve su perfil por 2s -> transiciona (cross-fade) a Vista 2. Si falla por red -> alerta. Si cancela -> estado inicial.
- **Acceptance Criteria**:
  - UI implementada en SwiftUI basada en la referencia.
  - SDK de Google SignIn integrado.
  - Alerta de error de red con texto específico: "Error de red. Inténtalo de nuevo."
  - Transición automática post-login de exactamente 2s usando cross-fade.
- **Auto-Login**: The AuthUseCase and LoginViewModel must check for an existing session on init via restorePreviousSignIn and skip the login button.

## Non-Functional
- **Security**: Los identificadores de sesión/tokens obtenidos deben guardarse de forma segura usando Keychain. If saving the token to Keychain fails, the system must revert the Google SignIn state and show a generic error alert to the user, preventing an invalid session state.
- **UX/UI**: Transición suave (cross-fade). Fidelidad al diseño de referencia.

## Technical constraints
- **Architecture**: MVVM con Clean Architecture (`LoginView`, `LoginViewModel`, `AuthUseCase`, `KeychainRepository`).
- **Dependencies**: SDK `GoogleSignIn` añadido mediante Swift Package Manager.
- **Environment**: Configuración de Client ID de Google Cloud asumida como presente en el proyecto.
- **Google Configuration**: URL Scheme configuration for GoogleSignIn must be verified by configuring the REVERSED_CLIENT_ID in Info.plist.

## Test criteria
- Validar mock exitoso de Google SDK en el UseCase.
- Validar manejo de errores (red vs. cancelación) en el ViewModel.
- Validar lógica de timing (2 segundos) en el ciclo de vida de la vista.

## Commitment
- Análisis completado. Bloqueos de definición resueltos.
- Listo para ser abordado en la fase de blueprint (diseño técnico).

## Out of scope
- Integración de "Sign in with Apple" u otros proveedores.
- Registro nativo con correo.
- Implementación de la UI y lógica de negocio de la Vista 2.
