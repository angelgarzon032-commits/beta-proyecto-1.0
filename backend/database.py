# backend/database.py
import mysql.connector
from mysql.connector import Error
from config import DB_CONFIG  # Importa los datos de conexión (host, user, password)

def obtener_conexion():
    """Establece y retorna una conexión limpia con la base de datos."""
    try:
        conexion = mysql.connector.connect(**DB_CONFIG)
        if conexion.is_connected():
            return conexion
    except Error as e:
        print(f"❌ Error crítico al conectar a MySQL: {e}")
        return None

def probar_conexion():
    """Función de diagnóstico para ejecutar directamente en la terminal."""
    print("🔄 Intentando conectar a la base de datos sex_shop_db...")
    conexion = obtener_conexion()
    
    if conexion:
        try:
            cursor = conexion.cursor(dictionary=True)
            # Hacemos una consulta rápida de prueba a tu tabla de categorías
            cursor.execute("SELECT COUNT(*) AS total FROM categorias;")
            resultado = cursor.fetchone()
            
            print("====================================================")
            print("✅ ¡CONEXIÓN EXITOSA CON PYTHON!")
            print(f"📊 Categorías registradas actualmente en la BD: {resultado['total']}")
            print("====================================================")
            
            cursor.close()
        except Error as e:
            print(f"❌ Error al ejecutar la consulta de prueba: {e}")
        finally:
            conexion.close() # Siempre cerramos la conexión para liberar memoria
    else:
        print("❌ No se pudo establecer la conexión. Verifica tu servidor local (XAMPP/Wamp).")

# Esto permite que si ejecutas el archivo directamente, corra la prueba de diagnóstico
if __name__ == "__main__":
    probar_conexion()