/* ════════════════════════════════════════
   CINEMATIC MOTION LAYER
   ----------------------------------------
   Ergänzt main.js um gezielte Bewegung: weiches Scrollen (Lenis), Scroll-Animationen (GSAP + ScrollTrigger),
   Linsen-Effekte (Tiefe, Licht, Unschärfe) und interaktive Karten/Buttons.

   Grundsätze
   - Die Seite funktioniert komplett ohne diese Datei. Nichts hier ändert Texte oder Inhalte.
   - «Bewegung reduzieren»: Datei macht gar nichts.
   - Bibliotheken werden erst NACH dem Laden der Seite geholt (kein Einfluss auf LCP / erste Darstellung).
   - Datensparmodus / 2G: keine Bibliotheken, nur die leichten Maus-Effekte.
   - Weiches Scrollen und Maus-Effekte nur auf Desktop mit Maus.
   - Elemente, die beim Start schon sichtbar sind, werden nie versteckt (kein Flackern).
════════════════════════════════════════ */
(function () {
  'use strict';
  var me = document.currentScript;
  var mq = function (q) { return window.matchMedia(q).matches; };
  if (!me || mq('(prefers-reduced-motion: reduce)')) return;

  var conn = navigator.connection || {};
  var SAVE = !!conn.saveData || /(^|-)2g$/.test(conn.effectiveType || '');
  var FINE = mq('(hover: hover) and (pointer: fine)');
  var DESK = mq('(min-width: 900px)');
  var root = document.documentElement;
  var $$ = function (s, c) { return Array.prototype.slice.call((c || document).querySelectorAll(s)); };
  var lerp = function (a, b, t) { return a + (b - a) * t; };
  var clamp = function (v, a, b) { return Math.max(a, Math.min(b, v)); };

  /* ── 1. OHNE BIBLIOTHEK (nur Maus) ─────────────────────────── */
  if (FINE) {
    spotlight();
    magnets();
    if (DESK) heroLens();
    portfolioLens();
  }

  /* Spotlight-Karten: weiches Licht folgt dem Mauszeiger */
  function spotlight() {
    $$('.prob-item, .test-card, .srv-item, .contact-item, .mon-card, .grade-card, .g-rating').forEach(function (el) {
      el.classList.add('spot');
      el.addEventListener('pointermove', function (e) {
        var r = el.getBoundingClientRect();
        el.style.setProperty('--mx', (e.clientX - r.left) + 'px');
        el.style.setProperty('--my', (e.clientY - r.top) + 'px');
      }, { passive: true });
    });
  }

  /* Magnet-Buttons: folgen der Maus ein Stück (CSS-Eigenschaft «translate», damit Hover-Transforms bleiben) */
  function magnets() {
    $$('.cta-primary, .nav-pill, .reel-ring-outer, .nav-lang, .fsoc').forEach(function (el) {
      var tx = 0, ty = 0, x = 0, y = 0, raf = 0;
      var k = el.classList.contains('reel-ring-outer') ? 0.35 : 0.22;
      function step() {
        x = lerp(x, tx, 0.18); y = lerp(y, ty, 0.18);
        if (Math.abs(x - tx) < 0.05 && Math.abs(y - ty) < 0.05) { x = tx; y = ty; }
        el.style.translate = x.toFixed(2) + 'px ' + y.toFixed(2) + 'px';
        raf = (x !== tx || y !== ty) ? requestAnimationFrame(step) : 0;
      }
      el.addEventListener('pointermove', function (e) {
        var r = el.getBoundingClientRect();
        tx = clamp((e.clientX - (r.left + r.width / 2)) * k, -14, 14);
        ty = clamp((e.clientY - (r.top + r.height / 2)) * k, -10, 10);
        if (!raf) raf = requestAnimationFrame(step);
      }, { passive: true });
      el.addEventListener('pointerleave', function () { tx = 0; ty = 0; if (!raf) raf = requestAnimationFrame(step); });
    });
  }

  /* Hero: Tiefe (Ebenen bewegen sich unterschiedlich stark) + anamorphotischer Lens-Flare am Mauszeiger */
  function heroLens() {
    var hero = document.getElementById('hero');
    if (!hero) return;
    var bg = hero.querySelector('.hero-bg');
    var body = hero.querySelector('.hero-body');
    var flare = document.createElement('div');
    flare.className = 'hero-flare';
    flare.setAttribute('aria-hidden', 'true');
    flare.innerHTML = '<span class="hero-flare-streak"></span><span class="hero-flare-orb"></span><span class="hero-flare-ghost"></span>';
    hero.appendChild(flare);

    var w = 1, h = 1, mx = 0.5, my = 0.5, cx = 0.5, cy = 0.5, raf = 0, inView = true;
    function size() { var r = hero.getBoundingClientRect(); w = r.width || 1; h = r.height || 1; }
    size(); addEventListener('resize', size);
    new IntersectionObserver(function (es) { inView = es[0].isIntersecting; }).observe(hero);

    function step() {
      cx = lerp(cx, mx, 0.08); cy = lerp(cy, my, 0.08);
      var dx = cx - 0.5, dy = cy - 0.5;
      if (bg) bg.style.translate = (dx * -22).toFixed(2) + 'px ' + (dy * -14).toFixed(2) + 'px';
      if (body) body.style.translate = (dx * 10).toFixed(2) + 'px ' + (dy * 6).toFixed(2) + 'px';
      flare.style.setProperty('--fx', (cx * w).toFixed(1) + 'px');
      flare.style.setProperty('--fy', (cy * h).toFixed(1) + 'px');
      // Geisterbild spiegelt sich durch die Bildmitte (wie bei einem echten Objektiv)
      flare.style.setProperty('--gx', ((1 - cx) * w).toFixed(1) + 'px');
      flare.style.setProperty('--gy', ((1 - cy) * h).toFixed(1) + 'px');
      var done = Math.abs(cx - mx) < 0.0005 && Math.abs(cy - my) < 0.0005;
      raf = (!done && inView) ? requestAnimationFrame(step) : 0;
    }
    hero.addEventListener('pointermove', function (e) {
      var r = hero.getBoundingClientRect();
      mx = (e.clientX - r.left) / w; my = (e.clientY - r.top) / h;
      flare.classList.add('on');
      if (!raf) raf = requestAnimationFrame(step);
    }, { passive: true });
    hero.addEventListener('pointerleave', function () {
      flare.classList.remove('on'); mx = 0.5; my = 0.5;
      if (!raf) raf = requestAnimationFrame(step);
    });
  }

  /* Portfolio: Bild verschiebt sich leicht gegen die Maus (Tiefe) + Lichtreflex auf der «Linse» */
  function portfolioLens() {
    $$('.pf-cell').forEach(function (cell) {
      var bg = cell.querySelector('.pf-cell-bg');
      cell.addEventListener('pointermove', function (e) {
        var r = cell.getBoundingClientRect();
        var px = (e.clientX - r.left) / r.width, py = (e.clientY - r.top) / r.height;
        cell.style.setProperty('--gx', (px * 100).toFixed(1) + '%');
        cell.style.setProperty('--gy', (py * 100).toFixed(1) + '%');
        if (bg) bg.style.translate = ((px - 0.5) * -14).toFixed(1) + 'px ' + ((py - 0.5) * -10).toFixed(1) + 'px';
      }, { passive: true });
      cell.addEventListener('pointerleave', function () { if (bg) bg.style.translate = ''; });
    });
  }

  if (SAVE) return;

  /* ── 2. GSAP + SCROLLTRIGGER (+ LENIS) NACH DEM LADEN ─────── */
  var SMOOTH = FINE && DESK && !!me.dataset.lenis;
  function load(src) {
    return new Promise(function (res, rej) {
      var s = document.createElement('script');
      s.src = src; s.async = false; s.onload = res; s.onerror = rej;
      document.head.appendChild(s);
    });
  }
  function boot() {
    var list = [me.dataset.gsap, me.dataset.st];
    if (SMOOTH) list.push(me.dataset.lenis);
    if (!list[0] || !list[1]) return;
    Promise.all(list.map(load)).then(function () { afterScrollSettles(init); }).catch(function () { /* ohne Bibliothek bleibt die Seite wie sie ist */ });
  }
  /* Erst loslegen, wenn gerade nicht gescrollt wird: ScrollTrigger misst beim Start alle Positionen neu
     und würde einen laufenden Ankersprung (CSS smooth scroll) abbrechen. */
  function afterScrollSettles(fn) {
    var t = 0;
    function on() { clearTimeout(t); t = setTimeout(function () { removeEventListener('scroll', on); fn(); }, 250); }
    addEventListener('scroll', on, { passive: true });
    on();
  }

  /* Start erst bei der ersten Interaktion (Scrollen, Maus, Touch, Taste) – so bleibt das erste Laden
     unberührt. Desktop: spätestens 3.5 s nach dem Laden, damit die Effekte auch ohne Interaktion bereit sind. */
  var started = false;
  var EVTS = ['scroll', 'wheel', 'pointermove', 'touchstart', 'keydown'];
  function kick() {
    if (started) return; started = true;
    EVTS.forEach(function (ev) { removeEventListener(ev, kick, true); });
    ('requestIdleCallback' in window) ? requestIdleCallback(boot, { timeout: 800 }) : setTimeout(boot, 50);
  }
  function arm() {
    EVTS.forEach(function (ev) { addEventListener(ev, kick, { capture: true, passive: true }); });
    if (DESK) setTimeout(kick, 3500);
  }
  if (document.readyState === 'complete') arm();
  else addEventListener('load', arm, { once: true });

  function init() {
    var gsap = window.gsap, ST = window.ScrollTrigger;
    if (!gsap || !ST) return;
    gsap.registerPlugin(ST);
    root.classList.add('has-gsap');
    var vh = window.innerHeight;
    var below = function (el) { return el.getBoundingClientRect().top > vh * 0.92; };

    /* Weiches Scrollen (Lenis) */
    if (SMOOTH && window.Lenis) startLenis();
    function startLenis() {
      var lenis = new window.Lenis({ lerp: 0.1, smoothWheel: true, autoRaf: false });
      lenis.on('scroll', ST.update);
      gsap.ticker.add(function (t) { lenis.raf(t * 1000); });
      gsap.ticker.lagSmoothing(0);
      // Modal/Menü sperren den Body (overflow: hidden) → Lenis anhalten
      var sync = function () { document.body.style.overflow === 'hidden' ? lenis.stop() : lenis.start(); };
      new MutationObserver(sync).observe(document.body, { attributes: true, attributeFilter: ['style'] });
      // Ankerlinks weich anfahren; Fokus folgt (wichtig für «Zum Inhalt springen»)
      document.addEventListener('click', function (e) {
        var a = e.target.closest && e.target.closest('a[href^="#"]');
        if (!a || e.defaultPrevented || e.button !== 0 || e.metaKey || e.ctrlKey) return;
        var id = a.getAttribute('href').slice(1);
        var t = id && document.getElementById(id);
        if (!t) return;
        e.preventDefault();
        lenis.scrollTo(t, { offset: 0, duration: 1.4, easing: function (x) { return 1 - Math.pow(1 - x, 4); } });
        if (history.replaceState) history.replaceState(null, '', '#' + id);
        if (t.tabIndex >= 0 || t.hasAttribute('tabindex')) t.focus({ preventScroll: true });
      });
    }

    /* Scroll-Fortschritt: feine Bronze-Linie ganz oben */
    var bar = document.createElement('div');
    bar.className = 'scroll-progress'; bar.setAttribute('aria-hidden', 'true');
    document.body.appendChild(bar);
    gsap.to(bar, { scaleX: 1, ease: 'none', scrollTrigger: { start: 0, end: 'max', scrub: 0.3 } });

    /* Navigation: beim Runterscrollen ausblenden, beim Hochscrollen wieder da */
    var nav = document.getElementById('nav'), mnav = document.getElementById('mnav');
    if (nav) {
      ST.create({
        start: 0, end: 'max',
        onUpdate: function (s) {
          var hide = s.direction === 1 && s.scroll() > vh * 0.9 && !(mnav && mnav.classList.contains('on'));
          nav.classList.toggle('nav-hide', hide);
        }
      });
    }

    /* Hero: «Rack Focus» beim Wegscrollen – Bild zoomt in die Tiefe, Text verliert die Schärfe, Letterbox zieht zu */
    var hero = document.getElementById('hero');
    if (hero) {
      var tl = gsap.timeline({ defaults: { ease: 'none' }, scrollTrigger: { trigger: hero, start: 'top top', end: 'bottom top', scrub: true } });
      tl.to(hero.querySelector('.hero-bg'), { scale: 1.14, yPercent: 10 }, 0)
        .to(hero.querySelector('.hero-body'), DESK ? { yPercent: -18, opacity: 0, filter: 'blur(10px)' } : { yPercent: -12, opacity: 0 }, 0)
        .to(hero.querySelector('.lbox-t'), { scaleY: 1.7, transformOrigin: 'top' }, 0)
        .to(hero.querySelector('.lbox-b'), { scaleY: 1.7, transformOrigin: 'bottom' }, 0);
    }

    /* Überschriften: Wort für Wort aus der Unschärfe in den Fokus (wie React Bits «BlurText») */
    $$('.h-display').forEach(function (h) {
      if (!below(h) || h.closest('.contact-bg-text')) return;
      var words = splitWords(h);
      if (!words.length) return;
      h.removeAttribute('data-sr'); h.classList.add('vis');
      gsap.fromTo(words,
        DESK ? { opacity: 0, yPercent: 55, filter: 'blur(14px)' } : { opacity: 0, yPercent: 45 },
        { opacity: 1, yPercent: 0, filter: 'blur(0px)', duration: 1.15, ease: 'expo.out', stagger: 0.07,
          clearProps: 'filter', scrollTrigger: { trigger: h, start: 'top 86%', once: true } });
    });

    /* Bilder und Filmkacheln: «Blende öffnet sich» – Ausschnitt wächst, Bild zoomt zurück auf 100 % */
    var apSel = '.pf-mosaic .pf-cell, .about-main-img, .about-bts-img, .look-frame, .mon-card, .grade-card';
    var apEls = $$(apSel).filter(below);
    apEls.forEach(function (el) { el.classList.add('ap'); el.style.setProperty('--ap', '0'); });
    ST.batch(apEls, {
      start: 'top 90%', once: true,
      onEnter: function (els) {
        gsap.to(els, { '--ap': 1, duration: 1.6, ease: 'expo.out', stagger: 0.09,
          onComplete: function () { els.forEach(function (el) { el.classList.remove('ap'); el.style.removeProperty('--ap'); }); } });
      }
    });

    /* Ablauf & Karten: gestaffelt einblenden */
    var stag = $$('.proc-step, .faq-item').filter(below);
    if (stag.length) {
      gsap.set(stag, { opacity: 0, y: 36 });
      ST.batch(stag, { start: 'top 90%', once: true,
        onEnter: function (els) { gsap.to(els, { opacity: 1, y: 0, duration: 1, ease: 'expo.out', stagger: 0.08, clearProps: 'transform,opacity' }); } });
    }

    /* Tiefe beim Scrollen: Ebenen laufen unterschiedlich schnell */
    var bts = document.querySelector('.about-bts-img');
    if (bts && DESK) gsap.fromTo(bts, { yPercent: 14 }, { yPercent: -14, ease: 'none', scrollTrigger: { trigger: bts.parentNode, start: 'top bottom', end: 'bottom top', scrub: true } });
    var tag = document.querySelector('.about-data-tag');
    if (tag && DESK) gsap.fromTo(tag, { yPercent: 40 }, { yPercent: -60, ease: 'none', scrollTrigger: { trigger: tag.parentNode, start: 'top bottom', end: 'bottom top', scrub: true } });
    var cbg = document.querySelector('.contact-bg-text');
    if (cbg) gsap.fromTo(cbg, { xPercent: 8 }, { xPercent: -6, ease: 'none', scrollTrigger: { trigger: cbg.parentNode, start: 'top bottom', end: 'bottom top', scrub: true } });

    /* Laufbänder reagieren auf Scroll-Tempo und -Richtung (wie React Bits «ScrollVelocity») */
    var bands = $$('.ticker-track, .divider-marquee');
    var anims = bands.map(function (el) { return el.getAnimations ? el.getAnimations()[0] : null; }).filter(Boolean);
    var divider = document.querySelector('.divider-full');
    if (anims.length) {
      var vel = 0, rate = 1, dir = 1, skew = 0, last = 1;
      ST.create({ start: 0, end: 'max', onUpdate: function (s) { vel = s.getVelocity(); if (Math.abs(vel) > 40) dir = vel < 0 ? -1 : 1; } });
      gsap.ticker.add(function () {
        vel *= 0.9;
        var target = dir * (1 + Math.min(3.5, Math.abs(vel) / 700));
        rate = lerp(rate, target, 0.08);
        if (Math.abs(rate - last) > 0.01) { anims.forEach(function (a) { a.playbackRate = rate; }); last = rate; }
        var sk = clamp(-vel / 400, -8, 8);
        skew = lerp(skew, sk, 0.12);
        if (divider) divider.style.setProperty('--skew', skew.toFixed(2));
      });
    }

    /* Schriften/Bilder können Höhen verändern → Positionen neu berechnen */
    if (document.fonts && document.fonts.ready) document.fonts.ready.then(function () { ST.refresh(); });
  }

  /* Text in Wörter teilen, ohne Inhalt oder Struktur (Akzent-Spans, <br>) zu ändern */
  function splitWords(el) {
    var out = [];
    (function walk(node) {
      Array.prototype.slice.call(node.childNodes).forEach(function (n) {
        if (n.nodeType === 3) {
          if (!n.textContent.trim()) return;
          var frag = document.createDocumentFragment();
          n.textContent.split(/(\s+)/).forEach(function (p) {
            if (!p) return;
            if (/^\s+$/.test(p)) { frag.appendChild(document.createTextNode(p)); return; }
            var s = document.createElement('span');
            s.className = 'sw'; s.textContent = p;
            frag.appendChild(s); out.push(s);
          });
          n.parentNode.replaceChild(frag, n);
        } else if (n.nodeType === 1 && n.tagName !== 'BR') walk(n);
      });
    })(el);
    return out;
  }
})();
