// =============================================================================
//                          Conjetura de Collatz
// -----------------------------------------------------------------------------
// Descripción:
//   La conjetura de Collatz postula que, para cualquier entero positivo n,
//   si se aplica repetidamente la función:
//       f(n) = n / 2        si n es par
//       f(n) = 3 * n + 1   si n es impar
//   la secuencia siempre llegará eventualmente al valor 1.
//   Este programa verifica la conjetura para todos los enteros en [2, N),
//   registra cuál número requiere la mayor cantidad de pasos y mide el
//   tiempo de ejecución total como métrica de benchmarking.
//
// Lenguaje:   JavaScript (Node.js)
// Asignatura: Lenguajes y compiladores
// Equipo:     Atomic Code
//             Segmentando el código, construyendo la lógica
//
// Integrantes:
//   - Victor Vargas    C.I: 30.697.219
//   - Keibel Guilarte  C.I: 28.726.605
//   - Oriana Márquez   C.I: 31.354.299
//   - Jeanny Monagas   C.I: 30.857.471
// =============================================================================

"use strict";

const readline = require("readline");
const fs       = require("fs");
const path     = require("path");

const LENGUAJES = ["Python", "JavaScript", "Zig", "Rust"];

function collatzSteps(n) {
    let steps = 0;
    while (n !== 1) {
        n = (n % 2 === 0) ? (n / 2) : (3 * n + 1);
        steps++;
    }
    return steps;
}

function rutaResultados() {
    return path.join(__dirname, "..", "resultados.txt");
}

function registrarResultado(tiempoMs) {
    const ruta       = rutaResultados();
    const resultados = {};

    if (fs.existsSync(ruta)) {
        const contenido = fs.readFileSync(ruta, "utf-8");
        for (const linea of contenido.split("\n")) {
            const idx = linea.indexOf(":");
            if (idx !== -1) {
                const lang = linea.slice(0, idx).trim();
                const val  = parseFloat(linea.slice(idx + 1).trim());
                if (lang && !isNaN(val)) resultados[lang] = val;
            }
        }
    }

    resultados["JavaScript"] = tiempoMs;

    const lineas = LENGUAJES
        .filter(l => l in resultados)
        .map(l => `${l}:${resultados[l].toFixed(2)}`);
    fs.writeFileSync(ruta, lineas.join("\n") + "\n", "utf-8");

    if (LENGUAJES.every(l => l in resultados)) {
        const ordenados = Object.entries(resultados).sort((a, b) => a[1] - b[1]);
        console.log("\n" + "=".repeat(60));
        console.log("  COMPARACIÓN DE LOS 4 LENGUAJES");
        console.log("=".repeat(60));
        for (const [lang, t] of ordenados) {
            console.log(`  ${lang.padEnd(14)}: ${t.toFixed(2).padStart(10)} ms`);
        }
        const [masRapido, tMin] = ordenados[0];
        console.log(`\n  El lenguaje más rápido fue: ${masRapido} (${tMin.toFixed(2)} ms)`);
        console.log("=".repeat(60));
        fs.unlinkSync(ruta);
    }
}

function pregunta(rl, texto) {
    return new Promise(resolve => rl.question(texto, resolve));
}

async function main() {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

    const entrada = await pregunta(rl, "Ingresa el valor de N (debe ser mayor a 50): ");
    const N       = parseInt(entrada, 10);

    if (isNaN(N) || N <= 50) {
        console.log(isNaN(N) ? "Valor no válido." : "N debe ser mayor a 50.");
        await pregunta(rl, "\nPresiona Enter para salir...");
        rl.close();
        return;
    }

    console.log(`\nConjetura de Collatz - verificando todos los enteros en [2, ${N.toLocaleString()})`);
    console.log("-".repeat(60));

    const inicio = performance.now();

    let maxPasos = 0;
    let numMax   = 0;

    for (let i = 2; i < N; i++) {
        const pasos = collatzSteps(i);
        if (pasos > maxPasos) {
            maxPasos = pasos;
            numMax   = i;
        }
    }

    const tiempoMs = performance.now() - inicio;

    console.log(`Rango verificado      : [2, ${N.toLocaleString()})`);
    console.log(`Número con más pasos  : ${numMax.toLocaleString()}  (${maxPasos} pasos)`);
    console.log(`Tiempo de ejecución   : ${tiempoMs.toFixed(2)} ms`);

    registrarResultado(tiempoMs);

    await pregunta(rl, "\nPresiona Enter para salir...");
    rl.close();
}

main().catch(err => { console.error(err); process.exit(1); });
