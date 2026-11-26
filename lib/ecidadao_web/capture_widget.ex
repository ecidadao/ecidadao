defmodule EcidadaoWeb.CaptureWidget do
  @moduledoc "Photo and location capture UI for an MCP Apps host."

  def uri, do: "ui://ecidadao/capture.html"

  def html do
    """
    <!doctype html>
    <html lang="pt">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Reportar com foto · eCidadão</title>
        <style>
          :root{font:16px system-ui,sans-serif;color:#14392e;background:#fff}*{box-sizing:border-box}
          body{margin:0;padding:20px;max-width:560px}h1{font-size:24px;margin:0 0 8px;letter-spacing:-.03em}
          p{line-height:1.5;color:#4b6258}label{display:block;font-weight:650;margin:18px 0 8px}
          input[type=file],input[type=text]{display:block;width:100%;padding:12px;border:1px solid #b9cec1;border-radius:10px}
          button{border:0;border-radius:10px;padding:13px 18px;background:#15734f;color:white;font:inherit;font-weight:700;cursor:pointer}
          button.secondary{background:#e8f3e8;color:#175f45}button:disabled{opacity:.5;cursor:wait}
          .row{display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin:16px 0}
          .preview{max-width:100%;max-height:260px;border-radius:10px;display:none}
          .note{padding:12px 14px;background:#e8f3e8;border-radius:10px;font-size:14px}
          .status{min-height:24px;font-size:14px}
        </style>
      </head>
      <body>
        <h1>Fotografe. Confirme o local.</h1>
        <p>O ChatGPT ajuda a descrever o problema. O local e a entidade responsável ficam à sua confirmação antes de qualquer envio.</p>
        <label for="photo">Fotografia</label>
        <input id="photo" type="file" accept="image/*" capture="environment">
        <img id="preview" class="preview" alt="Pré-visualização da fotografia selecionada">
        <div class="row"><button id="locate" type="button" class="secondary">Usar localização</button><span id="location-label">Local por confirmar</span></div>
        <label for="place">Local, se preferir escrever</label>
        <input id="place" type="text" maxlength="240" autocomplete="street-address" placeholder="Rua, edifício ou ponto de referência">
        <p class="note">A localização só é pedida quando tocar no botão. Reveja o local antes de reportar. O eCidadão ainda não envia pedidos aos serviços oficiais.</p>
        <div class="row"><button id="continue" type="button">Continuar no ChatGPT</button></div>
        <p id="status" class="status" role="status" aria-live="polite"></p>
        <script>
          const photo = document.getElementById('photo');
          const preview = document.getElementById('preview');
          const locate = document.getElementById('locate');
          const place = document.getElementById('place');
          const locationLabel = document.getElementById('location-label');
          const status = document.getElementById('status');
          const continueButton = document.getElementById('continue');
          let position = null;

          photo.addEventListener('change', () => {
            if (!photo.files?.[0]) return;
            if (preview.src) URL.revokeObjectURL(preview.src);
            preview.src = URL.createObjectURL(photo.files[0]);
            preview.style.display = 'block';
          });

          locate.addEventListener('click', () => {
            if (!navigator.geolocation) {
              status.textContent = 'A localização não está disponível aqui. Indique o local no campo acima.';
              return;
            }
            locate.disabled = true;
            status.textContent = 'A pedir autorização de localização…';
            navigator.geolocation.getCurrentPosition(
              result => {
                position = {
                  latitude: result.coords.latitude,
                  longitude: result.coords.longitude,
                  accuracy_m: Math.round(result.coords.accuracy)
                };
                locationLabel.textContent = 'Localização obtida (precisão aproximada: ' + position.accuracy_m + ' m). Confirme o local.';
                status.textContent = '';
                locate.disabled = false;
              },
              () => {
                position = null;
                status.textContent = 'Não foi possível obter a localização. Pode escrever o local.';
                locate.disabled = false;
              },
              {enableHighAccuracy: true, timeout: 12000, maximumAge: 0}
            );
          });

          continueButton.addEventListener('click', async () => {
            const host = window.openai;
            if (!host?.uploadFile || !host?.setWidgetState || !host?.sendFollowUpMessage) {
              status.textContent = 'Este ChatGPT não suporta o envio pelo cartão. Anexe a fotografia diretamente na conversa.';
              return;
            }
            if (!photo.files?.[0]) {
              status.textContent = 'Tire ou escolha uma fotografia primeiro.';
              return;
            }
            continueButton.disabled = true;
            status.textContent = 'A preparar fotografia…';
            try {
              const {fileId} = await host.uploadFile(photo.files[0], {library: false});
              const location = place.value.trim();
              host.setWidgetState({
                modelContent: {
                  intent: 'Preparar um reporte a partir da fotografia escolhida',
                  location_description_from_user: location || null,
                  device_location_shared_by_user: position,
                  location_confirmed: false,
                  submission_authorized: false
                },
                privateContent: {view: 'awaiting_review'},
                imageIds: [fileId]
              });
              await host.sendFollowUpMessage({prompt: 'Analisa a fotografia anexada pelo cartão e prepara uma prévia factual para o eCidadão. Usa a localização partilhada apenas como pista; pede-me que confirme o local exato e a entidade. Não envies o reporte.'});
              status.textContent = 'Fotografia enviada para análise nesta conversa.';
            } catch (_) {
              status.textContent = 'Não foi possível passar a fotografia ao ChatGPT. Tente anexá-la diretamente na conversa.';
            } finally {
              continueButton.disabled = false;
            }
          });
        </script>
      </body>
    </html>
    """
  end
end
