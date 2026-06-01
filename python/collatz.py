# =============================================================================
#                          Conjetura de Collatz
# -----------------------------------------------------------------------------
# Descripción:
#   La conjetura de Collatz postula que, para cualquier entero positivo n,
#   si se aplica repetidamente la función:
#       f(n) = n / 2        si n es par
#       f(n) = 3 * n + 1   si n es impar
#   la secuencia siempre llegará eventualmente al valor 1.
#   Este programa verifica la conjetura para todos los enteros en [2, N),
#   registra cuál número requiere la mayor cantidad de pasos y mide el
#   tiempo de ejecución total como métrica de benchmarking.
#
# Lenguaje:   Python 3
# Asignatura: Lenguajes y compiladores
# Equipo:     Atomic Code
#             Segmentando el código, construyendo la lógica
#
# Integrantes:
#   - Victor Vargas    C.I: 30.697.219
#   - Keibel Guilarte  C.I: 28.726.605
#   - Oriana Márquez   C.I: 31.354.299
#   - Jeanny Monagas   C.I: 30.857.471
# =============================================================================

import time
import os

LENGUAJES = ["Python", "JavaScript", "Zig", "Rust"]


def collatz_steps(n: int) -> int:
    steps = 0
    while n != 1:
        n = n // 2 if n % 2 == 0 else 3 * n + 1
        steps += 1
    return steps


def ruta_resultados() -> str:
    directorio = os.path.dirname(os.path.abspath(__file__))
    return os.path.join(directorio, "..", "resultados.txt")


def registrar_resultado(tiempo_ms: float):
    ruta = ruta_resultados()
    resultados: dict[str, float] = {}

    if os.path.exists(ruta):
        with open(ruta, "r", encoding="utf-8") as f:
            for linea in f:
                linea = linea.strip()
                if ":" in linea:
                    lang, t = linea.split(":", 1)
                    try:
                        resultados[lang.strip()] = float(t.strip())
                    except ValueError:
                        pass

    resultados["Python"] = tiempo_ms

    with open(ruta, "w", encoding="utf-8") as f:
        for lang in LENGUAJES:
            if lang in resultados:
                f.write(f"{lang}:{resultados[lang]:.2f}\n")

    if all(lang in resultados for lang in LENGUAJES):
        ordenados = sorted(resultados.items(), key=lambda x: x[1])
        print()
        print("=" * 60)
        print("  COMPARACIÓN DE LOS 4 LENGUAJES")
        print("=" * 60)
        for lang, t in ordenados:
            print(f"  {lang:<14}: {t:>10.2f} ms")
        mas_rapido, t_min = ordenados[0]
        print(f"\n  El lenguaje más rápido fue: {mas_rapido} ({t_min:.2f} ms)")
        print("=" * 60)
        os.remove(ruta)


def main():
    try:
        N = int(input("Ingresa el valor de N (debe ser mayor a 50): "))
    except ValueError:
        print("Valor no válido. Debe ser un número entero.")
        input("\nPresiona Enter para salir...")
        return

    if N <= 50:
        print("N debe ser mayor a 50.")
        input("\nPresiona Enter para salir...")
        return

    print(f"\nConjetura de Collatz - verificando todos los enteros en [2, {N:,})")
    print("-" * 60)

    inicio = time.perf_counter()

    max_pasos = 0
    num_max   = 0

    for i in range(2, N):
        pasos = collatz_steps(i)
        if pasos > max_pasos:
            max_pasos = pasos
            num_max   = i

    fin       = time.perf_counter()
    tiempo_ms = (fin - inicio) * 1_000

    print(f"Rango verificado      : [2, {N:,})")
    print(f"Número con más pasos  : {num_max:,}  ({max_pasos} pasos)")
    print(f"Tiempo de ejecución   : {tiempo_ms:.2f} ms")

    registrar_resultado(tiempo_ms)

    input("\nPresiona Enter para salir...")


if __name__ == "__main__":
    main()
