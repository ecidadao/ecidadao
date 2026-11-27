defmodule Ecidadao.ServiceDirectoryTest do
  use ExUnit.Case, async: true
  import Plug.Test
  alias Ecidadao.ServiceDirectory
  alias EcidadaoWeb.{Locale, Router}

  defp page(locale) do
    conn(:get, "/servicos?lang=" <> locale) |> Router.call(Router.init([]))
  end

  test "curated entries have unique stable identifiers, translated guidance and safe destinations" do
    entries = ServiceDirectory.all()
    assert length(entries) == 10
    assert length(Enum.uniq_by(entries, & &1.id)) == length(entries)

    for entry <- entries do
      assert entry.id =~ ~r/^[a-z-]+$/
      refute Locale.text(entry.title, "en") == entry.title
      refute Locale.text(entry.description, "en") == entry.description

      if entry.official do
        uri = URI.parse(entry.url)
        assert uri.scheme == "https"
        assert uri.host == "www.gov.pt"
        assert String.starts_with?(uri.path, "/servicos/")
      else
        assert entry.url in [
                 "/saude",
                 "/siga",
                 "/financas",
                 "/a-minha-rua",
                 "/reclamacoes",
                 "/livro-amarelo"
               ]
      end
    end
  end

  test "both routes deliver usable cards before JavaScript and never reflect query input" do
    for locale <- ["pt", "en"] do
      response = page(locale)
      assert response.status == 200
      body = response.resp_body
      assert body =~ Locale.text("Percursos selecionados", locale)

      assert body =~
               Locale.text(
                 "Pesquise pelo assunto que pretende resolver. O que escreve fica apenas nesta página: não é enviado, guardado ou colocado no endereço.",
                 locale
               )

      refute body =~ "Sem pesquisa externa"
      refute body =~ "No external search"
      refute body =~ "Filtra palavras"
      refute body =~ "Filters words"
      assert body =~ ~s(<label for="service-search">)
      assert body =~ ~s(id="service-search" type="search")
      assert body =~ ~s(id="service-search-status" role="status")
      assert body =~ ~s(id="service-empty" class="notice" hidden)
      assert body =~ ~s(10 #{Locale.text("serviços encontrados", locale)})
      assert body =~ ~s(href="https://www.gov.pt/servicos/renovar-o-cartao-de-cidadao")

      for entry <- ServiceDirectory.all() do
        assert body =~ ~s(data-service-id="#{entry.id}")
        assert body =~ ~s(href="#{entry.url}")
        [opening] = Regex.run(~r/<article[^>]+data-service-id="#{entry.id}"[^>]*>/, body)
        refute opening =~ "hidden"
      end

      refute body =~ "<form"
    end

    body =
      conn(:get, "/servicos?q=private-search-marker")
      |> Router.call(Router.init([]))
      |> Map.fetch!(:resp_body)

    refute body =~ "private-search-marker"
    home = conn(:get, "/") |> Router.call(Router.init([])) |> Map.fetch!(:resp_body)
    assert home =~ ~r/<nav>.*href="\/servicos"/s
    assert home =~ ~r/class="hero-actions">.*?href="\/servicos"/s
  end

  test "actual client script filters bilingual whole words, announces counts and safely clears" do
    for locale <- ["pt", "en"] do
      body = page(locale).resp_body
      [_, script] = Regex.run(~r/<script>\s*(\(\(\) => \{.*?\}\)\(\);)\s*<\/script>/s, body)

      fixtures =
        Enum.map(ServiceDirectory.all(), fn e ->
          %{id: e.id, aliases: e.aliases, title: Locale.text(e.title, locale)}
        end)

      harness = """
      const assert = require('node:assert/strict');
      const vm = require('node:vm');
      const cards = JSON.parse(process.argv[2]).map(e => ({
        id: e.id, hidden: false, dataset: {search: e.aliases},
        querySelector: () => ({textContent: e.title})
      }));
      const input = {value: '', handlers: {}, addEventListener(k, fn) {this.handlers[k] = fn;}};
      const status = {textContent: ''}, empty = {hidden: true};
      const elements = {'service-search': input, 'service-search-status': status, 'service-empty': empty};
      const context = {document: {getElementById: id => elements[id], querySelectorAll: () => cards}};
      vm.runInNewContext(process.argv[1], context);
      function search(value, ids) {
        input.value = value; input.handlers.input();
        assert.deepEqual(cards.filter(c => !c.hidden).map(c => c.id), ids, value);
        assert.equal(empty.hidden, ids.length !== 0);
        assert.ok(status.textContent.startsWith(ids.length + ' '));
      }
      search('RENOVAR CARTÃO', ['cc-renewal']);
      search('renovar cartao', ['cc-renewal']);
      search('renew citizen card', ['cc-renewal']);
      search('renew my citizen card', ['cc-renewal']);
      search('quero renovar o meu cartao', ['cc-renewal']);
      search('preciso de alterar a minha morada', ['cc-address', 'cc-address-confirmation']);
      search('I need to renew my citizen card', ['cc-renewal']);
      search('Como posso renovar o meu cartão, por favor?', ['cc-renewal']);
      search('I would like to renew my citizen card please', ['cc-renewal']);
      search('alterar morada', ['cc-address', 'cc-address-confirmation']);
      search('certidão', ['tax-certificates']);
      search('tax', ['financas', 'tax-certificates']);
      search('reclamar', ['consumer-complaint', 'public-feedback']);
      search('zzzinexistentezzz', []);
      search('quero zzzinexistentezzz', []);
      search('I need zzzinexistentezzz', []);
      search('I need to renew my citizen card zzzinexistentezzz', []);
      search('preciso de confirmar a minha morada', ['cc-address-confirmation']);
      search('quero uma certidão de não dívida', ['tax-certificates']);
      search('I want a tax certificate', ['tax-certificates']);
      search('taxi', []);
      search('<img src=x onerror=alert(1)>', []);
      search('', cards.map(c => c.id));
      search('  ', cards.map(c => c.id));
      input.value = 'reclamar'; input.handlers.search();
      assert.equal(cards.filter(c => !c.hidden).length, 2);
      """

      {output, status} =
        System.cmd("node", ["-e", harness, script, Jason.encode!(fixtures)],
          stderr_to_stdout: true
        )

      assert status == 0, output
      refute script =~ "innerHTML"
      refute script =~ "fetch("
      refute script =~ "localStorage"
      refute script =~ "sessionStorage"
      refute script =~ "location"
    end
  end
end
