<?php
// backend/conexion.php

// 1. Definición de credenciales de tu servidor local
$host    = 'localhost';
$db      = 'sex_shop_db'; // Tu base de datos creada
$user    = 'root';        // Usuario por defecto en XAMPP/Wamp
$pass    = '';            // Contraseña por defecto (vacía en XAMPP)
$charset = 'utf8mb4';     // Soporte completo para caracteres especiales y emojis

// Data Source Name: La cadena de configuración para el driver de MySQL
$dsn = "mysql:host=$host;dbname=$db;charset=$charset";

// 2. Opciones avanzadas de seguridad y rendimiento para PDO
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION, // Reportar errores como Excepciones ejecutables
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,       // Traer los datos como arrays asociativos fácilmente legibles
    PDO::ATTR_EMULATE_PREPARES   => false,                  // Usar sentencias preparadas nativas y reales (Seguridad máxima)
];

try {
    // 3. Intentar crear la instancia de conexión instanciando el objeto PDO
    $pdo = new PDO($dsn, $user, $pass, $options);
    
    // NOTA: Si solo quieres incluir este archivo en otros módulos, puedes borrar las líneas de abajo.
    // De momento, si entras a http://localhost/glowvibe-shop/backend/conexion.php te servirá de test:
    /*
    echo "✅ Conexión con PHP PDO exitosa a sex_shop_db.";
    */

} catch (\PDOException $e) {
    // 4. Si algo falla (servidor apagado, datos incorrectos), atrapa el error de forma segura
    // En producción es mejor guardar esto en un log en lugar de mostrarlo al cliente
    die("❌ Error crítico en la conexión a la base de datos: " . $e->getMessage());
}
?>