## Gap Summary

| Dimension | Status | Notes |
|-----------|--------|-------|
| Problem statement | present | Definido en intake: implementar AboutThePlaceView y persistencia de favoritos. |
| Acceptance criteria | present | Enriquecidos con estados reactivos, placeholders y lógica de favoritos en SwiftData. |
| User flow | present | Extendido para contemplar estados de carga bloqueantes y errores de OSM. |
| API / Data contract | present | OSM Overpass (`fetchElementDetails`) y `SwiftData` para persistencia local. |
| UI specification | present | Diseño estricto basado en mockups: cajas amarillas pastel, header verde pastel, íconos y layout. |
| File impact | missing | Deducido: Vistas SwiftUI (`AboutThePlaceView`), ViewModels, y persistencia de SwiftData. |
| Dependencies | missing | Deducido: SwiftData, Networking (Overpass). |
| Non-functional requirements | present | Cancelación de peticiones asíncronas para evitar memory leaks (crashes en dismiss temprano). |
| Test criteria | present | Unit tests de la lógica de ViewModel, UI Tests de overlay, persistencia en DB local. |
| Out of scope | present | Funcionalidad de routing real, edición del perfil. |

## Enhanced Ticket Content
**Description**
Implementar la vista de detalle `AboutThePlaceView`. Dado que `NearbyPlaces` ya obtiene lugares nativos de OSM mediante Overpass, se pasará el ID de OSM correspondiente hacia esta nueva vista. Al aparecer la vista, se ejecutará una llamada de red asíncrona a `fetchElementDetails`. Durante esta petición, la pantalla mostrará un overlay gris bloqueante semitransparente con un spinner rojo, y la interfaz base mostrará placeholders (e.g. "Cargando..." y un bloque de imagen verde pastel). Una vez que la petición resuelva, los datos poblarán la UI: se mostrará un mapa centrado en el lugar (no interactivo), y cajas de información color amarillo pastel mostrarán la calificación y el horario. Se implementará una funcionalidad de Favoritos persistida con `SwiftData`, relacionando el email del usuario en sesión y el ID de OSM del lugar. Si faltan datos en el payload de OSM, la interfaz adaptará fallbacks limpios. El manejo de errores replicará las alertas nativas ya implementadas en `NearbyPlaces`.

**Acceptance Criteria**
- Al entrar a `AboutThePlaceView`, se ejecuta inmediatamente la carga y se muestra un estado *idle* con placeholders más un overlay gris semitransparente con spinner rojo bloqueante.
- En caso de éxito de OSM, el overlay desaparece y el header se convierte en un mapa no-interactivo centrado en las coordenadas del lugar. Nombre, distancia, calificación y horario se muestran en la UI.
- Los campos opcionales ausentes (e.g. sin calificación, sin horario) se manejan con fallbacks definidos (como "Sin calificación" o "Horario no disponible") sin romper la simetría de los dos cuadros de información amarillo pastel.
- Si la petición asíncrona falla (timeout, error), desaparece el overlay y se levanta un `Alert` idéntico en patrón y diseño al utilizado en `NearbyPlaces`.
- El Toolbar (arriba a la derecha) y el Bottom Bar alojan un ícono/botón de Favoritos en sincronía bidireccional. Tocarlo cambiará el ícono de corazón a color rojo (activo) o gris (inactivo).
- La acción de marcar favorito persiste en `SwiftData` bajo el esquema clave-compuesta (email del usuario activo + OSM ID del producto).
- Descartar la pantalla antes de la finalización de `fetchElementDetails` cancelará explícitamente el `Task`, previniendo crashes o retenciones indebidas en memoria.

**Test Steps**
- Arrancar la aplicación e ingresar a la vista de detalles; verificar la retención inmediata en pantalla de carga mediante un overlay gris.
- Interceptar o forzar fallo de red durante el ingreso; validar que el overlay desaparece y un `Alert` nativo notifica el error.
- Ingresar exitosamente; validar visualmente la simetría de las cajas de horario y calificación con o sin datos (probando lugares dispares).
- Tocar el botón de favorito en el Toolbar; comprobar que el botón inferior también refleja el estado en rojo.
- Reiniciar la app; confirmar mediante SwiftData que el favorito persistió para ese correo de usuario en específico.
- Retroceder (Dismiss) la vista a mitad del tiempo de carga; verificar mediante la consola y memoria que el `Task` de concurrencia fue cancelado (`Task.cancel()`).

## Product Analysis
**Jobs-to-be-Done (JTBD):**
"Cuando encuentro un lugar de interés cercano, quiero ver detalles granulares (horarios, calificaciones, vista del mapa exacta) de forma inmediata, y poder marcarlo como favorito, para facilitar la toma de mi decisión sobre si visitarlo o guardar su referencia para el futuro."

**User Journey:**
1. El usuario selecciona un marcador o celda de lista en la vista previa (`NearbyPlaces`).
2. Se navega a la pantalla de detalles `AboutThePlaceView` pasándole el ID nativo de OSM y otros datos básicos inyectados.
3. El sistema muestra los "esqueletos" / placeholders ("Cargando...", bloque verde) y un velo gris bloqueante, evitando interacciones inmaduras.
4. Los detalles se cargan. El `ViewModel` mapea los metadatos de OSM, resolviendo ausencias con fallbacks elegantes.
5. El velo gris desaparece, la información se revela de golpe (mapa centrado, cajas amarillas de info).
6. El usuario pulsa el corazón (toolbar superior o botón inferior). La app lo guarda offline (`SwiftData`) bajo su cuenta para consultas posteriores.
7. Al no haber sorpresas, el usuario presiona "Atrás" y la vista libera recursos sanamente.

**MoSCoW Prioritization:**
- **Must Have**: Interfaz reactiva con overlay bloqueante y placeholders de carga; layout idéntico al diseño provisto; integración completa con OSM Overpass para el detalle granular; persistencia offline de favoritos vía `SwiftData` unida al usuario; manejo de excepciones (Alerts) igual a `NearbyPlaces`; Task cancellation al hacer dismiss.
- **Could Have**: Microinteracciones en el botón de favoritos (animaciones de latido o scale).
- **Won't Have**: Rutas paso-a-paso hacia el destino; reseñas escritas por usuarios.
