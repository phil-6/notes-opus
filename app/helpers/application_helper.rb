module ApplicationHelper
  include Pagy::Frontend

  def note_card_class(color)
    "note-card-#{color || 'gray'}"
  end
end
