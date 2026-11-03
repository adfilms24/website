/* End-Screen nach dem Video: Frage, Anfrage-Button, nochmal abspielen.
   Gilt für alle Videos mit Bedienleiste (Showreel im Dialog, Projektvideos), nicht für stumme Loops. */
(() => {
  const en = (document.documentElement.lang || '').startsWith('en');
  const T = en
    ? { q: 'Like this style?', cta: 'Start a project', replay: 'Watch again', contact: '/en/#contact' }
    : { q: 'Gefällt dir dieser Stil?', cta: 'Projekt anfragen', replay: 'Nochmal ansehen', contact: '/#contact' };
  const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  function remove(box) {
    const o = box.querySelector('.endscreen');
    if (o) o.remove();
  }

  function show(v) {
    const box = v.parentElement;
    if (!box || box.querySelector('.endscreen')) return;
    const o = document.createElement('div');
    o.className = 'endscreen';
    o.setAttribute('role', 'group');
    o.setAttribute('aria-label', T.q);
    o.innerHTML =
      '<p class="endscreen-q"></p>' +
      '<div class="endscreen-actions">' +
        '<a class="cta-primary endscreen-cta"></a>' +
        '<button type="button" class="endscreen-replay">' +
          '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M3 12a9 9 0 1 0 3-6.7L3 8M3 3v5h5" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>' +
          '<span></span></button>' +
      '</div>';
    o.querySelector('.endscreen-q').textContent = T.q;
    const a = o.querySelector('.endscreen-cta');
    a.textContent = T.cta;
    a.href = T.contact;
    o.querySelector('.endscreen-replay span').textContent = T.replay;

    a.addEventListener('click', (e) => {
      const target = document.getElementById('contact');
      if (!target) return;            /* Projektseite: normaler Link zur Startseite */
      e.preventDefault();
      const close = document.getElementById('modalClose');
      if (close && v.closest('#modal')) close.click();
      target.scrollIntoView({ behavior: reduced ? 'auto' : 'smooth', block: 'start' });
      history.replaceState(null, '', '#contact');
    });
    o.querySelector('.endscreen-replay').addEventListener('click', () => {
      remove(box);
      v.currentTime = 0;
      v.play().catch(() => {});
      v.focus();
    });

    box.appendChild(o);
    requestAnimationFrame(() => o.classList.add('on'));
    a.focus({ preventScroll: true });
  }

  /* "ended" steigt nicht auf, darum in der Capture-Phase am Dokument abfangen (deckt auch später erzeugte Videos ab) */
  document.addEventListener('ended', (e) => {
    const v = e.target;
    if (v instanceof HTMLVideoElement && v.controls && !v.loop) show(v);
  }, true);
  document.addEventListener('play', (e) => {
    const v = e.target;
    if (v instanceof HTMLVideoElement && v.parentElement) remove(v.parentElement);
  }, true);
})();
