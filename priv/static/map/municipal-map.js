/* eCidadão municipal coverage. No location leaves this closure. */
(() => {
  'use strict';
  const c = JSON.parse(document.getElementById('coverage-copy').textContent);
  const el = id => document.getElementById('coverage-' + id);
  let snapshot = null, selected = null, map = null, markers = [], position = null;
  let generation = 0, request = null, geoGeneration = 0;
  const make = (tag, text, className) => {
    const node = document.createElement(tag);
    if (text !== undefined) node.textContent = text;
    if (className) node.className = className;
    return node;
  };
  function internalLink(value) {
    if (typeof value !== 'string' || !value.startsWith('/') || value.startsWith('//')) return null;
    const url = new URL(value, location.origin);
    return url.origin === location.origin && ['/municipios', '/vagas', '/apoios', '/financas', '/siga', '/saude', '/a-minha-rua', '/reclamacoes', '/livro-amarelo'].includes(url.pathname) ? url.pathname + url.search + url.hash : null;
  }
  function sourceLink(value) {
    try {
      const url = new URL(value);
      const hosts = ['cm-gondomar.pt', 'cm-maia.pt', 'cm-pontedelima.pt', 'dgterritorio.gov.pt', 'gov.pt', 'seg-social.pt', 'portaldasfinancas.gov.pt'];
      return url.protocol === 'https:' && !url.username && !url.password && hosts.some(h => url.hostname === h || url.hostname.endsWith('.' + h)) ? url.href : null;
    } catch { return null; }
  }
  function link(label, href, official = false) {
    const a = make('a', label, official ? 'official' : '');
    a.href = href;
    return a;
  }
  function valid(data) {
    return data && data.language === c.language && typeof data.generated_at === 'string' && Number.isFinite(Date.parse(data.generated_at)) &&
      /^\d{4}-\d{2}-\d{2}$/.test(data.verified_on) && typeof data.notice === 'string' && typeof data.revision === 'string' &&
      Array.isArray(data.municipalities) && data.municipalities.length <= 400 && data.municipality_count === data.municipalities.length &&
      data.municipalities.every(m => m && typeof m.id === 'string') && new Set(data.municipalities.map(m => m.id)).size === data.municipality_count && data.municipalities.every(m =>
        /^[a-z][a-z0-9_]{0,79}$/.test(m.id) && typeof m.name === 'string' &&
        Number.isFinite(m.latitude) && m.latitude >= -90 && m.latitude <= 90 && Number.isFinite(m.longitude) && m.longitude >= -180 && m.longitude <= 180 &&
        Number.isInteger(m.service_count) && m.service_count >= 0 && typeof m.coverage === 'string' && typeof m.availability_lookup === 'boolean' &&
        Array.isArray(m.tools) && m.tools.every(t => typeof t === 'string') && Array.isArray(m.limitations) && m.limitations.every(t => typeof t === 'string') &&
        Array.isArray(m.links) && m.links.every(l => l && typeof l.label === 'string' && typeof l.url === 'string') &&
        Array.isArray(m.sources) && m.sources.every(l => l && typeof l.label === 'string' && typeof l.url === 'string')) &&
      data.total_service_count === data.municipalities.reduce((n, m) => n + m.service_count, 0) &&
      Array.isArray(data.national_capabilities) && data.national_capabilities.every(n => n && typeof n.title === 'string' && typeof n.description === 'string' && typeof n.url === 'string');
  }
  function setupMap() {
    if (!window.L) { el('map-error').hidden = false; el('portugal').disabled = true; return; }
    try {
      map = L.map(el('map'), {scrollWheelZoom: false, minZoom: 3, maxZoom: 16}).setView([39.7, -8], 6);
      // Browser caching and Referer defaults are preserved; only visible tiles load.
      L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 16, keepBuffer: 0, updateWhenIdle: true,
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      }).on('tileerror', () => { el('map-error').hidden = false; }).addTo(map);
      el('portugal').addEventListener('click', () => map.fitBounds([[30, -32], [42.3, -6]], {padding: [12, 12]}));
    } catch { el('map-error').hidden = false; map = null; }
    el('portugal').disabled = !map;
  }
  function choose(id, move = true) {
    const m = snapshot.municipalities.find(m => m.id === id);
    if (!m) return;
    selected = id;
    for (const b of el('list').querySelectorAll('button')) b.setAttribute('aria-pressed', String(b.dataset.id === id));
    const detail = el('detail'); detail.replaceChildren(); detail.hidden = false;
    const title = make('h3', m.name); title.id = 'coverage-selected'; detail.append(title);
    detail.append(make('p', m.service_count + ' ' + c.services), make('p', m.coverage), make('h4', c.limits));
    const limits = make('ul'); m.limitations.forEach(t => limits.append(make('li', t))); detail.append(limits);
    detail.append(make('h4', c.tools));
    const tools = make('ul', undefined, 'coverage-tools');
    m.tools.forEach(t => { const li = make('li'); li.append(make('code', t)); tools.append(li); }); detail.append(tools);
    m.links.forEach(l => { const href = internalLink(l.url); if (href) detail.append(link(l.label, href)); });
    if (m.id === 'ponte_de_lima' && m.availability_lookup) detail.append(link(c.appointment, '/vagas', true));
    detail.append(make('h4', c.sources));
    m.sources.forEach(s => { const href = sourceLink(s.url); if (href) detail.append(link(s.label, href)); });
    if (map && move) map.setView([m.latitude, m.longitude], 10);
  }
  function distance(lat1, lon1, lat2, lon2) {
    const r = Math.PI / 180, a = Math.sin((lat2 - lat1) * r / 2) ** 2 + Math.cos(lat1 * r) * Math.cos(lat2 * r) * Math.sin((lon2 - lon1) * r / 2) ** 2;
    return 6371 * 2 * Math.asin(Math.min(1, Math.sqrt(a)));
  }
  function nearest() {
    if (!position) return;
    if (!snapshot || snapshot.municipalities.length === 0) { el('location').textContent = c.pending; return; }
    const ranked = snapshot.municipalities.map(m => ({m, km: distance(position.latitude, position.longitude, m.latitude, m.longitude)})).sort((a, b) => a.km - b.km);
    el('location').textContent = c.nearest + ': ' + ranked[0].m.name + ' · ' + ranked[0].km.toLocaleString(c.language, {maximumFractionDigits: 1}) + ' ' + c.distance + ' ' + c.localOnly;
    // Do not pan, zoom or add a geolocation marker: tile URLs must not reveal position.
  }
  function render() {
    el('list').replaceChildren();
    if (map) markers.forEach(m => m.remove()); markers = [];
    snapshot.municipalities.forEach(m => {
      const li = make('li'), button = make('button'); button.type = 'button'; button.dataset.id = m.id;
      button.append(make('span', m.name), make('small', m.service_count + ' ' + c.services));
      button.addEventListener('click', () => choose(m.id)); li.append(button); el('list').append(li);
      if (map) {
        const marker = L.marker([m.latitude, m.longitude], {title: m.name, alt: m.name, keyboard: true,
          icon: L.divIcon({className: 'coverage-marker' + (m.availability_lookup ? ' coverage-marker-availability' : ''), iconSize: [22, 22], iconAnchor: [11, 11]})});
        marker.bindTooltip(make('span', m.name)).on('click', () => choose(m.id, false)).addTo(map); markers.push(marker);
      }
    });
    const next = snapshot.municipalities.find(m => m.id === selected) || snapshot.municipalities[0];
    if (next) choose(next.id, false);
    else { selected = null; el('detail').replaceChildren(); el('detail').hidden = true; }
    el('national').replaceChildren();
    snapshot.national_capabilities.forEach(n => {
      const li = make('li'); li.append(make('h3', n.title), make('p', n.description));
      const href = internalLink(n.url); if (href) li.append(link(c.select + ' ↗', href)); el('national').append(li);
    });
    el('metadata').textContent = c.generated + ': ' + snapshot.generated_at + ' (UTC) · ' + c.verified + ': ' + snapshot.verified_on + '. ' + c.snapshotNote;
    el('metadata').hidden = false; el('notice').textContent = snapshot.notice; nearest();
  }
  async function refresh() {
    const current = ++generation; if (request) request.abort();
    const controller = new AbortController(); request = controller;
    el('status').textContent = c.loading; el('error').hidden = true;
    const timeout = setTimeout(() => controller.abort(), 12000);
    try {
      const response = await fetch('/api/municipal/coverage?lang=' + c.language, {signal: controller.signal, headers: {Accept: 'application/json'}});
      if (!response.ok) throw new Error('source');
      const data = await response.json(); if (current !== generation) return;
      if (!valid(data)) throw new Error('schema');
      snapshot = data; render();
      el('status').textContent = snapshot.municipality_count + ' ' + c.count + ' · ' + snapshot.total_service_count + ' ' + c.services;
    } catch {
      if (current !== generation) return;
      el('status').textContent = snapshot ? c.stale : '';
      el('error').textContent = c.error; el('error').hidden = false;
    } finally { clearTimeout(timeout); }
  }
  el('refresh').addEventListener('click', refresh);
  el('locate').addEventListener('click', () => {
    if (!navigator.geolocation) { el('location').textContent = c.unsupported; return; }
    position = null;
    const current = ++geoGeneration; el('locate').disabled = true; el('location').textContent = c.locating;
    const timer = setTimeout(() => { if (current === geoGeneration) { ++geoGeneration; el('locate').disabled = false; el('location').textContent = c.geoError; } }, 11000);
    try { navigator.geolocation.getCurrentPosition(result => {
      clearTimeout(timer); if (current !== geoGeneration) return;
      el('locate').disabled = false;
      const {latitude, longitude} = result.coords;
      if (!Number.isFinite(latitude) || !Number.isFinite(longitude) || Math.abs(latitude) > 90 || Math.abs(longitude) > 180) { el('location').textContent = c.geoError; return; }
      position = {latitude, longitude}; nearest();
    }, error => {
      clearTimeout(timer); if (current !== geoGeneration) return;
      el('locate').disabled = false; el('location').textContent = error.code === 1 ? c.denied : c.geoError;
    }, {enableHighAccuracy: false, timeout: 10000, maximumAge: 0});
    } catch {
      clearTimeout(timer); el('locate').disabled = false; el('location').textContent = c.geoError;
    }
  });
  window.addEventListener('pagehide', () => { ++generation; ++geoGeneration; if (request) request.abort(); position = null; });
  setupMap(); refresh();
})();
