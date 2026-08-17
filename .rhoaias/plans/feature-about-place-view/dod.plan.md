## Functional Criteria
- [ ] La vista ejecuta la petición `fetchElementDetails` automáticamente al iniciar.
- [ ] Se despliega un overlay bloqueante con spinner rojo durante la espera.
- [ ] La UI presenta placeholders ("Cargando...") mientras los datos llegan.
- [ ] La respuesta exitosa oculta el overlay y muestra un mapa centrado, además de popular nombre, calificación, horario y distancia.
- [ ] Los campos opcionales ausentes en la respuesta OSM se manejan con fallbacks visuales simétricos.
- [ ] Un error de red levanta un Alert estandarizado igual al de `NearbyPlaces`.
- [ ] Los botones de Favorito (inferior y Toolbar) sincronizan su estado y actúan en conjunto.
- [ ] Marcar o desmarcar el favorito altera persistentemente los datos en `SwiftData`, utilizando `email` del usuario activo y el `osm_id`.

## Quality Criteria
- [ ] La navegación desde `NearbyPlaces` inyecta el ID correcto extraído del `NearbyPlacesEntity`.
- [ ] Si el usuario descarta `AboutThePlaceView` durante el `fetch`, la tarea se cancela limpiamente (evitando crasheos).

## Test Criteria
- [ ] **Happy Path:** Entrar a la vista -> Ver overlay y placeholders -> Ver datos llenos y mapa centrado -> Tocar favoritos y comprobar persistencia visual.
- [ ] **Failure Scenario:** Entrar a la vista -> Simular corte de red -> Verificar que el overlay desaparece y el `Alert` se muestra -> Tocar OK y regresar a pantalla previa.
- [ ] **Edge Case:** Múltiples toques repetitivos en el botón de favorito no corrompen la persistencia de SwiftData (idempotencia en borrado/guardado).
