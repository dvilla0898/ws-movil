# ws-movil · Aplicación móvil (tutorial)

Aplicación móvil construida con **Flutter** como proyecto de aprendizaje.

> Estado: repositorio recién creado. Ya tiene la CI y las medidas de seguridad;
> el proyecto Flutter se crea en el primer Pull Request (ver más abajo).

---

## Índice

1. [Requisitos](#1-requisitos)
2. [Primer arranque: crear el proyecto Flutter](#2-primer-arranque-crear-el-proyecto-flutter)
3. [Comandos útiles](#3-comandos-útiles)
4. [Flujo de trabajo con Pull Requests](#4-flujo-de-trabajo-con-pull-requests)
5. [Integración continua (CI)](#5-integración-continua-ci)
6. [Seguridad del repositorio](#6-seguridad-del-repositorio)

---

## 1. Requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) (canal **stable**). Comprueba la instalación con `flutter doctor`.
- Android Studio (SDK de Android y un emulador) o un móvil físico con la depuración USB activada.
- Para iOS: un Mac con Xcode.

## 2. Primer arranque: crear el proyecto Flutter

`master` está protegida, así que el proyecto se crea en una rama y entra por PR:

```bash
git clone https://github.com/dvilla0898/ws-movil.git
cd ws-movil
git checkout -b feature/crear-proyecto
flutter create --org com.dvilla0898 --project-name ws_movil .
flutter test                                   # el test de ejemplo debe pasar
git add . && git commit -m "feat: crear proyecto Flutter"
git push -u origin feature/crear-proyecto
# abre el PR en GitHub, espera la CI en verde y haz "Squash and merge"
```

> El `.` final hace que `flutter create` use la carpeta actual. No sobrescribe este README.

## 3. Comandos útiles

| Comando | Para qué sirve |
| --- | --- |
| `flutter run` | Ejecuta la app en el emulador o el móvil conectado |
| `flutter pub get` | Instala las dependencias de `pubspec.yaml` |
| `dart format .` | Formatea el código con el estilo oficial |
| `flutter analyze` | Busca errores y malas prácticas |
| `flutter test` | Ejecuta los tests |
| `flutter build apk --debug` | Compila un APK de prueba |

## 4. Flujo de trabajo con Pull Requests

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

## 5. Integración continua (CI)

El archivo `.github/workflows/ci.yml` se ejecuta en cada PR y en cada push a `master`:

`formato` → `análisis estático` → `tests` → `build del APK`

Si algo falla, el PR queda en rojo y no se puede fusionar. Mientras no exista `pubspec.yaml`
(antes del primer arranque), la CI pasa en verde sin ejecutar los pasos de Flutter.

## 6. Seguridad del repositorio

Las mismas medidas que `ws-notifier`. Se configuran en GitHub → **Settings**:

- **Rules → Rulesets → `proteger-master`** (rama por defecto):
  - no se puede borrar `master` ni hacer *force push*;
  - historial lineal;
  - PR obligatorio, solo con *squash*, con las conversaciones resueltas;
  - el check **"Análisis, tests y build"** debe estar en verde y la rama al día.
- **General → Pull Requests**: solo *squash merging* y borrado automático de ramas.
- **Advanced Security**: *secret scanning* con *push protection* (bloquea subir contraseñas o claves),
  *Dependabot alerts* y *security updates*, y *CodeQL* (cuando haya código).

> Nunca subas claves de firma (`*.jks`, `key.properties`) ni archivos `.env`: ya están en `.gitignore`.
