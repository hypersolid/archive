# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120608130722) do

  create_table "achievements_ladders", :id => false, :force => true do |t|
    t.integer  "achievement_id"
    t.integer  "ladder_id"
    t.datetime "created_at"
  end

  add_index "achievements_ladders", ["ladder_id", "achievement_id"], :name => "index_achievements_ladders_on_ladder_id_and_achievement_id"

  create_table "answers", :force => true do |t|
    t.integer  "question_id"
    t.integer  "user_id"
    t.integer  "tournament_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "claimed_points"
    t.integer  "acquired_points"
    t.integer  "quiz_id"
    t.string   "answer"
    t.float    "time"
    t.float    "time_lag"
  end

  add_index "answers", ["question_id"], :name => "index_answers_on_question_id"
  add_index "answers", ["user_id"], :name => "index_answers_on_user_id"

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "image"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authentications", ["user_id", "image"], :name => "index_authentications_on_user_id_and_image"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "email_fallbacks", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token",      :null => false
  end

  add_index "email_fallbacks", ["id"], :name => "index_email_fallbacks_on_id"
  add_index "email_fallbacks", ["token"], :name => "index_email_fallbacks_on_token"

  create_table "facebook_friends", :force => true do |t|
    t.integer "user_id",                   :null => false
    t.integer "friend_id"
    t.integer "facebook_uid", :limit => 8, :null => false
  end

  add_index "facebook_friends", ["user_id", "facebook_uid"], :name => "index_facebook_friends_on_user_id_and_facebook_uid", :unique => true

  create_table "ladders", :force => true do |t|
    t.integer  "tournament_id"
    t.integer  "user_id"
    t.integer  "position"
    t.integer  "score",                                             :default => 0
    t.integer  "combined_score",                                    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "set_at"
    t.boolean  "up"
    t.boolean  "down"
    t.decimal  "prize",               :precision => 8, :scale => 2, :default => 0.0
    t.integer  "wings_count",                                       :default => 0
    t.integer  "wing1_id"
    t.integer  "wing2_id"
    t.integer  "position_old"
    t.datetime "position_changed_at"
  end

  add_index "ladders", ["id"], :name => "index_ladders_on_id"
  add_index "ladders", ["tournament_id", "position"], :name => "index_ladders_on_tournament_id_and_position"
  add_index "ladders", ["tournament_id", "user_id"], :name => "index_ladders_on_tournament_id_and_user_id"

  create_table "payments", :force => true do |t|
    t.integer  "user_id"
    t.string   "status"
    t.string   "transaction_id"
    t.text     "query_string"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "amount",         :precision => 8, :scale => 2
    t.string   "mode"
  end

  add_index "payments", ["user_id"], :name => "index_payments_on_user_id"

  create_table "prizes", :force => true do |t|
    t.integer  "tournament_id"
    t.integer  "position"
    t.decimal  "amount",        :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "prizes", ["tournament_id", "position"], :name => "index_prizes_on_tournament_id_and_position"

  create_table "questions", :force => true do |t|
    t.integer  "difficulty"
    t.integer  "category_id"
    t.string   "question"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "best_user_id"
    t.string   "correct_answer"
    t.string   "wrong_answers"
    t.float    "best_time"
    t.float    "avg_time"
  end

  add_index "questions", ["id"], :name => "index_questions_on_id", :unique => true

  create_table "quizzes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "tournament_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "paid",          :default => false
  end

  add_index "quizzes", ["user_id"], :name => "index_quizzes_on_user_id"

  create_table "relations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "wingman_id"
    t.string   "request_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "invited_by"
    t.string   "email"
    t.string   "state"
    t.string   "name"
    t.string   "facebook_image_url"
    t.integer  "tournament_id",      :null => false
  end

  add_index "relations", ["user_id", "state"], :name => "index_relations_on_user_id_and_state"
  add_index "relations", ["wingman_id", "state"], :name => "index_relations_on_wingman_id_and_state"

  create_table "sessions", :force => true do |t|
    t.string   "session_id",                       :null => false
    t.text     "data",       :limit => 2147483647
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "tournament_counters", :force => true do |t|
    t.integer  "tournament_id"
    t.integer  "counter"
    t.integer  "difficulty"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tournament_counters", ["tournament_id"], :name => "index_tournament_counters_on_tournament_id"

  create_table "tournaments", :force => true do |t|
    t.integer  "time_limit"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "best_time_bonus"
    t.integer  "avg_time_bonus"
    t.integer  "points_per_second"
    t.integer  "avg_score",              :default => 0
    t.boolean  "deploy_average_scoring", :default => true
    t.integer  "cost_pence",             :default => 100
    t.integer  "existing_user_credits",  :default => 0
    t.integer  "new_user_credits",       :default => 2
    t.integer  "passes",                 :default => 2
    t.integer  "default_best_time",      :default => 10
    t.integer  "default_avg_time",       :default => 20
  end

  add_index "tournaments", ["id"], :name => "index_tournaments_on_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                         :default => "",   :null => false
    t.string   "encrypted_password",             :limit => 128, :default => "",   :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                 :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin"
    t.string   "name"
    t.string   "gender"
    t.integer  "credits",                                       :default => 0
    t.integer  "facebook_uid",                   :limit => 8
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "real_name"
    t.string   "address"
    t.string   "post_code"
    t.boolean  "email_movement",                                :default => true
    t.boolean  "email_final_summary",                           :default => true
    t.boolean  "email_wingman_request_accepted",                :default => true
    t.boolean  "popup_nudge",                                   :default => true
    t.string   "token"
    t.string   "status_message"
    t.boolean  "popup_invite",                                  :default => true
    t.boolean  "email_wall_message",                            :default => true
    t.boolean  "email_overtaken",                               :default => true
    t.datetime "last_fb_post_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "wall_messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wall_messages", ["sender_id", "recipient_id"], :name => "index_wall_messages_on_sender_id_and_recipient_id"

end
