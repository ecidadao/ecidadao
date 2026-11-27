defmodule EcidadaoWeb.LocaleTest do
  use ExUnit.Case, async: true
  import Plug.Test
  alias EcidadaoWeb.{Locale, Router}

  defp page(path, headers \\ []) do
    Enum.reduce(headers, conn(:get, path), fn {key, value}, conn ->
      Plug.Conn.put_req_header(conn, key, value)
    end)
    |> Router.call(Router.init([]))
  end

  test "all public pages render English on the server and keep Portuguese available" do
    for {path, title} <- [
          {"/", "Your next step, made simpler."},
          {"/servicos", "What do you need?"},
          {"/siga", "Compare queues near you."},
          {"/financas", "Prepare your question for e-balcão."},
          {"/reclamacoes", "A clear complaint starts with a good draft."},
          {"/livro-amarelo", "Help improve public services."},
          {"/a-minha-rua", "Help improve public spaces."},
          {"/como-usar", "Use eCidadão in a few steps."},
          {"/privacidade", "Privacy"},
          {"/termos", "Terms of use"},
          {"/apoio", "Support"}
        ] do
      en = page(path <> "?lang=en")
      assert en.status == 200
      assert en.resp_body =~ "<html lang=\"en\">"
      assert en.resp_body =~ title
      assert en.resp_body =~ "prefers-color-scheme:dark"
      assert page(path <> "?lang=pt").resp_body =~ "<html lang=\"pt\">"
    end
  end

  test "explicit choice overrides saved preference and browser language" do
    en = page("/?lang=en", [{"cookie", "ecidadao_language=pt"}, {"accept-language", "pt-PT"}])
    assert en.resp_cookies["ecidadao_language"].value == "en"
    assert en.resp_cookies["ecidadao_language"].http_only

    assert page("/apoio", [{"cookie", "ecidadao_language=en"}, {"accept-language", "pt-PT"}]).resp_body =~
             "<html lang=\"en\">"

    assert Plug.Conn.get_resp_header(en, "content-language") == ["en"]
    assert Plug.Conn.get_resp_header(en, "cache-control") == ["private, no-cache"]
  end

  test "browser language uses supported regional tags and quality, with a safe fallback" do
    for {header, expected} <- [
          {"fr, en-GB;q=0.8, pt;q=0.5", "en"},
          {"en;q=0.1, pt-PT;q=0.9", "pt"},
          {"en;q=0", "pt"},
          {"en;q=invalid", "pt"},
          {"de", "pt"}
        ] do
      assert page("/?lang=invalid", [{"accept-language", header}]).resp_body =~
               "<html lang=\"#{expected}\">"
    end

    assert page("/?lang[]=en").resp_body =~ "<html lang=\"pt\">"
  end

  test "translated categories retain the official value and API stays unchanged" do
    body = page("/a-minha-rua?lang=en").resp_body
    assert body =~ ~s(<option value="Animais Abandonados">Abandoned animals</option>)
    conn = conn(:post, "/api/complaints/prepare", %{}) |> Router.call(Router.init([]))
    assert conn.status == 422
    assert conn.resp_body =~ "Campo obrigatório."
  end

  test "translations are escaped for their HTML and script contexts" do
    assert Locale.t("<script>&", "en") == "&lt;script&gt;&amp;"
    assert Locale.tj("</script>", "pt") == ~s("\\u003c/script\\u003e")
  end

  test "public feedback is discoverable, distinguishes consumers and never asks for identity" do
    assert page("/?lang=en").resp_body =~ ~s(href="/livro-amarelo")

    assert page("/reclamacoes?lang=en").resp_body =~
             "Is this about service from a public organisation?"

    body = page("/livro-amarelo?lang=en").resp_body
    assert body =~ ~s(href="/reclamacoes")
    assert body =~ "Draft — not submitted"
    assert body =~ "Public organisation"
    assert body =~ "Requested outcome or improvement"
    refute body =~ ~s(name="consumer_name")
    refute body =~ ~s(name="consumer_email")

    assert page("/privacidade?lang=en").resp_body =~
             "without storing them in a database or sending them to gov.pt"

    assert page("/termos?lang=en").resp_body =~
             "does not represent Livro Amarelo or submit this feedback"

    for {field, limit} <- [
          {"organisation", 200},
          {"location", 200},
          {"incident_date", 10},
          {"description", 5000},
          {"requested_resolution", 1500}
        ] do
      {:error, errors} =
        Ecidadao.PublicFeedback.prepare(%{
          "type" => "complaint",
          field => String.duplicate("a", limit + 1)
        })

      messages = Jason.decode!(Locale.client_messages("en"))

      assert Enum.any?(
               errors,
               &(&1.field == field and messages[&1.message] == "Maximum #{limit} characters.")
             )
    end
  end

  test "feedback discards pending drafts after edits and offers a clipboard fallback" do
    body = page("/livro-amarelo?lang=en").resp_body
    [_, script] = Regex.run(~r/<script>\s*(\(\(\) => \{.*?\}\)\(\);)\s*<\/script>/s, body)

    harness = """
    const assert = require('node:assert/strict');
    const vm = require('node:vm');
    const elements = new Map();
    function element(id) {
      if (!elements.has(id)) elements.set(id, {hidden: id === 'feedback-result', textContent: '', disabled: false, handlers: {}, attrs: {},
        addEventListener(event, fn) { this.handlers[event] = fn; },
        setAttribute(k, v) { this.attrs[k] = v; }, removeAttribute(k) { delete this.attrs[k]; if(k === 'href') delete this.href; },
        focus() { this.focused = true; }});
      return elements.get(id);
    }
    let finish, selected = false;
    const context = {document: {getElementById: element, createRange: () => ({selectNodeContents() {selected = true;}})},
      window: {getSelection: () => ({removeAllRanges() {}, addRange() {}})},
      navigator: {clipboard: {writeText: async () => {throw Error('denied');}}},
      FormData: class { *[Symbol.iterator]() {yield ['type', 'complaint'];} },
      AbortController, URL, ui: x => x,
      fetch: () => new Promise(resolve => {finish = resolve;})};
    vm.runInNewContext(process.argv[1], context);
    const form = element('feedback-form'), result = element('feedback-result'), draft = element('feedback-draft');
    const payload = {draft: 'RASCUNHO', official_portal: 'https://www.gov.pt/servicos/fazer-elogio-a-um-servico-publico'};
    async function respond() {finish({ok: true, json: async () => payload});}
    (async () => {
      for (const event of ['input', 'change']) {
        const pending = form.handlers.submit({preventDefault() {}});
        form.handlers[event](); await respond(); await pending;
        assert.equal(result.hidden, true); assert.equal(draft.textContent, '');
        assert.equal(element('feedback-portal').href, undefined);
        assert.equal(element('feedback-prepare').disabled, false);
      }
      const pending = form.handlers.submit({preventDefault() {}});
      await respond(); await pending;
      assert.equal(result.hidden, false); assert.equal(draft.textContent, 'RASCUNHO');
      assert.equal(element('feedback-portal').href, payload.official_portal);
      await element('feedback-copy').handlers.click();
      assert.ok(selected); assert.ok(draft.focused);
      assert.match(element('feedback-message').textContent, /Automatic copying failed/);
      form.handlers.input();
      assert.equal(result.hidden, true); assert.equal(draft.textContent, '');
    })().catch(error => {console.error(error); process.exitCode = 1;});
    """

    {output, status} = System.cmd("node", ["-e", harness, script], stderr_to_stdout: true)
    assert status == 0, output
  end

  test "feedback without JavaScript posts privately and offers official alternatives" do
    for locale <- ["pt", "en"] do
      body = page("/livro-amarelo?lang=" <> locale).resp_body
      [form] = Regex.run(~r/<form\b[^>]*id="feedback-form"[^>]*>/, body)
      assert form =~ ~s(method="post")
      assert form =~ ~s(action="/api/public-feedback/prepare")
      [_, fallback] = Regex.run(~r/<noscript>(.*?)<\/noscript>/s, body)

      for type <- Ecidadao.PublicFeedback.types() do
        {:ok, feedback} =
          Ecidadao.PublicFeedback.prepare(%{
            "type" => type,
            "organisation" => "Test",
            "subject" => "Test",
            "description" => "Test"
          })

        assert fallback =~ ~s(href="#{feedback.official_portal}")
      end
    end

    assert page("/livro-amarelo?lang=en").resp_body =~
             "Alternatively, continue directly on gov.pt:"

    assert page("/termos?lang=en").resp_body =~ "Last updated: 26 November 2026."
  end
end
