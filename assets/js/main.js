/* EmailJS (Public Key ist für den Browser gedacht; in EmailJS die erlaubten Domains auf adfilms24.ch beschränken) */
if (window.emailjs) emailjs.init("mzeYAXh6J84HSDX5j");
const FINE_POINTER = window.matchMedia('(hover: hover) and (pointer: fine)').matches;
const REDUCED = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
/* ── LOADER – FILM COUNTDOWN ─── */
const loader = document.getElementById('loader');
const lcount = document.getElementById('lcount');
const marks  = document.querySelectorAll('.loader-mark');
const countVals = ['3','2','1','▶'];
let ci = 0;

function runCount() {
  lcount.style.animation = 'none';
  void lcount.offsetWidth;
  lcount.style.animation = 'countFlash .5s ease both';
  lcount.textContent = countVals[ci];
  // light up marks
  if (ci < marks.length) marks[ci].classList.add('lit');
  ci++;
  if (ci < countVals.length) setTimeout(runCount, 520);
  else setTimeout(() => loader.classList.add('exit'), 400);
}
setTimeout(runCount, 400);

/* ── CURSOR (nur Geräte mit Maus; Animationsschleife läuft nur während der Bewegung) ─── */
if (FINE_POINTER) {
  const dot  = document.getElementById('dot');
  const ring = document.getElementById('ring');
  let mx=0,my=0,rx=0,ry=0,raf=0;
  function tick() {
    rx += (mx-rx)*.15; ry += (my-ry)*.15;
    ring.style.left = rx+'px'; ring.style.top = ry+'px';
    raf = (Math.abs(mx-rx) > .3 || Math.abs(my-ry) > .3) ? requestAnimationFrame(tick) : 0;
  }
  document.addEventListener('mousemove', e => {
    mx = e.clientX; my = e.clientY;
    dot.style.left = mx+'px'; dot.style.top = my+'px';
    if (!raf) raf = requestAnimationFrame(tick);
  }, { passive: true });
  document.querySelectorAll('a, button, .pf-cell, .srv-item, .test-card, .contact-item, .gear-row').forEach(el => {
    el.addEventListener('mouseenter', () => ring.classList.add('big'));
    el.addEventListener('mouseleave', () => ring.classList.remove('big'));
  });
}

/* ── NAV PIN ─── */
const nav = document.getElementById('nav');
window.addEventListener('scroll', () => {
  nav.classList.toggle('pinned', window.scrollY > 70);
}, {passive:true});

/* ── MOBILE NAV ─── */
const mnav   = document.getElementById('mnav');
const burger = document.getElementById('burger');
function setMenu(open) {
  mnav.classList.toggle('on', open);
  burger.classList.toggle('x', open);
  burger.setAttribute('aria-expanded', String(open));
  burger.setAttribute('aria-label', open ? 'Menü schliessen' : 'Menü öffnen');
  if (open) mnav.removeAttribute('inert'); else mnav.setAttribute('inert', '');
  document.body.style.overflow = open ? 'hidden' : '';
}
function toggleM() { setMenu(!mnav.classList.contains('on')); }
function closeM() { setMenu(false); }
burger.addEventListener('click', toggleM);
document.querySelectorAll('.mnav-item').forEach(a => a.addEventListener('click', closeM));

/* ── SCROLL REVEAL ─── */
const srEls = document.querySelectorAll('[data-sr]');
const srObs = new IntersectionObserver(entries => {
  entries.forEach(e => {
    if (e.isIntersecting) { e.target.classList.add('vis'); srObs.unobserve(e.target); }
  });
}, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });
srEls.forEach(el => srObs.observe(el));

/* ── TIMECODE (nur sichtbar + Tab aktiv, ca. 10 Aktualisierungen pro Sekunde) ─── */
function pad(n) { return String(n).padStart(2,'0'); }
(function () {
  const tc = document.getElementById('tc');
  const hero = document.getElementById('hero');
  if (!tc || REDUCED) return;
  let timer = 0, visible = true;
  function draw() {
    const now = new Date();
    tc.textContent = `${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}:${pad(Math.floor(now.getMilliseconds()/41.7))}`;
  }
  function sync() {
    const run = visible && !document.hidden;
    if (run && !timer) { draw(); timer = setInterval(draw, 100); }
    if (!run && timer) { clearInterval(timer); timer = 0; }
  }
  new IntersectionObserver(es => { visible = es[0].isIntersecting; sync(); }).observe(hero);
  document.addEventListener('visibilitychange', sync);
  sync();
})();

/* ── PORTFOLIO FILTER ─── */
document.querySelectorAll('.pf-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    document.querySelectorAll('.pf-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    const f = btn.dataset.f;
    document.querySelectorAll('.pf-cell').forEach(c => {
      const show = f === 'all' || c.dataset.cat === f;
      c.style.opacity = show ? '1' : '0.15';
      c.style.pointerEvents = show ? 'auto' : 'none';
      c.style.transition = 'opacity 0.4s';
    });
  });
});

/* ── MODAL ─── */
const modalEl = document.getElementById('modal');
const modalVid = document.getElementById('modalVid');
const modalVidDefault = modalVid.innerHTML;
let lastFocus = null;

function playInModal(src, poster) {
  modalVid.innerHTML = '';
  const v = document.createElement('video');
  v.controls = true; v.autoplay = true; v.playsInline = true; v.preload = 'auto';
  v.poster = poster || '';
  v.setAttribute('controlslist', 'nodownload');
  const so = document.createElement('source'); so.src = src; so.type = 'video/mp4';
  v.appendChild(so);
  modalVid.appendChild(v);
  v.play().catch(() => {});
}
function fillModal(t, d, c, k, y) {
  document.getElementById('mT').textContent = t || '—';
  document.getElementById('mD').textContent = d || '—';
  document.getElementById('mC').textContent = c || '—';
  document.getElementById('mK').textContent = k || '—';
  document.getElementById('mY').textContent = y || '—';
}
function showModal() {
  lastFocus = document.activeElement;
  modalEl.classList.add('open');
  modalEl.setAttribute('aria-hidden', 'false');
  document.body.style.overflow = 'hidden';
  const cb = modalEl.querySelector('.modal-close'); if (cb) cb.focus();
}
function openModal(el) {
  fillModal(el.dataset.title, el.dataset.desc, el.dataset.client, el.dataset.cam, el.dataset.year);
  if (el.dataset.video) playInModal(el.dataset.video, el.dataset.poster);
  else { modalVid.innerHTML = modalVidDefault; document.getElementById('modalVidLabel').textContent = el.dataset.title; }
  showModal();
}
function closeModal() {
  if (!modalEl.classList.contains('open')) return;
  modalEl.classList.remove('open');
  modalEl.setAttribute('aria-hidden', 'true');
  document.body.style.overflow = '';
  const v = modalVid.querySelector('video'); if (v) { v.pause(); }
  setTimeout(() => { if (!modalEl.classList.contains('open')) modalVid.innerHTML = modalVidDefault; }, 450);
  if (lastFocus && lastFocus.focus) lastFocus.focus();
}
document.addEventListener('keydown', e => {
  if (!modalEl.classList.contains('open')) return;
  if (e.key === 'Escape') { closeModal(); return; }
  if (e.key === 'Tab') {            /* Fokus im Dialog halten */
    const f = [...modalEl.querySelectorAll('button, video[controls], a[href], [tabindex]:not([tabindex="-1"])')].filter(x => x.offsetParent !== null);
    if (!f.length) return;
    const first = f[0], last = f[f.length-1];
    if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
    else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
  }
});
document.getElementById('modalClose').addEventListener('click', closeModal);
document.getElementById('modalScrim').addEventListener('click', closeModal);
/* Portfolio-Karten (Klick + Tastatur) */
document.querySelectorAll('.pf-cell').forEach(c => {
  c.addEventListener('click', () => openModal(c));
  c.addEventListener('keydown', e => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); openModal(c); } });
});

/* ── SHOWREEL ─── */
function openShowreel() {
  fillModal('Showreel 2026', 'Ein Auszug aus meiner aktuellen Arbeit: Cinematography, Slow Motion und Bildsprache aus Zürich.', 'A.D.Films24', 'Sony FX3', '2026');
  playInModal('/assets/video/showreel.mp4', '/assets/video/showreel-poster.jpg');
  showModal();
}
document.getElementById('reelBtn').addEventListener('click', openShowreel);
document.getElementById('reelBtn2').addEventListener('click', openShowreel);

/* ── HERO VIDEO (nur Desktop, ohne Datensparmodus / reduzierte Bewegung) ─── */
(function () {
  const v = document.getElementById('heroVideo');
  if (!v) return;
  const conn = navigator.connection || {};
  const ok = window.matchMedia('(min-width: 900px)').matches &&
             !window.matchMedia('(prefers-reduced-motion: reduce)').matches &&
             !conn.saveData && !/(^|-)2g$/.test(conn.effectiveType || '');
  if (!ok) return;
  v.src = v.dataset.src;
  v.addEventListener('canplay', () => { v.classList.add('on'); v.play().catch(() => {}); }, { once: true });
  document.addEventListener('visibilitychange', () => { document.hidden ? v.pause() : v.play().catch(() => {}); });
  v.load();
})();

/* ── FORM ─── */
const SEND_LABEL = '<svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M1 6H11M6 1L11 6L6 11" stroke="currentColor" stroke-width="1.3"/></svg> Anfrage senden';
const MAIL = 'abdi.dhiblawe1@gmail.com';
const COOLDOWN_MS = 30000;
function setStatus(el, cls, html) { el.className = 'f-status ' + cls; el.innerHTML = html; }

function sendForm(e) {
  e.preventDefault();
  const form = e.target;
  const btn = document.getElementById('sendBtn');
  const st  = document.getElementById('formStatus');

  /* Spam-Schutz 1: Honeypot-Feld (Menschen sehen es nicht, Bots füllen es aus) */
  if (form.elements['website'] && form.elements['website'].value) { form.reset(); return; }

  /* Browser-Validierung mit Hinweis */
  if (!form.checkValidity()) { form.reportValidity(); return; }

  /* Spam-Schutz 2: Pause zwischen zwei Anfragen */
  let last = 0; try { last = +sessionStorage.getItem('adf24_last_send') || 0; } catch (_) {}
  const wait = COOLDOWN_MS - (Date.now() - last);
  if (wait > 0) { setStatus(st, 'err', `Bitte warte noch ${Math.ceil(wait/1000)} Sekunden, bevor du erneut sendest.`); return; }

  const fd = new FormData(form);
  const vorname = fd.get('vorname') || '';
  const nachname = fd.get('nachname') || '';
  const projekttyp = fd.get('projekttyp') || '';
  const templateParams = {
    name:        `${vorname} ${nachname}`.trim(),
    title:       projekttyp,
    email:       fd.get('email') || '',
    projekttyp:  projekttyp,
    nachricht:   fd.get('nachricht') || '',
  };

  btn.disabled = true;
  btn.innerHTML = '… Wird gesendet';
  setStatus(st, '', 'Deine Anfrage wird gesendet …');

  emailjs.send('service_3bk9u16', 'template_d87r2kf', templateParams)
    .then(() => {
      try { sessionStorage.setItem('adf24_last_send', String(Date.now())); } catch (_) {}
      btn.innerHTML = '✓ &nbsp;Gesendet!';
      btn.style.background = '#1a6b3a';
      setStatus(st, 'ok', 'Danke! Deine Anfrage ist angekommen. Ich melde mich so schnell wie möglich bei dir.');
      setTimeout(() => { btn.disabled = false; btn.innerHTML = SEND_LABEL; btn.style.background = ''; form.reset(); }, 3500);
    })
    .catch((err) => {
      console.error('EmailJS Fehler:', err);
      btn.disabled = false;
      btn.innerHTML = SEND_LABEL;
      setStatus(st, 'err', `Das Senden hat leider nicht geklappt. Bitte versuche es nochmals oder schreibe direkt an <a href="mailto:${MAIL}">${MAIL}</a> bzw. per <a href="https://wa.me/41767649300" target="_blank" rel="noopener">WhatsApp</a>.`);
    });
}
document.querySelector('.contact-form').addEventListener('submit', sendForm);
