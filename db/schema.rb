# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20150401220114) do

  create_table "addons", :force => true do |t|
    t.string   "addon_url"
    t.string   "addon_name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "bucket_item_pairs", :force => true do |t|
    t.integer  "bucket_id"
    t.integer  "item_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "bucket_item_pairs", ["bucket_id"], :name => "index_bucket_item_pairs_on_bucket_id"
  add_index "bucket_item_pairs", ["id"], :name => "index_bucket_item_pairs_on_id"
  add_index "bucket_item_pairs", ["item_id"], :name => "index_bucket_item_pairs_on_item_id"

  create_table "bucket_user_pairs", :force => true do |t|
    t.integer  "bucket_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "phone_number"
  end

  create_table "buckets", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "bucket_type"
    t.integer  "items_count", :default => 0
  end

  add_index "buckets", ["id"], :name => "index_buckets_on_id"
  add_index "buckets", ["user_id"], :name => "index_buckets_on_user_id"

  create_table "contact_cards", :force => true do |t|
    t.integer  "bucket_id"
    t.text     "contact_info"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "country_codes", :force => true do |t|
    t.string   "calling_code"
    t.string   "country_code"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "device_tokens", :force => true do |t|
    t.string   "android_device_token"
    t.string   "ios_device_token"
    t.integer  "user_id"
    t.string   "environment"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "emails", :force => true do |t|
    t.string   "From"
    t.string   "FromName"
    t.string   "To"
    t.text     "Cc"
    t.text     "Bcc"
    t.string   "ReplyTo"
    t.text     "Subject"
    t.string   "MessageID"
    t.string   "Date"
    t.text     "MailboxHash"
    t.text     "TextBody"
    t.text     "HtmlBody"
    t.text     "StrippedTextReply"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "item_id"
    t.string   "email"
    t.text     "Attachments"
  end

  create_table "introduction_questions", :force => true do |t|
    t.string   "question_text"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.string   "status",        :default => "live"
  end

  create_table "introduction_responses", :force => true do |t|
    t.string   "response_text"
    t.integer  "introduction_question_id"
    t.boolean  "flagged"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "items", :force => true do |t|
    t.text     "message"
    t.integer  "person_id"
    t.integer  "user_id"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.string   "item_type"
    t.date     "reminder_date"
    t.string   "status",                   :default => "outstanding"
    t.string   "input_method"
    t.integer  "bucket_id"
    t.text     "media_urls"
    t.text     "media_content_types"
    t.text     "buckets_string"
    t.string   "device_timestamp"
    t.float    "latitude"
    t.float    "longitude"
    t.float    "device_request_timestamp"
  end

  add_index "items", ["id"], :name => "index_items_on_id"
  add_index "items", ["latitude"], :name => "index_items_on_latitude"
  add_index "items", ["longitude"], :name => "index_items_on_longitude"
  add_index "items", ["user_id"], :name => "index_items_on_user_id"

  create_table "push_notifications", :force => true do |t|
    t.integer  "device_token_id"
    t.text     "message"
    t.integer  "badge_count"
    t.integer  "item_id"
    t.integer  "bucket_id"
    t.string   "status"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "rpush_apps", :force => true do |t|
    t.string   "name",                                   :null => false
    t.string   "environment"
    t.text     "certificate"
    t.string   "password"
    t.integer  "connections",             :default => 1, :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "type",                                   :null => false
    t.string   "auth_key"
    t.string   "client_id"
    t.string   "client_secret"
    t.string   "access_token"
    t.datetime "access_token_expiration"
  end

  create_table "rpush_feedback", :force => true do |t|
    t.string   "device_token", :limit => 64,  :null => false
    t.datetime "failed_at",                   :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "app_id",       :limit => 255
  end

  add_index "rpush_feedback", ["device_token"], :name => "index_rapns_feedback_on_device_token"

  create_table "rpush_notifications", :force => true do |t|
    t.integer  "badge"
    t.string   "device_token",      :limit => 64
    t.string   "sound",                            :default => "default"
    t.string   "alert"
    t.text     "data"
    t.integer  "expiry",                           :default => 86400
    t.boolean  "delivered",                        :default => false,     :null => false
    t.datetime "delivered_at"
    t.boolean  "failed",                           :default => false,     :null => false
    t.datetime "failed_at"
    t.integer  "error_code"
    t.text     "error_description", :limit => 255
    t.datetime "deliver_after"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.boolean  "alert_is_json",                    :default => false
    t.string   "type",                                                    :null => false
    t.string   "collapse_key"
    t.boolean  "delay_while_idle",                 :default => false,     :null => false
    t.text     "registration_ids"
    t.integer  "app_id",                                                  :null => false
    t.integer  "retries",                          :default => 0
    t.string   "uri"
    t.datetime "fail_after"
    t.boolean  "processing",                       :default => false,     :null => false
    t.integer  "priority"
    t.text     "url_args"
    t.string   "category"
  end

  add_index "rpush_notifications", ["app_id", "delivered", "failed", "deliver_after"], :name => "index_rapns_notifications_multi"
  add_index "rpush_notifications", ["delivered", "failed"], :name => "index_rpush_notifications_multi"

  create_table "sms", :force => true do |t|
    t.string   "ToCountry"
    t.string   "ToState"
    t.string   "SmsMessageSid"
    t.string   "NumMedia"
    t.string   "ToCity"
    t.string   "FromZip"
    t.string   "SmsSid"
    t.string   "FromState"
    t.string   "SmsStatus"
    t.string   "FromCity"
    t.text     "Body"
    t.string   "FromCountry"
    t.string   "To"
    t.string   "ToZip"
    t.string   "MessageSid"
    t.string   "AccountSid"
    t.string   "From"
    t.string   "ApiVersion"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "item_id"
    t.text     "MediaContentTypes"
    t.text     "MediaUrls"
  end

  add_index "sms", ["id"], :name => "index_sms_on_id"
  add_index "sms", ["item_id"], :name => "index_sms_on_item_id"

  create_table "tokens", :force => true do |t|
    t.string   "token_string"
    t.integer  "user_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "addon_id"
    t.string   "status",       :default => "live"
  end

  create_table "twilio_messengers", :force => true do |t|
    t.string   "body"
    t.string   "to_number"
    t.string   "from_number"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "phone"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "country_code"
    t.string   "email"
    t.integer  "number_items",   :default => 0
    t.integer  "number_buckets", :default => 0
    t.string   "calling_code"
  end

  add_index "users", ["id"], :name => "index_users_on_id"
  add_index "users", ["phone"], :name => "index_users_on_phone"

end
