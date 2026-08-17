## Intake: Vista 1 — Login con Google

## Description
Implementar la "Vista 1" de la aplicación (Login), permitiendo a los usuarios autenticarse mediante Google Sign-In (Google Identity Services). La pantalla debe replicar fielmente el diseño provisto en la imagen de referencia (ícono central, título "Explorador de lugares", subtítulo y botón "Continuar con Google"). Incluye un flujo UX específico donde, tras una autenticación exitosa, se muestre brevemente el nombre y foto de perfil del usuario antes de transicionar automáticamente a la "Vista 2". Se requiere además el manejo y visualización de estados de error si la autenticación falla o es cancelada por el usuario.

## Motivation
Se requiere un método de autenticación con la menor fricción posible para que los usuarios puedan comenzar a descubrir puntos de interés rápidamente. Utilizar Google Sign-In elimina la necesidad de crear y recordar contraseñas, mejorando la conversión inicial (onboarding) y permitiendo personalizar la experiencia desde el primer uso.

## Desired Outcome
- Pantalla de login implementada en SwiftUI respetando la tipografía, espaciados y elementos visuales de la referencia.
- Integración del SDK de Google Sign-In configurada y operativa.
- Al tocar "Continuar con Google", se inicia el flujo nativo de autenticación.
- Al tener éxito: captura del perfil (nombre y foto), visualización temporal en pantalla por exactamente 2 segundos (feedback visual), y navegación automática a la Vista 2 mediante una transición suave de disolución (cross-fade).
- Al fallar o cancelar: Si falla por error de red, mostrar una alerta nativa con el texto "Error de red. Inténtalo de nuevo." y un botón "OK". Si el usuario cancela explícitamente, la UI debe regresar silenciosamente al estado inicial de la vista sin mostrar alertas.

## Product Analysis Carry-Over
**Jobs-to-be-Done (JTBD):**
"Cuando abro la aplicación por primera vez, quiero autenticarme de forma rápida y segura usando mi cuenta de Google, para poder comenzar a descubrir puntos de interés cercanos sin el esfuerzo de crear una nueva cuenta."

**User Journey:**
1. El usuario abre la app y visualiza la pantalla de bienvenida / login.
2. Lee la propuesta de valor ("Descubre puntos de interes cerca de ti") y toca "Continuar con Google".
3. Completa el flujo de Google Sign-In (consentimiento).
4. *Success Path*: El sistema recibe el token y datos del perfil. La pantalla muestra el nombre y la foto brevemente para confirmar el éxito.
5. El sistema navega automáticamente a la Vista 2.
6. *Error Path*: Si cancela o hay error de red, la app vuelve al estado inicial de la Vista 1 y muestra un mensaje de error claro (alerta o mensaje inline).

**MoSCoW Prioritization:**
- **Must Have**: Botón de Google Sign-In, integración de SDK, manejo de errores/cancelación, visualización temporal del perfil al tener éxito, navegación a Vista 2, fidelidad al diseño adjunto.
- **Should Have**: Animación o transición suave entre la vista del botón y la muestra del perfil.
- **Won't Have**: Registro tradicional con email y contraseña, Apple Sign-In (fuera del alcance inicial de este task).

## Open Questions
<!-- Bullet list of unresolved questions to address during /enrich. Leave empty if none. -->

## Out of Scope
- Integración de "Sign in with Apple" u otros proveedores sociales.
- Registro nativo por correo y contraseña.
- Implementación de la Vista 2 (solo se debe dejar preparado el punto de navegación o routing).

## Constraints and Assumptions
- **Constraint**: La implementación debe adherirse al patrón MVVM con Clean Architecture y usar SwiftUI (definido en el stack-profile).
- **Constraint**: El estado de la sesión (tokens/identificadores de Google) debe persistirse de forma segura utilizando Keychain.
- **Assumption**: El proyecto en Google Cloud Platform / Firebase ya cuenta con el Client ID de iOS configurado y listo para ser integrado en el proyecto Xcode.

## Notes
- La imagen de referencia muestra un texto legal implícito ("Al continuar aceptas los terminos y el uso de tu ubicacion"). Este texto debe estar presente y ser legible en la parte inferior de la pantalla.
