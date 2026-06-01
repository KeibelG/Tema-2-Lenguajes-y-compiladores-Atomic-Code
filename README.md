# Tema 2 - Lenguajes de programación
### Benchmarking: Conjetura de Collatz

**Asignatura:** Lenguajes y compiladores  
**Equipo:** Atomic Code - *Segmentando el código, construyendo la lógica*

| Integrante | C.I |
|---|---|
| Victor Vargas | 30.697.219 |
| Keibel Guilarte | 28.726.605 |
| Oriana Márquez | 31.354.299 |
| Jeanny Monagas | 30.857.471 |

---

## Descripción del algoritmo

La **Conjetura de Collatz** establece que, para cualquier entero positivo `n`, si se aplica repetidamente la siguiente función:

```
f(n) = n / 2       si n es par
f(n) = 3n + 1      si n es impar
```

la secuencia siempre llegará al valor 1.

Este programa verifica la conjetura para todos los enteros en el rango `[2, N)`, donde `N` es ingresado por el usuario. Registra cuál número requiere la mayor cantidad de pasos y mide el tiempo de ejecución total para comparar el rendimiento entre lenguajes.

---

## Estructura del repositorio

```
/
├── python/
│   ├── collatz.py
│   └── ejecutar.bat
├── javascript/
│   ├── collatz.js
│   └── ejecutar.bat
├── rust/
│   ├── src/
│   │   └── main.rs
│   ├── Cargo.toml
│   └── ejecutar.bat
├── zig/
│   ├── collatz.zig
│   └── ejecutar.bat
└── README.md
```

---

## Requisitos

| Lenguaje | Herramienta | Descarga |
|---|---|---|
| Python | Python 3.x | https://python.org |
| JavaScript | Node.js | https://nodejs.org |
| Rust | rustup (toolchain GNU) | https://rustup.rs |
| Zig | Zig 0.16.0 | https://ziglang.org/download |

> **Rust:** durante la instalación de rustup elegir el toolchain `x86_64-pc-windows-gnu`.

> **Zig:** descomprimir el zip en una carpeta (ej. `C:\zig\`) y agregarla al PATH del sistema.

---

## Cómo ejecutar

### Forma rápida
Cada carpeta tiene un archivo `ejecutar.bat`. Abrirlo desde una terminal dentro de la carpeta correspondiente:

```
.\ejecutar.bat
```

### Forma manual

**Python**
```bash
cd python
python collatz.py
```

**JavaScript**
```bash
cd javascript
node collatz.js
```

**Rust** - compilar y ejecutar:
```bash
cd rust
cargo run --release
```
O si ya está compilado:
```bash
.\target\release\collatz.exe
```

**Zig**
```bash
cd zig
zig run collatz.zig
```
O compilar y guardar el ejecutable:
```bash
zig build-exe collatz.zig
.\collatz.exe
```

---

## Reproducir el benchmarking

1. Abrir una terminal en cada carpeta de lenguaje.
2. Ejecutar el programa con el mismo valor de `N` en los 4 lenguajes.
3. El programa pedirá el valor de `N` al iniciar (debe ser mayor a 50).
4. Cada ejecución guarda su resultado en un archivo `resultados.txt` en la raíz del proyecto.
5. Cuando los 4 lenguajes hayan corrido, el programa muestra automáticamente la comparación y borra el archivo para permitir una nueva ronda.

> Para un benchmarking significativo se recomienda usar `N = 1.000.000` o mayor.

