document.addEventListener("DOMContentLoaded", function () {
    const loadingBarContainer = document.getElementById("loading-bar-container");
    const loadingBar = document.getElementById("loading-bar");
    const loadingPercent = document.getElementById("loading-percent");

    // Attendre au moins 3 secondes avant de masquer la barre
    const minLoadingTime = 3000;
    const startTime = Date.now();

    let percent = 0;
    const interval = setInterval(() => {
        if (percent < 100) {
            percent += 1;
            loadingBar.style.width = `${percent}%`;
            loadingPercent.textContent = `${percent}%`;
        }
    }, minLoadingTime / 100);

    window.addEventListener("load", function () {
        const elapsedTime = Date.now() - startTime;
        const remainingTime = Math.max(0, minLoadingTime - elapsedTime);

        setTimeout(() => {
            clearInterval(interval);
            loadingBar.style.width = `100%`;
            loadingPercent.textContent = `100%`;

            // Ajouter une classe pour afficher le site avec un fade-in
            document.body.classList.add("loaded");

            // Supprimer le conteneur de la barre après le fade-out
            setTimeout(() => {
                loadingBarContainer.style.display = "none";
            }, 500); // Durée du fade-out
        }, remainingTime);
    });
});

// Mode nuit/jour avec changement d'icône
$(document).ready(function () {
    const themeToggle = $('#theme-toggle');
    
    themeToggle.click(function () {
        $('body').toggleClass('dark');
        
        const icon = $('#theme-icon');
        if ($('body').hasClass('dark')) {
            icon.removeClass('lnr-moon').addClass('lnr-sun');
        } else {
            icon.removeClass('lnr-sun').addClass('lnr-moon'); 
        }
    });
});

// Bordure animée pour la photo de profil
$(document).ready(function () {
    $('.profile-photo').hover(
        function () {
            $(this).css({
                'border-color': '#FFD700', 
                'transition': 'border-color 0.5s ease-in-out'
            });
        },
        function () {
            $(this).css({
                'border-color': '#007BFF', 
                'transition': 'border-color 0.5s ease-in-out'
            });
        }
    );
});

// Animation avec ScrollMagic
$(document).ready(function () {
    const controller = new ScrollMagic.Controller();
    
    $('section').each(function () {
        new ScrollMagic.Scene({
            triggerElement: this,
            triggerHook: 0.8
        })
        .setClassToggle(this, 'fade-in')
        .addTo(controller);
    });
});

// Déplacer le contenu du header dans #infos-personnelles lors de l'impression
window.addEventListener('beforeprint', function () {
    const headerContent = document.querySelector('.central-header').innerHTML;
    const infosSection = document.querySelector('#infos-personnelles');

    // Créer un conteneur temporaire pour le contenu du header
    const headerContainer = document.createElement('div');
    headerContainer.classList.add('header-print');
    headerContainer.innerHTML = headerContent;

    // Ajouter le contenu du header au début de la section #infos-personnelles
    infosSection.prepend(headerContainer);
});

// Restaurer l'état initial après l'impression
window.addEventListener('afterprint', function () {
    const headerContainer = document.querySelector('.header-print');
    if (headerContainer) {
        headerContainer.remove(); // Supprimer le contenu temporaire
    }
});

