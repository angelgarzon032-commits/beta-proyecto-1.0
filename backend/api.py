# backend/api.py
print("hola esta leyendo esto correctamente")
from flask import Flask, jsonify, request
from flask_cors import CORS
import mysql.connector
from config import DB_CONFIG  # Importamos la configuración segura

app = Flask(__name__)
CORS(app)  # Permite que tu frontend acceda a la API sin bloqueos de seguridad

# ============================================================
# ENDPOINT PARA OBTENER PRODUCTOS (Corregido a /api/products)
# ============================================================
@app.route('/api/productos', methods=['GET'])
def obtener_productos():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor(dictionary=True)
        
        # Consumimos tu vista estructurada
        cursor.execute("SELECT * FROM vista_productos_completa WHERE activo = 1")
        productos = cursor.fetchall()
        
        cursor.close()
        conn.close()
        return jsonify(productos), 200
    except Exception as e:
        print(f"Error en GET /api/products: {str(e)}")
        return jsonify({"error": str(e)}), 500

# ============================================================
# ENDPOINT PARA PROCESAR EL CHECKOUT
# ============================================================
@app.route('/api/checkout', methods=['POST'])
def procesar_checkout():
    datos = request.json
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        argumentos = (
            datos['usuario_id'],
            datos['producto_id'],
            datos['cantidad'],
            datos['precio_unitario'],
            datos['direccion'],
            datos['ciudad'],
            datos['departamento']
        )
        
        cursor.callproc('registrar_compra', argumentos)
        
        nuevo_pedido_id = None
        for result in cursor.stored_results():
            fila = result.fetchone()
            if fila:
                nuevo_pedido_id = fila[0]
        
        conn.commit()
        cursor.close()
        conn.close()
        
        return jsonify({
            "mensaje": "¡Pedido registrado!",
            "nuevo_pedido_id": nuevo_pedido_id
        }), 201
        
    except mysql.connector.Error as err:
        return jsonify({"error": err.msg}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# ============================================================
# ENDPOINT PARA REGISTRAR UN NUEVO USUARIO (Con logs mejorados)
# ============================================================
@app.route('/api/auth/register', methods=['POST'])
def registrar_usuario():
    datos = request.json
    nombre = datos.get('nombre')
    correo = datos.get('correo')
    telefono = datos.get('telefono')
    contrasena = datos.get('contrasena')

    if not nombre or not correo or not contrasena:
        return jsonify({"error": "Faltan campos obligatorios en el formulario"}), 400

    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()

        query = """
            INSERT INTO usuarios (nombre, correo, telefono, contraseña, rol, estado) 
            VALUES (%s, %s, %s, %s, 'cliente', 'activo')
        """
        cursor.execute(query, (nombre, correo, telefono, contrasena))
        conn.commit()

        cursor.close()
        conn.close()
        return jsonify({"message": "Usuario registrado correctamente"}), 201

    except mysql.connector.Error as err:
        # IMPORTANTE: Esto imprimirá el error real de MySQL en tu consola de comandos
        print("\n[DEBUG] Error real ocurrido en la Base de Datos:")
        print(f"Código de error: {err.errno}")
        print(f"Mensaje: {err.msg}\n")
        
        # Si es un error de duplicado (Código 1062 en MySQL)
        if err.errno == 1062:
            return jsonify({"error": "El correo o el teléfono ya se encuentran registrados en el sistema."}), 400
        
        # Cualquier otro error (tablas que no existen, columnas mal escritas, etc.)
        return jsonify({"error": f"Error interno en la base de datos: {err.msg}"}), 400

# ============================================================
# ENDPOINT PARA INICIAR SESIÓN (LOGIN)
# ============================================================
@app.route('/api/auth/login', methods=['POST'])
def iniciar_sesion():
    datos = request.json
    identificador = datos.get('identificador')
    contrasena = datos.get('contrasena')

    if not identificador or not contrasena:
        return jsonify({"error": "Faltan campos obligatorios"}), 400

    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor(dictionary=True)

        query = """
            SELECT id, nombre, correo, telefono, contraseña, rol, estado 
            FROM usuarios 
            WHERE (correo = %s OR telefono = %s) AND estado = 'activo'
        """
        cursor.execute(query, (identificador, identificador))
        usuario = cursor.fetchone()

        cursor.close()
        conn.close()

        if usuario and usuario['contraseña'] == contrasena:
            usuario.pop('contraseña')
            return jsonify({
                "mensaje": "Inicio de sesión exitoso",
                "usuario": usuario
            }), 200
        else:
            return jsonify({"error": "Credenciales incorrectas o cuenta inactiva"}), 401

    except mysql.connector.Error as err:
        print(f"Error en LOGIN: {str(err)}")
        return jsonify({"error": f"Error interno en la base de datos: {str(err)}"}), 500

if __name__ == '__main__':
    app.run(port=5000, debug=True)