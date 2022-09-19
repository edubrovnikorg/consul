class CreateNiasSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :nias_sessions do |t|
      t.references :user, default: nil, foreign_key: true, index: { unique: true }
      t.integer :session_index, null: false
      t.string :subject_id, null: false
      t.string :subject_id_format, null: false
      t.integer :user_type, default: 0
      t.integer :login_status, default: 0
      t.integer :logout_status, default: 0


      t.timestamps
      t.index :subject_id
    end
  end
end
