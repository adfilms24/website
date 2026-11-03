/* Texte der aktuellen Sprache (kommen als JSON-Block aus der HTML-Seite) */
let I18N = {};
try { I18N = JSON.parse(document.getElementById('i18n').textContent); } catch (_) {}
const tr = (k, fb) => (I18N[k] !== undefined ? I18N[k] : fb);

const FINE_POINTER = window.matchMedia('(hover: hover) and (pointer: fine)').matches;
const REDUCED = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
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
  burger.setAttribute('aria-label', open ? (burger.dataset.labelClose || 'Close menu') : (burger.dataset.labelOpen || 'Open menu'));
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
  modalEl.inert = false;   /* geschlossen ist der Dialog für Tastatur und Screenreader gesperrt */
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
  modalEl.inert = true;
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
/* ── SHOWREEL ─── */
function openShowreel() {
  fillModal(tr('showreel_title','Showreel 2026'), tr('showreel_desc',''), tr('showreel_client','A.D.Films24'), tr('showreel_camera','Sony FX3'), tr('showreel_year','2026'));
  playInModal(tr('showreel_src', 'https://media.adfilms24.ch/assets/video/showreel.mp4'), tr('showreel_poster', '/assets/video/showreel-poster.webp'));
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
const SEND_LABEL = document.getElementById('sendBtn').innerHTML;
const MAIL = tr('mail', 'info@adfilms24.ch');
const COOLDOWN_MS = 30000;
function setStatus(el, cls, html) { el.className = 'f-status ' + cls; el.innerHTML = html; }

/* ── FORMULAR IN SCHRITTEN: Projektart → Budget & Zeit → Branche → Kontakt ───
   Ohne JavaScript bleiben alle Schritte sichtbar. */
const FormSteps = (function () {
  const form = document.querySelector('.contact-form');
  const steps = form ? [...form.querySelectorAll('.f-step')] : [];
  if (steps.length < 2) return { goTo() {}, reset() {}, stepOf() { return 0; } };
  const nav = form.querySelector('.f-nav');
  const back = form.querySelector('.f-back');
  const next = form.querySelector('.f-next');
  const prog = form.querySelector('.f-progress');
  const fields = (i) => [...steps[i].querySelectorAll('input, select, textarea')];
  let cur = 0;

  function goTo(i, focus) {
    cur = Math.max(0, Math.min(steps.length - 1, i));
    steps.forEach((s, k) => { s.hidden = k !== cur; });
    back.hidden = cur === 0;
    next.hidden = cur === steps.length - 1;
    prog.textContent = tr('step_of', 'Step {n} of {m}').replace('{n}', cur + 1).replace('{m}', steps.length);
    form.dataset.step = String(cur + 1);
    if (focus) {
      const first = fields(cur).find((el) => el.type !== 'hidden' && !el.closest('.hp'));
      const checked = steps[cur].querySelector('input[type=radio]:checked');
      (checked || first)?.focus({ preventScroll: true });
      const top = form.getBoundingClientRect().top + window.scrollY - 90;
      if (form.getBoundingClientRect().top < 60) window.scrollTo({ top, behavior: 'smooth' });
    }
  }
  function forward() {
    const bad = fields(cur).find((el) => !el.checkValidity());
    if (bad) { bad.reportValidity(); return; }
    goTo(cur + 1, true);
  }
  next.addEventListener('click', forward);
  back.addEventListener('click', () => goTo(cur - 1, true));
  // Projektart gewählt → gleich weiter
  steps[0].addEventListener('change', (e) => { if (e.target.name === 'projekttyp') setTimeout(forward, 180); });
  // Enter in einem Feld vor dem letzten Schritt: weiter statt absenden
  form.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && cur < steps.length - 1 && e.target.tagName !== 'TEXTAREA') { e.preventDefault(); forward(); }
  });
  nav.hidden = false;
  prog.hidden = false;
  goTo(0, false);
  return {
    goTo,
    reset: () => goTo(0, false),
    stepOf: (el) => Math.max(0, steps.findIndex((s) => s.contains(el))),
  };
})();

/* ── SPAM-SCHUTZ: unsichtbarer Check (Cloudflare Turnstile) ───
   /api/anfrage sagt, ob der Check eingerichtet ist. Erst wenn der Kontaktbereich näher kommt, wird
   das Skript von Cloudflare geladen. Der Server schickt die Anfrage per Resend an info@ und legt sie im CRM ab. */
const Guard = (function () {
  const form = document.querySelector('.contact-form');
  const SRC = 'https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit';
  let ready = null, box = null, widget = null, pending = null;

  function settle(ok, val) {
    if (!pending) return;
    const p = pending; pending = null; clearTimeout(p.timer);
    ok ? p.res(val) : p.rej(new Error(val || 'turnstile'));
  }
  function loadScript() {
    return new Promise((res, rej) => {
      if (window.turnstile) return res();
      const s = document.createElement('script');
      s.src = SRC; s.async = true; s.onload = res; s.onerror = () => rej(new Error('script'));
      document.head.appendChild(s);
    });
  }
  function render(sitekey) {
    box = document.createElement('div');
    box.className = 'f-check';
    form.querySelector('.f-send').appendChild(box);
    widget = window.turnstile.render(box, {
      sitekey,
      execution: 'execute',
      appearance: 'interaction-only',
      language: document.documentElement.lang || 'auto',
      callback: (t) => settle(true, t),
      'error-callback': (code) => { settle(false, 'error ' + code); return true; },
      'expired-callback': () => { try { window.turnstile.reset(widget); } catch (_) {} },
      'timeout-callback': () => settle(false, 'timeout'),
    });
  }
  function init() {
    if (ready) return ready;
    ready = fetch('/api/anfrage', { headers: { accept: 'application/json' } })
      .then((r) => (r.ok ? r.json() : { enabled: false }))
      .catch(() => ({ enabled: false }))
      .then((cfg) => {
        if (!cfg || !cfg.enabled || !cfg.sitekey) return false;
        return loadScript().then(() => { render(cfg.sitekey); return true; }).catch(() => 'blocked');
      });
    return ready;
  }
  function token() {
    return new Promise((res, rej) => {
      settle(false, 'restart');
      pending = { res, rej, timer: setTimeout(() => settle(false, 'timeout'), 45000) };
      try { window.turnstile.reset(widget); window.turnstile.execute(box); } catch (e) { settle(false, 'execute'); }
    });
  }
  if (form) {
    const section = document.getElementById('contact') || form;
    if ('IntersectionObserver' in window) {
      const io = new IntersectionObserver((es) => { if (es.some((x) => x.isIntersecting)) { io.disconnect(); init(); } }, { rootMargin: '800px 0px' });
      io.observe(section);
    } else init();
    form.addEventListener('focusin', init, { once: true });
  }
  return { init, token };
})();

function attributionData() {
  try { return JSON.parse(sessionStorage.getItem('adf24_attr') || '{}') || {}; } catch (_) { return {}; }
}

/* Schickt die Anfrage an /api/anfrage (mit Spam-Check). Wirft bei jedem Fehler, dann zeigt das Formular die Ausweichkontakte. */
async function sendViaServer(fd) {
  const token = await Guard.token();
  const fields = {};
  fd.forEach((v, k) => { if (typeof v === 'string') fields[k] = v; });
  const res = await fetch('/api/anfrage', {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ token, fields, attr: attributionData(), lang: document.documentElement.lang || 'de' }),
  });
  if (!res.ok) throw new Error('server ' + res.status);
  return 'ok';
}

async function sendForm(e) {
  e.preventDefault();
  const form = e.target;
  const btn = document.getElementById('sendBtn');
  const st  = document.getElementById('formStatus');

  /* Spam-Schutz 1: Honeypot-Feld (Menschen sehen es nicht, Bots füllen es aus) */
  if (form.elements['website'] && form.elements['website'].value) { form.reset(); return; }

  /* Browser-Validierung mit Hinweis */
  if (!form.checkValidity()) {
    const bad = form.querySelector('input:invalid, select:invalid, textarea:invalid');
    if (bad) { FormSteps.goTo(FormSteps.stepOf(bad)); bad.reportValidity(); } else form.reportValidity();
    return;
  }

  /* Spam-Schutz 2: Pause zwischen zwei Anfragen */
  let last = 0; try { last = +sessionStorage.getItem('adf24_last_send') || 0; } catch (_) {}
  const wait = COOLDOWN_MS - (Date.now() - last);
  if (wait > 0) { setStatus(st, 'err', tr('form_wait','Please wait {s} seconds.').replace('{s}', Math.ceil(wait/1000))); return; }

  const fd = new FormData(form);

  btn.disabled = true;
  btn.innerHTML = tr('form_sending','… Sending');
  setStatus(st, '', tr('form_sending_status','Sending …'));

  /* Spam-Schutz 3: unsichtbarer Check. Der Server übernimmt Mail und CRM. */
  let guarded = false;
  try { guarded = await Guard.init(); } catch (_) {}

  const sending = guarded === true ? sendViaServer(fd) : Promise.reject(new Error(guarded === 'blocked' ? 'check blocked' : 'check off'));

  sending
    .then(() => {
      try { sessionStorage.setItem('adf24_last_send', String(Date.now())); } catch (_) {}
      btn.innerHTML = tr('form_sent_btn','✓ Sent');
      btn.style.background = '#1a6b3a';
      setStatus(st, 'ok', tr('form_ok','Thank you!'));
      setTimeout(() => { btn.disabled = false; btn.innerHTML = SEND_LABEL; btn.style.background = ''; form.reset(); FormSteps.reset(); }, 3500);
    })
    .catch((err) => {
      console.error('Formular-Fehler:', err);
      btn.disabled = false;
      btn.innerHTML = SEND_LABEL;
      setStatus(st, 'err', tr('form_fail','Sending failed.').replace(/\{mail\}/g, MAIL));
    });
}
document.querySelector('.contact-form').addEventListener('submit', sendForm);

/* ── MOBILE: fixe Anfrage-Leiste (nach dem Hero, ausgeblendet im Kontaktbereich) ─── */
(() => {
  const bar = document.getElementById('stickyCta');
  const hero = document.getElementById('hero');
  const contact = document.getElementById('contact');
  if (!bar || !hero || !contact || !('IntersectionObserver' in window)) return;
  let heroVisible = true, contactVisible = false;
  const update = () => {
    const show = !heroVisible && !contactVisible;
    bar.classList.toggle('show', show);
    bar.inert = !show;
  };
  new IntersectionObserver(([e]) => { heroVisible = e.isIntersecting; update(); }).observe(hero);
  new IntersectionObserver(([e]) => { contactVisible = e.isIntersecting; update(); }).observe(contact);
})();

// Vorher/Nachher-Regler: S-Log3 gegen Rec.709
(function () {
  var frame = document.getElementById('lookFrame'), range = document.getElementById('lookRange');
  if (!frame || !range) return;
  var log = document.getElementById('lookLog'), g = document.getElementById('look709');
  range.addEventListener('input', function () { frame.style.setProperty('--pos', range.value + '%'); });
  document.querySelectorAll('.look-tab').forEach(function (b) {
    b.addEventListener('click', function () {
      var k = b.getAttribute('data-look');
      log.src = '/assets/img/look/' + k + '-log.webp'; g.src = '/assets/img/look/' + k + '-709.webp';
      document.querySelectorAll('.look-tab').forEach(function (x) { var on = x === b; x.classList.toggle('on', on); x.setAttribute('aria-pressed', on ? 'true' : 'false'); });
    });
  });
})();

/* ── Bilder unterhalb des Hero erst laden, wenn sie in die Nähe kommen ──
   Portfolio-Kacheln (data-bg) und Hintergrund von #process. Auf dem Handy bleibt so die Leitung frei für Schrift und Hero. */
function whenNear(el, fn, margin) {
  if (!('IntersectionObserver' in window)) { fn(); return; }
  const io = new IntersectionObserver(es => { if (es.some(x => x.isIntersecting)) { io.disconnect(); fn(); } }, { rootMargin: (margin || '600px') + ' 0px' });
  io.observe(el);
}
(function lazyBackgrounds() {
  document.querySelectorAll('.pf-cell-bg[data-bg]').forEach(el => whenNear(el, () => {
    el.style.backgroundImage = "linear-gradient(rgba(6,6,6,.25),rgba(6,6,6,.35)),url('" + el.dataset.bg + "')";
  }));
  const proc = document.getElementById('process');
  if (proc) whenNear(proc, () => proc.classList.add('bg-in'));
})();

/* ── MOTION: Play-Cursor, Hover-Clips im Portfolio, Scroll-Film ───
   Alles nur mit Maus, ohne «Bewegung reduzieren» und ohne Datensparmodus. Videos laden erst bei Bedarf. */
const LIGHT_DATA = (() => { const c = navigator.connection || {}; return !c.saveData && !/(^|-)2g$/.test(c.effectiveType || ''); })();

(function playCursor() {
  const ring = document.getElementById('ring');
  if (!FINE_POINTER || !ring) return;
  document.querySelectorAll('.pf-cell.featured, .pf-cell[data-preview], #reelBtn, #reelBtn2').forEach(el => {
    el.addEventListener('mouseenter', () => ring.classList.add('play'));
    el.addEventListener('mouseleave', () => ring.classList.remove('play'));
  });
})();

(function hoverClips() {
  if (!FINE_POINTER || REDUCED || !LIGHT_DATA) return;
  document.querySelectorAll('.pf-cell[data-preview]').forEach(cell => {
    let v = null, inside = false;
    cell.addEventListener('mouseenter', () => {
      inside = true;
      if (!v) {
        v = document.createElement('video');
        v.className = 'pf-preview';
        v.muted = true; v.loop = true; v.playsInline = true; v.preload = 'auto';
        v.setAttribute('aria-hidden', 'true'); v.tabIndex = -1;
        v.src = cell.dataset.preview;
        cell.querySelector('.pf-cell-bg').after(v);
      }
      v.play().then(() => { if (inside) cell.classList.add('previewing'); else v.pause(); }).catch(() => {});
    });
    cell.addEventListener('mouseleave', () => {
      inside = false;
      cell.classList.remove('previewing');
      if (v) setTimeout(() => { if (!inside) v.pause(); }, 600);
    });
  });
})();

(function scrollFilm() {
  const sec = document.getElementById('scrub');
  if (!sec) return;
  const v = sec.querySelector('.scrub-video');
  const words = sec.querySelectorAll('.scrub-word');
  const live = window.matchMedia('(min-width: 900px)').matches && !REDUCED && LIGHT_DATA;
  if (!live) {
    sec.classList.add('static');
    // Standbild: auf Hochkant-Bildschirmen reicht der Ausschnitt aus der Bildmitte (gleiche Schärfe, rund 40 % kleiner)
    const box = sec.querySelector('.scrub-sticky');
    const tall = box.clientWidth / Math.max(1, box.clientHeight) <= 0.92; // Ausschnitt ist 1000 × 1080 px
    whenNear(sec, () => { v.poster = (tall && v.dataset.posterM) || v.dataset.poster; });
    return;
  }
  v.poster = v.dataset.poster;

  let target = 0, cur = 0, raf = 0, dur = 0;
  const progress = () => {
    const r = sec.getBoundingClientRect();
    return Math.min(1, Math.max(0, -r.top / Math.max(1, r.height - innerHeight)));
  };
  function frame() {
    cur += (target - cur) * 0.14;
    if (Math.abs(target - cur) < 0.0004) cur = target;
    sec.style.setProperty('--p', cur.toFixed(4));
    if (dur && !v.seeking) {
      const t = Math.min(dur - 0.05, cur * dur);
      if (Math.abs(v.currentTime - t) > 0.02) v.currentTime = t;
    }
    words.forEach((w, i) => w.classList.toggle('on', cur > 0.18 + i * 0.22));
    raf = cur !== target ? requestAnimationFrame(frame) : 0;
  }
  const kick = () => { target = progress(); if (!raf) raf = requestAnimationFrame(frame); };

  // Video erst laden, wenn der Abschnitt näher kommt
  new IntersectionObserver((entries, obs) => {
    if (!entries[0].isIntersecting) return;
    obs.disconnect();
    v.src = v.dataset.src;
    v.addEventListener('loadedmetadata', () => { dur = v.duration || 0; kick(); }, { once: true });
    v.load();
  }, { rootMargin: '100% 0px' }).observe(sec);

  addEventListener('scroll', kick, { passive: true });
  addEventListener('resize', kick);
  kick();
})();
