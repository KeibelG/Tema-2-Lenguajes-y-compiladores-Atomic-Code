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
// Lenguaje:   Zig 0.16.0
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

const std = @import("std");

// Windows API
extern "kernel32" fn QueryPerformanceCounter(lp: *i64) callconv(.winapi) u32;
extern "kernel32" fn QueryPerformanceFrequency(lp: *i64) callconv(.winapi) u32;
extern "kernel32" fn GetStdHandle(n: u32) callconv(.winapi) ?*anyopaque;
extern "kernel32" fn ReadConsoleA(h: ?*anyopaque, buf: [*]u8, len: u32, read: *u32, ctrl: ?*anyopaque) callconv(.winapi) i32;
extern "kernel32" fn CreateFileA(name: [*:0]const u8, access: u32, share: u32, sec: ?*anyopaque, disp: u32, flags: u32, tmpl: ?*anyopaque) callconv(.winapi) ?*anyopaque;
extern "kernel32" fn ReadFile(h: ?*anyopaque, buf: [*]u8, n: u32, read: *u32, ov: ?*anyopaque) callconv(.winapi) i32;
extern "kernel32" fn WriteFile(h: ?*anyopaque, buf: [*]const u8, n: u32, written: *u32, ov: ?*anyopaque) callconv(.winapi) i32;
extern "kernel32" fn CloseHandle(h: ?*anyopaque) callconv(.winapi) i32;
extern "kernel32" fn DeleteFileA(name: [*:0]const u8) callconv(.winapi) i32;

const STD_INPUT_HANDLE: u32 = 0xFFFFFFF6;
const GENERIC_READ:     u32 = 0x80000000;
const GENERIC_WRITE:    u32 = 0x40000000;
const FILE_SHARE_READ:  u32 = 0x00000001;
const OPEN_EXISTING:    u32 = 3;
const CREATE_ALWAYS:    u32 = 2;
const FILE_ATTR_NORMAL: u32 = 0x80;

const RUTA      = "..\\resultados.txt";
const LENGUAJES = [4][]const u8{ "Python", "JavaScript", "Zig", "Rust" };

fn handleValido(h: ?*anyopaque) bool {
    const p = h orelse return false;
    return @intFromPtr(p) != std.math.maxInt(usize);
}

fn leerLinea(buf: []u8) []u8 {
    const stdin = GetStdHandle(STD_INPUT_HANDLE);
    var n: u32 = 0;
    _ = ReadConsoleA(stdin, buf.ptr, @intCast(buf.len - 1), &n, null);
    var len = n;
    while (len > 0 and (buf[len - 1] == '\n' or buf[len - 1] == '\r')) : (len -= 1) {}
    return buf[0..len];
}

fn leerArchivo(buf: []u8) []u8 {
    const h = CreateFileA(RUTA, GENERIC_READ, FILE_SHARE_READ, null, OPEN_EXISTING, FILE_ATTR_NORMAL, null);
    if (!handleValido(h)) return buf[0..0];
    defer _ = CloseHandle(h);
    var n: u32 = 0;
    _ = ReadFile(h, buf.ptr, @intCast(buf.len - 1), &n, null);
    buf[n] = 0;
    return buf[0..n];
}

fn escribirArchivo(contenido: []const u8) void {
    const h = CreateFileA(RUTA, GENERIC_WRITE, 0, null, CREATE_ALWAYS, FILE_ATTR_NORMAL, null);
    if (!handleValido(h)) return;
    defer _ = CloseHandle(h);
    var w: u32 = 0;
    _ = WriteFile(h, contenido.ptr, @intCast(contenido.len), &w, null);
}

fn collatzSteps(n: u64) u64 {
    var cur = n;
    var steps: u64 = 0;
    while (cur != 1) {
        cur = if (cur % 2 == 0) cur / 2 else 3 * cur + 1;
        steps += 1;
    }
    return steps;
}

fn registrarResultado(tiempo_ms: f64) void {
    var tempos = [4]f64{ -1.0, -1.0, -1.0, -1.0 };

    var file_buf: [4096]u8 = [_]u8{0} ** 4096;
    const contenido = leerArchivo(&file_buf);

    var iter = std.mem.splitScalar(u8, contenido, '\n');
    while (iter.next()) |linea| {
        const l = std.mem.trimEnd(u8, linea, "\r\n ");
        if (l.len == 0) continue;
        if (std.mem.indexOf(u8, l, ":")) |idx| {
            const lang    = l[0..idx];
            const val_str = std.mem.trimStart(u8, l[idx + 1 ..], " ");
            for (LENGUAJES, 0..) |nombre, i| {
                if (std.mem.eql(u8, lang, nombre)) {
                    tempos[i] = std.fmt.parseFloat(f64, val_str) catch -1.0;
                    break;
                }
            }
        }
    }

    tempos[2] = tiempo_ms;

    var out_buf: [1024]u8 = undefined;
    var out_len: usize = 0;
    for (LENGUAJES, 0..) |nombre, i| {
        if (tempos[i] >= 0.0) {
            const s = std.fmt.bufPrint(out_buf[out_len..], "{s}:{d:.2}\n", .{ nombre, tempos[i] }) catch continue;
            out_len += s.len;
        }
    }
    escribirArchivo(out_buf[0..out_len]);

    var todos = true;
    for (tempos) |t| {
        if (t < 0.0) { todos = false; break; }
    }

    if (todos) {
        var indices = [4]usize{ 0, 1, 2, 3 };
        for (0..3) |j| {
            for (0..3 - j) |k| {
                if (tempos[indices[k]] > tempos[indices[k + 1]]) {
                    const tmp      = indices[k];
                    indices[k]     = indices[k + 1];
                    indices[k + 1] = tmp;
                }
            }
        }

        std.debug.print("\n============================================================\n", .{});
        std.debug.print("  COMPARACION DE LOS 4 LENGUAJES\n",                              .{});
        std.debug.print("============================================================\n",   .{});
        for (indices) |idx| {
            std.debug.print("  {s:<14}: {d:>10.2} ms\n", .{ LENGUAJES[idx], tempos[idx] });
        }
        std.debug.print("\n  El lenguaje mas rapido fue: {s} ({d:.2} ms)\n",
            .{ LENGUAJES[indices[0]], tempos[indices[0]] });
        std.debug.print("============================================================\n", .{});
        _ = DeleteFileA(RUTA);
    }
}

pub fn main() void {
    std.debug.print("Ingresa el valor de N (debe ser mayor a 50): ", .{});

    var buf: [64]u8 = [_]u8{0} ** 64;
    const entrada = leerLinea(&buf);

    const N = std.fmt.parseInt(u64, entrada, 10) catch {
        std.debug.print("Valor no valido. Debe ser un numero entero.\n", .{});
        std.debug.print("\nPresiona Enter para salir...", .{});
        var tmp: [64]u8 = [_]u8{0} ** 64;
        _ = leerLinea(&tmp);
        return;
    };

    if (N <= 50) {
        std.debug.print("N debe ser mayor a 50.\n", .{});
        std.debug.print("\nPresiona Enter para salir...", .{});
        var tmp: [64]u8 = [_]u8{0} ** 64;
        _ = leerLinea(&tmp);
        return;
    }

    std.debug.print("\nConjetura de Collatz -- verificando todos los enteros en [2, {d})\n", .{N});
    std.debug.print("------------------------------------------------------------\n", .{});

    var freq: i64 = 0;
    var ini:  i64 = 0;
    var fin:  i64 = 0;
    _ = QueryPerformanceFrequency(&freq);
    _ = QueryPerformanceCounter(&ini);

    var max_pasos: u64 = 0;
    var num_max:   u64 = 0;
    var i: u64 = 2;
    while (i < N) : (i += 1) {
        const pasos = collatzSteps(i);
        if (pasos > max_pasos) {
            max_pasos = pasos;
            num_max   = i;
        }
    }

    _ = QueryPerformanceCounter(&fin);
    const tiempo_ms = @as(f64, @floatFromInt(fin - ini)) * 1000.0 / @as(f64, @floatFromInt(freq));

    std.debug.print("Rango verificado      : [2, {d})\n",         .{N});
    std.debug.print("Numero con mas pasos  : {d}  ({d} pasos)\n", .{ num_max, max_pasos });
    std.debug.print("Tiempo de ejecucion   : {d:.2} ms\n",        .{tiempo_ms});

    registrarResultado(tiempo_ms);

    std.debug.print("\nPresiona Enter para salir...", .{});
    var tmp: [64]u8 = [_]u8{0} ** 64;
    _ = leerLinea(&tmp);
}
