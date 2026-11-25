class CreateConsentEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :consent_events do |t|
      t.references :consent, null: false, foreign_key: true
      t.string :action, null: false
      t.string :actor, null: false
      t.text :scope
      t.string :term_version, null: false
      t.timestamps
    end
  end
end
