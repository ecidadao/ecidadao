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
          {"/siga", "Compare queues near you."},
          {"/financas", "Prepare your question for e-balcão."},
          {"/reclamacoes", "A clear complaint starts with a good draft."},
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
end
