/* MoodWave — custom crosshair cursor (shared, self-contained) */
(function () {
  const style = document.createElement('style');
  style.textContent = `
    *, *::before, *::after { cursor: none !important; }

    /* Dot — small white center point */
    #cx-dot {
      position: fixed; width: 5px; height: 5px; border-radius: 50%;
      background: #fff; pointer-events: none; z-index: 10000;
      transform: translate(-50%,-50%);
      transition: opacity .15s, transform .1s;
    }

    /* Ring — orbiting circle */
    #cx-circle {
      position: fixed; width: 34px; height: 34px; border-radius: 50%;
      border: 1px solid rgba(255,255,255,0.5);
      pointer-events: none; z-index: 9999;
      transform: translate(-50%,-50%);
      transition: width .38s cubic-bezier(.22,1,.36,1),
                  height .38s cubic-bezier(.22,1,.36,1),
                  border-color .3s, box-shadow .3s, opacity .15s;
    }

    /* Crosshair lines */
    #cx-h {
      position: fixed; top: 0; left: 0; width: 100%; height: 1px;
      background: rgba(255,255,255,0.07);
      pointer-events: none; z-index: 9997;
      transition: top 0s;
    }
    #cx-v {
      position: fixed; left: 0; top: 0; width: 1px; height: 100%;
      background: rgba(255,255,255,0.07);
      pointer-events: none; z-index: 9997;
      transition: left 0s;
    }

    /* Hover: over buttons/CTA — ring expands with purple glow */
    #cx-circle.on-cta {
      width: 64px; height: 64px;
      border-color: rgba(217,70,239,0.9);
      box-shadow: 0 0 20px rgba(217,70,239,0.45);
    }

    /* Hover: over nav links — ring shrinks tight */
    #cx-circle.on-nav {
      width: 22px; height: 22px;
      border-color: rgba(217,70,239,0.8);
    }
    #cx-visualizer {
      position: fixed; inset: 0; pointer-events: none; z-index: 9998;
    }
  `;
  document.head.appendChild(style);

  // Inject cursor elements as very first children of body
  document.body.insertAdjacentHTML('afterbegin', `
    <canvas id="cx-visualizer"></canvas>
    <div id="cx-h"></div>
    <div id="cx-v"></div>
    <div id="cx-dot"></div>
    <div id="cx-circle"></div>
  `);

  const cxH    = document.getElementById('cx-h');
  const cxV    = document.getElementById('cx-v');
  const cxDot  = document.getElementById('cx-dot');
  const cxCirc = document.getElementById('cx-circle');
  const canvas = document.getElementById('cx-visualizer');
  const ctx = canvas.getContext('2d');

  let mx = 0, my = 0, cx = 0, cy = 0, frameN = 0, state = '';

  function resize() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
  }
  window.addEventListener('resize', resize);
  resize();

  document.addEventListener('mousemove', e => {
    mx = e.clientX; my = e.clientY;
    cxDot.style.left = mx + 'px'; cxDot.style.top = my + 'px';
    cxH.style.top = my + 'px'; cxV.style.left = mx + 'px';

    if (frameN % 2 === 0) {
      const hit = document.elementFromPoint(mx, my);
      const onCta = hit && (
        hit.closest('button') || hit.closest('.btn-main') || hit.closest('.btn-ghost') ||
        hit.closest('.play-ring') || hit.closest('.vibe-circle') || hit.closest('.mood-card')
      );
      const onNav = hit && hit.closest('nav.mw-nav');
      const newState = onCta ? 'cta' : onNav ? 'nav' : '';
      if (newState !== state) {
        state = newState;
        cxCirc.className = state ? 'on-' + state : '';
      }
    }
    frameN++;
  }, { passive: true });

  (function tick() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    const power = (window.mw_current_volume || 0); 
    const freqData = (window.mw_frequency_data || []);
    const mood = window.mw_active_mood_id || 'happy';
    
    cx += (mx - cx) * 0.13;
    cy += (my - cy) * 0.13;
    cxCirc.style.left = cx + 'px';
    cxCirc.style.top  = cy + 'px';

    // ── Draw Symmetrical Neon Circular Visualizer around cursor ──
    if (freqData.length > 0 && power > 0.01) {
      const baseRadius = 32 + (power * 15);
      const bars = 64;
      const step = (Math.PI * 2) / bars;
      const rotation = frameN * 0.005;
      const binCount = Math.min(freqData.length, 64);

      // Color palettes per mood
      const palettes = {
        happy:     ['#FFCC33', '#FF5733'],
        energetic: ['#EF4444', '#ff8800'],
        chill:     ['#00D2FF', '#00ffcc'],
        night:     ['#00D2FF', '#00ffcc'],
        sad:       ['#A855F7', '#D8B4FE'],
        focus:     ['#3B82F6', '#2dd4bf']
      };
      const colors = palettes[mood] || ['#d946ef', '#fff'];

      ctx.save();
      ctx.lineCap = 'round';
      ctx.lineWidth = 2.5;
      ctx.shadowBlur = 8;

      for (let i = 0; i < bars; i++) {
        const dataIndex = i < bars/2 ? i % binCount : (bars - 1 - i) % binCount;
        const val = freqData[dataIndex] || 0;
        const normalizedVal = val / 255;
        const barHeight = Math.pow(normalizedVal, 1.5) * 40 * (1 + power);
        const angle = i * step + rotation;
        
        const x1 = cx + Math.cos(angle) * baseRadius;
        const y1 = cy + Math.sin(angle) * baseRadius;
        const x2 = cx + Math.cos(angle) * (baseRadius + barHeight + 2);
        const y2 = cy + Math.sin(angle) * (baseRadius + barHeight + 2);
        
        const c = colors[i % 2];
        ctx.strokeStyle = c;
        ctx.shadowColor = c;
        
        ctx.beginPath();
        ctx.moveTo(x1, y1);
        ctx.lineTo(x2, y2);
        ctx.stroke();
      }
      ctx.restore();
    }

    frameN++;
    requestAnimationFrame(tick);
  })();

  document.addEventListener('mouseleave', () => {
    cxDot.style.opacity = cxCirc.style.opacity = cxH.style.opacity = cxV.style.opacity = canvas.style.opacity = '0';
  });
  document.addEventListener('mouseenter', () => {
    cxDot.style.opacity = cxCirc.style.opacity = cxH.style.opacity = cxV.style.opacity = canvas.style.opacity = '1';
  });
})();
