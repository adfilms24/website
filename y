<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<meta name="description" content="Cinematographer & Content Creator — Visual storytelling für Brands, Events und Social Media. Basel, Zürich & International.">
<meta name="keywords" content="Cinematographer, Fotograf, Videograf, Content Creator, Commercial Video, Social Media, Drohne, Brand Films">
<meta name="author" content="Abdi Dhiblawe">
<title>www.adfilms24.ch — Cinematography & Direction</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<!-- Bebas Neue (brutal display) + Instrument Serif (editorial body) + JetBrains Mono (precision detail) -->
<link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Instrument+Serif:ital@0;1&family=JetBrains+Mono:wght@300;400;500&display=swap" rel="stylesheet">

<style>
/* ════════════════════════════════════════
   TOKEN SYSTEM
════════════════════════════════════════ */
:root {
  /* Palette: Near-black base, bone white text, grey accent */
  --void:        #060606;
  --deep-1:      #0e0e0e;
  --deep-2:      #161616;
  --deep-3:      #1f1f1f;
  --line:        rgba(255,255,255,0.08);
  --line-strong: rgba(255,255,255,0.16);
  --bone:        #EDE9E0;
  --bone-60:     rgba(237,233,224,0.6);
  --bone-25:     rgba(237,233,224,0.25);
  --bone-08:     rgba(237,233,224,0.08);
  --orange:      #777777;
  --orange-glow: rgba(119,119,119,0.15);
  --orange-faint: rgba(119,119,119,0.06);

  /* Type */
  --f-display: 'Bebas Neue', 'Arial Black', sans-serif;
  --f-serif:   'Instrument Serif', Georgia, serif;
  --f-mono:    'JetBrains Mono', 'Courier New', monospace;

  /* Motion */
  --swift:  cubic-bezier(0.22, 1, 0.36, 1);
  --spring: cubic-bezier(0.34, 1.56, 0.64, 1);
  --cinematic: cubic-bezier(0.16, 1, 0.3, 1);
}

/* ════════════════════════════════════════
   RESET + BASE
════════════════════════════════════════ */
*, *::before, *::after { margin:0; padding:0; box-sizing:border-box; }

html {
  scroll-behavior: smooth;
  overflow-x: hidden;
  font-size: 16px;
}

body {
  background: var(--void);
  color: var(--bone);
  font-family: var(--f-mono);
  -webkit-font-smoothing: antialiased;
  overflow-x: hidden;
  cursor: none;
}

::selection { background: var(--orange); color: var(--void); }
a { color: inherit; text-decoration: none; }
button { background: none; border: none; color: inherit; font-family: inherit; cursor: none; }
img, video { display: block; max-width: 100%; }

/* Password gate overlay */
.access-gate {
  position: fixed;
  inset: 0;
  display: none;
  align-items: center;
  justify-content: center;
  background: rgba(6,6,6,0.95);
  z-index: 10050;
  padding: 2rem;
  text-align: center;
}
.access-gate.active { display: flex; }
.access-gate-panel {
  width: min(520px, 100%);
  background: rgba(14,14,14,0.98);
  border: 1px solid rgba(255,255,255,0.08);
  padding: 2.5rem;
  border-radius: 12px;
  box-shadow: 0 40px 100px rgba(0,0,0,0.35);
}
.access-gate h2 {
  font-family: var(--f-display);
  font-size: clamp(2rem, 4vw, 3rem);
  margin-bottom: 1rem;
}
.access-gate p {
  color: var(--bone-60);
  margin-bottom: 1.8rem;
  line-height: 1.75;
}
.access-gate input {
  width: 100%;
  padding: 1rem 1rem;
  font-family: var(--f-mono);
  font-size: 0.95rem;
  border: 1px solid rgba(255,255,255,0.12);
  background: rgba(255,255,255,0.03);
  color: var(--bone);
  margin-bottom: 1rem;
}
.access-gate button {
  width: 100%;
  padding: 1rem 1rem;
  background: var(--orange);
  color: var(--void);
  text-transform: uppercase;
  letter-spacing: 0.18em;
  font-weight: 600;
}
.access-gate .gate-note {
  margin-top: 1rem;
  font-size: 0.85rem;
  color: var(--bone-25);
}

::-webkit-scrollbar { width: 2px; }
::-webkit-scrollbar-track { background: var(--void); }
::-webkit-scrollbar-thumb { background: var(--orange); }

/* ════════════════════════════════════════
   GRAIN + SCANLINES
════════════════════════════════════════ */
body::before {
  content: '';
  position: fixed;
  inset: 0;
  pointer-events: none;
  z-index: 9990;
  background: repeating-linear-gradient(
    0deg,
    transparent,
    transparent 2px,
    rgba(0,0,0,0.03) 2px,
    rgba(0,0,0,0.03) 4px
  );
  mix-blend-mode: multiply;
}

body::after {
  content: '';
  position: fixed;
  inset: 0;
  pointer-events: none;
  z-index: 9991;
  opacity: 0.022;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='250' height='250'%3E%3Cfilter id='g'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='250' height='250' filter='url(%23g)'/%3E%3C/svg%3E");
}

/* ════════════════════════════════════════
   CURSOR
════════════════════════════════════════ */
#dot {
  position: fixed;
  width: 5px; height: 5px;
  background: var(--orange);
  border-radius: 50%;
  pointer-events: none;
  z-index: 10000;
  transform: translate(-50%,-50%);
  transition: width .15s, height .15s;
}
#ring {
  position: fixed;
  width: 28px; height: 28px;
  border: 1px solid rgba(255,77,0,.5);
  border-radius: 50%;
  pointer-events: none;
  z-index: 9999;
  transform: translate(-50%,-50%);
  transition: width .35s var(--swift), height .35s var(--swift), border-color .3s;
}
#ring.big { width: 54px; height: 54px; border-color: var(--orange); }
#ring.text-mode {
  width: 72px; height: 72px;
  background: var(--orange);
  border-color: var(--orange);
  mix-blend-mode: difference;
}

/* ════════════════════════════════════════
   LOADER — FILM COUNTDOWN
════════════════════════════════════════ */
#loader {
  position: fixed;
  inset: 0;
  background: var(--void);
  z-index: 9000;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}
#loader.exit {
  animation: loaderExit 0.7s var(--swift) forwards;
}
@keyframes loaderExit {
  to { transform: translateY(-100%); }
}

.loader-inner {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 3rem;
}
.loader-count {
  font-family: var(--f-display);
  font-size: clamp(8rem, 25vw, 18rem);
  line-height: 0.85;
  color: var(--bone);
  letter-spacing: -0.02em;
  animation: countFlash .4s ease both;
}
@keyframes countFlash {
  0%   { opacity: 0; transform: scale(1.3); }
  20%  { opacity: 1; }
  80%  { opacity: 1; }
  100% { opacity: 0; transform: scale(0.8); }
}
.loader-progress {
  width: 240px;
  height: 1px;
  background: var(--line);
  position: relative;
  overflow: hidden;
}
.loader-progress-bar {
  position: absolute;
  inset: 0 100% 0 0;
  background: var(--orange);
  animation: progFill 2s var(--cinematic) 0.3s forwards;
}
@keyframes progFill { to { right: 0; } }
.loader-label {
  font-size: 0.55rem;
  letter-spacing: 0.3em;
  text-transform: uppercase;
  color: var(--bone-25);
}

/* Loader film markers */
.loader-marks {
  display: flex;
  gap: 0.4rem;
  position: absolute;
  bottom: 2rem;
}
.loader-mark {
  width: 20px; height: 14px;
  border: 1px solid var(--line-strong);
}
.loader-mark.lit { background: var(--orange-faint); border-color: var(--orange); }

/* ════════════════════════════════════════
   NAV
════════════════════════════════════════ */
#nav {
  position: fixed;
  inset: 0 0 auto 0;
  z-index: 800;
  padding: 2rem 3rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  transition: padding .4s var(--swift), border-color .4s;
  border-bottom: 1px solid transparent;
}
#nav.pinned {
  padding: 1.1rem 3rem;
  background: rgba(6,6,6,0.92);
  backdrop-filter: blur(20px) saturate(160%);
  border-color: var(--line);
}

.nav-logo {
  font-family: var(--f-display);
  font-size: 1.4rem;
  letter-spacing: 0.08em;
  color: var(--bone);
  transition: color .3s;
}
.nav-logo span { color: var(--orange); }

.nav-center {
  display: flex;
  gap: 2.5rem;
  list-style: none;
  position: absolute;
  left: 50%; transform: translateX(-50%);
}
.nav-center a {
  font-size: 0.6rem;
  font-weight: 400;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: var(--bone-60);
  transition: color .3s;
  position: relative;
  padding-bottom: 2px;
}
.nav-center a::after {
  content: '';
  position: absolute;
  bottom: 0; left: 50%; right: 50%;
  height: 1px;
  background: var(--orange);
  transition: left .3s var(--swift), right .3s var(--swift);
}
.nav-center a:hover { color: var(--bone); }
.nav-center a:hover::after { left: 0; right: 0; }

.nav-right {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}
.nav-pill {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.55rem 1.4rem;
  border: 1px solid var(--line-strong);
  font-size: 0.58rem;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  color: var(--bone);
  transition: all .3s;
  position: relative;
  overflow: hidden;
}
.nav-pill::before {
  content: '';
  position: absolute;
  inset: 0;
  background: var(--orange);
  transform: scaleX(0);
  transform-origin: left;
  transition: transform .3s var(--swift);
}
.nav-pill:hover { color: var(--void); border-color: var(--orange); }
.nav-pill:hover::before { transform: scaleX(1); }
.nav-pill span { position: relative; z-index: 1; }
.nav-dot {
  width: 6px; height: 6px;
  background: var(--orange);
  border-radius: 50%;
  display: inline-block;
  animation: dotPulse 2s ease-in-out infinite;
}
@keyframes dotPulse {
  0%,100% { opacity: 1; }
  50% { opacity: 0.3; }
}

/* Burger */
.burger {
  display: none;
  flex-direction: column;
  gap: 5px;
}
.burger b {
  display: block;
  height: 1px;
  background: var(--bone);
  transition: all .35s var(--swift);
}
.burger b:nth-child(1) { width: 28px; }
.burger b:nth-child(2) { width: 18px; }
.burger b:nth-child(3) { width: 24px; }
.burger.x b:nth-child(1) { width: 28px; transform: rotate(45deg) translate(4px,4px); }
.burger.x b:nth-child(2) { opacity: 0; width: 0; }
.burger.x b:nth-child(3) { width: 28px; transform: rotate(-45deg) translate(4px,-4px); }

/* Mobile overlay */
#mnav {
  position: fixed;
  inset: 0;
  background: var(--deep-1);
  z-index: 799;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  opacity: 0;
  pointer-events: none;
  transition: opacity .4s;
}
#mnav.on { opacity: 1; pointer-events: all; }
.mnav-item {
  font-family: var(--f-display);
  font-size: clamp(3.5rem, 12vw, 7rem);
  letter-spacing: 0.05em;
  color: var(--bone-25);
  transition: color .3s, transform .3s var(--spring);
  display: block;
  line-height: 1;
}
.mnav-item:hover { color: var(--bone); transform: translateX(10px); }
.mnav-item span { color: var(--orange); }
.mnav-bottom {
  position: absolute;
  bottom: 2.5rem;
  left: 3rem;
  font-size: 0.55rem;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  color: var(--bone-25);
}

/* ════════════════════════════════════════
   HERO
════════════════════════════════════════ */
#hero {
  position: relative;
  height: 100dvh;
  min-height: 600px;
  overflow: hidden;
  display: grid;
  grid-template-rows: 1fr auto;
}

/* BG */
.hero-bg {
  position: absolute;
  inset: 0;
  z-index: 0;
}
.hero-bg video { width:100%; height:100%; object-fit:cover; }
.hero-bg-ph {
  width: 100%; height: 100%;
  background:
    radial-gradient(ellipse at 15% 50%, rgba(255,77,0,0.07) 0%, transparent 45%),
    radial-gradient(ellipse at 85% 20%, rgba(237,233,224,0.03) 0%, transparent 40%),
    linear-gradient(175deg, #0c0a08 0%, #060606 45%, #08060e 100%);
}

/* Cinematic letterbox bars — wider on desktop */
.lbox-t, .lbox-b {
  position: absolute;
  left: 0; right: 0;
  background: var(--void);
  z-index: 2;
  pointer-events: none;
}
.lbox-t { top: 0; height: 12%; }
.lbox-b { bottom: 0; height: 12%; }

/* Vignette */
.hero-vgn {
  position: absolute; inset: 0; z-index: 1;
  background: linear-gradient(
    to bottom,
    transparent 15%,
    transparent 50%,
    rgba(6,6,6,0.7) 80%,
    var(--void) 100%
  );
}

/* Side vignette */
.hero-vgn-side {
  position: absolute; inset: 0; z-index: 1;
  background: linear-gradient(
    to right,
    rgba(6,6,6,0.6) 0%,
    transparent 30%,
    transparent 70%,
    rgba(6,6,6,0.4) 100%
  );
}

/* Film perforations (cinematic detail) */
.perfs {
  position: absolute;
  top: 0; left: 0; bottom: 0;
  width: 28px;
  z-index: 3;
  display: flex;
  flex-direction: column;
  justify-content: space-evenly;
  padding: 14% 0;
}
.perf {
  width: 14px; height: 20px;
  border: 1px solid var(--line-strong);
  margin: 0 auto;
  background: var(--void);
}
.perfs-r {
  left: auto; right: 0;
}

/* Timecode */
.timecode {
  position: absolute;
  top: 14%; right: 3rem;
  z-index: 4;
  font-size: 0.9  rem;
  font-weight: 300;
  letter-spacing: 0.12em;
  color: var(--orange);
  opacity: 0.7;
}

/* Hero content grid */
.hero-body {
  position: relative;
  z-index: 4;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  padding: 0 4rem 5rem 5rem;
  max-width: 1600px;
  width: 100%;
  margin: 0 auto;
  align-self: end;
}

.hero-eyebrow {
  font-size: 0.55rem;
  font-weight: 400;
  letter-spacing: 0.32em;
  text-transform: uppercase;
  color: var(--orange);
  margin-bottom: 1.2rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  opacity: 0;
  animation: riseUp .8s var(--swift) 2.2s both;
}
.hero-eyebrow-line {
  width: 40px; height: 1px;
  background: var(--orange);
}

.hero-h1 {
  font-family: var(--f-display);
  font-size: clamp(5.5rem, 14vw, 15rem);
  letter-spacing: -0.01em;
  line-height: 0.86;
  overflow: hidden;
}
.h1-row {
  overflow: hidden;
  display: block;
}
.h1-inner {
  display: block;
  transform: translateY(105%);
  animation: lineUp 1s var(--swift) both;
}
.h1-row:nth-child(1) .h1-inner { animation-delay: 2.3s; }
.h1-row:nth-child(2) .h1-inner { animation-delay: 2.42s; color: var(--orange); }

.hero-sub-row {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 3rem;
  margin-top: 2.5rem;
  opacity: 0;
  animation: riseUp .8s var(--swift) 2.7s both;
}
.hero-desc {
  font-family: var(--f-serif);
  font-style: italic;
  font-size: clamp(1rem, 1.6vw, 1.3rem);
  color: var(--bone-60);
  max-width: 380px;
  line-height: 1.7;
}
.hero-actions { display: flex; gap: 1rem; align-items: center; flex-shrink: 0; }

/* CTAs */
.cta-primary {
  display: inline-flex; align-items: center; gap: .7rem;
  padding: 1rem 2.4rem;
  background: var(--orange);
  color: var(--void);
  font-size: 0.65rem;
  font-weight: 500;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  transition: transform .3s var(--spring), box-shadow .3s;
}
.cta-primary:hover {
  transform: translateY(-3px);
  box-shadow: 0 20px 50px rgba(255,77,0,0.35);
}

.cta-ghost {
  display: inline-flex; align-items: center; gap: .7rem;
  padding: 1rem 2rem;
  border: 1px solid var(--line-strong);
  color: var(--bone-60);
  font-size: 0.62rem;
  font-weight: 400;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  transition: all .3s var(--swift);
}
.cta-ghost:hover { border-color: var(--bone); color: var(--bone); transform: translateY(-3px); }

/* Showreel floating trigger */
.reel-trigger {
  position: absolute;
  bottom: 42%; left: 50%;
  transform: translateX(-50%);
  z-index: 5;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
  opacity: 0;
  animation: fadeIn .8s ease 3s both;
}
.reel-ring-outer {
  width: 90px; height: 90px;
  border: 1px solid var(--line-strong);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  transition: border-color .3s, transform .5s var(--spring);
}
.reel-ring-outer:hover { border-color: var(--orange); transform: scale(1.1); }
.reel-ring-spin {
  position: absolute;
  inset: 6px;
  border-radius: 50%;
  border: 1px dashed rgba(255,77,0,0.3);
  animation: spin 8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }
.reel-icon { font-size: 1.5rem; }
.reel-caption {
  font-size: 0.52rem;
  letter-spacing: 0.28em;
  text-transform: uppercase;
  color: var(--bone-25);
}

/* Scroll hint */
.hero-scroll {
  position: absolute;
  bottom: 15%; right: 3.5rem;
  z-index: 4;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: .8rem;
  opacity: 0;
  animation: fadeIn .8s ease 3.2s both;
}
.scroll-word {
  font-size: 0.5rem;
  letter-spacing: 0.28em;
  text-transform: uppercase;
  color: var(--bone-25);
  writing-mode: vertical-lr;
}
.scroll-line-track {
  width: 1px; height: 56px;
  background: var(--line-strong);
  position: relative; overflow: hidden;
}
.scroll-line-fill {
  position: absolute;
  width: 1px; height: 10px;
  background: var(--orange);
  animation: scrollAnim 2s ease-in-out infinite;
}
@keyframes scrollAnim {
  0%   { top: -10px; opacity: 0; }
  30%  { opacity: 1; }
  100% { top: 100%; opacity: 0; }
}

/* ════════════════════════════════════════
   SECTION LAYOUT
════════════════════════════════════════ */
.wrap { max-width: 1440px; margin: 0 auto; padding: 0 3rem; }
.section { padding: clamp(5rem, 10vw, 10rem) 3rem; }

/* Section label + title pattern */
.s-meta {
  font-size: 0.52rem;
  font-weight: 400;
  letter-spacing: 0.28em;
  text-transform: uppercase;
  color: var(--orange);
  display: flex;
  align-items: center;
  gap: 0.8rem;
  margin-bottom: 1rem;
}
.s-meta::before { content: ''; width: 24px; height: 1px; background: var(--orange); }

/* Big display heading */
.h-display {
  font-family: var(--f-display);
  font-size: clamp(3.5rem, 7vw, 8rem);
  letter-spacing: 0.01em;
  line-height: 0.92;
}
.h-display .accent { color: var(--orange); }
.h-display .serif {
  font-family: var(--f-serif);
  font-style: italic;
  font-weight: 400;
  color: var(--bone-60);
  font-size: 0.65em;
  letter-spacing: 0;
}

/* ════════════════════════════════════════
   INTRO BAND
════════════════════════════════════════ */
.intro-band {
  background: var(--deep-1);
  border-top: 1px solid var(--line);
  border-bottom: 1px solid var(--line);
  overflow: hidden;
  padding: 1.4rem 0;
}
.ticker-track {
  display: flex;
  width: max-content;
  animation: tickScroll 18s linear infinite;
  gap: 0;
}
@keyframes tickScroll { to { transform: translateX(-50%); } }
.tick {
  display: flex; align-items: center; gap: 2.5rem;
  padding: 0 3rem;
  font-size: 0.6rem;
  font-weight: 400;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: var(--bone-25);
  white-space: nowrap;
}
.tick .hi { color: var(--bone-60); font-weight: 500; }
.tick-sep { color: var(--orange); font-size: 0.5rem; }

/* ════════════════════════════════════════
   COUNTERS
════════════════════════════════════════ */
.counters {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  border: 1px solid var(--line);
}
.ctr {
  padding: 3.5rem 2.5rem;
  border-right: 1px solid var(--line);
  position: relative;
  overflow: hidden;
  transition: background .35s;
}
.ctr:last-child { border-right: none; }
.ctr:hover { background: var(--bone-08); }
.ctr::before {
  content: attr(data-n);
  position: absolute;
  top: -0.1em; right: -0.05em;
  font-family: var(--f-display);
  font-size: 7rem;
  color: var(--line);
  line-height: 1;
  pointer-events: none;
  user-select: none;
}
.ctr-val {
  font-family: var(--f-display);
  font-size: clamp(3rem, 5vw, 5rem);
  line-height: 1;
  color: var(--bone);
  display: flex;
  align-items: baseline;
  gap: 2px;
}
.ctr-val sup { font-size: 35%; color: var(--orange); margin-bottom: 0.4em; }
.ctr-lbl {
  margin-top: 0.8rem;
  font-size: 0.55rem;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: var(--bone-25);
}

/* ════════════════════════════════════════
   PORTFOLIO
════════════════════════════════════════ */
#portfolio { background: var(--void); }

.pf-controls {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  margin-bottom: 3rem;
  gap: 2rem;
  flex-wrap: wrap;
}
.pf-filters { display: flex; gap: 0.3rem; flex-wrap: wrap; }
.pf-btn {
  font-size: 0.56rem;
  font-weight: 400;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  padding: 0.5rem 1rem;
  border: 1px solid var(--line);
  color: var(--bone-25);
  background: transparent;
  transition: all .25s;
}
.pf-btn.active, .pf-btn:hover { border-color: var(--orange); color: var(--orange); }

/* Unusual asymmetric grid */
.pf-mosaic {
  display: grid;
  grid-template-columns: repeat(10, 1fr);
  grid-auto-rows: 220px;
  gap: 2px;
}
.pf-cell { position: relative; overflow: hidden; background: var(--deep-2); }

/* Grid placement rules */
.pf-cell[data-size="xl"] { grid-column: span 6; grid-row: span 2; }
.pf-cell[data-size="tall"] { grid-column: span 4; grid-row: span 2; }
.pf-cell[data-size="wide"] { grid-column: span 5; }
.pf-cell[data-size="std"] { grid-column: span 3; }
.pf-cell[data-size="sq"] { grid-column: span 4; }

/* Gradient fills */
.bg-a { background: linear-gradient(150deg, #1a0e06 0%, #0a0808 100%); }
.bg-b { background: linear-gradient(150deg, #060e1a 0%, #060606 100%); }
.bg-c { background: linear-gradient(150deg, #1a0606 0%, #060606 100%); }
.bg-d { background: linear-gradient(150deg, #06140e 0%, #060606 100%); }
.bg-e { background: linear-gradient(150deg, #100a16 0%, #060606 100%); }
.bg-f { background: linear-gradient(150deg, #141008 0%, #060606 100%); }

.pf-cell-bg {
  position: absolute; inset: 0;
  display: flex; align-items: center; justify-content: center;
  transition: transform 1.1s var(--cinematic);
}
.pf-cell:hover .pf-cell-bg { transform: scale(1.07); }

.pf-glyph {
  font-family: var(--f-display);
  font-size: 9rem;
  color: var(--bone);
  opacity: 0.03;
  user-select: none;
  pointer-events: none;
}

.pf-overlay {
  position: absolute; inset: 0;
  background: linear-gradient(to top, rgba(6,6,6,0.97) 0%, rgba(6,6,6,0.3) 55%, transparent 100%);
  display: flex; flex-direction: column; justify-content: flex-end;
  padding: 1.6rem;
  opacity: 0;
  transform: translateY(4px);
  transition: opacity .4s, transform .4s var(--swift);
}
.pf-cell:hover .pf-overlay { opacity: 1; transform: translateY(0); }

.pf-tag {
  font-size: 0.5rem;
  font-weight: 500;
  letter-spacing: 0.24em;
  text-transform: uppercase;
  color: var(--orange);
  margin-bottom: 0.4rem;
}
.pf-title {
  font-family: var(--f-display);
  font-size: clamp(1.2rem, 2.5vw, 2rem);
  letter-spacing: 0.02em;
  line-height: 1.05;
  color: var(--bone);
}
.pf-caret {
  position: absolute;
  top: 1.2rem; right: 1.2rem;
  width: 36px; height: 36px;
  border: 1px solid var(--line-strong);
  display: flex; align-items: center; justify-content: center;
  opacity: 0;
  transform: scale(0.6) rotate(-45deg);
  transition: opacity .35s, transform .4s var(--spring), border-color .3s;
}
.pf-cell:hover .pf-caret { opacity: 1; transform: scale(1) rotate(0deg); border-color: var(--orange); }

/* ════════════════════════════════════════
   DIVIDER — FULL BLEED TEXT
════════════════════════════════════════ */
.divider-full {
  overflow: hidden;
  border-top: 1px solid var(--line);
  border-bottom: 1px solid var(--line);
  background: var(--deep-1);
  padding: 1.2rem 0;
  white-space: nowrap;
}
.divider-marquee {
  display: inline-flex;
  animation: tickScroll 14s linear infinite;
  gap: 0;
}
.dm-item {
  font-family: var(--f-display);
  font-size: clamp(2.5rem, 5vw, 4.5rem);
  letter-spacing: 0.04em;
  color: var(--bone-08);
  padding: 0 2rem;
  flex-shrink: 0;
}
.dm-item .o { color: var(--orange); }

/* ════════════════════════════════════════
   ABOUT
════════════════════════════════════════ */
#about { background: var(--deep-1); position: relative; }

.about-layout {
  display: grid;
  grid-template-columns: 5fr 7fr;
  gap: 5rem;
  align-items: start;
}

.about-img-col { position: relative; }

.about-main-img {
  aspect-ratio: 3/4;
  background: var(--deep-2);
  position: relative;
  overflow: hidden;
}
.about-main-img-inner {
  width: 100%; height: 100%;
  background: linear-gradient(160deg, #1a0e06, #0e0e0e);
  display: flex; align-items: center; justify-content: center;
}
.about-main-img-inner span {
  font-family: var(--f-display);
  font-size: 12rem;
  color: var(--bone);
  opacity: 0.03;
}
/* Overlay corner markers */
.about-main-img::before, .about-main-img::after {
  content: '';
  position: absolute;
  width: 20px; height: 20px;
  border-color: var(--orange);
  border-style: solid;
}
.about-main-img::before { top: 1rem; left: 1rem; border-width: 1px 0 0 1px; }
.about-main-img::after  { bottom: 1rem; right: 1rem; border-width: 0 1px 1px 0; }

.about-bts-img {
  position: absolute;
  top: auto; bottom: -3rem; right: -3rem;
  width: 55%;
  aspect-ratio: 1;
  background: var(--deep-3);
  border: 4px solid var(--deep-1);
  overflow: hidden;
}
.about-bts-img-inner {
  width: 100%; height: 100%;
  background: linear-gradient(135deg, #0e1418, #060606);
  display: flex; align-items: center; justify-content: center;
}
.about-bts-img-inner span {
  font-family: var(--f-display);
  font-size: 5rem;
  color: var(--bone);
  opacity: 0.04;
}

.about-data-tag {
  position: absolute;
  top: 3rem; left: -1.5rem;
  background: var(--orange);
  color: var(--void);
  padding: 0.8rem 1.2rem;
  writing-mode: vertical-rl;
  font-size: 0.52rem;
  font-weight: 500;
  letter-spacing: 0.22em;
  text-transform: uppercase;
}

/* About text */
.about-text-col { padding-top: 1rem; }

.about-bio {
  font-family: var(--f-serif);
  font-size: clamp(1.05rem, 1.4vw, 1.2rem);
  line-height: 1.9;
  color: var(--bone-60);
  margin-top: 2.5rem;
}
.about-bio + .about-bio { margin-top: 1.2rem; }
.about-bio strong { color: var(--bone); font-style: italic; font-weight: 400; }

/* Gear table */
.gear-head {
  margin-top: 4rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--line);
  font-size: 0.52rem;
  font-weight: 500;
  letter-spacing: 0.28em;
  text-transform: uppercase;
  color: var(--orange);
}
.gear-rows {}
.gear-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 0;
  border-bottom: 1px solid var(--line);
  transition: padding-left .3s var(--swift);
}
.gear-row:hover { padding-left: 0.5rem; }
.gear-name { font-size: 0.82rem; color: var(--bone); font-weight: 400; }
.gear-type {
  font-size: 0.52rem;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  color: var(--orange);
}

/* ════════════════════════════════════════
   SERVICES
════════════════════════════════════════ */
#services { background: var(--void); }

.srv-header {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 4rem;
  align-items: flex-end;
  margin-bottom: 5rem;
}
.srv-header-desc {
  font-family: var(--f-serif);
  font-style: italic;
  font-size: 1.1rem;
  color: var(--bone-60);
  line-height: 1.85;
  align-self: flex-end;
  padding-bottom: 0.3rem;
}

/* Numbered service list — editorial style */
.srv-list-editorial { border-top: 1px solid var(--line); }
.srv-item {
  display: grid;
  grid-template-columns: 80px 1fr 1fr auto;
  align-items: center;
  gap: 3rem;
  padding: 2.8rem 0;
  border-bottom: 1px solid var(--line);
  transition: background .3s;
  position: relative;
  overflow: hidden;
}
.srv-item::before {
  content: '';
  position: absolute;
  left: 0; top: 0; bottom: 0;
  width: 0;
  background: var(--orange-faint);
  transition: width .5s var(--swift);
}
.srv-item:hover { background: var(--bone-08); }
.srv-item:hover::before { width: 100%; }

.srv-num {
  font-family: var(--f-display);
  font-size: 3rem;
  color: var(--line-strong);
  line-height: 1;
  transition: color .3s;
  position: relative;
}
.srv-item:hover .srv-num { color: var(--orange); }

.srv-name {
  font-family: var(--f-display);
  font-size: clamp(1.5rem, 3vw, 2.5rem);
  letter-spacing: 0.02em;
  line-height: 1;
  position: relative;
}
.srv-name em {
  display: block;
  font-family: var(--f-serif);
  font-style: italic;
  font-size: 0.5em;
  letter-spacing: 0;
  color: var(--bone-60);
  font-weight: 400;
  margin-top: 0.3rem;
}

.srv-tags {
  display: flex;
  gap: 0.4rem;
  flex-wrap: wrap;
  position: relative;
}
.srv-tag {
  font-size: 0.52rem;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  padding: 0.3rem 0.7rem;
  border: 1px solid var(--line);
  color: var(--bone-25);
  transition: all .3s;
}
.srv-item:hover .srv-tag { border-color: var(--orange-faint); color: var(--bone-60); }

.srv-arrow {
  position: relative;
  width: 44px; height: 44px;
  border: 1px solid var(--line);
  display: flex; align-items: center; justify-content: center;
  transition: all .35s var(--spring);
  flex-shrink: 0;
}
.srv-item:hover .srv-arrow {
  border-color: var(--orange);
  background: var(--orange);
  transform: rotate(45deg) scale(1.1);
}

/* ════════════════════════════════════════
   TESTIMONIALS
════════════════════════════════════════ */
#testimonials { background: var(--deep-1); }

.test-layout {
  display: grid;
  grid-template-columns: 1fr 2fr;
  gap: 6rem;
  align-items: start;
}
.test-sidebar {
  position: sticky;
  top: 8rem;
}
.test-sidebar .s-meta { margin-bottom: 1.5rem; }
.test-stat {
  margin-top: 3rem;
  padding-top: 3rem;
  border-top: 1px solid var(--line);
}
.ts-num {
  font-family: var(--f-display);
  font-size: 5rem;
  line-height: 1;
  color: var(--bone);
}
.ts-num sup { font-size: 35%; color: var(--orange); }
.ts-label { font-size: 0.52rem; letter-spacing: 0.22em; text-transform: uppercase; color: var(--bone-25); margin-top: 0.5rem; }

.test-cards-col { display: flex; flex-direction: column; gap: 2px; }

.test-card {
  background: var(--deep-2);
  padding: 3rem;
  position: relative;
  transition: background .3s;
  border-left: 2px solid transparent;
}
.test-card:hover { background: var(--deep-3); border-left-color: var(--orange); }

.test-q {
  font-family: var(--f-display);
  font-size: 4rem;
  color: var(--orange);
  opacity: 0.18;
  line-height: 0.6;
  margin-bottom: 1.5rem;
  display: block;
}
.test-body {
  font-family: var(--f-serif);
  font-style: italic;
  font-size: clamp(0.95rem, 1.3vw, 1.1rem);
  line-height: 1.85;
  color: var(--bone);
  margin-bottom: 2rem;
}
.test-foot {
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.test-author-info {}
.test-author-name {
  font-size: 0.78rem;
  font-weight: 500;
  color: var(--bone);
  letter-spacing: 0.05em;
}
.test-author-role {
  font-size: 0.52rem;
  letter-spacing: 0.18em;
  text-transform: uppercase;
  color: var(--bone-25);
  margin-top: 0.2rem;
}
.test-stars { display: flex; gap: 3px; }
.star { width: 10px; height: 10px; background: var(--orange); clip-path: polygon(50% 0%, 61% 35%, 98% 35%, 68% 57%, 79% 91%, 50% 70%, 21% 91%, 32% 57%, 2% 35%, 39% 35%); }

/* Clients */
.clients-strip {
  margin-top: 6rem;
  padding-top: 4rem;
  border-top: 1px solid var(--line);
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 2rem;
  flex-wrap: wrap;
}
.client-logo {
  font-family: var(--f-display);
  font-size: 1.1rem;
  letter-spacing: 0.14em;
  color: var(--bone-25);
  transition: color .3s;
}
.client-logo:hover { color: var(--bone-60); }

/* ════════════════════════════════════════
   CONTACT
════════════════════════════════════════ */
#contact { background: var(--void); position: relative; overflow: hidden; }

/* Big background text */
.contact-bg-text {
  position: absolute;
  bottom: -3rem; right: -2rem;
  font-family: var(--f-display);
  font-size: clamp(8rem, 20vw, 18rem);
  color: var(--line);
  letter-spacing: -0.02em;
  pointer-events: none;
  user-select: none;
  line-height: 1;
}

.contact-layout {
  display: grid;
  grid-template-columns: 5fr 7fr;
  gap: 6rem;
  position: relative;
  z-index: 1;
}

.contact-info {}
.contact-tagline {
  font-family: var(--f-serif);
  font-style: italic;
  font-size: clamp(1rem, 1.5vw, 1.3rem);
  color: var(--bone-60);
  line-height: 1.8;
  margin-top: 2rem;
  margin-bottom: 4rem;
}
.contact-links { display: flex; flex-direction: column; gap: 1px; }
.contact-item {
  display: flex;
  align-items: center;
  gap: 1.2rem;
  padding: 1.4rem 1.6rem;
  background: var(--deep-2);
  border-left: 2px solid transparent;
  transition: all .3s var(--swift);
}
.contact-item:hover {
  background: var(--deep-3);
  border-left-color: var(--orange);
  transform: translateX(6px);
}
.contact-icon {
  width: 38px; height: 38px;
  background: var(--deep-3);
  border: 1px solid var(--line);
  display: flex; align-items: center; justify-content: center;
  font-size: 0.9rem;
  flex-shrink: 0;
  transition: border-color .3s;
}
.contact-item:hover .contact-icon { border-color: var(--orange); }
.c-lbl {
  font-size: 0.52rem;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  color: var(--orange);
  display: block;
  margin-bottom: 0.2rem;
}
.c-val {
  font-family: var(--f-serif);
  font-size: 1rem;
  color: var(--bone);
}

/* Form */
.contact-form { display: flex; flex-direction: column; gap: 1.2rem; }
.f-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
.f-group { display: flex; flex-direction: column; gap: 0.4rem; }
.f-group label {
  font-size: 0.52rem;
  font-weight: 500;
  letter-spacing: 0.22em;
  text-transform: uppercase;
  color: var(--orange);
}
.f-group input, .f-group select, .f-group textarea {
  background: var(--deep-2);
  border: 1px solid var(--line);
  border-bottom-color: var(--line-strong);
  color: var(--bone);
  padding: 0.9rem 1rem;
  font-family: var(--f-mono);
  font-size: 0.8rem;
  font-weight: 300;
  outline: none;
  transition: border-color .3s, background .3s;
  appearance: none;
  border-radius: 0;
}
.f-group input:focus, .f-group select:focus, .f-group textarea:focus {
  border-color: var(--orange);
  background: var(--deep-3);
}
.f-group input::placeholder, .f-group textarea::placeholder { color: var(--bone-25); }
.f-group textarea { min-height: 120px; resize: vertical; }
.f-group select option { background: var(--deep-2); }
.f-send { display: flex; align-items: center; gap: 2rem; margin-top: 0.5rem; }
.f-note {
  font-size: 0.52rem;
  letter-spacing: 0.1em;
  color: var(--bone-25);
  line-height: 1.7;
}

/* ════════════════════════════════════════
   FOOTER
════════════════════════════════════════ */
footer {
  background: var(--deep-1);
  border-top: 1px solid var(--line);
}
.footer-top {
  padding: 4rem 3rem 3rem;
  max-width: 1440px; margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 2rem;
  flex-wrap: wrap;
}
.footer-logo {
  font-family: var(--f-display);
  font-size: 1.8rem;
  letter-spacing: 0.06em;
}
.footer-logo span { color: var(--orange); }
.footer-links { display: flex; gap: 2rem; list-style: none; }
.footer-links a {
  font-size: 0.56rem;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  color: var(--bone-25);
  transition: color .3s;
}
.footer-links a:hover { color: var(--bone); }
.footer-socials { display: flex; gap: 0.6rem; }
.fsoc {
  width: 36px; height: 36px;
  border: 1px solid var(--line);
  display: flex; align-items: center; justify-content: center;
  font-size: 0.62rem;
  font-weight: 500;
  letter-spacing: 0.05em;
  color: var(--bone-25);
  transition: all .3s;
}
.fsoc:hover { border-color: var(--orange); color: var(--orange); }
.footer-bottom {
  padding: 1.5rem 3rem;
  max-width: 1440px; margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-top: 1px solid var(--line);
  flex-wrap: wrap;
  gap: 1rem;
}
.footer-copy {
  font-size: 0.52rem;
  letter-spacing: 0.14em;
  color: var(--bone-25);
}

/* ════════════════════════════════════════
   MODAL
════════════════════════════════════════ */
#modal {
  position: fixed; inset: 0;
  z-index: 2000;
  display: flex; align-items: center; justify-content: center;
  opacity: 0; pointer-events: none;
  transition: opacity .4s;
}
#modal.open { opacity: 1; pointer-events: all; }
.modal-scrim {
  position: absolute; inset: 0;
  background: rgba(6,6,6,0.95);
  backdrop-filter: blur(16px) saturate(150%);
}
.modal-panel {
  position: relative;
  width: 94%;
  max-width: 1060px;
  max-height: 92vh;
  overflow-y: auto;
  background: var(--deep-1);
  border: 1px solid var(--line-strong);
  transform: translateY(24px) scale(0.97);
  transition: transform .45s var(--swift);
}
#modal.open .modal-panel { transform: translateY(0) scale(1); }
.modal-close {
  position: absolute; top: 1.4rem; right: 1.4rem; z-index: 10;
  width: 42px; height: 42px;
  border: 1px solid var(--line-strong);
  display: flex; align-items: center; justify-content: center;
  color: var(--bone-60);
  font-size: 1rem;
  transition: all .3s;
}
.modal-close:hover { border-color: var(--orange); color: var(--orange); }
.modal-vid {
  aspect-ratio: 16/9;
  background: var(--deep-2);
  display: flex; align-items: center; justify-content: center;
  position: relative; overflow: hidden;
}
.modal-vid iframe { width:100%; height:100%; border:none; }
.modal-vid-ph {
  display: flex; flex-direction: column; align-items: center; gap: 1.2rem;
  color: var(--bone-25);
}
.modal-vid-ph-play {
  width: 64px; height: 64px;
  border: 1px solid var(--line-strong);
  border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
}
.modal-vid-ph span {
  font-size: 0.55rem;
  letter-spacing: 0.22em;
  text-transform: uppercase;
}
.modal-body {
  padding: 3rem;
  display: grid;
  grid-template-columns: 3fr 2fr;
  gap: 3rem;
}
.modal-title {
  grid-column: 1 / -1;
  font-family: var(--f-display);
  font-size: clamp(2rem, 4vw, 3.5rem);
  letter-spacing: 0.01em;
  line-height: 1;
}
.modal-desc {
  font-family: var(--f-serif);
  font-style: italic;
  font-size: 1.05rem;
  line-height: 1.9;
  color: var(--bone-60);
}
.modal-meta { display: flex; flex-direction: column; gap: 1.5rem; }
.modal-meta-row label {
  display: block;
  font-size: 0.52rem;
  letter-spacing: 0.2em;
  text-transform: uppercase;
  color: var(--orange);
  margin-bottom: 0.3rem;
}
.modal-meta-row span {
  font-family: var(--f-serif);
  font-size: 1rem;
  color: var(--bone);
}

/* ════════════════════════════════════════
   SCROLL REVEAL SYSTEM
════════════════════════════════════════ */
[data-sr] {
  opacity: 0;
  transition: opacity .9s var(--swift), transform .9s var(--swift);
}
[data-sr="u"] { transform: translateY(48px); }
[data-sr="l"] { transform: translateX(-48px); }
[data-sr="r"] { transform: translateX(48px); }
[data-sr="s"] { transform: scale(0.92); }
[data-sr].vis { opacity: 1; transform: none; }
[data-d="1"] { transition-delay: 0.1s; }
[data-d="2"] { transition-delay: 0.2s; }
[data-d="3"] { transition-delay: 0.3s; }
[data-d="4"] { transition-delay: 0.4s; }
[data-d="5"] { transition-delay: 0.5s; }
[data-d="6"] { transition-delay: 0.6s; }

/* ════════════════════════════════════════
   KEYFRAMES
════════════════════════════════════════ */
@keyframes riseUp {
  from { opacity:0; transform: translateY(18px); }
  to   { opacity:1; transform: translateY(0); }
}
@keyframes lineUp {
  to { transform: translateY(0); }
}
@keyframes fadeIn {
  to { opacity: 1; }
}

/* ════════════════════════════════════════
   RESPONSIVE
════════════════════════════════════════ */
@media (max-width: 1100px) {
  .pf-mosaic {
    grid-template-columns: repeat(6, 1fr);
    grid-auto-rows: 200px;
  }
  .pf-cell[data-size="xl"]   { grid-column: span 4; grid-row: span 2; }
  .pf-cell[data-size="tall"] { grid-column: span 2; grid-row: span 2; }
  .pf-cell[data-size="wide"] { grid-column: span 3; }
  .pf-cell[data-size="std"]  { grid-column: span 2; }
  .pf-cell[data-size="sq"]   { grid-column: span 3; }
  .about-layout { grid-template-columns: 1fr; }
  .about-bts-img { right: -1rem; bottom: -1rem; }
  .srv-item { grid-template-columns: 60px 1fr; gap: 1.5rem; }
  .srv-tags, .srv-arrow { display: none; }
  .test-layout { grid-template-columns: 1fr; }
  .test-sidebar { position: static; }
  .contact-layout { grid-template-columns: 1fr; gap: 4rem; }
}

@media (max-width: 768px) {
  .nav-center, .nav-pill { display: none; }
  .burger { display: flex; }
  .hero-body { padding: 0 2rem 5rem; }
  .reel-trigger { display: none; }
  .perfs, .perfs-r { display: none; }
  .counters { grid-template-columns: 1fr 1fr; }
  .pf-mosaic {
    grid-template-columns: 1fr 1fr;
    grid-auto-rows: 200px;
  }
  .pf-cell[data-size] { grid-column: span 1; grid-row: span 1; }
  .pf-cell[data-size="xl"] { grid-column: span 2; grid-row: span 1; }
  .srv-header { grid-template-columns: 1fr; }
  .clients-strip { justify-content: center; }
  .footer-top { flex-direction: column; align-items: flex-start; }
  .footer-bottom { flex-direction: column; }
  .modal-body { grid-template-columns: 1fr; }
  .section { padding: 5rem 2rem; }
  .wrap { padding: 0 1.5rem; }
  .contact-layout { gap: 3rem; }
  .f-row { grid-template-columns: 1fr; }
}

@media (max-width: 480px) {
  body { cursor: auto; }
  #dot, #ring { display: none; }
  .lbox-t, .lbox-b { height: 7%; }
  .hero-scroll { display: none; }
  .counters { grid-template-columns: 1fr; }
}
</style>
</head>
<body>

<!-- ── LOADER ─────────────────────────── -->
<div id="loader">
  <div class="loader-inner">
    <div class="loader-count" id="lcount">3</div>
    <div class="loader-progress"><div class="loader-progress-bar"></div></div>
    <div class="loader-label">Loading</div>
  </div>
  <div class="loader-marks" id="lmarks">
    <div class="loader-mark lit"></div>
    <div class="loader-mark lit"></div>
    <div class="loader-mark lit"></div>
    <div class="loader-mark"></div>
    <div class="loader-mark"></div>
    <div class="loader-mark"></div>
    <div class="loader-mark"></div>
    <div class="loader-mark"></div>
  </div>
</div>

<!-- ── CURSOR ─────────────────────────── -->
<div id="dot"></div>
<div id="ring"></div>

<!-- ── MOBILE NAV ─────────────────────── -->
<div id="mnav">
  <a href="#hero" class="mnav-item" onclick="closeM()">HOME</a>
  <a href="#portfolio" class="mnav-item" onclick="closeM()">PROJEKTE</a>
  <a href="#about" class="mnav-item" onclick="closeM()">ÜBER MICH</a>
  <a href="#services" class="mnav-item" onclick="closeM()">LEISTUNGEN</a>
  <a href="#testimonials" class="mnav-item" onclick="closeM()">KUNDEN</a>
  <a href="#contact" class="mnav-item" onclick="closeM()">KONTAKT</a>
  <p class="mnav-bottom">© 2024 · Zürich & LONDON</p>
</div>

<!-- ── NAV ────────────────────────────── -->
<nav id="nav">
  <a href="#hero" class="nav-logo">www.a.d.films24.ch<span>.</span></a>
  <ul class="nav-center">
    <li><a href="#portfolio">Projekte</a></li>
    <li><a href="#about">Über mich</a></li>
    <li><a href="#services">Leistungen</a></li>
    <li><a href="#testimonials">Kunden</a></li>
    <li><a href="#contact">Kontakt</a></li>
  </ul>
  <div class="nav-right">
    <a href="#contact" class="nav-pill">
      <span class="nav-dot"></span>
      <span>Verfügbar</span>
    </a>
    <button class="burger" id="burger" onclick="toggleM()">
      <b></b><b></b><b></b>
    </button>
  </div>
</nav>

<!-- ══════════════════════════════════════
     HERO
══════════════════════════════════════════ -->
<section id="hero">
  <div class="hero-bg">
    <video autoplay muted loop playsinline preload="metadata" poster="poster.jpg">
      <source src="showreel.mp4" type="video/mp4">
      Dein Browser unterstützt dieses Video-Format nicht.
    </video>
    <div class="hero-bg-ph"></div>
  </div>

  <!-- Film perforations left & right -->
  <div class="perfs">
    <div class="perf"></div><div class="perf"></div><div class="perf"></div>
    <div class="perf"></div><div class="perf"></div><div class="perf"></div>
    <div class="perf"></div><div class="perf"></div>
  </div>
  <div class="perfs perfs-r">
    <div class="perf"></div><div class="perf"></div><div class="perf"></div>
    <div class="perf"></div><div class="perf"></div><div class="perf"></div>
    <div class="perf"></div><div class="perf"></div>
  </div>

  <!-- Cinematic bars -->
  <div class="lbox-t"></div>
  <div class="lbox-b"></div>
  <div class="hero-vgn"></div>
  <div class="hero-vgn-side"></div>

  <!-- Timecode -->
  <div class="timecode" id="tc">00:00:00:00</div>

  <!-- Floating showreel -->
  <button class="reel-trigger" id="reelBtn">
    <div class="reel-ring-outer">
      <div class="reel-ring-spin"></div>
      <span class="reel-icon">▶</span>
    </div>
    <span class="reel-caption">Showreel 2024</span>
  </button>

  <!-- Scroll indicator -->
  <div class="hero-scroll">
    <span class="scroll-word">Scroll</span>
    <div class="scroll-line-track"><div class="scroll-line-fill"></div></div>
  </div>

  <!-- Main content -->
  <div class="hero-body" style="max-width:1440px; margin:0 auto;">
    <p class="hero-eyebrow">
      <span class="hero-eyebrow-line"></span>
      Videograf & Content Creator  Zürich
    </p>
    <h1 class="hero-h1">
      <span class="h1-row"><span class="h1-inner">CREATE</span></span>
      <span class="h1-row"><span class="h1-inner">MORE.</span></span>
    </h1>
    <div class="hero-sub-row">
      <p class="hero-desc">Cinematic Precision. Emotional Impact.<br>For Brands, who wanna stand out.</p>
      <div class="hero-actions">
        <a href="#portfolio" class="cta-primary">
          <svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M1 6H11M6 1L11 6L6 11" stroke="currentColor" stroke-width="1.3"/></svg>
          Portfolio
        </a>
        <a href="#contact" class="cta-ghost">Request Project</a>
        <a href="/showreel.mp4" download class="cta-ghost">Download Showreel</a>
      </div>
    </div>
  </div>
</section>

<!-- Ticker band -->
<div class="intro-band">
  <div class="ticker-track">
    <span class="tick"><span class="hi">Videografie</span><span class="tick-sep">✦</span></span>
    <span class="tick"><span class="hi">Commercial</span><span class="tick-sep">✦</span></span>
    <span class="tick"><span class="hi">Social Media</span><span class="tick-sep">✦</span></span>
    <span class="tick"><span class="hi">Drohne</span><span class="tick-sep">✦</span></span>
    <span class="tick"><span class="hi">Real Estate</span><span class="tick-sep">✦</span></span>
    <span class="tick"><span class="hi">Automotive</span><span class="tick-sep">✦</span></span>
    <span class="tick"><span class="hi">Events</span><span class="tick-sep">✦</span></span>
    <span class="tick"><span class="hi">Travel</span><span class="tick-sep">✦</span></span>
    <!-- duplicate -->
    <span class="tick"><span class="hi">Videografie</span><span class="tick-sep">✦</span></span>
    <span class="tick"><span class="hi">Commercial</span><span class="tick-sep">✦</span></span>
    <span class="tick"><span class="hi">Social Media</span><span class="tick-sep">✦</span></span>
    <span class="tick"><span class="hi">Drohne</span><span class="tick-sep">✦</span></span>
    <span class="tick"><span class="hi">Real Estate</span><span class="tick-sep">✦</span></span>
    <span class="tick"><span class="hi">Automotive</span><span class="tick-sep">✦</span></span>
    <span class="tick"><span class="hi">Events</span><span class="tick-sep">✦</span></span>
    <span class="tick"><span class="hi">Travel</span><span class="tick-sep">✦</span></span>
  </div>
</div>

<!-- Counters -->
<div class="section" style="background:var(--deep-1); padding-top:5rem; padding-bottom:5rem;">
  <div style="max-width:1440px; margin:0 auto; padding:0 3rem;">
    <div class="counters">
      <div class="ctr" data-n="01" data-sr="u">
        <div class="ctr-val">20<sup>+</sup></div>
        <div class="ctr-lbl">Projekte realisiert</div>
      </div>
      <div class="ctr" data-n="02" data-sr="u" data-d="2">
        <div class="ctr-val">2</div>
        <div class="ctr-lbl">Jahre Erfahrung</div>
      </div>
      <div class="ctr" data-n="03" data-sr="u" data-d="3">
        <div class="ctr-val">4<sup>+</sup></div>
        <div class="ctr-lbl">Premium-Kunden</div>
      </div>
      <div class="ctr" data-n="04" data-sr="u" data-d="4">
        <div class="ctr-val">100K<sup>+</sup></div>
        <div class="ctr-lbl">Views generiert</div>
      </div>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════
     PORTFOLIO
══════════════════════════════════════════ -->
<section class="section" id="portfolio">
  <div style="max-width:1440px; margin:0 auto; padding:0 3rem;">

    <div class="pf-controls">
      <div>
        <div class="s-meta" data-sr="u">Portfolio</div>
        <h2 class="h-display" data-sr="u" data-d="2">
          AUSGEWÄHLTE<br><span class="serif">Arbeiten</span>
        </h2>
      </div>
      <div class="pf-filters" data-sr="u" data-d="3">
        <button class="pf-btn active" data-f="all">Alle</button>
        <button class="pf-btn" data-f="commercial">Commercial</button>
        <button class="pf-btn" data-f="social">Social</button>
        <button class="pf-btn" data-f="real-estate">Real Estate</button>
        <button class="pf-btn" data-f="events">Events</button>
        <button class="pf-btn" data-f="travel">Travel</button>
      </div>
    </div>

    <div class="pf-video" data-sr="u" data-d="4" style="margin: 2.5rem 0; overflow: hidden; border-radius: 24px; background: #090909;">
      <video controls preload="metadata" poster="poster.jpg" style="width:100%; display:block;">
        <source src="showreel.mp4" type="video/mp4">
        Dein Browser unterstützt das Video-Format nicht.
      </video>
    </div>

    <div class="pf-mosaic" data-sr="u" data-d="2">

      <!-- XL Featured -->
      <div class="pf-cell" data-size="xl" data-cat="commercial"
           data-title="FINELLI — URBAN MOTION" data-client="FINELLI Switzerland"
           data-cam="Sony FX3 / DJI Ronin 5 " data-year="2024"
           data-desc="Cineastische Kurzfilme für einen Streetbrand in der Schweiz. Urbane Bewegung und sportliche Energie — gedreht auf den Straßen Zürichs von der Golden Hour bis Blue Hour. Roh, echt, kraftvoll."
           onclick="openModal(this)">
        <div class="pf-cell-bg bg-a"><span class="pf-glyph">N</span></div>
        <div class="pf-overlay">
          <div class="pf-tag">Commercial · 2024</div>
          <div class="pf-title">Streetbrand — URBAN MOTION</div>
        </div>
        <div class="pf-caret">
          <svg width="14" height="14" viewBox="0 0 14 14" fill="none"><path d="M1 7H13M7 1L13 7L7 13" stroke="#FF4D00" stroke-width="1.4"/></svg>
        </div>
      </div>

      <!-- Tall -->
      <div class="pf-cell" data-size="tall" data-cat="real-estate"
           data-title="PENTHOUSE ZÜRICHSEE" data-client="Sotheby's International"
           data-cam="DJI Inspire 3 / RED Komodo" data-year="2024"
           data-desc="Luxuriöse Immobilienpräsentation eines Apartments direkt am Zürichsee. Drohnenaufnahmen bei Sonnenuntergang, cinematische Innenraumshots mit natürlichem Licht."
           onclick="openModal(this)">
        <div class="pf-cell-bg bg-b"><span class="pf-glyph">◆</span></div>
        <div class="pf-overlay">
          <div class="pf-tag">Real Estate · 2024</div>
          <div class="pf-title">Apartment ZÜRICHSEE</div>
        </div>
        <div class="pf-caret">
          <svg width="14" height="14" viewBox="0 0 14 14" fill="none"><path d="M1 7H13M7 1L13 7L7 13" stroke="#FF4D00" stroke-width="1.4"/></svg>
        </div>
      </div>

      <!-- Wide -->
      <div class="pf-cell" data-size="wide" data-cat="automotive"
           data-title="PORSCHE 911 — RAW POWER" data-client="Auto Zentrum Zürich"
           data-cam="Sony FX6 / Phantom Flex 4K" data-year="2023"
           data-desc="Hochgeschwindigkeits-Cinematik für Autos. Slow-Motion bis 1.000fps trifft auf dramatische Fahraufnahmen durch die Alpen."
           onclick="openModal(this)">
        <div class="pf-cell-bg bg-c"><span class="pf-glyph">◎</span></div>
        <div class="pf-overlay">
          <div class="pf-tag">Automotive · 2023</div>
        </div>
        <div class="pf-caret">
          <svg width="14" height="14" viewBox="0 0 14 14" fill="none"><path d="M1 7H13M7 1L13 7L7 13" stroke="#FF4D00" stroke-width="1.4"/></svg>
        </div>
      </div>

      <!-- Wide -->
      <div class="pf-cell" data-size="wide" data-cat="travel"
           data-title="WANDERLUST — Schweiz" data-client="Swiss Travel Agency"
           data-cam="Sony FX3 / DJI Mini 4 Pro" data-year="2024"
           data-desc="Zwei Tage durch Berge Extremlandschaften:  Geysire, Gletscherhöhlen. Eine visuelle Reise."
           onclick="openModal(this)">
        <div class="pf-cell-bg bg-d"><span class="pf-glyph">✦</span></div>
        <div class="pf-overlay">
          <div class="pf-tag">Travel · 2024</div>
          <div class="pf-title">WANDERLUST — Schweiz</div>
        </div>
        <div class="pf-caret">
          <svg width="14" height="14" viewBox="0 0 14 14" fill="none"><path d="M1 7H13M7 1L13 7L7 13" stroke="#FF4D00" stroke-width="1.4"/></svg>
        </div>
      </div>

      <!-- Std -->
      <div class="pf-cell" data-size="sq" data-cat="events"
           data-title="ART BASEL — OPENING NIGHT" data-client="Art Basel"
           data-cam="Sony FX3 / Sony 24-70 GM II" data-year="2024"
           data-desc="Die Opening Night der Art Basel Basel — Kunst, Menschen, Atmosphäre. Dokumentarisch und cinematisch zugleich."
           onclick="openModal(this)">
        <div class="pf-cell-bg bg-e"><span class="pf-glyph">◉</span></div>
        <div class="pf-overlay">
          <div class="pf-tag">Events · 2024</div>
          <div class="pf-title">ART BASEL — OPENING</div>
        </div>
        <div class="pf-caret">
          <svg width="14" height="14" viewBox="0 0 14 14" fill="none"><path d="M1 7H13M7 1L13 7L7 13" stroke="#FF4D00" stroke-width="1.4"/></svg>
        </div>
      </div>

      <!-- Sq -->
      <div class="pf-cell" data-size="sq" data-cat="social"
           data-title="@BRAND — SOCIAL SERIES" data-client="Luxury Skincare Brand"
           data-cam="Sony A7 IV / Zhiyun Crane 4" data-year="2024"
           data-desc="Monatliche Content-Serie für Instagram & TikTok. 12 Reels, Mehr + Views. Sell-out nach jedem Posting. Modernes Brand Storytelling."
           onclick="openModal(this)">
        <div class="pf-cell-bg bg-f"><span class="pf-glyph">∞</span></div>
        <div class="pf-overlay">
          <div class="pf-tag">Social Media · 2024</div>
          <div class="pf-title">@BRAND — SOCIAL SERIES</div>
        </div>
        <div class="pf-caret">
          <svg width="14" height="14" viewBox="0 0 14 14" fill="none"><path d="M1 7H13M7 1L13 7L7 13" stroke="#FF4D00" stroke-width="1.4"/></svg>
        </div>
      </div>

    </div>
  </div>
</section>

<!-- Full-bleed marquee -->
<div class="divider-full">
  <div class="divider-marquee">
    <span class="dm-item">VISUAL <span class="o">STORIES</span></span>
    <span class="dm-item">CINEMATIC <span class="o">PRECISION</span></span>
    <span class="dm-item">PREMIUM <span class="o">CONTENT</span></span>
    <span class="dm-item">ZÜRICH & <span class="o">LONDON</span></span>
    <span class="dm-item">VISUAL <span class="o">STORIES</span></span>
    <span class="dm-item">CINEMATIC <span class="o">PRECISION</span></span>
    <span class="dm-item">PREMIUM <span class="o">CONTENT</span></span>
    <span class="dm-item">ZÜRICH & <span class="o">LONDON</span></span>
  </div>
</div>

<!-- ══════════════════════════════════════
     ÜBER MICH
══════════════════════════════════════════ -->
<section class="section" id="about">
  <div style="max-width:1440px; margin:0 auto; padding:0 3rem;">
    <div class="about-layout">

      <!-- Image column -->
      <div class="about-img-col" data-sr="l">
        <div class="about-main-img">
          <!--
            Bild einbinden:
            <img src="portrait.jpg" alt="Dein Name – Cinematographer" loading="lazy" style="width:100%;height:100%;object-fit:cover;position:absolute;inset:0;">
          -->
          <div class="about-main-img-inner"><span>◎</span></div>
        </div>
        <div class="about-bts-img">
          <!-- Behind-the-scenes: <img src="bts.jpg" alt="Behind the Scenes" loading="lazy" style="width:100%;height:100%;object-fit:cover;"> -->
          <div class="about-bts-img-inner"><span>◉</span></div>
        </div>
        <div class="about-data-tag">Zürich · CH · 2025</div>
      </div>

      <!-- Text column -->
      <div data-sr="r">
        <div class="s-meta">Über mich</div>
        <h2 class="h-display">
          MEINE VISION,<br><span class="serif">deine Geschichte</span>
        </h2>
        <p class="about-bio">
          A.D.Films24 ist ein Videoproduktions-Studio aus Zürich, Schweiz. Wir produzieren professionelle Brand Films, Social Media Content, Eventvideos, Drohnenaufnahmen und Unternehmensfotos für Firmen, Start-ups, Restaurants und Influencer in der ganzen Schweiz. Von Konzept bis Color Grading — kreativ, schnell, hochwertig., Videograf und Content Creator aus Zürich — mit einer <strong>tiefen Leidenschaft für visuelles Storytelling</strong>. Was mich antreibt, ist nicht die Technik, sondern der Moment, in dem ein Bild etwas auslöst.
        </p>
        <p class="about-bio">
          Mit 2 Jahr Erfahrung in <strong>Commercial, Streetfilms und Social Media</strong> haben wir gelernt: Jede Marke hat eine Geschichte. Die Frage ist nur, ob sie gut genug erzählt wird.
        </p>
        <p class="about-bio">
          Wir arbeiten international — von Zürich bis London — mit einem klaren Anspruch: <strong>kein Kompromiss in Qualität.</strong>
        </p>

        <div class="gear-section">
          <div class="gear-head">Equipment</div>
          <div class="gear-rows">
            <div class="gear-row"><span class="gear-name">Sony FX3</span><span class="gear-type">Cinema Kamera</span></div>
            <div class="gear-row"><span class="gear-name">Gimbal Ronin RS5</span><span class="gear-type">Stabilisierung</span></div>
            <div class="gear-row"><span class="gear-name">Sony 24-70mm GM II</span><span class="gear-type">Hauptobjektiv</span></div>
            <div class="gear-row"><span class="gear-name">Drone</span><span class="gear-type">Luftaufnahmen</span></div>
            <div class="gear-row"><span class="gear-name">Microphone</span><span class="gear-type">Audio</span></div>
            <div class="gear-row"><span class="gear-name">MacBook Pro</span><span class="gear-type">Workstation</span></div>
            <div class="gear-row"><span class="gear-name">DaVinci Resolve Studio / Adobe Premium</span><span class="gear-type">Color Grading</span></div>
            <div class="gear-row"><span class="gear-name">Aperture Light & Dome</span><span class="gear-type">Lichtsystem</span></div>
            <div class="gear-row"><span class="gear-name">Atomos Ninja V</span><span class="gear-type">Monitor</span></div>
          </div>
        </div>
      </div>

    </div>
  </div>
</section>

<!-- ══════════════════════════════════════
     LEISTUNGEN
══════════════════════════════════════════ -->
<section class="section" id="services" style="background:var(--deep-1);">
  <div style="max-width:1440px; margin:0 auto; padding:0 3rem;">
    <div class="srv-header">
      <div>
        <div class="s-meta" data-sr="u">Leistungen</div>
        <h2 class="h-display" data-sr="u" data-d="2">WAS WIR FÜR<br><span class="accent">DICH TUN</span></h2>
      </div>
      <p class="srv-header-desc" data-sr="r" data-d="2">
        Von der ersten Idee bis zum finalen Export alles aus einer Hand. Kein Kompromiss. Kein Schritt übersprungen.
      </p>
    </div>

    <div class="srv-list-editorial" data-sr="u" data-d="2">

      <div class="srv-item">
        <div class="srv-num">01</div>
        <div class="srv-name">VIDEOGRAFIE<em>Cinematic Production</em></div>
        <div class="srv-tags">
          <span class="srv-tag">Pre-Production</span>
          <span class="srv-tag">Multi-Location</span>
          <span class="srv-tag">Color Grading</span>
        </div>
        <div class="srv-arrow">
          <svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M1 6H11M6 1L11 6L6 11" stroke="currentColor" stroke-width="1.3"/></svg>
        </div>
      </div>

      <div class="srv-item">
        <div class="srv-num">02</div>
        <div class="srv-name">SOCIAL MEDIA<em>Content Strategy & Production</em></div>
        <div class="srv-tags">
          <span class="srv-tag">Reels & TikTok</span>
          <span class="srv-tag">Monatlich</span>
          <span class="srv-tag">Analytics</span>
        </div>
        <div class="srv-arrow">
          <svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M1 6H11M6 1L11 6L6 11" stroke="currentColor" stroke-width="1.3"/></svg>
        </div>
      </div>

      <div class="srv-item">
        <div class="srv-num">03</div>
        <div class="srv-name">EDITING & GRADING<em>Post-Production Excellence</em></div>
        <div class="srv-tags">
          <span class="srv-tag">DaVinci Resolve</span>
          <span class="srv-tag">Custom LUTs</span>
          <span class="srv-tag">Sound Design</span>
        </div>
        <div class="srv-arrow">
          <svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M1 6H11M6 1L11 6L6 11" stroke="currentColor" stroke-width="1.3"/></svg>
        </div>
      </div>

      <div class="srv-item">
        <div class="srv-num">04</div>
        <div class="srv-name">DRONE SHOTS<em>Aerial Cinematography</em></div>
        <div class="srv-tags">
          <span class="srv-tag">A1/A3 Lizenz CH</span>
          <span class="srv-tag">DJI Inspire 3</span>
          <span class="srv-tag">4K/6K</span>
        </div>
        <div class="srv-arrow">
          <svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M1 6H11M6 1L11 6L6 11" stroke="currentColor" stroke-width="1.3"/></svg>
        </div>
      </div>

      <div class="srv-item">
        <div class="srv-num">05</div>
        <div class="srv-name">BRANDING VIDEOS<em>Brand Identity Films</em></div>
        <div class="srv-tags">
          <span class="srv-tag">Brand Story</span>
          <span class="srv-tag">Corporate</span>
          <span class="srv-tag">Produkt</span>
        </div>
        <div class="srv-arrow">
          <svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M1 6H11M6 1L11 6L6 11" stroke="currentColor" stroke-width="1.3"/></svg>
        </div>
      </div>

      <div class="srv-item">
        <div class="srv-num">06</div>
        <div class="srv-name">EVENT COVERAGE<em>Documentary & Highlights</em></div>
        <div class="srv-tags">
          <span class="srv-tag">Multi-Kamera</span>
          <span class="srv-tag">Same-Day-Edit</span>
          <span class="srv-tag">Livestream</span>
        </div>
        <div class="srv-arrow">
          <svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M1 6H11M6 1L11 6L6 11" stroke="currentColor" stroke-width="1.3"/></svg>
        </div>
      </div>

    </div>
  </div>
</section>

<!-- ══════════════════════════════════════
     TESTIMONIALS
══════════════════════════════════════════ -->
<section class="section" id="testimonials" style="background:var(--void);">
  <div style="max-width:1440px; margin:0 auto; padding:0 3rem;">
    <div class="test-layout">

      <!-- Sticky sidebar -->
      <div class="test-sidebar">
        <div class="s-meta" data-sr="u">Testimonials</div>
        <h2 class="h-display" data-sr="u" data-d="2">WAS<br>KUNDEN<br><span class="serif">sagen</span></h2>
        <div class="test-stat" data-sr="u" data-d="3">
          <div class="ts-num">4.9<sup>/5</sup></div>
          <div class="ts-label">Durchschnittsbewertung</div>
        </div>
      </div>

      <!-- Cards -->
      <div class="test-cards-col">
        <div class="test-card" data-sr="r" data-d="1">
          <span class="test-q">&ldquo;</span>
          <div class="test-stars"><div class="star"></div><div class="star"></div><div class="star"></div><div class="star"></div><div class="star"></div></div>
          <p class="test-body">„Die Qualität hat unsere Erwartungen bei weitem übertroffen. Unser Instagram-Engagement stieg um 340% — wir buchen bereits das nächste Projekt."</p>
          <div class="test-foot">
            <div>
              <div class="test-author-name">MARC.</div>
              <div class="test-author-role">SALES AGENT · Luxury Brand Zürich</div>
            </div>
            <div class="test-stars"><div class="star"></div><div class="star"></div><div class="star"></div><div class="star"></div><div class="star"></div></div>
          </div>
        </div>

        <div class="test-card" data-sr="r" data-d="2">
          <span class="test-q">&ldquo;</span>
          <div class="test-stars"><div class="star"></div><div class="star"></div><div class="star"></div><div class="star"></div><div class="star"></div></div>
          <p class="test-body">„Professionell, kreativ, zuverlässig.“</p>
          <div class="test-foot">
            <div>
              <div class="test-author-name">SHANIK.</div>
              <div class="test-author-role">MODEL ·</div>
            </div>
            <div class="test-stars"><div class="star"></div><div class="star"></div><div class="star"></div><div class="star"></div><div class="star"></div></div>
          </div>
        </div>

        <div class="test-card" data-sr="r" data-d="3">
          <span class="test-q">&ldquo;</span>
          <div class="test-stars"><div class="star"></div><div class="star"></div><div class="star"></div><div class="star"></div><div class="star"></div></div>
          <p class="test-body">„48 Stunden nach dem Brand Film hatten wir mehr Anfragen als im ganzen Vorjahr. Der ROI war schlicht unglaublich."</p>
          <div class="test-foot">
            <div>
              <div class="test-author-name">Marc </div>
              <div class="test-author-role">Saler Agent · Tech Startup Zürich</div>
            </div>
            <div class="test-stars"><div class="star"></div><div class="star"></div><div class="star"></div><div class="star"></div><div class="star"></div></div>
          </div>
        </div>

        <div class="test-card" data-sr="r" data-d="4">
          <span class="test-q">&ldquo;</span>
          <p class="test-body">„Unser Event wurde so festgehalten, als wäre es ein Kurzfilm. Das Editing ist auf einem anderen Level! Wir haben ihn auf allen Kanälen eingesetzt."</p>
          <div class="test-foot">
            <div>
              <div class="test-author-name">Laura </div>
              <div class="test-author-role">Event Manager · Basel</div>
            </div>
            <div class="test-stars"><div class="star"></div><div class="star"></div><div class="star"></div><div class="star"></div><div class="star"></div></div>
          </div>
        </div>
      </div>
    </div>

 
    </div>
  </div>
</section>

<!-- ══════════════════════════════════════
     KONTAKT
══════════════════════════════════════════ -->
<section class="section" id="contact" style="background:var(--deep-1);">
  <div style="max-width:1440px; margin:0 auto; padding:0 3rem; position:relative;">
    <div class="contact-bg-text">HALLO.</div>
    <div class="contact-layout">

      <div class="contact-info">
        <a href="#hero" class="nav-logo" style="display: block; margin-bottom: 2.5rem; font-size: 1.4rem;">www.a.d.films24.ch<span>.</span></a>
        <div class="s-meta" data-sr="u">Kontakt</div>
        <h2 class="h-display" data-sr="u" data-d="2">LASS UNS<br>REDEN.</h2>
        <p class="contact-tagline" data-sr="u" data-d="3">
          Bereit für ein Projekt, das bleibt? Schreib mir.
        </p>
        <div class="contact-links" data-sr="u" data-d="4">
          <a href="mailto:abdi.dhiblawe@gmail.com" class="contact-item">
            <div class="contact-icon">✉</div>
            <div><span class="c-lbl">E-Mail</span><span class="c-val">a.dfilms24@gmail.com</span></div>
          </a>
          <a href="https://wa.me/41767649300" target="_blank" class="contact-item">
            <div class="contact-icon">💬</div>
            <div><span class="c-lbl">WhatsApp</span><span class="c-val">+41 76 764 93 00</span></div>
          </a>
          <a href="https://instagram.com/a.d.films24" target="_blank" class="contact-item">
            <div class="contact-icon">◈</div>
            <div><span class="c-lbl">Instagram</span><span class="c-val">@a.d.films24</span></div>
          </a>
        </div>
      </div>

      <form class="contact-form" data-sr="r" data-d="2" onsubmit="sendForm(event)">
        <div class="f-row">
          <div class="f-group">
            <label>Vorname</label>
            <input type="text" placeholder="Max" required>
          </div>
          <div class="f-group">
            <label>Nachname</label>
            <input type="text" placeholder="Mustermann" required>
          </div>
        </div>
        <div class="f-group">
          <label>E-Mail</label>
          <input type="email" placeholder="max@beispiel.ch" required>
        </div>
        <div class="f-group">
          <label>Projekttyp</label>
          <select>
            <option value="" disabled selected>— Bitte wählen —</option>
            <option>Commercial / Brand Film</option>
            <option>Social Media Content</option>
            <option>Drohnenaufnahmen</option>
            <option>Anderes</option>
          </select>
        </div>
        <div class="f-group">
          <label>Dein Projekt</label>
          <textarea placeholder="Erzähl mir von deiner Vision — Zeitrahmen, Budget, Ziele …"></textarea>
        </div>
        <div class="f-send">
          <button type="submit" class="cta-primary" id="sendBtn">
            <svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M1 6H11M6 1L11 6L6 11" stroke="currentColor" stroke-width="1.3"/></svg>
            Anfrage senden
          </button>
          <p class="f-note">Keine Werbung. Nur echte Antworten.</p>
        </div>
      </form>
    </div>
  </div>
</section>

<!-- ══════════════════════════════════════
     FOOTER
══════════════════════════════════════════ -->
<footer>
  <div class="footer-top">
    <div class="footer-logo">www.a.d.films24.ch<span>.</span></div>
    <ul class="footer-links">
      <li><a href="#portfolio">Projekte</a></li>
      <li><a href="#about">Über mich</a></li>
      <li><a href="#services">Leistungen</a></li>
      <li><a href="#contact">Kontakt</a></li>
      <li><a href="#">Impressum</a></li>
      <li><a href="#">Datenschutz</a></li>
    </ul>
    <div class="footer-socials">
      <a href="https://instagram.com" target="_blank" class="fsoc">IG</a>
      <a href="https://vimeo.com" target="_blank" class="fsoc">VI</a>
      <a href="https://youtube.com" target="_blank" class="fsoc">YT</a>
    </div>
  </div>
  <div class="footer-bottom">
    <span class="footer-copy">© 2025 www.a.d.films24.ch Alle Rechte vorbehalten.</span>
    <span class="footer-copy">Zürich · LONDON · International · Made with precision.</span>
  </div>
</footer>

<!-- ══════════════════════════════════════
     MODAL
══════════════════════════════════════════ -->
<div id="modal">
  <div class="modal-scrim" onclick="closeModal()"></div>
  <div class="modal-panel">
    <button class="modal-close" onclick="closeModal()">✕</button>
    <div class="modal-vid" id="modalVid">
      <!--
        Vimeo: <iframe src="https://player.vimeo.com/video/YOURID?autoplay=1" allow="autoplay; fullscreen" allowfullscreen></iframe>
        YouTube: <iframe src="https://www.youtube.com/embed/YOURID?autoplay=1" allow="autoplay; fullscreen" allowfullscreen></iframe>
      -->
      <div class="modal-vid-ph">
        <div class="modal-vid-ph-play">
          <svg width="16" height="18" viewBox="0 0 16 18" fill="none"><path d="M2 2L14 9L2 16V2Z" fill="#FF4D00"/></svg>
        </div>
        <span id="modalVidLabel">Video Placeholder</span>
      </div>
    </div>
    <div class="modal-body">
      <h2 class="modal-title" id="mT">—</h2>
      <p class="modal-desc" id="mD">—</p>
      <div class="modal-meta">
        <div class="modal-meta-row"><label>Kunde</label><span id="mC">—</span></div>
        <div class="modal-meta-row"><label>Kamera</label><span id="mK">—</span></div>
        <div class="modal-meta-row"><label>Jahr</label><span id="mY">—</span></div>
      </div>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════
     PASSWORD GATE
══════════════════════════════════════════ -->
<div id="accessGate" class="access-gate">
  <div class="access-gate-panel">
    <h2>Zugangscode erforderlich</h2>
    <p>Gib dein Einmalpasswort ein, um die Website freizuschalten.</p>
    <input id="gatePassword" type="password" placeholder="Passwort" autocomplete="off" />
    <button id="gateSubmit" type="button">Freischalten</button>
    <p id="gateMessage" class="gate-note"></p>
  </div>
</div>

<!-- ══════════════════════════════════════
     JAVASCRIPT
══════════════════════════════════════════ -->
<script>
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

/* ── CURSOR ─── */
const dot  = document.getElementById('dot');
const ring = document.getElementById('ring');
let mx=0,my=0,rx=0,ry=0;
document.addEventListener('mousemove', e => {
  mx = e.clientX; my = e.clientY;
  dot.style.left = mx+'px';
  dot.style.top  = my+'px';
});
(function ar() {
  rx += (mx-rx)*.1; ry += (my-ry)*.1;
  ring.style.left = rx+'px'; ring.style.top = ry+'px';
  requestAnimationFrame(ar);
})();
const hels = document.querySelectorAll('a, button, .pf-cell, .srv-item, .test-card, .contact-item, .gear-row');
hels.forEach(el => {
  el.addEventListener('mouseenter', () => ring.classList.add('big'));
  el.addEventListener('mouseleave', () => ring.classList.remove('big'));
});

/* ── NAV PIN ─── */
const nav = document.getElementById('nav');
window.addEventListener('scroll', () => {
  nav.classList.toggle('pinned', window.scrollY > 70);
}, {passive:true});

/* ── MOBILE NAV ─── */
const mnav   = document.getElementById('mnav');
const burger = document.getElementById('burger');
function toggleM() {
  const o = mnav.classList.toggle('on');
  burger.classList.toggle('x', o);
  document.body.style.overflow = o ? 'hidden' : '';
}
function closeM() {
  mnav.classList.remove('on');
  burger.classList.remove('x');
  document.body.style.overflow = '';
}

/* ── SCROLL REVEAL ─── */
const srEls = document.querySelectorAll('[data-sr]');
const srObs = new IntersectionObserver(entries => {
  entries.forEach(e => {
    if (e.isIntersecting) { e.target.classList.add('vis'); srObs.unobserve(e.target); }
  });
}, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });
srEls.forEach(el => srObs.observe(el));

/* ── TIMECODE ─── */
function pad(n) { return String(n).padStart(2,'0'); }
let fr = 0;
setInterval(() => {
  const now = new Date();
  fr = (fr + 1) % 24;
  document.getElementById('tc').textContent =
    `${pad(now.getHours())}:${pad(now.getMinutes())}:${pad(now.getSeconds())}:${pad(fr)}`;
}, 42);

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
function openModal(el) {
  document.getElementById('mT').textContent = el.dataset.title  || '—';
  document.getElementById('mD').textContent = el.dataset.desc   || '—';
  document.getElementById('mC').textContent = el.dataset.client || '—';
  document.getElementById('mK').textContent = el.dataset.cam    || '—';
  document.getElementById('mY').textContent = el.dataset.year   || '—';
  document.getElementById('modalVidLabel').textContent = el.dataset.title;
  /*
    REAL VIDEO EMBED:
    document.getElementById('modalVid').innerHTML =
      `<iframe src="https://player.vimeo.com/video/YOUR_ID?autoplay=1&color=ff4d00" allow="autoplay; fullscreen" allowfullscreen></iframe>`;
  */
  document.getElementById('modal').classList.add('open');
  document.body.style.overflow = 'hidden';
}
function closeModal() {
  document.getElementById('modal').classList.remove('open');
  document.body.style.overflow = '';
}
document.addEventListener('keydown', e => { if (e.key === 'Escape') closeModal(); });

/* ── SHOWREEL ─── */
document.getElementById('reelBtn').addEventListener('click', () => {
  window.open('/showreel.mp4', '_blank');
});

/* ── PASSWORD GATE ─── */
const ACCESS_PASSWORD = 'adfilms24';
const STORAGE_KEY = 'adfilms24_access_used';
const GATE_ALLOW_KEY = 'adfilms24_access_allowed';
const accessGate = document.getElementById('accessGate');
const gatePassword = document.getElementById('gatePassword');
const gateSubmit = document.getElementById('gateSubmit');
const gateMessage = document.getElementById('gateMessage');

function lockSite() {
  accessGate.classList.add('active');
  document.body.style.overflow = 'hidden';
}
function unlockSite() {
  accessGate.classList.remove('active');
  document.body.style.overflow = '';
}
function markAccessUsed() {
  localStorage.setItem(STORAGE_KEY, 'true');
  localStorage.setItem(GATE_ALLOW_KEY, 'true');
}
function isAccessAllowed() {
  return localStorage.getItem(GATE_ALLOW_KEY) === 'true';
}
function isAccessUsed() {
  return localStorage.getItem(STORAGE_KEY) === 'true';
}
function showGateMessage(text, error = false) {
  gateMessage.textContent = text;
  gateMessage.style.color = error ? '#ff7a66' : 'var(--bone-25)';
}
function validateGate() {
  const value = gatePassword.value.trim();
  if (!value) {
    showGateMessage('Bitte gib ein Passwort ein.', true);
    return;
  }
  if (value === ACCESS_PASSWORD) {
    markAccessUsed();
    unlockSite();
    showGateMessage('Zugang gewährt. Willkommen!', false);
    return;
  }
  showGateMessage('Falsches Passwort. Der Zugang wurde nicht freigeschaltet.', true);
}

gateSubmit.addEventListener('click', validateGate);
gatePassword.addEventListener('keypress', e => {
  if (e.key === 'Enter') validateGate();
});

if (!isAccessAllowed()) {
  if (isAccessUsed()) {
    showGateMessage('Dieses Passwort wurde bereits verwendet. Um einen neuen Zugang zu erhalten, kontaktiere uns.', true);
    gatePassword.disabled = true;
    gateSubmit.disabled = true;
  }
  lockSite();
}

/* ── FORM ─── */
function sendForm(e) {
  e.preventDefault();
  const btn = document.getElementById('sendBtn');
  btn.innerHTML = '✓ &nbsp;Gesendet!';
  btn.style.background = '#1a6b3a';
  setTimeout(() => {
    btn.innerHTML = '<svg width="12" height="12" viewBox="0 0 12 12" fill="none"><path d="M1 6H11M6 1L11 6L6 11" stroke="currentColor" stroke-width="1.3"/></svg> Anfrage senden';
    btn.style.background = '';
    e.target.reset();
  }, 3500);
}
</script>
</body>
</html>
