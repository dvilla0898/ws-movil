# ws-movil · Lista de tareas (tutorial)

Aplicación móvil hecha con **Flutter** como proyecto de aprendizaje. Es una lista de tareas
(*to-do list*) con inicio de sesión, guardada en **SQLite**, con estado gestionado por
**Cubit** (Bloc) y organizada con **arquitectura hexagonal / Clean Architecture** y
**un caso de uso por cada acción**.

> Credenciales de prueba: **`admin` / `admin123`** (se crea solo la primera vez que abres la app).

---

## Índice

1. [Qué hace la app](#1-qué-hace-la-app)
2. [Tecnologías y por qué](#2-tecnologías-y-por-qué)
3. [Ejecutar la app](#3-ejecutar-la-app)
4. [Arquitectura](#4-arquitectura)
5. [Casos de uso](#5-casos-de-uso)
6. [Cómo funciona por dentro](#6-cómo-funciona-por-dentro)
7. [Tests](#7-tests)
8. [Flujo de trabajo con Pull Requests](#8-flujo-de-trabajo-con-pull-requests)
9. [Integración continua (CI)](#9-integración-continua-ci)
10. [Seguridad del repositorio](#10-seguridad-del-repositorio)
11. [Ejercicios y próximos pasos](#11-ejercicios-y-próximos-pasos)

---

## 1. Qué hace la app

| Pantalla | Qué permite |
| --- | --- |
| **Login** | Entrar con usuario y contraseña. La sesión se recuerda 7 días. |
| **Listado** | Ver las tareas, filtrarlas (todas / pendientes / hechas), marcarlas como hechas y cerrar sesión. |
| **Registrar** | Crear una tarea: título, descripción, prioridad (baja/media/alta) y fecha límite. |
| **Actualizar** | Editar una tarea (se abre al tocarla en el listado). |
| **Modal de eliminar** | Confirmar antes de borrar una tarea. |

Las tareas vencidas (pendientes con la fecha límite pasada) se marcan en rojo.
La interfaz está en **español e inglés** (botón 🌐 en la barra superior).

## 2. Tecnologías y por qué

| Paquete | Para qué |
| --- | --- |
| `flutter_bloc` | Gestión de estado con **Cubit**: cada pantalla tiene un Cubit que llama a los casos de uso y emite estados. |
| `sqflite` + `path` | Base de datos **SQLite** local en el móvil. |
| `crypto` | Hash **SHA-256** con sal para no guardar la contraseña en texto plano. |
| `equatable` | Comparar estados y entidades por valor. |
| `flutter_localizations` | Traducciones de los widgets de Material (calendario, etc.). |
| `sqflite_common_ffi` *(solo tests)* | Usar SQLite en el ordenador para probar los repositorios. |

## 3. Ejecutar la app

Necesitas [Flutter](https://docs.flutter.dev/get-started/install) (canal **stable**) y un emulador
Android, un simulador iOS (en Mac) o un móvil conectado. Compruébalo con `flutter doctor`.

```bash
flutter pub get      # instala las dependencias
flutter run          # abre la app
```

| Comando | Para qué sirve |
| --- | --- |
| `dart format .` | Formatea el código con el estilo oficial |
| `flutter analyze` | Busca errores y malas prácticas |
| `flutter test` | Ejecuta los tests |
| `flutter build apk --debug` | Compila un APK de prueba |

## 4. Arquitectura

### La idea: el dominio en el centro

```
        ┌──────────────── presentation (Flutter, Cubit) ────────────────┐
        │   pantallas y Cubits: solo llaman a casos de uso              │
        │   ┌──────────── application (casos de uso) ─────────────┐     │
        │   │   orquestan: validan, consultan puertos, deciden    │     │
        │   │   ┌──────────── domain ────────────┐                │     │
        │   │   │ entidades, value objects,      │                │     │
        │   │   │ errores y PUERTOS (interfaces) │                │     │
        │   │   └────────────────────────────────┘                │     │
        │   └─────────────────────────────────────────────────────┘     │
        └───────────────────────────────────────────────────────────────┘
              ▲ implementan los puertos
        infrastructure (SQLite, SHA-256): los ADAPTADORES
```

**Regla de dependencias:** las flechas siempre apuntan hacia dentro. El dominio no importa
nada de Flutter ni de SQLite; los casos de uso solo conocen **puertos** (interfaces como
`TaskRepository`). La infraestructura implementa esos puertos (`SqliteTaskRepository`).
Por eso los tests pueden cambiar SQLite por una lista en memoria sin tocar los casos de uso.

### Estructura de carpetas

```
lib/
├── main.dart                     # abre SQLite, monta dependencias y arranca
├── app/
│   ├── app.dart                  # MaterialApp + AuthGate (login o listado)
│   ├── dependencies.dart         # raíz de composición: conecta adaptadores y casos de uso
│   └── l10n/                     # textos es/en, LocaleCubit y botón de idioma
├── core/                         # piezas compartidas por todos los módulos
│   ├── domain/                   # Result (Ok/Err), Failure, Clock
│   ├── application/guard.dart    # convierte excepciones en Err
│   └── infrastructure/           # AppDatabase (esquema de SQLite)
└── features/
    ├── auth/                     # módulo de autenticación
    │   ├── domain/               # User, Session, Username, Password, puertos
    │   ├── application/use_cases/
    │   ├── infrastructure/       # SQLite (usuarios y sesión) y SHA-256
    │   └── presentation/         # AuthCubit, LoginCubit, LoginPage
    └── tasks/                    # módulo de tareas
        ├── domain/               # Task, TaskDetails, TaskPriority, TaskTitle..., puerto
        ├── application/          # TaskInput y casos de uso
        ├── infrastructure/       # SqliteTaskRepository
        └── presentation/         # Cubits, páginas y widgets (incluido el modal)
```

Cada módulo (*feature*) tiene las mismas cuatro capas. Para añadir uno nuevo (por ejemplo,
categorías), copia esa estructura.

## 5. Casos de uso

Cada acción del usuario es **una clase** con un método `call`, que devuelve un `Result`:

| Módulo | Caso de uso | Qué hace |
| --- | --- | --- |
| auth | `SeedDefaultUserUseCase` | Crea `admin` / `admin123` si no hay usuarios. |
| auth | `LoginUseCase` | Valida, comprueba la contraseña contra el hash y guarda la sesión. |
| auth | `GetCurrentSessionUseCase` | Recupera la sesión al abrir la app (o la borra si caducó). |
| auth | `LogoutUseCase` | Borra la sesión. |
| tasks | `ListTasksUseCase` | Lista con filtro y orden (pendientes primero, por fecha y prioridad). |
| tasks | `GetTaskUseCase` | Carga una tarea para editarla. |
| tasks | `CreateTaskUseCase` | Valida y registra una tarea. |
| tasks | `UpdateTaskUseCase` | Valida y actualiza una tarea. |
| tasks | `ToggleTaskStatusUseCase` | Marca como hecha o pendiente. |
| tasks | `DeleteTaskUseCase` | Elimina una tarea. |

## 6. Cómo funciona por dentro

### `Result` en lugar de excepciones

Los errores esperados (contraseña incorrecta, título vacío...) no se lanzan: se devuelven.

```dart
switch (await login(username: 'admin', password: 'admin123')) {
  case Ok(:final value):   // value es la Session
  case Err(:final failure): // failure es InvalidCredentialsFailure, ValidationFailure...
}
```

`Result` es una clase `sealed`, así que Dart obliga a tratar los dos casos.

### Value objects: validar una sola vez

`Username`, `Password`, `TaskTitle` y `TaskDescription` solo se crean con `create(...)`, que
devuelve un `Err(ValidationFailure(...))` si el valor no cumple las reglas. Las reglas viven
en el dominio, no en la pantalla: la interfaz solo muestra el error bajo el campo.

### Un viaje completo: registrar una tarea

1. `CreateTaskPage` recoge los campos y llama a `TaskFormCubit.submit(TaskInput)`.
2. El Cubit llama a `CreateTaskUseCase`.
3. El caso de uso valida con `TaskDetails.create(...)` y, si todo va bien, llama al puerto
   `TaskRepository.insert(...)`.
4. `SqliteTaskRepository` (el adaptador) hace el `INSERT` en SQLite.
5. El Cubit emite `saved`, la pantalla se cierra y el listado recarga y muestra «Tarea creada».

### Login y sesión

- La contraseña nunca se guarda: se guarda `SHA-256(sal + contraseña)` y la sal.
- Al iniciar sesión se guarda una fila en la tabla `sessions` (solo admite una).
- Al abrir la app, `AuthCubit.checkSession()` decide si mostrar el login o el listado.

> ⚠️ Es una simulación educativa: en una app real el login lo valida un **servidor** y se
> usa un algoritmo lento pensado para contraseñas (bcrypt, Argon2).

### Base de datos

Tres tablas, creadas en `AppDatabase` la primera vez: `users`, `sessions` y `tasks`. SQLite
no tiene fechas ni booleanos: las fechas se guardan como texto ISO-8601 y `is_done` como 0/1.
Para cambiar el esquema más adelante, sube `AppDatabase.version` y añade un `onUpgrade`.

### Idiomas

`AppStrings` es una clase abstracta con un getter por texto; `EsStrings` y `EnStrings` la
implementan. Si añades un texto y no lo traduces, **el código no compila**. En un widget:
`AppStrings.of(context).loginTitle`.

## 7. Tests

```
test/
├── helpers/fakes.dart            # repositorios en memoria y reloj fijo (adaptadores falsos)
└── features/
    ├── auth/   domain · application · infrastructure · presentation
    └── tasks/  domain · application · infrastructure · presentation
```

| Tipo | Qué prueba |
| --- | --- |
| Dominio | Reglas de los value objects y de `Task` (por ejemplo, cuándo vence). |
| Casos de uso | La lógica con repositorios **en memoria** y un **reloj fijo** (`FixedClock`). |
| Infraestructura | Los repositorios de SQLite con una base de datos en memoria. |
| Widgets | Recorridos completos: login, registrar, actualizar, marcar y eliminar con el modal. |

## 8. Flujo de trabajo con Pull Requests

La rama principal es `master`. **No se hace push directo a `master`**: cada cambio entra por un PR.

```bash
git checkout master && git pull                              # 1. parte de la última versión
git checkout -b feature/nombre-del-cambio                    # 2. crea una rama
# ... cambios ...
dart format . && flutter analyze && flutter test             # 3. verifica en local
git add . && git commit -m "feat: descripción"               # 4. commit
git push -u origin feature/nombre-del-cambio                 # 5. sube la rama
# 6. abre el PR en GitHub -> se ejecuta la CI
# 7. si todo está en verde: "Squash and merge" (la rama se borra sola)
```

## 9. Integración continua (CI)

El archivo `.github/workflows/ci.yml` se ejecuta en cada PR y en cada push a `master`:

`formato` → `análisis estático` → `tests` → `build del APK`

Si algo falla, el PR queda en rojo y no se puede fusionar.

## 10. Seguridad del repositorio

Las mismas medidas que `ws-notifier`, configuradas en GitHub → **Settings**:

- **Rules → Rulesets → `proteger-master`** (rama por defecto):
  - no se puede borrar `master` ni hacer *force push*;
  - historial lineal;
  - PR obligatorio, solo con *squash*, con las conversaciones resueltas;
  - el check **"Análisis, tests y build"** debe estar en verde y la rama al día.
- **General → Pull Requests**: solo *squash merging* y borrado automático de ramas.
- **Advanced Security**: *secret scanning* con *push protection*, *Dependabot alerts* y
  *security updates*, y *CodeQL* (analiza los workflows; Dart no está soportado).

> Nunca subas claves de firma (`*.jks`, `key.properties`) ni archivos `.env`: ya están en `.gitignore`.

## 11. Ejercicios y próximos pasos

- **Recordar el idioma**: guarda la elección de `LocaleCubit` en una tabla `settings` de SQLite.
- **Buscar tareas**: crea `SearchTasksUseCase` (filtra por texto en el título) y añade un buscador.
- **Tareas por usuario**: añade `user_id` a `tasks` (migración con `onUpgrade`) y filtra por la sesión.
- **Categorías**: un módulo nuevo `features/categories/` con sus cuatro capas.
- **Probar un Cubit**: escribe tests de `TasksCubit` con los repositorios en memoria.
