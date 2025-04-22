document.addEventListener("DOMContentLoaded", function () {
    const loadingBarContainer = document.getElementById("loading-bar-container");
    const loadingBar = document.getElementById("loading-bar");
    const loadingPercent = document.getElementById("loading-percent");

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
            document.body.classList.add("loaded");

            setTimeout(() => {
                loadingBarContainer.style.display = "none";
            }, 500);
        }, remainingTime);
    });
})

// jQuery
$(document).ready(function () {
    $('#theme-toggle').click(function () {
        $('body').toggleClass('dark');
        const icon = $('#theme-icon');
        icon.toggleClass('lnr-moon lnr-sun');
    });

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

// Impression
window.addEventListener('beforeprint', function () {
    const headerContent = document.querySelector('.central-header').innerHTML;
    const infosSection = document.querySelector('#infos-personnelles');
    const headerContainer = document.createElement('div');
    headerContainer.classList.add('header-print');
    headerContainer.innerHTML = headerContent;
    infosSection.prepend(headerContainer);
});

window.addEventListener('afterprint', function () {
    const headerContainer = document.querySelector('.header-print');
    if (headerContainer) headerContainer.remove();
});

document.getElementById("print-btn").addEventListener("click", () => {
    // Scroll vers le bas de la page
    window.scrollTo({ top: document.body.scrollHeight, behavior: "smooth" });

    // Attendre un peu pour que tous les éléments s'affichent
    setTimeout(() => {
        window.print();
    }, 800); // 800ms pour laisser le temps au scroll/animations de se finir
});

window.addEventListener('beforeprint', function () {
    document.body.classList.remove('dark');
    const icon = document.getElementById('theme-icon');
    if (icon) icon.classList.remove('lnr-sun');

    const linkedinLink = document.querySelector('a[href*="linkedin.com"]');
    if (linkedinLink) {
        linkedinLink.textContent = linkedinLink.href;
    }
});

window.addEventListener('afterprint', function () {
    const linkedinLink = document.querySelector('a[href*="linkedin.com"]');
    if (linkedinLink) {
        linkedinLink.textContent = "mon profil";
    }
});



