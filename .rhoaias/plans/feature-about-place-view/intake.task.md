## Intake: AboutThePlaceView con UI Reactiva, SwiftData y Refactor de OSM

## Description
Implementar la vista `AboutThePlaceView` con llamadas asíncronas a la API de OSM (`fetchElementDetails`), diseño de UI idéntico a la imagen provista (usando placeholders y un overlay bloqueante gris con spinner rojo), y persistencia local de Favoritos vinculada al email del usuario mediante SwiftData. Como prerrequisito fundamental, se refactorizará la fuente de datos de la vista previa (`NearbyPlaces`) para que utilice objetos OSM nativos en lugar de `MKMapItem`, permitiendo transferir el ID de OSM de forma directa hacia esta nueva vista; las transformaciones a `MKMapItem` se realizarán únicamente al vuelo para renderizar el mapa. El manejo de errores reutilizará el patrón de `Alert`s ya definido en `NearbyPlaces`.

## Motivation
La vista `NearbyPlaces` ya permite seleccionar un lugar y navegar hacia el detalle, pero la pantalla destino carece de implementación. Se necesita completar el flujo para permitir al usuario ver detalles ricos del lugar y guardar favoritos, asegurando que la arquitectura de datos entre ambas vistas sea coherente y robusta.

## Desired Outcome
- Al abrir la vista, se dispara `fetchElementDetails` en el `onAppear`.
- Durante la carga, se muestra un overlay gris semitransparente con un spinner rojo bloqueando la interacción.
- La UI en estado *idle* muestra placeholders ("Cargando...", imagen verde pastel con icono de mapa oscuro).
- Al resolverse la petición, la vista se rellena con un header (nombre), distancia, calificación, horario/disponibilidad, descripción del lugar y horario estructurado.
- El botón de Favoritos en la parte inferior (texto "Marcar como favorito" con icono de corazón gris, o "Desmarcar como favorito" con corazón rojo) interactúa con `SwiftData` usando la clave compuesta `email + OSM ID`.
- El Toolbar superior derecho tiene un botón de corazón que sincroniza su estado con el botón inferior.
- La vista `NearbyPlaces` ha sido refactorizada para manejar objetos OSM nativos y proveer el ID necesario.

## Product Analysis Carry-Over
**Deducciones de UX y Lógica:**
- La experiencia de carga incluye placeholders detrás de un velo bloqueante, previniendo interacción temprana y evitando una pantalla en blanco.
- Los campos faltantes en el payload de OSM (ej. calificación, horarios) deberán tener un fallback visual de "N/D" o ser ocultados según se defina, para no corromper la maqueta.
- SwiftData depende del estado de autenticación (Login), forzando a la vista a recuperar el email del usuario activo de forma segura.

## Open Questions
- Si `NearbyPlaces` se refactoriza para consumir y mantener objetos OSM desde el inicio (en lugar del resultado directo de `MKLocalSearch`), ¿debemos cambiar el mecanismo entero de búsqueda de Apple Maps (`MKLocalSearch`) a una query espacial directa a OSM Overpass, o cruzaremos datos de ambas APIs? (Esto debe resolverse en `/enrich` o `/blueprint`).

## Out of Scope
- Funcionalidad de routing (navegación paso a paso al lugar).
- Edición del perfil de usuario u otras funcionalidades ajenas al detalle del lugar y sus favoritos.

## Constraints and Assumptions
- El diseño debe adherirse estrictamente a la maqueta provista (colores pastel, iconos específicos, layout), implementado con componentes nativos de SwiftUI.
- Se asume que el objeto OSM retornado contiene o puede proveer los metadatos de calificación y horario, o se deberá manejar grácilmente la ausencia de estos datos.
- El manejo de errores debe acoplarse y reutilizar exactamente la implementación de alertas de `NearbyPlaces`.

## Notes
- La imagen adjunta es la "fuente de la verdad" para márgenes, pesos de fuente y colores (rojo, verde pastel, amarillo pastel).
