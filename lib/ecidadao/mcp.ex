defmodule Ecidadao.MCP do
  @moduledoc "Minimal, stateless MCP Streamable HTTP JSON-RPC handler."
  alias Ecidadao.{Complaint, Financas, MinhaRua, Observation, PublicFeedback, Siga}

  @version "2025-11-25"
  @supported_versions ~w(2025-11-25 2025-06-18 2025-03-26 2024-11-05)
  @server_version Mix.Project.config()[:version]
  @public_tools ~w(
    siga_visit_guidance
    financas_service_guidance
    prepare_financas_ebalcao
    prepare_street_report
    prepare_complaint
    official_submission_guidance
    sns24_service_guidance
  )

  def public_handle(%{"jsonrpc" => "2.0", "method" => "initialize", "id" => id} = request) do
    {:reply,
     result(id, %{
       protocolVersion: negotiate_version(request),
       capabilities: %{tools: %{listChanged: false}},
       serverInfo: %{name: "ecidadao-public", version: @server_version},
       instructions:
         "Orienta para SIGA, Finanças e SNS 24 e prepara rascunhos de e-balcão, A Minha Rua e reclamações. Serviço independente; não acede a contas, consulta filas ou vagas, cria senhas ou marcações, nem submete pedidos. Não solicite credenciais, identificadores governamentais ou dados clínicos para orientação SNS 24."
     })}
  end

  def public_handle(%{"jsonrpc" => "2.0", "method" => "tools/list", "id" => id}) do
    public_tools = Enum.filter(tools(), &(&1.name in @public_tools))
    {:reply, result(id, %{tools: public_tools})}
  end

  def public_handle(
        %{
          "jsonrpc" => "2.0",
          "method" => "tools/call",
          "id" => id,
          "params" => %{"name" => name}
        } = request
      ) do
    if name in @public_tools,
      do: handle(request),
      else: {:reply, error(id, -32602, "Ferramenta indisponível neste endpoint.")}
  end

  def public_handle(%{"jsonrpc" => "2.0", "method" => "resources/list", "id" => id}),
    do: {:reply, result(id, %{resources: []})}

  def public_handle(%{"jsonrpc" => "2.0", "method" => "resources/read", "id" => id}),
    do: {:reply, error(id, -32602, "Recurso indisponível neste endpoint.")}

  def public_handle(request), do: handle(request)

  # MCP lifecycle: echo the client's version when supported, otherwise offer our latest.
  defp negotiate_version(%{"params" => %{"protocolVersion" => requested}})
       when requested in @supported_versions,
       do: requested

  defp negotiate_version(_request), do: @version

  def handle(%{"jsonrpc" => "2.0", "method" => "initialize", "id" => id} = request) do
    {:reply,
     result(id, %{
       protocolVersion: negotiate_version(request),
       capabilities: %{tools: %{listChanged: false}, resources: %{listChanged: false}},
       serverInfo: %{name: "ecidadao", version: @server_version},
       instructions:
         "Prepara rascunhos de reclamações, ocorrências A Minha Rua e questões e-balcão; consulta filas públicas SIGA e orienta para SIGA e Portal das Finanças. Serviço independente. Nunca afirma que um pedido, senha ou marcação foi submetido; a conclusão ocorre no portal oficial."
     })}
  end

  def handle(%{"jsonrpc" => "2.0", "method" => "notifications/initialized"}), do: :accepted

  def handle(%{"jsonrpc" => "2.0", "method" => "ping", "id" => id}),
    do: {:reply, result(id, %{})}

  def handle(%{"jsonrpc" => "2.0", "method" => "tools/list", "id" => id}) do
    {:reply, result(id, %{tools: tools()})}
  end

  def handle(%{"jsonrpc" => "2.0", "method" => "resources/list", "id" => id}) do
    {:reply,
     result(id, %{
       resources: [
         %{
           uri: EcidadaoWeb.CaptureWidget.uri(),
           name: "Captura de fotografia e localização",
           mimeType: "text/html;profile=mcp-app"
         }
       ]
     })}
  end

  def handle(%{
        "jsonrpc" => "2.0",
        "method" => "resources/read",
        "id" => id,
        "params" => %{"uri" => "ui://ecidadao/capture.html"}
      }) do
    {:reply,
     result(id, %{
       contents: [
         %{
           uri: EcidadaoWeb.CaptureWidget.uri(),
           mimeType: "text/html;profile=mcp-app",
           text: EcidadaoWeb.CaptureWidget.html(),
           _meta: %{
             ui: %{
               prefersBorder: true,
               permissions: %{camera: %{}, geolocation: %{}}
             }
           }
         }
       ]
     })}
  end

  def handle(%{
        "jsonrpc" => "2.0",
        "method" => "tools/call",
        "id" => id,
        "params" => %{"name" => "prepare_public_service_feedback", "arguments" => args}
      }) do
    {:reply,
     result(id, prepared(PublicFeedback.prepare(args), "Dados incompletos ou inválidos."))}
  end

  def handle(%{
        "jsonrpc" => "2.0",
        "method" => "tools/call",
        "id" => id,
        "params" => %{"name" => "prepare_complaint", "arguments" => args}
      }) do
    response =
      case Complaint.prepare(args) do
        {:ok, draft} ->
          %{content: [%{type: "text", text: draft.draft}], structuredContent: draft}

        {:error, errors} ->
          %{
            content: [%{type: "text", text: "Dados incompletos ou inválidos."}],
            structuredContent: %{errors: errors},
            isError: true
          }
      end

    {:reply, result(id, response)}
  end

  def handle(%{
        "jsonrpc" => "2.0",
        "method" => "tools/call",
        "id" => id,
        "params" => %{"name" => "official_submission_guidance"}
      }) do
    guidance = %{
      portal: "https://www.livroreclamacoes.pt/Inicio/",
      steps: [
        "Abra o portal oficial.",
        "Escolha Consumidor(a) / Utente.",
        "Preencha e confirme os dados no portal.",
        "Guarde o comprovativo emitido pelo portal."
      ],
      warning: "O eCidadão não submete reclamações nem emite comprovativos oficiais."
    }

    {:reply,
     result(id, %{
       content: [%{type: "text", text: Enum.join(guidance.steps, " ")}],
       structuredContent: guidance
     })}
  end

  def handle(%{
        "jsonrpc" => "2.0",
        "method" => "tools/call",
        "id" => id,
        "params" => %{"name" => "prepare_street_report", "arguments" => args}
      }) do
    response =
      case MinhaRua.prepare(args) do
        {:ok, draft} ->
          %{content: [%{type: "text", text: draft.draft}], structuredContent: draft}

        {:error, errors} ->
          %{
            content: [%{type: "text", text: "Dados incompletos ou inválidos."}],
            structuredContent: %{errors: errors},
            isError: true
          }
      end

    {:reply, result(id, response)}
  end

  def handle(%{
        "jsonrpc" => "2.0",
        "method" => "tools/call",
        "id" => id,
        "params" => %{"name" => "preview_photo_report", "arguments" => args} = params
      }) do
    response =
      case Observation.preview(args, Map.get(params, "_meta", %{})) do
        {:ok, preview} ->
          %{
            content: [%{type: "text", text: preview.draft <> "\n" <> preview.next_question}],
            structuredContent: preview
          }

        {:error, errors} ->
          %{
            content: [%{type: "text", text: "Faltam factos observáveis para preparar o reporte."}],
            structuredContent: %{errors: errors},
            isError: true
          }
      end

    {:reply, result(id, response)}
  end

  def handle(%{
        "jsonrpc" => "2.0",
        "method" => "tools/call",
        "id" => id,
        "params" => %{"name" => "open_report_camera"}
      }) do
    {:reply,
     result(id, %{
       content: [
         %{
           type: "text",
           text:
             "Abra o cartão para tirar ou selecionar uma fotografia e, se quiser, autorizar a localização. A localização e o destinatário serão confirmados antes de qualquer envio."
         }
       ],
       structuredContent: %{status: "a_aguardar_fotografia", submission_authorized: false}
     })}
  end

  def handle(%{
        "jsonrpc" => "2.0",
        "method" => "tools/call",
        "id" => id,
        "params" => %{"name" => "list_recent_street_reports"}
      }) do
    response =
      case MinhaRua.latest() do
        {:ok, reports} ->
          %{
            content: [
              %{
                type: "text",
                text:
                  "Ocorrências públicas recentes do portal A Minha Rua. Consulte os links oficiais para detalhes."
              }
            ],
            structuredContent: reports
          }

        {:error, _} ->
          %{
            content: [
              %{type: "text", text: "A consulta oficial está temporariamente indisponível."}
            ],
            isError: true
          }
      end

    {:reply, result(id, response)}
  end

  def handle(%{
        "jsonrpc" => "2.0",
        "method" => "tools/call",
        "id" => id,
        "params" => %{"name" => "siga_visit_guidance", "arguments" => args}
      }) do
    {:reply, result(id, prepared(Siga.guide(args), "Não foi possível orientar o percurso SIGA."))}
  end

  def handle(%{
        "jsonrpc" => "2.0",
        "method" => "tools/call",
        "id" => id,
        "params" => %{"name" => "compare_siga_queues", "arguments" => args}
      }) do
    {:reply,
     result(id, prepared(Siga.compare(args), "Não foi possível consultar as filas SIGA."))}
  end

  def handle(%{
        "jsonrpc" => "2.0",
        "method" => "tools/call",
        "id" => id,
        "params" => %{"name" => "financas_service_guidance", "arguments" => args}
      }) do
    {:reply,
     result(
       id,
       prepared(Financas.guide(args), "Não foi possível identificar o serviço das Finanças.")
     )}
  end

  def handle(%{
        "jsonrpc" => "2.0",
        "method" => "tools/call",
        "id" => id,
        "params" => %{"name" => "prepare_financas_ebalcao", "arguments" => args}
      }) do
    {:reply,
     result(id, prepared(Financas.prepare_ebalcao(args), "Dados incompletos ou inválidos."))}
  end

  def handle(%{
        "jsonrpc" => "2.0",
        "method" => "tools/call",
        "id" => id,
        "params" => %{"name" => "sns24_service_guidance", "arguments" => args}
      }) do
    {:reply, result(id, prepared(Ecidadao.Sns24.guide(args), "Percurso SNS 24 inválido."))}
  end

  def handle(%{"jsonrpc" => "2.0", "method" => "tools/call", "id" => id}),
    do: {:reply, error(id, -32602, "Ferramenta ou argumentos inválidos.")}

  def handle(%{"jsonrpc" => "2.0", "id" => id}),
    do: {:reply, error(id, -32601, "Método não encontrado.")}

  def handle(_), do: {:reply, error(nil, -32600, "Pedido JSON-RPC inválido.")}

  def tools do
    [
      %{
        name: "sns24_service_guidance",
        title: "Orientar serviços SNS 24",
        description:
          "Explica percursos oficiais para consultas, exames, renovação de medicação habitual e referenciações no Portal/App SNS 24, em PT ou EN. Não consulta contas, vagas ou dados clínicos; não faz triagem nem submete pedidos. Não envie dados pessoais.",
        inputSchema: %{
          type: "object",
          properties: %{
            service: %{type: "string", enum: Ecidadao.Sns24.services()},
            language: %{type: "string", enum: ["pt", "en"], default: "pt"},
            channel: %{type: "string", enum: ["portal", "app", "both"], default: "both"}
          },
          required: ["service"],
          additionalProperties: false
        },
        annotations: %{readOnlyHint: true, destructiveHint: false, openWorldHint: false}
      },
      %{
        name: "open_report_camera",
        title: "Tirar fotografia para reportar",
        description:
          "Use quando a pessoa quer iniciar um reporte com a câmara ou escolher uma fotografia no ChatGPT. Abre um cartão que pode pedir acesso à câmara e à localização após ação da pessoa. Não envia pedidos a serviços públicos.",
        inputSchema: %{type: "object", properties: %{}, additionalProperties: false},
        outputSchema: %{
          type: "object",
          properties: %{
            status: %{type: "string"},
            submission_authorized: %{type: "boolean"}
          },
          required: ["status", "submission_authorized"],
          additionalProperties: false
        },
        annotations: %{readOnlyHint: true, destructiveHint: false, openWorldHint: false},
        _meta: %{
          "openai/outputTemplate" => "ui://ecidadao/capture.html",
          ui: %{resourceUri: "ui://ecidadao/capture.html"}
        }
      },
      %{
        name: "preview_photo_report",
        title: "Preparar reporte a partir de uma fotografia",
        description:
          "Use quando a pessoa partilha uma fotografia no ChatGPT e quer reportar um problema. Passe apenas factos visíveis na imagem e contexto fornecido pela pessoa; não invente causas, identidades, morada ou GPS. O eCidadão sugere o canal e a próxima confirmação. Não recebe a fotografia nem envia o reporte.",
        inputSchema: %{
          type: "object",
          properties: %{
            observations: %{
              type: "string",
              description:
                "Descrição breve e factual do que é visível na fotografia, sem dados pessoais"
            },
            context_hint: %{
              type: "string",
              enum: ~w(street public_service business unknown),
              description: "Tipo de local ou entidade, apenas se houver indicação suficiente"
            },
            organization_name: %{
              type: "string",
              description:
                "Nome da entidade, se a pessoa o forneceu ou estiver claramente visível"
            }
          },
          required: ["observations"],
          additionalProperties: false
        },
        annotations: %{readOnlyHint: true, destructiveHint: false, openWorldHint: false}
      },
      %{
        name: "prepare_complaint",
        title: "Preparar reclamação de consumo",
        description:
          "Valida dados e produz um rascunho em português para o Livro de Reclamações Eletrónico. Não submete a reclamação.",
        inputSchema: %{
          type: "object",
          properties: %{
            business_name: %{
              type: "string",
              description: "Nome do fornecedor ou prestador de serviços"
            },
            description: %{type: "string", description: "Factos concretos, em ordem cronológica"},
            requested_resolution: %{type: "string", description: "Solução pretendida"},
            consumer_name: %{type: "string"},
            consumer_email: %{type: "string"},
            reference: %{
              type: "string",
              description: "Número de encomenda ou contrato, se existir"
            },
            incident_date: %{type: "string", description: "Data AAAA-MM-DD, se conhecida"}
          },
          required: ["business_name", "description", "requested_resolution"],
          additionalProperties: false
        },
        annotations: %{readOnlyHint: true, destructiveHint: false, openWorldHint: false}
      },
      %{
        name: "prepare_public_service_feedback",
        title: "Preparar reclamação, elogio ou sugestão para um serviço público",
        description:
          "Experimental: prepara localmente um rascunho para o Livro Amarelo e indica o percurso gov.pt adequado. Não contacta portais, não submete nem emite comprovativos. Peça apenas factos necessários, sem identidade, NIF, credenciais ou códigos; identificação e autenticação apenas no portal oficial.",
        inputSchema: %{
          type: "object",
          properties: %{
            type: %{type: "string", enum: PublicFeedback.types()},
            organisation: %{
              type: "string",
              minLength: 1,
              maxLength: 200,
              description: "Entidade pública"
            },
            location: %{
              type: "string",
              maxLength: 200,
              description: "Local de atendimento, se conhecido"
            },
            incident_date: %{
              type: "string",
              maxLength: 10,
              description: "Data válida AAAA-MM-DD, se conhecida; omita se desconhecida"
            },
            subject: %{type: "string", minLength: 1, maxLength: 200},
            description: %{
              type: "string",
              minLength: 1,
              maxLength: 5000,
              description: "Factos, reconhecimento ou proposta, sem dados pessoais"
            },
            requested_resolution: %{
              type: "string",
              maxLength: 1500,
              description: "Resultado, reconhecimento ou melhoria pretendida, se aplicável"
            }
          },
          required: ~w(type organisation subject description),
          additionalProperties: false
        },
        annotations: %{
          readOnlyHint: true,
          destructiveHint: false,
          idempotentHint: true,
          openWorldHint: false
        }
      },
      %{
        name: "official_submission_guidance",
        title: "Como apresentar no portal oficial",
        description: "Indica o portal e os passos gerais para apresentar a reclamação preparada.",
        inputSchema: %{type: "object", properties: %{}, additionalProperties: false},
        annotations: %{readOnlyHint: true, destructiveHint: false, openWorldHint: false}
      },
      %{
        name: "prepare_street_report",
        title: "Preparar ocorrência A Minha Rua",
        description:
          "Valida e organiza um reporte sobre espaço público. Não envia dados à autarquia; o nome, email, consentimento e reCAPTCHA são preenchidos no portal oficial.",
        inputSchema: %{
          type: "object",
          properties: %{
            district: %{type: "string", description: "Distrito da ocorrência"},
            municipality: %{type: "string", description: "Município da ocorrência"},
            parish: %{type: "string", description: "Freguesia da ocorrência"},
            address: %{type: "string", description: "Morada que poderá ficar pública"},
            category: %{type: "string", enum: MinhaRua.categories()},
            subject: %{type: "string", description: "Assunto curto"},
            description: %{
              type: "string",
              description: "Descrição dos factos, sem dados pessoais; poderá ficar pública"
            }
          },
          required: ~w(district municipality parish address category subject description),
          additionalProperties: false
        },
        annotations: %{readOnlyHint: true, destructiveHint: false, openWorldHint: false}
      },
      %{
        name: "list_recent_street_reports",
        title: "Consultar ocorrências recentes A Minha Rua",
        description:
          "Lê até dez ocorrências recentes da página pública A Minha Rua, com data de consulta e links oficiais. Não pesquisa o histórico completo nem filtra por município.",
        inputSchema: %{type: "object", properties: %{}, additionalProperties: false},
        annotations: %{readOnlyHint: true, destructiveHint: false, openWorldHint: true}
      },
      %{
        name: "siga_visit_guidance",
        title: "Orientar marcação ou senha SIGA",
        description:
          "Indica o percurso oficial para agendar atendimento, consultar filas ou obter uma senha. Não cria marcação nem senha.",
        inputSchema: %{
          type: "object",
          properties: %{purpose: %{type: "string", enum: ~w(appointment queues ticket)}},
          required: ["purpose"],
          additionalProperties: false
        },
        annotations: %{readOnlyHint: true, destructiveHint: false, openWorldHint: false}
      },
      %{
        name: "compare_siga_queues",
        title: "Comparar filas públicas SIGA",
        description:
          "Consulta os tempos públicos de espera para uma entidade e tipo de senha num distrito, calcula distância em linha reta a partir da localização indicada e ordena balcões abertos. A pesquisa pode não cobrir distritos vizinhos. Não inclui viagem nem emite senha.",
        inputSchema: %{
          type: "object",
          properties: %{
            district: %{
              type: "string",
              description: "Nome ou número do distrito SIGA, por exemplo Porto"
            },
            entity: %{
              type: "string",
              description: "Nome da entidade SIGA, por exemplo Autoridade Tributária e Aduaneira"
            },
            ticket_type: %{
              type: "string",
              description: "Tipo de senha, por exemplo Atendimento Geral"
            },
            latitude: %{type: "number", description: "Latitude confirmada pela pessoa"},
            longitude: %{type: "number", description: "Longitude confirmada pela pessoa"},
            radius_km: %{
              type: "number",
              description: "Raio em quilómetros, de 1 a 100; padrão 40"
            }
          },
          required: ~w(district entity ticket_type latitude longitude),
          additionalProperties: false
        },
        annotations: %{readOnlyHint: true, destructiveHint: false, openWorldHint: true}
      },
      %{
        name: "financas_service_guidance",
        title: "Encontrar serviço no Portal das Finanças",
        description:
          "Encaminha para IRS, IMI, pagamentos, certidões ou e-balcão no portal oficial. Não acede a dados fiscais nem à conta da pessoa.",
        inputSchema: %{
          type: "object",
          properties: %{
            service: %{type: "string", enum: ~w(ebalcao irs imi pagamentos certidoes outro)}
          },
          required: ["service"],
          additionalProperties: false
        },
        annotations: %{readOnlyHint: true, destructiveHint: false, openWorldHint: false}
      },
      %{
        name: "prepare_financas_ebalcao",
        title: "Preparar questão para o e-balcão",
        description:
          "Organiza assunto e mensagem para o e-balcão da AT. Peça apenas os factos necessários, sem passwords, códigos ou NIF. Não autentica nem envia o pedido.",
        inputSchema: %{
          type: "object",
          properties: %{
            subject: %{type: "string", description: "Questão a esclarecer, até 200 caracteres"},
            message: %{
              type: "string",
              description:
                "Factos e pedido de esclarecimento, até 5000 caracteres; sem identificadores sensíveis"
            },
            tax_area: %{
              type: "string",
              description: "Área sugerida, se conhecida; confirmar categoria no portal"
            }
          },
          required: ~w(subject message),
          additionalProperties: false
        },
        annotations: %{readOnlyHint: true, destructiveHint: false, openWorldHint: false}
      }
    ]
  end

  defp prepared({:ok, %{status: "consulta_publica_nao_reserva"} = value}, _error) do
    summary =
      value.locations
      |> Enum.map(fn place ->
        "#{place.name}: #{place.distance_km} km, #{place.state}, #{if(place.open, do: "#{place.wait_minutes || "?"} min de espera", else: "sem tempo disponível")}."
      end)

    text =
      [
        "Filas públicas SIGA consultadas em #{value.observed_at}.",
        if(summary == [],
          do: "Nenhum balcão encontrado no raio indicado.",
          else: Enum.join(summary, "\n")
        ),
        value.note
      ]
      |> Enum.join("\n")

    %{content: [%{type: "text", text: text}], structuredContent: value}
  end

  defp prepared({:ok, value}, _error) do
    message =
      value[:draft] || value[:steps] ||
        "Consulta concluída. Confirme os dados e a disponibilidade no portal oficial."

    %{content: [%{type: "text", text: message}], structuredContent: value}
  end

  defp prepared({:error, errors}, message) do
    %{
      content: [%{type: "text", text: message}],
      structuredContent: %{errors: errors},
      isError: true
    }
  end

  defp result(id, value), do: %{jsonrpc: "2.0", id: id, result: value}

  defp error(id, code, message),
    do: %{jsonrpc: "2.0", id: id, error: %{code: code, message: message}}
end
