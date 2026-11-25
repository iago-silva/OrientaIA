class ReviewRecord < ApplicationRecord
  class TransitionError < StandardError; end

  ITEMS = %w[summary next_steps transcript].freeze
  belongs_to :orientation
  belongs_to :meeting, optional: true
  belongs_to :work_version, optional: true
  belongs_to :feedback, optional: true
  has_many :audit_events, -> { order(:created_at, :id) }, dependent: :destroy
  has_many :processing_requests, dependent: :destroy

  validates :title, presence: true
  validates :kind, inclusion: { in: %w[meeting work feedback] }
  validates :status, inclusion: { in: %w[pending editing published rejected] }
  validates :revision, numericality: { only_integer: true, greater_than: 0 }
  scope :pending, -> { where(status: %w[pending editing]) }
  scope :published, -> { where(status: "published") }

  def content
    original_content.merge(edited_content)
  end

  def publication_scope
    Digest::SHA256.hexdigest([ id, revision, included_items.sort, content ].to_json)
  end

  def editable!
    raise TransitionError, "Este registro já foi finalizado. A decisão publicada foi preservada." unless %w[pending editing].include?(status)
  end

  def event!(actor, action, details = {})
    audit_events.create!(actor: actor.name, action: action, revision: revision, details: details)
  end

  def acknowledge!(actor)
    with_lock do
      editable!
      update!(acknowledged_limits: true)
      event!(actor, "limits_acknowledged")
    end
  end

  def mark_source!(actor)
    with_lock do
      editable!
      update!(source_checked: true)
      event!(actor, "source_checked", { evidence: evidence })
    end
  end

  def save_edit!(actor, changes, reason)
    raise TransitionError, "Registre a justificativa da edição." if reason.blank?
    with_lock do
      editable!
      before = content
      clean = changes.to_h.stringify_keys.slice(*ITEMS)
      update!(edited_content: edited_content.merge(clean), justification: reason, status: "editing", revision: revision + 1, included_items: [])
      event!(actor, "edited", { before: before, after: content, justification: reason })
    end
  end

  def select_items!(actor, items)
    with_lock do
      editable!
      clean = Array(items).map(&:to_s).intersection(ITEMS).select { |item| content[item].present? }
      update!(included_items: clean)
      event!(actor, "scope_selected", { items: clean })
    end
  end

  def contest!(actor, note)
    raise TransitionError, "Escreva o motivo da contestação." if note.blank?
    with_lock do
      editable!
      event!(actor, "contested", { note: note })
    end
  end

  def reject!(actor, reason, items = nil)
    raise TransitionError, "Informe o motivo da rejeição." if reason.blank?
    with_lock do
      editable!
      if items.present?
        remaining = included_items - Array(items)
        update!(included_items: remaining)
        event!(actor, "item_rejected", { items: Array(items), reason: reason })
      else
        update!(status: "rejected", included_items: [], justification: reason)
        event!(actor, "rejected", { reason: reason })
      end
    end
  end

  def publish!(actor, expected_revision:, confirmations:, expected_scope: nil)
    with_lock do
      editable!
      raise TransitionError, "A versão mudou. Confira o conteúdo e confirme novamente." unless revision == expected_revision.to_i
      if expected_scope && !ActiveSupport::SecurityUtils.secure_compare(publication_scope, expected_scope)
        raise TransitionError, "Os itens selecionados mudaram em outra janela. Confira o escopo e confirme novamente."
      end
      raise TransitionError, "Leia os limites da IA e confira a fonte antes de publicar." unless acknowledged_limits && source_checked
      raise TransitionError, "Escolha pelo menos um item para compartilhar." if included_items.empty?
      required = %w[read justification transcript scope]
      raise TransitionError, "Confira as quatro declarações antes de publicar." unless required.all? { |key| confirmations[key] == "1" }
      payload = content.slice(*included_items)
      update!(status: "published", published_at: Time.current, published_by: actor.name, published_content: payload)
      if work_version
        work_version.update!(status: "approved")
        work_version.academic_work.update!(status: "reviewed")
        work_version.review_comments.update_all(published_at: Time.current)
      end
      event!(actor, "published", { items: included_items, content: payload, recipient: orientation.student.name, confirmations: confirmations })
    end
  end
end
