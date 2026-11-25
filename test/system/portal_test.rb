require "application_system_test_case"
require_relative "../support/portal_data"

class PortalTest < ApplicationSystemTestCase
  include PortalData
  setup { build_portal }

  test "student navigates every section and mobile sidebar" do
    browser_sign_in(@student)
    assert_text "Sua pesquisa, um passo adiante."
    { "Trabalhos" => "Cada versão, uma evolução.", "Análise ABNT" => "Mais cuidado com a forma.", "Agenda" => "Um passo de cada vez.", "Reuniões" => "Cada conversa, um caminho registrado.", "Submissões" => "Sua pesquisa encontra novos espaços.", "Privacidade" => "Privacidade e consentimentos" }.each do |link, heading|
      within(".side-nav") { click_link link }
      assert_selector "h1", text: heading
    end
    page.current_window.resize_to(390, 844)
    find("[data-sidebar-toggle]").click
    assert_selector ".sidebar.open"
    within(".side-nav") { click_link "Painel" }
    assert_selector "h1", text: "Sua pesquisa, um passo adiante."
  end

  test "professor opens dialogs and publishes only reviewed selected content" do
    browser_sign_in(@professor)
    visit review_record_path(@record)
    assert_text "SÍNTESE PRIVADA NÃO PUBLICADA"
    click_button "Conferir fonte e contexto"
    assert_selector "dialog[open]"
    click_button "Marcar trecho conferido"
    assert_text "Trecho-fonte marcado como conferido."
    click_button "Li e compreendi os limites da IA"
    assert_text "Limites reconhecidos"
    check "Incluir síntese"
    click_button "Salvar itens selecionados"
    assert_text "Itens selecionados: Síntese"
    assert_button "Aprovar e publicar v1", disabled: true
    %w[read justification transcript scope].each { |key| find("input[name='confirmations[#{key}]']").check }
    click_button "Aprovar e publicar v1"
    assert_selector "h1", text: "Prontuário publicado."
    assert @record.reload.published_content.key?("summary")
    assert_not @record.published_content.key?("transcript")
  end

  test "formation prevents access until reading correct answer and commitment" do
    @student.update!(training_step: 0, training_completed_at: nil)
    browser_sign_in(@student)
    assert_selector "h1", text: "Pesquisar com IA exige olhar crítico."
    click_button "Concluir apresentação e continuar"
    choose "Não incorporar a referência; verificar sua existência e pertinência em fontes confiáveis e discutir a dúvida com a orientadora."
    click_button "Continuar"
    assert_button "Concluir formação e acessar meu espaço", disabled: true
    check "Li, compreendi e assumo este compromisso de uso responsável."
    click_button "Concluir formação e acessar meu espaço"
    assert_selector "h1", text: "Sua pesquisa, um passo adiante."
  end

  test "student creates a document uploads a version and records blocked processing" do
    browser_sign_in(@student)
    visit academic_works_path
    click_button "Novo documento"
    fill_in "Título do documento", with: "Artigo da pesquisa"
    click_button "Criar documento"
    assert_text "Documento criado."
    page.execute_script(<<~JAVASCRIPT)
      const transfer = new DataTransfer();
      transfer.items.add(new File(["%PDF-1.4"], "documento-arrastado.pdf", {type:"application/pdf"}));
      document.querySelector(".upload-drop").dispatchEvent(new DragEvent("drop", {bubbles:true,dataTransfer:transfer}));
    JAVASCRIPT
    assert_text "documento-arrastado.pdf"
    Tempfile.create([ "orienta-browser-upload", ".pdf" ]) do |file|
      file.binmode
      file.write(DemoDocument.pdf("Pesquisa", "Conteúdo de exemplo"))
      file.flush
      attach_file "work_version_file", file.path, make_visible: true
      choose "Dados sensíveis"
      fill_in "O que mudou nesta versão?", with: "Primeira versão do artigo"
      click_button "Salvar rascunho"
      assert_text "Rascunho salvo."
    end
    assert_text "Primeira versão do artigo"
    click_button "Solicitar análise local"
    assert_text "bloqueada"
    assert_equal "blocked", ProcessingRequest.last.status
  end

  private

  def browser_sign_in(user)
    visit login_path
    fill_in "E-mail", with: user.email
    fill_in "Senha", with: "pesquisa2026"
    click_button "Entrar no meu espaço"
    assert_selector ".sidebar"
  end
end
