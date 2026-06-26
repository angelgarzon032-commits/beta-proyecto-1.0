// ============================================================
// CONFIGURACIÓN GLOBAL Y ESTADO DE LA APLICACIÓN
// ============================================================
const API_URL = 'https://sturdy-pancake-5vgj9vwv5w9h774w-5000.app.github.dev/api';
let carrito = [];
let usuarioLogueado = null; 

// ============================================================
// ELEMENTOS DEL DOM
// ============================================================
const cartToggle = document.getElementById('cartToggle');
const sidebarCarrito = document.getElementById('sidebarCarrito');
const cerrarCarrito = document.getElementById('cerrarCarrito');
const gridProductos = document.getElementById('gridProductos');
const itemsCarrito = document.getElementById('itemsCarrito');
const cartCount = document.getElementById('cartCount');
const totalPrecio = document.getElementById('totalPrecio');
const btnCheckout = document.getElementById('btnCheckout');

const btnAbrirAuth = document.getElementById('btnAbrirAuth');
const modalAuth = document.getElementById('modalAuth');
const btnCerrarAuth = document.getElementById('btnCerrarAuth');
const sidebarUsuario = document.getElementById('sidebarUsuario');
const cerrarUsuario = document.getElementById('cerrarUsuario');
const statusDot = document.getElementById('statusDot');
const userMenuNombre = document.getElementById('userMenuNombre');
const formLogin = document.getElementById('form-login');
const formRegister = document.getElementById('form-register');
const btnCerrarSesion = document.getElementById('btnCerrarSesion');
const btnCambiarCuenta = document.getElementById('btnCambiarCuenta');

// Elementos nuevos para sub-modales
const modalSubSeccion = document.getElementById('modalSubSeccion');
const subSeccionDinamica = document.getElementById('subSeccionDinamica');
const btnCerrarSub = document.getElementById('btnCerrarSub');

// ============================================================
// SISTEMA DE NOTIFICACIONES TOAST (PREMIUM)
// ============================================================
function mostrarNotificacion(mensaje, tipo = 'info') {
    const container = document.getElementById('toast-container');
    if (!container) return;

    const toast = document.createElement('div');
    toast.className = `toast ${tipo}`;
    
    let icono = '<i class="fas fa-info-circle"></i>';
    if (tipo === 'success') icono = '<i class="fas fa-check-circle"></i>';
    if (tipo === 'error') icono = '<i class="fas fa-exclamation-circle"></i>';

    toast.innerHTML = `${icono} <span>${mensaje}</span>`;
    container.appendChild(toast);

    setTimeout(() => toast.classList.add('show'), 10);
    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

// ============================================================
// LÓGICA DE CONTROL DE MODALES Y SIDEBARS
// ============================================================
if (btnAbrirAuth) {
    btnAbrirAuth.addEventListener('click', () => {
        if (usuarioLogueado) sidebarUsuario.classList.add('active');
        else modalAuth.classList.add('active');
    });
}

if (btnCerrarAuth) btnCerrarAuth.addEventListener('click', () => modalAuth.classList.remove('active'));
if (cerrarUsuario) cerrarUsuario.addEventListener('click', () => sidebarUsuario.classList.remove('active'));
if (btnCerrarSub) btnCerrarSub.addEventListener('click', () => modalSubSeccion.classList.remove('active'));

// Cierre al hacer clic fuera
[modalAuth, modalSubSeccion].forEach(m => {
    if (m) m.addEventListener('click', (e) => { if (e.target === m) m.classList.remove('active'); });
});

window.switchTab = function(tab) {
    const tabLogin = document.getElementById('tab-login');
    const tabRegister = document.getElementById('tab-register');
    if (tab === 'login') {
        formLogin.classList.remove('hidden'); formRegister.classList.add('hidden');
        tabLogin.classList.add('active'); tabRegister.classList.remove('active');
    } else {
        formLogin.classList.add('hidden'); formRegister.classList.remove('hidden');
        tabLogin.classList.remove('active'); tabRegister.classList.add('active');
    }
};

// ============================================================
// LÓGICA DE SUB-MODALES DINÁMICOS
// ============================================================
window.abrirSubSeccion = function(tipo) {
    if (!usuarioLogueado) {
        mostrarNotificacion("Debes iniciar sesión para realizar esta acción.", "error");
        return;
    }
    modalSubSeccion.classList.add('active');
    subSeccionDinamica.innerHTML = '';

    switch(tipo) {
        case 'pedidos':
            subSeccionDinamica.innerHTML = `<h3><i class="fas fa-shopping-bag"></i> Estado de tus Pedidos</h3><p>Historial para: <strong>${usuarioLogueado.correo}</strong></p>`;
            break;
        case 'direcciones':
            subSeccionDinamica.innerHTML = `<h3><i class="fas fa-truck"></i> Dirección</h3><form id="form-sub-direccion" class="auth-form"><div class="input-group"><label>Ciudad</label><input type="text" id="sub-ciudad" required></div><div class="input-group"><label>Dirección</label><input type="text" id="sub-direccion" required></div><button type="submit" class="btn-submit">Guardar</button></form>`;
            document.getElementById('form-sub-direccion').addEventListener('submit', async (e) => {
                e.preventDefault();
                mostrarNotificacion("Dirección actualizada.", "success");
                modalSubSeccion.classList.remove('active');
            });
            break;
        case 'pagos':
            subSeccionDinamica.innerHTML = `<h3><i class="fas fa-credit-card"></i> Métodos de Pago</h3><p>Funcionalidad de tarjeta vinculada.</p>`;
            break;
        case 'correo':
            subSeccionDinamica.innerHTML = `<h3><i class="fas fa-envelope"></i> Cambiar Correo</h3><form id="form-sub-correo" class="auth-form"><div class="input-group"><label>Nuevo Correo</label><input type="email" id="sub-nuevo-correo" required></div><button type="submit" class="btn-submit">Confirmar</button></form>`;
            document.getElementById('form-sub-correo').addEventListener('submit', async (e) => { e.preventDefault(); mostrarNotificacion("Correo actualizado.", "success"); modalSubSeccion.classList.remove('active'); });
            break;
        case 'password':
            subSeccionDinamica.innerHTML = `<h3><i class="fas fa-lock"></i> Contraseña</h3><form id="form-sub-pass" class="auth-form"><div class="input-group"><label>Nueva Contraseña</label><input type="password" id="sub-new-pass" required></div><button type="submit" class="btn-submit">Actualizar</button></form>`;
            document.getElementById('form-sub-pass').addEventListener('submit', async (e) => { e.preventDefault(); mostrarNotificacion("Contraseña actualizada.", "success"); modalSubSeccion.classList.remove('active'); });
            break;
        case 'ayuda':
            subSeccionDinamica.innerHTML = `<h3><i class="fas fa-question-circle"></i> Soporte</h3><a href="https://wa.me/573001234567" class="btn-submit">Contactar Asesor</a>`;
            break;
    }
};

// ============================================================
// LOGIN Y REGISTRO
// ============================================================
if (formLogin) {
    formLogin.addEventListener('submit', async (e) => {
        e.preventDefault();
        const identificador = document.getElementById('login-identifier').value;
        const contrasena = document.getElementById('login-password').value;
        try {
            const response = await fetch(`${API_URL}/auth/login`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ identificador, contrasena })
            });
            const data = await response.json();
            if (response.ok) {
                usuarioLogueado = data.usuario;
                statusDot.classList.add('active');
                userMenuNombre.textContent = usuarioLogueado.nombre;
                modalAuth.classList.remove('active');
                mostrarNotificacion(`Bienvenido, ${usuarioLogueado.nombre}`, 'success');
            } else {
                mostrarNotificacion(data.error || "Error de credenciales.", 'error');
            }
        } catch (error) {
            mostrarNotificacion("Error de conexión.", 'error');
        }
    });
}

if (formRegister) {
    formRegister.addEventListener('submit', async (e) => {
        e.preventDefault();
        const nombre = document.getElementById('reg-nombre').value;
        const correo = document.getElementById('reg-correo').value;
        const telefono = document.getElementById('reg-telefono').value;
        const contrasena = document.getElementById('reg-password').value;
        try {
            const response = await fetch(`${API_URL}/auth/register`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ nombre, correo, telefono, contrasena })
            });
            const data = await response.json();
            if (response.ok) {
                mostrarNotificacion("¡Tu cuenta ha sido creada con éxito!", 'success');
                formRegister.reset();
                switchTab('login'); 
            } else {
                mostrarNotificacion(data.error || "Ocurrió un error al registrarse.", 'error');
            }
        } catch (error) {
            mostrarNotificacion("Error al conectar con el servidor.", 'error');
        }
    });
}

if (btnCerrarSesion) {
    btnCerrarSesion.addEventListener('click', () => {
        usuarioLogueado = null;
        statusDot.classList.remove('active');
        sidebarUsuario.classList.remove('active');
        mostrarNotificacion("Has cerrado sesión de forma segura.", 'info');
    });
}

if (btnCambiarCuenta) {
    btnCambiarCuenta.addEventListener('click', () => {
        usuarioLogueado = null;
        statusDot.classList.remove('active');
        sidebarUsuario.classList.remove('active');
        switchTab('login');
        modalAuth.classList.add('active'); 
    });
}

window.loginFacebook = function() {
    mostrarNotificacion("Conexión con la API segura de Facebook en desarrollo técnico.", 'info');
};

// ============================================================
// LÓGICA DE TIENDA: PRODUCTOS Y CARRITO DE COMPRAS
// ============================================================
if (cartToggle) cartToggle.addEventListener('click', () => sidebarCarrito.classList.add('active'));
if (cerrarCarrito) cerrarCarrito.addEventListener('click', () => sidebarCarrito.classList.remove('active'));

async function cargarProductos() {
    if (!gridProductos) return;
    try {
        const response = await fetch(`${API_URL}/productos`);
        const productos = await response.json();

        gridProductos.innerHTML = '';
        productos.forEach(prod => {
            const card = document.createElement('div');
            card.className = 'producto-card';
            card.innerHTML = `
                <img src="${prod.imagen_url || 'https://via.placeholder.com/250'}" alt="${prod.nombre}">
                <div class="producto-info">
                    <h3>${prod.nombre}</h3>
                    <p class="categoria-tag">${prod.categoria || 'GlowVibe'}</p>
                    <p class="precio">$${parseFloat(prod.precio).toLocaleString()}</p>
                    <p class="stock-info ${prod.stock < 5 ? 'bajo' : ''}">Disponibles: ${prod.stock}</p>
                    <button class="btn-agregar" onclick="agregarAlCarrito(${prod.id}, '${prod.nombre}', ${prod.precio})">
                        <i class="fas fa-shopping-cart"></i> Agregar
                    </button>
                </div>
            `;
            gridProductos.appendChild(card);
        });
    } catch (error) {
        console.error("Error trayendo productos de Flask:", error);
        gridProductos.innerHTML = `<p class="error-msg">No pudimos cargar el catálogo. Verifica que Flask esté encendido.</p>`;
    }
}

window.agregarAlCarrito = function(id, nombre, precio) {
    const itemExistente = carrito.find(item => item.id === id);
    if (itemExistente) {
        itemExistente.cantidad++;
    } else {
        carrito.push({ id, nombre, precio, cantidad: 1 });
    }
    actualizarInterfazCarrito();
};

function actualizarInterfazCarrito() {
    if (!itemsCarrito) return;
    itemsCarrito.innerHTML = '';
    let total = 0;
    let totalUnidades = 0;

    carrito.forEach(item => {
        total += item.precio * item.cantidad;
        totalUnidades += item.cantidad;

        const row = document.createElement('div');
        row.className = 'item-carrito-row';
        row.innerHTML = `
            <div>
                <h4>${item.nombre}</h4>
                <small>$${parseFloat(item.precio).toLocaleString()} x ${item.cantidad}</small>
            </div>
            <button onclick="eliminarDelCarrito(${item.id})" class="btn-eliminar-item">&times;</button>
        `;
        itemsCarrito.appendChild(row);
    });

    cartCount.textContent = totalUnidades;
    totalPrecio.textContent = `$${total.toLocaleString()}`;
}

window.eliminarDelCarrito = function(id) {
    carrito = carrito.filter(item => item.id !== id);
    actualizarInterfazCarrito();
};

if (btnCheckout) {
    btnCheckout.addEventListener('click', () => {
        if (!usuarioLogueado) {
            mostrarNotificacion("Para proceder al pago, primero debes Iniciar Sesión con tu cuenta.", 'info');
            modalAuth.classList.add('active');
            sidebarCarrito.classList.remove('active');
            return;
        }
        if (carrito.length === 0) {
            mostrarNotificacion("Tu carrito está totalmente vacío.", 'error');
            return;
        }
        mostrarNotificacion(`Pasarela integrada con éxito. Procesando pedido para ${usuarioLogueado.nombre}...`, 'success');
    });
}

document.addEventListener('DOMContentLoaded', cargarProductos);