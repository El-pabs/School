document.addEventListener("DOMContentLoaded", function() {
    const lettres = ['a', 'a', 'i', 's', 'c', 'j', 'v', 't', 'r', 'p'];
    const nbCases = 10;
    const casesDiv = document.querySelector('.cases');
    const jetonsDiv = document.querySelector('.jetons');
    let dernierNoir = null;

    // Générer les cases
    for(let i=0; i<nbCases; i++) {
        const c = document.createElement('div');
        c.className = 'case';
        casesDiv.appendChild(c);
    }

    // Générer les jetons
    const jetons = [];
    for(let i=0; i<lettres.length; i++) {
        const j = document.createElement('div');
        j.className = 'jeton';
        j.textContent = lettres[i];
        jetonsDiv.appendChild(j);
        jetons.push(j);
    }

    // Positionnement aléatoire des jetons (100px des bords)
    function randomPos() {
        const w = window.innerWidth;
        const h = jetonsDiv.offsetHeight;
        const minX = 100, minY = 100;
        const maxX = w - 60 - 100;
        const maxY = h - 60 - 100;
        return {
            left: Math.floor(Math.random() * (maxX - minX + 1)) + minX,
            top: Math.floor(Math.random() * (maxY - minY + 1)) + minY
        };
    }

    jetons.forEach(jeton => {
        const pos = randomPos();
        jeton.style.left = pos.left + "px";
        jeton.style.top = pos.top + "px";
    });

    // Apparition progressive
    jetons.forEach((jeton, i) => {
        setTimeout(() => {
            jeton.style.opacity = 1;
        }, 300 + i*120);
    });

    // Survol
    jetons.forEach(jeton => {
        jeton.addEventListener('mouseenter', function() {
            if (!jeton.classList.contains('noir')) jeton.classList.add('survol');
        });
        jeton.addEventListener('mouseleave', function() {
            jeton.classList.remove('survol');
        });
    });

    // Clic sur jeton
    jetons.forEach(jeton => {
        jeton.addEventListener('click', function() {
            if (dernierNoir) dernierNoir.classList.remove('noir');
            jeton.classList.remove('survol');
            jeton.classList.add('noir');
            dernierNoir = jeton;
        });
    });

    // Clic sur case : déplacer le jeton noir
    document.querySelectorAll('.case').forEach((c, idx) => {
        c.addEventListener('click', function() {
            if (!dernierNoir) return;
            // Position de la case par rapport au conteneur jetons
            const caseRect = c.getBoundingClientRect();
            const jetonsRect = jetonsDiv.getBoundingClientRect();
            const left = caseRect.left - jetonsRect.left + (c.offsetWidth - dernierNoir.offsetWidth)/2;
            const top = caseRect.top - jetonsRect.top + (c.offsetHeight - dernierNoir.offsetHeight)/2;
            dernierNoir.style.transition = "left 0.8s, top 0.8s";
            dernierNoir.style.left = left + "px";
            dernierNoir.style.top = top + "px";
        });
    });
});