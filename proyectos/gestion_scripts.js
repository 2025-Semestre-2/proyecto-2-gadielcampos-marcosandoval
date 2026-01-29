function openTab(evt, tabName) {
    // 1. Ocultar todos los contenidos
    var contents = document.getElementsByClassName("tab-content");
    for (var i = 0; i < contents.length; i++) {
        contents[i].classList.remove("active");
    }

    // 2. Quitar la clase 'active' de todos los botones
    var buttons = document.getElementsByClassName("tab-btn");
    for (var i = 0; i < buttons.length; i++) {
        buttons[i].classList.remove("active");
    }

    // 3. Mostrar la pestaña actual y añadir 'active' al botón que la abrió
    document.getElementById(tabName).classList.add("active");
    evt.currentTarget.classList.add("active");
}