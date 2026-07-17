import json
import sqlite3
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parent
DB_PATH = ROOT / "base_datos" / "sig_gloria.sqlite"
PORT = 8000


def money(value):
    return f"S/ {float(value):,.2f}"


def connect():
    con = sqlite3.connect(DB_PATH)
    con.row_factory = sqlite3.Row
    ensure_schema(con)
    return con


def ensure_schema(con):
    con.execute("""CREATE TABLE IF NOT EXISTS clientes (
        id_cliente INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo TEXT NOT NULL,
        nombre TEXT NOT NULL,
        dni_ruc TEXT,
        ubicacion TEXT,
        telefono TEXT,
        correo TEXT,
        tipo_comprobante TEXT,
        razon_social TEXT,
        estado TEXT
    )""")
    con.execute("""CREATE TABLE IF NOT EXISTS productos (
        id_producto INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        presentacion TEXT NOT NULL,
        precio_unitario REAL NOT NULL,
        stock_estado TEXT NOT NULL
    )""")
    con.commit()


def read_all():
    with connect() as con:
        productores = [
            [
                r["codigo"],
                r["nombre"],
                r["ubicacion"],
                r["telefono"],
                r["volumen_promedio_litros"],
                r["calidad"],
                r["estado"],
            ]
            for r in con.execute("SELECT * FROM productores ORDER BY id_productor")
        ]
        controles = [
            [
                r["fecha_hora"],
                r["lote"],
                r["productor"],
                str(r["grasa"]),
                str(r["densidad"]),
                str(r["temperatura"]),
                r["resultado"],
                r["usuario"],
            ]
            for r in con.execute("SELECT * FROM controles_calidad ORDER BY id_control")
        ]
        pedidos = [
            [
                r["codigo"],
                r["cliente"],
                r["fecha_hora"],
                r["canal"],
                money(r["total"]),
                r["estado"],
                {
                    "producto": r["producto"],
                    "presentacion": r["presentacion"],
                    "cantidad": r["cantidad"],
                    "precio": r["precio_unitario"],
                },
            ]
            for r in con.execute("SELECT * FROM pedidos ORDER BY id_pedido")
        ]
        inventario = [
            [
                r["codigo"],
                r["producto"],
                r["lote"],
                r["stock_disponible"],
                r["vencimiento"],
                r["ubicacion"],
                r["estado"],
            ]
            for r in con.execute("SELECT * FROM inventario ORDER BY id_inventario")
        ]
        tickets = [
            [r["codigo"], r["tipo"], r["descripcion"], r["estado"], r["fecha_hora"]]
            for r in con.execute("SELECT * FROM tickets_soporte ORDER BY id_ticket")
        ]
        clientes = [
            [
                r["codigo"],
                r["nombre"],
                r["dni_ruc"],
                r["ubicacion"],
                r["telefono"],
                r["correo"],
                r["tipo_comprobante"],
                r["razon_social"],
                r["estado"],
            ]
            for r in con.execute("SELECT * FROM clientes ORDER BY id_cliente")
        ]
        productos = [
            [
                "PRG-" + str(r["id_producto"]).zfill(3),
                r["nombre"],
                r["presentacion"],
                r["precio_unitario"],
                r["stock_estado"],
            ]
            for r in con.execute("SELECT * FROM productos ORDER BY id_producto")
        ]
        usuarios = [
            [r["nombre"], r["correo"], r["password_hash"], r["rol"].lower()]
            for r in con.execute("SELECT * FROM usuarios ORDER BY id_usuario")
        ]
        return {
            "productores": productores,
            "controles": controles,
            "pedidos": pedidos,
            "inventario": inventario,
            "tickets": tickets,
            "clientes": clientes,
            "productos": productos,
            "usuarios": usuarios,
        }


def save_dataset(key, rows):
    with connect() as con:
        if key == "usuarios":
            con.execute("DELETE FROM usuarios")
            con.executemany(
                "INSERT INTO usuarios(nombre, correo, password_hash, rol) VALUES (?, ?, ?, ?)",
                [(r[0], r[1], r[2], str(r[3]).upper()) for r in rows],
            )
        elif key == "productores":
            con.execute("DELETE FROM productores")
            con.executemany(
                "INSERT INTO productores(codigo, nombre, ubicacion, telefono, volumen_promedio_litros, calidad, estado) VALUES (?, ?, ?, ?, ?, ?, ?)",
                rows,
            )
        elif key == "controles":
            con.execute("DELETE FROM controles_calidad")
            con.executemany(
                "INSERT INTO controles_calidad(fecha_hora, lote, productor, grasa, densidad, temperatura, resultado, usuario) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                rows,
            )
        elif key == "inventario":
            con.execute("DELETE FROM inventario")
            con.executemany(
                "INSERT INTO inventario(codigo, producto, lote, stock_disponible, vencimiento, ubicacion, estado) VALUES (?, ?, ?, ?, ?, ?, ?)",
                rows,
            )
        elif key == "tickets":
            con.execute("DELETE FROM tickets_soporte")
            con.executemany(
                "INSERT INTO tickets_soporte(codigo, tipo, descripcion, estado, fecha_hora) VALUES (?, ?, ?, ?, ?)",
                rows,
            )
        elif key == "clientes":
            con.execute("DELETE FROM clientes")
            con.executemany(
                "INSERT INTO clientes(codigo, nombre, dni_ruc, ubicacion, telefono, correo, tipo_comprobante, razon_social, estado) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                rows,
            )
        elif key == "productos":
            con.execute("DELETE FROM productos")
            con.executemany(
                "INSERT INTO productos(nombre, presentacion, precio_unitario, stock_estado) VALUES (?, ?, ?, ?)",
                [(r[1], r[2], float(r[3] or 0), r[4]) for r in rows],
            )
        elif key == "pedidos":
            con.execute("DELETE FROM pedidos")
            data = []
            for r in rows:
                det = r[6] if len(r) > 6 and isinstance(r[6], dict) else {}
                total_text = str(r[4]).replace("S/", "").replace(",", "").strip()
                total = float(total_text or 0)
                data.append(
                    (
                        r[0],
                        r[1],
                        r[2],
                        r[3],
                        det.get("producto", "Productos Gloria"),
                        det.get("presentacion", "Pedido variado"),
                        int(det.get("cantidad", 1) or 1),
                        float(det.get("precio", 0) or 0),
                        total,
                        r[5],
                    )
                )
            con.executemany(
                "INSERT INTO pedidos(codigo, cliente, fecha_hora, canal, producto, presentacion, cantidad, precio_unitario, total, estado) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                data,
            )
        else:
            raise ValueError("Dataset no permitido")
        con.commit()


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def _json(self, status, payload):
        body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = urlparse(self.path).path
        if path == "/api/health":
            return self._json(200, {"ok": True, "database": str(DB_PATH.name)})
        if path == "/api/data":
            return self._json(200, read_all())
        return super().do_GET()

    def do_POST(self):
        path = urlparse(self.path).path
        if path.startswith("/api/data/"):
            key = path.rsplit("/", 1)[-1]
            length = int(self.headers.get("Content-Length", "0"))
            payload = json.loads(self.rfile.read(length).decode("utf-8"))
            save_dataset(key, payload)
            return self._json(200, {"ok": True, "dataset": key})
        return self._json(404, {"ok": False, "error": "Ruta no encontrada"})


if __name__ == "__main__":
    print("SIG-GLORIA conectado a SQLite")
    print(f"Base de datos: {DB_PATH}")
    print(f"Abrir: http://localhost:{PORT}")
    ThreadingHTTPServer(("localhost", PORT), Handler).serve_forever()
