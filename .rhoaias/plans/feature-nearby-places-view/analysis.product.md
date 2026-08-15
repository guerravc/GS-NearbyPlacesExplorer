## Gap Summary

| Dimension | Status | Notes |
|-----------|--------|-------|
| Problem statement | present | Definido en intake (encontrar lugares cercanos) |
| Acceptance criteria | present | Enriquecidos con lógica de concurrencia, copies exactos y catálogo de íconos |
| User flow | present | Extendido para contemplar peticiones de permisos de ubicación y estados fallidos |
| API / Data contract | present | MKLocalSearch de MapKit. Mapeo profundo de `MKPointOfInterestCategory` |
| UI specification | present | Diseño de celdas estricto, iconos de TabBar, botón de Logout, y directivas de accesibilidad |
| File impact | missing | Deducido: Vistas SwiftUI y ViewModel MVVM |
| Dependencies | missing | Deducido: MapKit y CoreLocation |
| Non-functional requirements | present | Overlay de carga bloqueante, ignoringSafeArea, retención de estado transversal |
| Test criteria | present | Unit Tests (ViewModel), MKLocalSearch mocks, Edge cases de red y permisos |
| Out of scope | present | Implementación visual y lógica de Vista 3. Sólo se deja la estructura de enrutamiento |

## Enhanced Ticket Content
**Description**
Implementar la "Vista 2" (Lugares cercanos) utilizando un `TabView` para presentar los mismos datos bajo dos formatos: "Mapa" y "Lista".
El desarrollo exige gestionar dinámicamente los permisos de ubicación mediante CoreLocation para calcular distancias relativas y centrar el mapa. La búsqueda (searchable) utiliza la API nativa de Apple (`MKLocalSearch`) que se dispara mediante `onSubmit`. Durante el procesamiento asíncrono, se mostrará un overlay semi-transparente bloqueante para prevenir saturación de peticiones concurrentes o interacciones anómalas.
La presentación visual de los resultados (tanto en pines del mapa como en celdas de lista) estará gobernada por un diccionario estricto que mapea `MKPointOfInterestCategory` a `SF Symbols` para dar identidad visual a cada tipo de lugar (ej. `cafe` -> `cup.and.saucer.fill`, `museum` -> `building.columns.fill`).
Las vistas deben incluir un comportamiento resiliente con copies exactos: si Apple Maps no devuelve datos de horarios, mostrar "Horario no disponible"; si el usuario deniega la ubicación, mostrar alerta para ir a Preferencias; y si ocurre un fallo de red o la búsqueda es vacía, desplegar las alertas correspondientes con textos pre-definidos. A nivel de UI, se exige la inclusión de un botón de "Locate Me" con soporte de VoiceOver, un botón superior de Logout permanente, y un diseño de celda específico (contenedor rojo pastel, título bold, subtítulo de distancia/estado y chevron de navegación) que prepare el terreno técnico para la navegación a `AboutThePlaceView`.

**Acceptance Criteria**
- El flujo verifica permisos de CoreLocation. Si está denegado, muestra Alerta: Título "Ubicación necesaria", Mensaje "Necesitamos tu ubicación para calcular las distancias y mostrar lugares cercanos. Por favor, habilítala en las preferencias de tu dispositivo.", con botones "Cancelar" e "Ir a Preferencias".
- La interfaz implementa un `TabView` ("Mapa" con icono `map`, "Lista" con `list.bullet`).
- El estado de la búsqueda reside en un nivel superior (ej. `NavigationStack`) para que el cambio de tabs no reinicie los resultados.
- El placeholder del Searchable debe ser "Buscar lugares cercanos".
- Existe un botón global de Logout (`rectangle.portrait.and.arrow.right`) en la barra de navegación superior derecha.
- Al disparar la búsqueda (`onSubmit`), la UI interrumpe la interacción con un overlay translúcido + `ProgressView`.
- **Diccionario de Íconos:** Los lugares deben renderizar un ícono dependiendo de su categoría (`MKPointOfInterestCategory`). Ejemplos mínimos requeridos: `.airport` (`airplane`), `.bank` (`building.columns.fill`), `.cafe` (`cup.and.saucer.fill`), `.restaurant` (`fork.knife`), `.hospital` (`cross.case.fill`), `.park` (`leaf.fill`), `.store` (`bag.fill`), fallback default (`mappin.and.ellipse`).
- La celda de la lista replica el diseño objetivo: contenedor de icono redondeado (radius 8) fondo rojo pastel (`Color.red.opacity(0.15)`), icono rojo oscuro (`Color.red`), título principal en negritas (`headline`), subtítulo gris (`subheadline`) con formato "X.X km • [Estado]" y `chevron.right` final.
- Si la metadata del `MKMapItem` no permite conocer el estado, el subtítulo mostrará "Horario no disponible".
- El toque en un marcador interactivo o una celda prepara el `NavigationLink` hacia `AboutThePlaceView`.
- Empty State visual: Mensaje "No encontramos resultados para '[Término]'. Intenta con otra búsqueda." con ícono `magnifyingglass`.
- Error de Red: Alerta Título "Error de búsqueda", Mensaje "Hubo un problema al buscar lugares. Revisa tu conexión a internet e intenta de nuevo."

**Test Steps**
- Arrancar la aplicación simulando "Ubicación Denegada" y validar la carga de la vista por defecto y el alert de permisos.
- Realizar una búsqueda exitosa; validar que el resultado persiste al cambiar entre la pestaña Mapa y Lista.
- Comprobar visualmente que una cafetería renderice `cup.and.saucer.fill` y un parque `leaf.fill`.
- Durante la carga de búsqueda, intentar tocar el TabBar o el botón de Logout; validar que el overlay impida la interacción.
- Buscar un término que garantice 0 resultados y validar el copy exacto del Empty State.

## Product Analysis
**Jobs-to-be-Done (JTBD):**
"Cuando me encuentro explorando mi entorno, quiero ver opciones cercanas identificables rápidamente por su tipo (icono), con sus distancias exactas, de forma que pueda decidir si me dirijo allí con base en la cercanía y su disponibilidad horaria."

**User Journey:**
1. El usuario aterriza en la Vista 2. El sistema pide acceso a la ubicación si no lo tiene.
2. Si denegado, el sistema alerta sobre la funcionalidad reducida con el copy definido.
3. El usuario escribe en la barra de búsqueda y confirma. El sistema interrumpe la UI con un spinner.
4. Los resultados se procesan. El `ViewModel` mapea la categoría de cada lugar a su SF Symbol correspondiente.
5. Los resultados se grafican en el mapa con sus iconos. El usuario panea y usa `location.fill` para recentrar.
6. El usuario salta a la pestaña Lista para ver las métricas (0.4 km • Abierto / Cerrado / Horario no disponible).
7. Al no haber sorpresas, el usuario toca la celda (marcada con el chevron) para navegar a la siguiente etapa.

**MoSCoW Prioritization:**
- **Must Have**: Gestión de permisos de ubicación con alertas de UI, mapeo de `MKPointOfInterestCategory` a SF Symbols, diseño exacto de celdas y barra de navegación, copies estrictos para Empty/Error states, retención de datos entre tabs.
- **Could Have**: Animaciones personalizadas al renderizar los resultados en la lista.
- **Won't Have**: Desarrollo profundo de Vista 3. Soporte de Accesibilidad (A11y/VoiceOver).
