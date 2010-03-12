# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100221010704) do

  create_table "agents", :force => true do |t|
    t.string   "name",         :null => false
    t.integer  "user_id"
    t.datetime "created_at"
    t.text     "saved"
    t.string   "class_name",   :null => false
    t.string   "filename",     :null => false
    t.integer  "size"
    t.string   "content_type"
    t.foreign_key "users", :column => "user_id", :dependent => nil
  end

  create_table "agents_games", :id => false, :force => true do |t|
    t.integer "agent_id"
    t.integer "game_id"
    t.foreign_key "agents", :column => "agent_id", :dependent => nil
    t.foreign_key "games", :column => "game_id", :dependent => nil
  end

  add_index "agents_games", ["agent_id", "game_id"], :name => "index_agents_games_on_agent_id_and_game_id", :unique => true

  create_table "games", :force => true do |t|
    t.string   "name",         :null => false
    t.integer  "user_id",      :null => false
    t.datetime "created_at"
    t.text     "saved"
    t.string   "class_name",   :null => false
    t.string   "filename",     :null => false
    t.integer  "size"
    t.string   "content_type"
    t.foreign_key "users", :column => "user_id", :dependent => nil
  end

  create_table "participants", :id => false, :force => true do |t|
    t.integer "result_id"
    t.integer "agent_id"
    t.integer "player_id"
    t.integer "score"
    t.text    "result"
    t.boolean "winner"
    t.text    "saved"
    t.foreign_key "agents", :column => "agent_id", :dependent => nil
    t.foreign_key "players", :column => "player_id", :dependent => nil
    t.foreign_key "results", :column => "result_id", :dependent => nil
  end

  add_index "participants", ["result_id", "agent_id", "player_id"], :name => "index_participants_on_result_id_and_agent_id_and_player_id", :unique => true

  create_table "players", :force => true do |t|
    t.string  "name",                       :null => false
    t.integer "game_id"
    t.boolean "required", :default => true, :null => false
    t.foreign_key "games", :column => "game_id", :dependent => nil
  end

  create_table "results", :force => true do |t|
    t.integer  "game_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.text     "result",     :null => false
    t.text     "saved"
    t.foreign_key "games", :column => "game_id", :dependent => nil
    t.foreign_key "users", :column => "user_id", :dependent => nil
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

end
