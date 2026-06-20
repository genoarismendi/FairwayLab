# FairwayLab — Referencia del Código

App iOS de golf en SwiftUI. Permite configurar una ronda, registrar scores en vivo y calcular resultados de múltiples formatos de juego simultáneamente.

---

## Arquitectura

Estructura de carpetas bajo `FairwayLab/`:

```
DomainModels*        — Structs de datos puros (inmutables, Codable)
DomainServices*      — Calculadoras de resultados (lógica de negocio pura)
DomainUtilities*     — Helpers y datos mock de campos
UIViews*             — Vistas SwiftUI
UIViewModels*        — ViewModels (@MainActor, @Published)
AppState.swift       — Estado global del ciclo de vida de la ronda
Services*            — Clientes externos (API de campos)
```

Convención de nombres: el prefijo indica la capa. Un archivo `DomainServicesCaraEPerroCalculator.swift` pertenece a la capa de dominio, sublayer services.

---

## Modelos principales

### `Player`
```swift
struct Player: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var handicap: Double   // Handicap index del jugador. Rango válido: 0–54
}
```

### `HoleDefinition`
```swift
struct HoleDefinition: Identifiable, Hashable, Codable {
    let id: UUID
    let actualHoleNumber: Int  // 1–18, número real del hoyo en el campo
    let displayOrder: Int      // 1–N, orden en que se juega la ronda
    let par: Int
    var strokeIndex: Int       // 1–N, índice de dificultad del hoyo (SI)
    let yardage: Int
}
```

`strokeIndex` es crítico para Cara 'e Perro. Debe ser una permutación válida de `1...N` donde N = número de hoyos.

### `Tee`
```swift
struct Tee: Identifiable, Hashable, Codable {
    let name: String
    let courseRating: Double   // Rating del campo desde este tee
    let slope: Int             // Slope del campo desde este tee
    let pars: [Int]            // Par de cada hoyo, índice 0–17
    let yardages: [Int]
    var strokeIndices: [Int]   // SI de cada hoyo, índice 0–17
}
```

### `RoundDefinition`
Configuración inmutable de la ronda (pre-juego):
- `players`, `course`, `tee`, `holes`
- `selectedGames: Set<GameType>` — múltiples juegos pueden correr en paralelo
- `handicapMode: HandicapMode` — `.absolute` o `.relativeToLowest`
- `isNineHole`, `isBackNine`

Valida que: haya ≥2 jugadores, hoyos = 9 o 18, y que el stroke index sea válido si se seleccionó Cara 'e Perro.

### `RoundState`
Estado mutable durante el juego:
- `grossScores: [UUID: [UUID: Int]]` → `playerID → holeID → strokes`
- `putts: [UUID: [UUID: Int]]`
- `kpWinners: [UUID: UUID?]` → `holeID → playerID?`

### `CalculationInput`
Estructura normalizada que reciben todas las calculadoras. Se construye desde `RoundDefinition` + `RoundState`.

```swift
struct CalculationInput {
    let players: [Player]
    let holes: [HoleDefinition]
    let handicapMode: HandicapMode
    let scores: [UUID: [UUID: Int]]   // playerID → holeID → grossStrokes
    let kpWinners: [UUID: UUID?]
}
```

---

## Juegos disponibles (`GameType`)

| Enum case      | Nombre display    | Requiere SI válido |
|---------------|-------------------|--------------------|
| `.stableford` | Stableford        | No                 |
| `.skins`      | Skins             | No                 |
| `.nassau`     | Nassau            | No                 |
| `.kp`         | KP                | No                 |
| `.caraEPerro` | Cara 'e Perro     | **Sí**             |

---

## Handicap

### `HandicapMode`
- `.absolute` — cada jugador recibe su handicap de campo completo
- `.relativeToLowest` — cada jugador recibe la diferencia respecto al de menor handicap (el mejor queda en 0)

### `HandicapCalculator`
Fórmula de course handicap estándar:
```
courseHandicap = round(handicapIndex × slope / 113 + (courseRating - par))
```

Distribución de strokes por hoyo:
```
fullRounds = playingHandicap / totalHoles
remainder  = playingHandicap % totalHoles
strokes en hoyo X = fullRounds + (1 si strokeIndex(X) <= remainder, si no 0)
```

---

## Calculadoras

### Stableford (`DomainServicesStablefordCalculator`)
Puntos por hoyo según diferencia con el par (neto o bruto):

| Score vs par | Puntos |
|-------------|--------|
| Eagle o mejor (≤ -2) | 4 |
| Birdie (-1) | 3 |
| Par (0) | 2 |
| Bogey (+1) | 1 |
| Doble bogey o peor (≥ +2) | 0 |

### Skins (`DomainServicesSkinsCalculator`)
- Gana el skin quien tenga el mejor score (neto o bruto) en el hoyo
- Si hay empate, el skin se acumula (carry) al siguiente hoyo si `withCarry = true`
- El valor inicial es 1 skin por hoyo

### Nassau (`DomainServicesNassauCalculator`)
- Solo para rondas de 18 hoyos
- Tres apuestas independientes: front nine, back nine, total
- Gana quien tenga menor score neto en cada segmento
- 1 punto por segmento ganado (máximo 3 puntos)

### KP — Closest to Pin (`DomainServicesKPCalculator`)
- Solo aplica en hoyos par-3
- El ganador es registrado manualmente durante el juego (`kpWinners` en `RoundState`)
- Resultado: número de KPs ganados por jugador

---

## Cara 'e Perro — Algoritmo detallado

> **Esta calculadora es la más sensible del proyecto. Cualquier cambio en la lógica de handicap o de asignación del stroke puede producir resultados incorrectos silenciosamente. Leer esta sección completa antes de tocar el código.**

Archivo: `DomainServicesCaraEPerroCalculator.swift`

### Concepto del juego
Cada jugador se enfrenta contra cada otro jugador en cada hoyo (comparación por parejas). No hay score global: los puntos emergen de los duelos uno a uno. La suma de puntos de todos los jugadores en cualquier hoyo siempre es **cero** — es un juego de suma cero.

### Paso 1 — Rounding del handicap
El handicap de cada jugador (`Double`) se redondea al entero más cercano **antes** de cualquier cálculo.

```swift
handicapIndices[player.id] = Int(round(player.handicap))
```

Esto se hace una sola vez al inicio. No se usa el handicap flotante en ningún cálculo posterior.

### Paso 2 — Delta entre cada par de jugadores
Para cada par único (i, j), se calcula el delta una sola vez:

```swift
delta = abs(hcp_i - hcp_j)
```

Se almacena con clave `"UUID_i-UUID_j"` y también `"UUID_j-UUID_i"` (ambos sentidos) para lookup simétrico rápido.

### Paso 3 — Comparación en cada hoyo
Para cada hoyo, para cada par (i, j):

**3a. Determinar si aplica stroke en este hoyo:**
```
si delta >= strokeIndex del hoyo:
    el jugador con MENOR handicap recibe +1 stroke (su score bruto aumenta en 1)
si delta < strokeIndex del hoyo:
    no hay ajuste
```

> **ATENCIÓN — Contraintuitivo:** el stroke extra lo recibe el jugador **mejor** (menor handicap), no el peor. Esto es para "nivelar" la ventaja natural del mejor jugador en el contexto del duelo.

**3b. Comparar scores ajustados:**
```
si adjustedScore_i < adjustedScore_j:  jugador i gana → i +1, j -1
si adjustedScore_i > adjustedScore_j:  jugador j gana → j +1, i -1
si adjustedScore_i == adjustedScore_j: empate → ambos 0
```

### Paso 4 — Acumulación
Los puntos de cada hoyo se suman al acumulado. El resultado final (`playerCumulativePoints`) es la suma de todos los hoyos.

---

### Ejemplo canónico (del test suite)

**Setup:** 4 jugadores en hoyo 1, par 4, SI = 5

| Jugador | HCP (raw) | HCP (rounded) |
|---------|-----------|---------------|
| A       | 8.0       | 8             |
| B       | 4.0       | 4             |
| C       | 25.0      | 25            |
| D       | 13.0      | 13            |

**Scores brutos:** A=4, B=6, C=5, D=5

**Deltas entre pares:**

| Par  | Delta |
|------|-------|
| A–B  | 4     |
| A–C  | 17    |
| A–D  | 5     |
| B–C  | 21    |
| B–D  | 9     |
| C–D  | 12    |

**Condición de stroke:** `delta >= SI (5)`

| Par  | Delta | ¿Stroke? | Recibe stroke | Score A | Score B | Score C | Score D | Resultado      |
|------|-------|----------|---------------|---------|---------|---------|---------|----------------|
| A–B  | 4     | No (4<5) | —             | 4       | 6       | —       | —       | A gana: A+1, B-1 |
| A–C  | 17    | Sí       | A (hcp 8 < 25)| 5       | —       | 5       | —       | Empate: 0, 0   |
| A–D  | 5     | Sí       | A (hcp 8 < 13)| 5       | —       | —       | 5       | Empate: 0, 0   |
| B–C  | 21    | Sí       | B (hcp 4 < 25)| —       | 7       | 5       | —       | C gana: B-1, C+1 |
| B–D  | 9     | Sí       | B (hcp 4 < 13)| —       | 7       | —       | 5       | D gana: B-1, D+1 |
| C–D  | 12    | Sí       | D (hcp 13 < 25)| —      | —       | 5       | 6       | C gana: C+1, D-1 |

**Resultado final hoyo 1:** A=+1, B=-3, C=+2, D=0 — suma = 0 ✓

---

### Invariantes que siempre deben cumplirse

1. **Suma cero:** la suma de `playerHolePoints.values` en cualquier hoyo siempre debe ser 0.
2. **Stroke index válido:** el stroke index de cada hoyo debe ser una permutación de `1...N`. `RoundDefinition.isStrokeIndexValid()` valida esto antes de empezar.
3. **El stroke va al de MENOR handicap** — no al de mayor. El código lo verifica con `if hcp1 < hcp2 { adjustedStrokes1 += 1 }`.
4. **Condición inclusiva:** `delta >= strokeIndex`, no `>`. Con delta igual al SI sí aplica stroke.
5. **Handicaps redondeados:** siempre usar `handicapIndices` (Int), nunca `player.handicap` (Double) dentro del cálculo.

---

### Tests de referencia

Archivo: `FairwayLabUITests/TestsCaraEPerroCalculatorTests.swift`

| Test | Escenario |
|------|-----------|
| `testCaraEPerroSpecExample` | 4 jugadores, 1 hoyo, caso canónico con resultado A=+1, B=-3, C=+2, D=0 |
| `testCaraEPerroTwoPlayersWithStroke` | 2 jugadores, delta>=SI, el mejor recibe stroke y pierde |
| `testCaraEPerroTwoPlayersNoStroke` | 2 jugadores, delta<SI, sin stroke, el mejor gana limpio |
| `testCaraEPerroCumulativeScoring` | 2 jugadores, 2 hoyos, ambos empatan en los dos hoyos |

---

## Flujo de la app

```
HomeView
  └── SetupWizardView (isSetupPresented)
        ├── RoundDetailsSetupView   — campo, tee, 9/18 hoyos
        ├── PlayersSetupView        — jugadores + handicaps
        ├── GamesSetupView          — selección de juegos
        ├── StrokeIndexEditorView   — edición de SI (obligatorio para Cara 'e Perro)
        └── ReviewSetupView         — confirmar → AppState.finalizeSetup()
  └── PlayRoundPlayView (isPlayPresented)
        └── ResultsHubView (isResultsPresented)
              ├── ResultsCaraEPerroDetailView
              ├── ResultsNassauDetailView
              ├── ResultsKPDetailView
              └── ...
```

### `AppState` (estado global)
`@MainActor`, `ObservableObject`. Propiedades clave:
- `roundDefinition: RoundDefinition?` — configuración activa
- `roundState: RoundState?` — scores en vivo
- `lastValidRoundDefinition: RoundDefinition?` — permite volver a la última config válida

Transiciones: `startNewRound()` → `finalizeSetup()` → `showResults()` / `backToPlay()` → `endRound()`

---

## Datos del campo

`DomainUtilitiesMockCourseData` provee campos de prueba hardcodeados.

`ServicesGolfCourseAPIClient` es el cliente HTTP para buscar campos reales (integración con API externa).

---

## Notas importantes para futuros cambios

- **No tocar el orden de `players` en `CalculationInput`** sin revisar Cara 'e Perro: el algoritmo itera sobre `input.players` directamente y el orden afecta qué par se evalúa primero (aunque no el resultado final por ser pairwise).
- **Stroke Index en rondas de 9 hoyos:** los SI deben ser `1..9`, no `1..18`. `isStrokeIndexValid()` verifica la permutación correcta según `holes.count`.
- **Nassau solo corre en 18 hoyos.** La calculadora retorna `nil` si hay menos hoyos.
- **KP solo cuenta hoyos par-3.** Se filtra con `isPar3` antes de calcular.
