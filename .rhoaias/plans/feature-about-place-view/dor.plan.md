## Problem Statement
La vista de detalles de lugares (`AboutThePlaceView`) se encuentra vacía. Dado que `NearbyPlaces` ya obtiene lugares desde OSM y provee su ID nativo, se requiere conectar ambos flujos: inyectar el ID de OSM en `AboutThePlaceView`, disparar `fetchElementDetails` con este ID, popular una interfaz idéntica a la maqueta provista y habilitar la persistencia de favoritos vía SwiftData.

## Acceptance Criteria
- Given que un usuario entra a `AboutThePlaceView`, When se monta la vista, Then se muestra un estado *idle* con placeholders ("Cargando...", imagen verde pastel con icono) y un overlay semitransparente gris con spinner rojo que bloquea toda la pantalla.
- Given el estado de carga activo, When la API de OSM responde exitosamente, Then el overlay desaparece y el header de imagen verde se reemplaza por un mapa centrado en el pinmarker, mostrando los datos de nombre, calificación, horario y distancia.
- Given la respuesta de OSM, When falten campos opcionales como calificación o horario de apertura, Then las dos cajas amarillas pastel muestran textos por defecto (e.g., "Sin calificación", "N/D") pero mantienen su simetría visual.
- Given una falla en la petición (timeout o red), When ocurre el error, Then desaparece el overlay y se dispara un `Alert` nativo con los mismos estilos implementados en `NearbyPlaces`.
- Given la interfaz cargada, When el usuario toca el botón de favoritos (inferior o en el Toolbar), Then el ícono de corazón cambia a rojo y se guarda la asociación en `SwiftData` utilizando el correo del usuario (sesión activa) y el ID del producto de OSM.
- Given la persistencia de un lugar, When el usuario toca nuevamente el botón de favorito rojo, Then se elimina el registro en SwiftData y el corazón vuelve a su estado inactivo (gris).

## User Flow
1. Navegación desde `NearbyPlaces` inyectando el ID de OSM y datos básicos.
2. Estado bloqueante de carga (Placeholders + Overlay).
3. Transición de UI a datos reales o estado de error (Alert).
4. Interacción con los botones de Favoritos y persistencia offline.

## API / Data Contract
- **Entrada a la Vista:** ID de OSM (String que puede castearse a entero o usarse directamente) y el tipo (ej. `"node"`).
- **Llamada de red:** `fetchElementDetails(id: Int, type: String)` que devuelve un `OSMElement?`.
- **Base de Datos Local (SwiftData):** Un modelo de tipo `FavoritePlace` (o equivalente) que posea las propiedades únicas `userEmail` y `osmId`.

## UI Specification
- **Overlay:** Color `Color.gray.opacity(0.4)` (o similar) con un `ProgressView` de `tint` `.red` (mismo rojo de logout).
- **Idle Header:** Rectángulo superior color verde pastel (ej. `#D4EBE1`) y centrado un icono de mapa (`photo` o similar de SFSymbol) color verde oscuro.
- **Loaded Header:** Un `Map` bloqueado para interacción (`.disabled(true)` o `.allowsHitTesting(false)`) centrado en las coordenadas del punto.
- **Cuadros de Información:** Dos cajas con `.background(Color.yellow.opacity(0.2))` y `.cornerRadius(8)`, separadas equitativamente (`HStack` con `spacing`).
- **Fav Button (Bottom):** Forma redondeada con borde. Texto: "Marcar como favorito" / "Desmarcar como favorito". Ícono: `heart` (gris) o `heart.fill` (rojo pastel/rojo).
- **Toolbar Icon:** `heart` o `heart.fill` reaccionando a la misma propiedad de estado que el botón inferior.

## Non-Functional Requirements
- **Concurrencia:** La tarea asíncrona debe ser adjuntada al ciclo de vida de la vista (`.task` o con referencia a un `Task` que soporte cancelación `cancel()`).
- **Performance:** El mapa no-interactivo debe renderizarse lo más ligero posible, sin cargar capas 3D o POIs innecesarios de Apple Maps, solo el pin de ubicación.
