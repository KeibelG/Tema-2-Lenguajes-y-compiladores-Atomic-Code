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
// Lenguaje:   Rust
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

use std::collections::HashMap;
use std::fs;
use std::io::{self, BufRead, Write};
use std::path::PathBuf;
use std::time::Instant;

const LENGUAJES: &[&str] = &["Python", "JavaScript", "Zig", "Rust"];

fn collatz_steps(mut n: u64) -> u64 {
    let mut steps: u64 = 0;
    while n != 1 {
        n = if n % 2 == 0 { n / 2 } else { 3 * n + 1 };
        steps += 1;
    }
    steps
}

fn ruta_resultados() -> PathBuf {
    // El ejecutable está en rust/target/release/collatz.exe
    // Subimos 4 niveles para llegar a la raíz del proyecto
    std::env::current_exe()
        .unwrap_or_default()
        .ancestors()
        .nth(4)
        .unwrap_or(std::path::Path::new("."))
        .join("resultados.txt")
}

fn registrar_resultado(tiempo_ms: f64) {
    let ruta = ruta_resultados();
    let mut resultados: HashMap<String, f64> = HashMap::new();

    if ruta.exists() {
        let contenido = fs::read_to_string(&ruta).unwrap_or_default();
        for linea in contenido.lines() {
            if let Some(idx) = linea.find(':') {
                let lang = linea[..idx].trim().to_string();
                if let Ok(t) = linea[idx + 1..].trim().parse::<f64>() {
                    resultados.insert(lang, t);
                }
            }
        }
    }

    resultados.insert("Rust".to_string(), tiempo_ms);

    let contenido: String = LENGUAJES.iter()
        .filter_map(|l| resultados.get(*l).map(|t| format!("{l}:{t:.2}")))
        .collect::<Vec<_>>()
        .join("\n") + "\n";
    fs::write(&ruta, contenido).unwrap_or(());

    if LENGUAJES.iter().all(|l| resultados.contains_key(*l)) {
        let mut ordenados: Vec<(&str, f64)> = LENGUAJES.iter()
            .filter_map(|l| resultados.get(*l).map(|t| (*l, *t)))
            .collect();
        ordenados.sort_by(|a, b| a.1.partial_cmp(&b.1).unwrap());

        println!();
        println!("{}", "=".repeat(60));
        println!("  COMPARACIÓN DE LOS 4 LENGUAJES");
        println!("{}", "=".repeat(60));
        for (lang, t) in &ordenados {
            println!("  {:<14}: {:>10.2} ms", lang, t);
        }
        let (mas_rapido, t_min) = ordenados[0];
        println!("\n  El lenguaje más rápido fue: {mas_rapido} ({t_min:.2} ms)");
        println!("{}", "=".repeat(60));
        fs::remove_file(&ruta).unwrap_or(());
    }
}

fn leer_linea() -> String {
    let mut buf = String::new();
    io::stdin().lock().read_line(&mut buf).unwrap_or(0);
    buf.trim().to_string()
}

fn esperar_enter() {
    print!("\nPresiona Enter para salir...");
    io::stdout().flush().unwrap_or(());
    leer_linea();
}

fn main() {
    print!("Ingresa el valor de N (debe ser mayor a 50): ");
    io::stdout().flush().unwrap_or(());

    let n: u64 = match leer_linea().parse() {
        Ok(v) => v,
        Err(_) => {
            println!("Valor no válido. Debe ser un número entero.");
            esperar_enter();
            return;
        }
    };

    if n <= 50 {
        println!("N debe ser mayor a 50.");
        esperar_enter();
        return;
    }

    println!("\nConjetura de Collatz - verificando todos los enteros en [2, {n})");
    println!("{}", "-".repeat(60));

    let inicio = Instant::now();

    let mut max_pasos: u64 = 0;
    let mut num_max:   u64 = 0;

    for i in 2..n {
        let pasos = collatz_steps(i);
        if pasos > max_pasos {
            max_pasos = pasos;
            num_max   = i;
        }
    }

    let tiempo_ms = inicio.elapsed().as_secs_f64() * 1_000.0;

    println!("Rango verificado      : [2, {n})");
    println!("Número con más pasos  : {num_max}  ({max_pasos} pasos)");
    println!("Tiempo de ejecución   : {tiempo_ms:.2} ms");

    registrar_resultado(tiempo_ms);

    esperar_enter();
}
