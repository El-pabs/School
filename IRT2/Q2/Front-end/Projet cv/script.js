// Mode nuit/jour avec changement d'icône
$(document).ready(function () {
    const themeToggle = $('#theme-toggle');
    
    themeToggle.click(function () {
        $('body').toggleClass('dark');
        
        const icon = $('#theme-icon');
        if ($('body').hasClass('dark')) {
            icon.removeClass('lnr-moon').addClass('lnr-sun'); // Icône lune
        } else {
            icon.removeClass('lnr-sun').addClass('lnr-moon'); // Icône soleil
        }
    });
});

// Bordure animée pour la photo de profil
$(document).ready(function () {
    $('.profile-photo').hover(
        function () {
            $(this).css({
                'border-color': '#FFD700', // Couleur dorée
                'transition': 'border-color 0.5s ease-in-out'
            });
        },
        function () {
            $(this).css({
                'border-color': '#007BFF', // Couleur originale
                'transition': 'border-color 0.5s ease-in-out'
            });
        }
    );
});

// Animation avec ScrollMagic
$(document).ready(function () {
    if ($(window).width() > 850) { // Désactiver ScrollMagic pour les petits écrans
        const controller = new ScrollMagic.Controller();
        
        $('section').each(function () {
            new ScrollMagic.Scene({
                triggerElement: this,
                triggerHook: 0.8
            })
            .setClassToggle(this, 'fade-in')
            .addTo(controller);
        });
    } else {
        // Afficher toutes les sections sans animation pour les petits écrans
        $('section').addClass('fade-in');
    }
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

