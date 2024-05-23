# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_05_22_090823) do

  create_table "comments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "comment", null: false
    t.bigint "organization_id", null: false
    t.bigint "video_id", null: false
    t.bigint "system_admin_id"
    t.bigint "user_id"
    t.bigint "viewer_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organization_id"], name: "index_comments_on_organization_id"
    t.index ["system_admin_id"], name: "index_comments_on_system_admin_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
    t.index ["video_id"], name: "index_comments_on_video_id"
    t.index ["viewer_id"], name: "index_comments_on_viewer_id"
  end

  create_table "folders", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "organization_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organization_id"], name: "index_folders_on_organization_id"
  end

  create_table "organization_viewers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "organization_id", null: false
    t.bigint "viewer_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organization_id"], name: "index_organization_viewers_on_organization_id"
    t.index ["viewer_id"], name: "index_organization_viewers_on_viewer_id"
  end

  create_table "organizations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.boolean "is_valid", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "plan"
    t.boolean "payment_success", default: false
    t.string "customer_id"
    t.string "subscription_id"
  end

  create_table "replies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "reply", null: false
    t.bigint "organization_id", null: false
    t.bigint "system_admin_id"
    t.bigint "user_id"
    t.bigint "viewer_id"
    t.bigint "comment_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["comment_id"], name: "index_replies_on_comment_id"
    t.index ["organization_id"], name: "index_replies_on_organization_id"
    t.index ["system_admin_id"], name: "index_replies_on_system_admin_id"
    t.index ["user_id"], name: "index_replies_on_user_id"
    t.index ["viewer_id"], name: "index_replies_on_viewer_id"
  end

  create_table "system_admins", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "image"
    t.string "provider"
    t.string "uid"
    t.string "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.index ["confirmation_token"], name: "index_system_admins_on_confirmation_token", unique: true
    t.index ["email"], name: "index_system_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_system_admins_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_system_admins_on_unlock_token", unique: true
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "image"
    t.string "provider"
    t.string "uid"
    t.string "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.integer "role", default: 0, null: false
    t.bigint "organization_id", default: 1, null: false
    t.boolean "is_valid", default: true, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "video_folders", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "video_id", null: false
    t.bigint "folder_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["folder_id"], name: "index_video_folders_on_folder_id"
    t.index ["video_id"], name: "index_video_folders_on_video_id"
  end

  create_table "videos", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title"
    t.integer "audience_rate"
    t.datetime "open_period"
    t.boolean "range", default: false
    t.boolean "comment_public", default: false
    t.boolean "login_set", default: false
    t.boolean "popup_before_video", default: false
    t.boolean "popup_after_video", default: false
    t.string "data_url"
    t.boolean "is_valid", default: true, null: false
    t.bigint "organization_id", null: false
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["organization_id"], name: "index_videos_on_organization_id"
    t.index ["user_id"], name: "index_videos_on_user_id"
  end

  create_table "viewers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "image"
    t.string "provider"
    t.string "uid"
    t.string "oauth_token"
    t.datetime "oauth_expires_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.boolean "is_valid", default: true, null: false
    t.index ["confirmation_token"], name: "index_viewers_on_confirmation_token", unique: true
    t.index ["email"], name: "index_viewers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_viewers_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_viewers_on_unlock_token", unique: true
  end

  add_foreign_key "comments", "organizations"
  add_foreign_key "comments", "system_admins"
  add_foreign_key "comments", "users"
  add_foreign_key "comments", "videos"
  add_foreign_key "comments", "viewers"
  add_foreign_key "folders", "organizations"
  add_foreign_key "organization_viewers", "organizations"
  add_foreign_key "organization_viewers", "viewers"
  add_foreign_key "replies", "comments"
  add_foreign_key "replies", "organizations"
  add_foreign_key "replies", "system_admins"
  add_foreign_key "replies", "users"
  add_foreign_key "replies", "viewers"
  add_foreign_key "users", "organizations"
  add_foreign_key "video_folders", "folders"
  add_foreign_key "video_folders", "videos"
  add_foreign_key "videos", "organizations"
  add_foreign_key "videos", "users"
end
