/* Läuft vor dem ersten Zeichnen: Besucher, die das Lade-Intro schon kennen, sehen es nicht erneut. */
try { if (localStorage.getItem('adf24_intro_seen') === '1') document.documentElement.classList.add('no-intro'); } catch (e) {}
