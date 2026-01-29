// --- LÓGICA DE LOGIN ---
const botonLogin = document.getElementById('btnIngresar');
if (botonLogin) { // Solo se ejecuta si el botón existe (pantalla login)
    botonLogin.addEventListener('click', function() {
        const inputUsuario = document.getElementById('usuario');
        const inputPass = document.getElementById('password');
        if (inputUsuario.value !== "" && inputPass.value !== "") {
            window.location.href = "index.html"; 
        } else {
            alert("Por favor, completa todos los campos.");
        }
    });
}

// --- Volvel al menu presionando el logo ---
const btnIndex = document.querySelector('.logo');
const btnIndex2 = document.querySelector('.logo small');
if (btnIndex || btnIndex2) {
    btnIndex.addEventListener('click', () => {
        navegarA('index.html');
    });
    btnIndex.addEventListener('click', () => {
        navegarA('index.html');
    });
}


// --- LÓGICA DE FILTROS ---
const filterBtn = document.getElementById('filterBtn');
const filterPanel = document.getElementById('filterPanel');
const priceSlider = document.getElementById('priceSlider');
const priceValue = document.getElementById('priceValue');

if (filterBtn && filterPanel) {
    // Abrir/Cerrar menú
    filterBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        filterPanel.classList.toggle('show');
    });

    // Actualizar texto del precio en tiempo real
    if (priceSlider && priceValue) {
        priceSlider.addEventListener('input', (e) => {
            priceValue.textContent = `$${e.target.value}`;
        });
    }

    // Cerrar al hacer clic fuera
    document.addEventListener('click', (e) => {
        if (!filterPanel.contains(e.target) && e.target !== filterBtn) {
            filterPanel.classList.remove('show');
        }
    });
}


// Función genérica para redirigir
function navegarA(url) {
    window.location.href = url;
}

// 1. De las tarjetas de hotel al detalle
// Buscamos todas las tarjetas y les damos clic
document.querySelectorAll('.hotel-card').forEach(card => {
    card.addEventListener('click', () => {
        navegarA('detalle_habitacion.html'); 
    });
});

// 2. Del botón "Reservar" a la Facturación o Confirmación
const btnReservar = document.querySelector('.btn-reservar');
if (btnReservar) {
    btnReservar.addEventListener('click', () => {
        navegarA('reserva.html');
    });
}

// 3. Botones de Gestión (CRUD)
const btnGestionarHabitaciones = document.getElementById('btnGestionHab');
if (btnGestionarHabitaciones) {
    btnGestionarHabitaciones.addEventListener('click', () => {
        navegarA('crud_habitaciones.html');
    });
}


