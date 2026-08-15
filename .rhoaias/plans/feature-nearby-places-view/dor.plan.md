## Functional
- **User Flow**: Petición de ubicación -> Búsqueda con retención de estado -> Identificación visual de lugares por categoría (Icono) -> Despliegue en Mapa o Lista alternable -> Navegación preparada a Vista 3 -> Logout.
- **Acceptance Criteria**:
  - `TabView` gestionando las vistas de Mapa y Lista con iconos definidos (`map` y `list.bullet`).
  - Botón Logout con icono `rectangle.portrait.and.arrow.right`.
  - Mapeo programático de `MKPointOfInterestCategory` a SF Symbols (mínimo 15 categorías críticas + fallback `mappin.and.ellipse`).
  - Bloqueo de UI (Overlay) durante peticiones de red vía `MKLocalSearch`.
  - Diseño calcado de celda (contenedor rojo pastel opacity 0.15, icono oscuro, título headline, subtítulo subheadline gris con formato "X.X km • Estado", chevron.right).
  - Copies exactos para el estado horario: "Abierto", "Cerrado", "Horario no disponible".
  - Copies exactos para Empty State, Fallo de Red y Permisos Denegados.

## Non-Functional
- **UX/UI**: El overlay de carga es una prevención de race condition crítica. El diccionario visual (SF Symbols) debe hacer que la exploración del mapa sea intuitiva.
- **Performance/State**: El array de resultados y la lógica de búsqueda NO deben estar amarrados a los ciclos de vida de un tab individual, sino al padre.

## Technical constraints
- **Architecture**: MVVM Clean Architecture. Un diccionario estático o capa de servicio debe abstraer el mapeo de `MKPointOfInterestCategory` a SF Symbols.
- **Dependencies**: `MapKit` para los renderizados y metadatos, `CoreLocation` para distancias.

## Test criteria
- Pruebas de unidad para validar el mapeo correcto del enum `MKPointOfInterestCategory` al nombre del SF Symbol esperado.
- Pruebas para asegurar que el ViewModel maneje correctamente los strings de Empty State y Error State.
- Pruebas de inyección de errores (timeout simulado) para comprobar la alerta.

## Commitment
- Análisis profundo ejecutado resolviendo la falta de definición visual y de copies (strings e iconos exactos).
- Listo para ser abordado en la fase de blueprint (diseño técnico).

## Out of scope
- La pantalla `AboutThePlaceView` en toda su extensión.
- Accessibility (A11y/VoiceOver) support for buttons and cells.
