## Gap Summary

| Dimension | Status | Notes |
|-----------|--------|-------|
| Problem statement | present | Reducir fricción de onboarding |
| Acceptance criteria | incomplete | Formalizados criterios (2s, cross-fade, alertas, Keychain) |
| User flow | present | Definido en intake |
| API / Data contract | missing | Especificado GoogleSignIn SDK para iOS |
| UI specification | present | Imagen de referencia provista |
| File impact | missing | Deducido: LoginView, LoginViewModel, AuthUseCase, KeychainRepository |
| Dependencies | missing | Deducido: GoogleSignIn vía SPM |
| Non-functional requirements | incomplete | Deducido: Persistencia segura en Keychain |
| Test criteria | missing | Deducido: Unit Tests (ViewModel/UseCase), UI Tests |
| Out of scope | present | Apple Sign-In, Email/Password, Vista 2 |

## Enhanced Ticket Content
**Description**
Implementar la "Vista 1" de la aplicación (Login), permitiendo a los usuarios autenticarse mediante Google Sign-In (Google Identity Services). La pantalla debe replicar fielmente el diseño provisto en la imagen de referencia. Incluye un flujo UX específico donde, tras una autenticación exitosa, se muestre brevemente el nombre y foto de perfil del usuario por exactamente 2 segundos antes de transicionar automáticamente a la "Vista 2" mediante un cross-fade. Se requiere el manejo y visualización de estados de error específicos: alerta en fallo de red, y silencio en cancelación de usuario. El token de sesión debe guardarse de forma segura en Keychain. Se seguirá el patrón MVVM con Clean Architecture y SwiftUI.

**Acceptance Criteria**
- La UI de la Vista 1 coincide visualmente con la referencia provista.
- El botón "Continuar con Google" inicia el flujo del SDK nativo `GoogleSignIn`.
- En caso de éxito, el nombre y foto de perfil se muestran por exactamente 2 segundos.
- Tras la espera de 2 segundos, la navegación a la Vista 2 se realiza con animación cross-fade.
- Si hay un error de red durante la autenticación, se muestra una alerta nativa con el texto "Error de red. Inténtalo de nuevo." y un botón "OK".
- Si el usuario cancela el flujo de autenticación, la interfaz regresa al estado inicial de forma silenciosa sin mostrar errores.
- Los credenciales/tokens de sesión devueltos por Google se persisten utilizando Keychain.

**Test Steps**
- Ejecutar Unit Tests para validar el comportamiento del UseCase de autenticación y el ViewModel (mockeando respuestas exitosas y fallidas).
- Lanzar la app y presionar el botón de Google Sign-In; verificar que el modal nativo se despliega.
- Cancelar el flujo del modal y verificar que no aparece ninguna alerta y el botón vuelve a estar activo.
- Interceptar o forzar fallo de red, intentar autenticar y verificar que aparece la alerta exacta "Error de red. Inténtalo de nuevo."
- Autenticar con éxito y verificar visualmente que el nombre y la foto de perfil se muestran por 2 segundos antes de la transición cross-fade hacia la siguiente vista.

## Product Analysis
**Jobs-to-be-Done (JTBD):**
"Cuando abro la aplicación por primera vez, quiero autenticarme de forma rápida y segura usando mi cuenta de Google, para poder comenzar a descubrir puntos de interés cercanos sin el esfuerzo de crear una nueva cuenta."

**User Journey:**
1. El usuario abre la app y visualiza la pantalla de bienvenida / login.
2. Lee la propuesta de valor y toca "Continuar con Google".
3. Completa el flujo de Google Sign-In.
4. *Success Path*: El sistema recibe el token y datos del perfil. La pantalla muestra el nombre y la foto por exactamente 2 segundos.
5. El sistema navega automáticamente a la Vista 2 mediante cross-fade.
6. *Error Path*: Si hay error de red, muestra alerta. Si cancela, vuelve al estado inicial de forma silenciosa.

**MoSCoW Prioritization:**
- **Must Have**: Botón Google Sign-In, integración SDK, alertas específicas, fallback silencioso en cancelación, persistencia en Keychain, navegación a Vista 2 con cross-fade.
- **Won't Have**: Registro tradicional, Apple Sign-In, implementación completa de la Vista 2.
