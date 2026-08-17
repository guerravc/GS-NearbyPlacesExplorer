## Intake: Vista 2 — Listado de lugares cercanos

## Description
Implementar la "Vista 2" (Lugares cercanos) de la aplicación, la cual es la pantalla principal tras el login. Debe contener un `searchable` para buscar lugares, y un `TabView` o equivalente para alternar entre dos modos de visualización:
1. **Mapa (MapKit)**: Ignorando el "safe area" (pantalla completa o expandida), centrado en la ubicación actual del usuario y mostrando pines de los lugares obtenidos desde la API.
2. **Lista**: Mostrando celdas con información detallada de cada lugar (ícono, nombre, distancia, estado).
La carga de datos debe ser asíncrona (`async/await`) y debe incluir una pantalla o capa de carga (loading state) con fondo translúcido (alpha) y un spinner que bloquee la interacción mientras se resuelven los datos. Finalmente, la pantalla debe tener manejo explícito para estado vacío (sin resultados) y estado de error (sin conexión/fallo de API).

## Motivation
Tras autenticarse, el usuario necesita ver inmediatamente el valor central de la app: descubrir qué tiene a su alrededor. El formato dual (mapa para contexto espacial y lista para exploración rápida) cubre diferentes necesidades de exploración, mientras que el manejo robusto de la red (loading/error) asegura una UX fluida y sin frustración.

## Desired Outcome
- Tab 1 implementado con MapKit, centrado en ubicación actual, con pines (`ignoringSafeArea`).
- Tab 2 implementado como lista de celdas mostrando: icono, nombre, distancia, estado (e.g. abierto/cerrado).
- Modificador `.searchable` agregado en la barra de navegación para filtrado o búsqueda.
- Integración de llamada a la API usando `async/await`.
- Estado de loading (overlay translúcido + spinner) implementado para evitar múltiples interacciones simultáneas.
- Estados de error y de vacío manejados y visibles al usuario.
- UI basada en la imagen de referencia.

## Product Analysis Carry-Over
**Jobs-to-be-Done (JTBD):**
"Cuando estoy explorando mi entorno, quiero ver los lugares cercanos tanto en un mapa como en formato de lista, para poder orientarme espacialmente o leer detalles rápidos según me convenga en ese momento."

**User Journey:**
1. El usuario aterriza en la Vista 2.
2. La app solicita/revisa permisos de ubicación e intenta obtener coordenadas actuales.
3. Se dispara la petición a la API. El overlay de loading bloquea la pantalla con un spinner.
4. *Success*: Se oculta el loading. Se muestran pines en el mapa y la lista se puebla.
5. El usuario cambia entre la pestaña de Mapa y Lista.
6. El usuario usa el buscador (`searchable`) para filtrar lugares específicos.
7. *Error / Empty*: Si no hay red, la pantalla muestra un mensaje de error y un botón de reintento. Si no hay resultados cercanos, muestra un empty state amigable.

**MoSCoW Prioritization:**
- **Must Have**: Mapa de MapKit (ignoring safe area), Lista con celdas completas, Toggle/TabBar, Searchable nativo, Loading overlay bloqueante, Manejo de errores y estado vacío, `async/await` fetching.
- **Should Have**: Botón de "Mi ubicación" en el mapa. Refresco automático al hacer pan/zoom en el mapa.
- **Could Have**: Animaciones personalizadas al cambiar de modo mapa a lista.
- **Won't Have**: Detalles a fondo del lugar (Vista 3) en esta tarea.

## Resolved Questions
- **Comportamiento del `.searchable`**: Lanzará una nueva petición de búsqueda a la API en el evento `.onSubmit(of: .search)`, priorizando la región visible actual del mapa.
- **API a utilizar**: Se usará de forma nativa `MKLocalSearch` del framework `MapKit` de Apple. Los modelos de datos esperados serán instancias de `MKMapItem`, las cuales proveerán coordenadas, nombre, y otra metadata asociada para renderizar los `Marker` en el mapa y la celda en la lista.
- **Control de navegación**: Se utilizará un `TabView` estándar de iOS (TabBarView en la parte inferior) con dos pestañas ("Mapa" y "Lista") que alternarán completamente el contenido principal de la pantalla.

## Out of Scope
- Vista de detalles de un lugar individual (Vista 3 o Sheet).
- Manejo complejo de permisos de ubicación si el usuario los denegó permanentemente desde Ajustes (se asumirá flujo genérico inicial).

## Constraints and Assumptions
- **Constraint**: Uso mandatorio de `async/await`, MVVM Clean Architecture, SwiftUI y MapKit (según `stack-profile.md`).
- **Assumption**: El flujo asume que los permisos de ubicación se gestionarán transparentemente antes o durante la renderización de esta vista.

## Notes
- La imagen de referencia muestra un Picker segmentado ("Mapa" | "Lista") y no el típico TabBar de navegación inferior. Se documenta la discrepancia verbal/visual para refinar en la fase de Enriquecimiento/Blueprint.
