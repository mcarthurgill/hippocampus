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

ActiveRecord::Schema.define(:version => 20160125200914) do

  create_table "addons", :force => true do |t|
    t.string   "addon_url"
    t.string   "addon_name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "addresses", :force => true do |t|
    t.string   "phone"
    t.string   "street"
    t.string   "street_two"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "object_type"
    t.string   "local_key"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "country"
  end

  create_table "bucket_item_pairs", :force => true do |t|
    t.integer  "bucket_id"
    t.integer  "item_id"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "object_type", :default => "bucket_item_pair"
  end

  add_index "bucket_item_pairs", ["bucket_id"], :name => "index_bucket_item_pairs_on_bucket_id"
  add_index "bucket_item_pairs", ["id"], :name => "index_bucket_item_pairs_on_id"
  add_index "bucket_item_pairs", ["item_id"], :name => "index_bucket_item_pairs_on_item_id"

  create_table "bucket_tag_pairs", :force => true do |t|
    t.integer  "bucket_id"
    t.integer  "tag_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "bucket_user_pairs", :force => true do |t|
    t.integer  "bucket_id"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.string   "phone_number"
    t.string   "name",         :default => "You"
    t.datetime "last_viewed"
    t.string   "unseen_items", :default => "no"
    t.integer  "group_id"
    t.string   "object_type",  :default => "bucket_user_pair"
  end

  add_index "bucket_user_pairs", ["bucket_id"], :name => "index_bucket_user_pairs_on_bucket_id"
  add_index "bucket_user_pairs", ["group_id"], :name => "index_bucket_user_pairs_on_group_id"
  add_index "bucket_user_pairs", ["id"], :name => "index_bucket_user_pairs_on_id"
  add_index "bucket_user_pairs", ["phone_number"], :name => "index_bucket_user_pairs_on_phone_number"

  create_table "buckets", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "bucket_type"
    t.integer  "items_count",         :default => 0
    t.string   "visibility",          :default => "private"
    t.integer  "creation_reason"
    t.text     "authorized_user_ids"
    t.string   "object_type",         :default => "bucket"
    t.string   "local_key"
    t.float    "device_timestamp"
    t.string   "cached_item_message"
    t.string   "relation_level",      :default => "recent"
    t.text     "tags_array"
  end

  add_index "buckets", ["id"], :name => "index_buckets_on_id"
  add_index "buckets", ["user_id"], :name => "index_buckets_on_user_id"

  create_table "calls", :force => true do |t|
    t.string   "AccountSid"
    t.string   "ToZip"
    t.string   "FromState"
    t.string   "Called"
    t.string   "FromCountry"
    t.string   "CallerCountry"
    t.string   "CalledZip"
    t.string   "Direction"
    t.string   "FromCity"
    t.string   "CalledCountry"
    t.string   "CallerState"
    t.string   "CallSid"
    t.string   "CalledState"
    t.string   "From"
    t.string   "CallerZip"
    t.string   "FromZip"
    t.string   "CallStatus"
    t.string   "ToCity"
    t.string   "ToState"
    t.string   "To"
    t.string   "ToCountry"
    t.string   "CallerCity"
    t.string   "ApiVersion"
    t.string   "Caller"
    t.string   "CalledCity"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "RecordingUrl"
    t.string   "action"
    t.string   "controller"
    t.string   "format"
    t.string   "Digits"
    t.string   "RecordingDuration"
    t.string   "RecordingSid"
    t.string   "TranscriptionSid"
    t.string   "TranscriptionText"
    t.string   "TranscriptionStatus"
    t.string   "TranscriptionUrl"
    t.integer  "item_id"
    t.integer  "medium_id"
  end

  create_table "contact_cards", :force => true do |t|
    t.integer  "bucket_id"
    t.text     "contact_info"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.text     "media_urls"
    t.text     "media_content_types"
    t.string   "object_type",         :default => "contact_card"
    t.text     "contact_details"
  end

  add_index "contact_cards", ["bucket_id"], :name => "index_contact_cards_on_bucket_id"
  add_index "contact_cards", ["id"], :name => "index_contact_cards_on_id"

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
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.string   "object_type",          :default => "device_token"
  end

  add_index "device_tokens", ["id"], :name => "index_device_tokens_on_id"
  add_index "device_tokens", ["user_id"], :name => "index_device_tokens_on_user_id"

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
    t.text     "mandrill_events"
  end

  add_index "emails", ["From"], :name => "index_emails_on_From"
  add_index "emails", ["To"], :name => "index_emails_on_To"
  add_index "emails", ["id"], :name => "index_emails_on_id"
  add_index "emails", ["item_id"], :name => "index_emails_on_item_id"

  create_table "groups", :force => true do |t|
    t.string   "group_name"
    t.integer  "user_id"
    t.integer  "number_buckets", :default => 0
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "object_type",    :default => "group"
  end

  add_index "groups", ["id"], :name => "index_groups_on_id"
  add_index "groups", ["user_id"], :name => "index_groups_on_user_id"

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
    t.text     "links"
    t.string   "audio_url"
    t.text     "buckets_array"
    t.string   "object_type",              :default => "item"
    t.string   "local_key"
    t.text     "media_cache"
    t.text     "message_html_cache"
    t.text     "message_full_cache"
  end

  add_index "items", ["id"], :name => "index_items_on_id"
  add_index "items", ["latitude"], :name => "index_items_on_latitude"
  add_index "items", ["longitude"], :name => "index_items_on_longitude"
  add_index "items", ["user_id"], :name => "index_items_on_user_id"

  create_table "links", :force => true do |t|
    t.integer  "response_status"
    t.string   "url"
    t.string   "scheme"
    t.string   "host"
    t.string   "root_url"
    t.text     "title"
    t.text     "best_title"
    t.text     "description"
    t.text     "images"
    t.text     "images_with_size"
    t.text     "best_image",       :limit => 255
    t.text     "favicon",          :limit => 255
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.string   "object_type",                     :default => "link"
    t.string   "local_key"
    t.string   "raw_url"
  end

  create_table "media", :force => true do |t|
    t.string   "media_url"
    t.integer  "width"
    t.integer  "height"
    t.string   "media_type"
    t.string   "media_extension"
    t.string   "media_name"
    t.integer  "user_id"
    t.integer  "item_id"
    t.string   "thumbnail_url"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.float    "duration"
    t.string   "item_local_key"
    t.string   "local_key"
    t.string   "object_type",        :default => "medium"
    t.text     "transcription_text"
  end

  create_table "outgoing_messages", :force => true do |t|
    t.string   "to_number"
    t.string   "from_number"
    t.text     "message",     :limit => 255
    t.string   "reason"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "media_url"
  end

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

  add_index "push_notifications", ["id"], :name => "index_push_notifications_on_id"

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

  create_table "setup_questions", :force => true do |t|
    t.string   "question"
    t.integer  "percentage"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "build_type"
    t.integer  "parent_id"
  end

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

  add_index "sms", ["From"], :name => "index_sms_on_From"
  add_index "sms", ["id"], :name => "index_sms_on_id"
  add_index "sms", ["item_id"], :name => "index_sms_on_item_id"

  create_table "tags", :force => true do |t|
    t.string   "tag_name"
    t.integer  "user_id"
    t.string   "local_key"
    t.integer  "number_buckets", :default => 0
    t.string   "object_type",    :default => "tag"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "tokens", :force => true do |t|
    t.string   "token_string"
    t.integer  "user_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "addon_id"
    t.string   "status",       :default => "live"
    t.string   "object_type",  :default => "token"
  end

  add_index "tokens", ["id"], :name => "index_tokens_on_id"
  add_index "tokens", ["user_id"], :name => "index_tokens_on_user_id"

  create_table "use_cases", :force => true do |t|
    t.text     "text"
    t.string   "image_url"
    t.float    "order"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "phone"
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.string   "country_code"
    t.string   "email"
    t.integer  "number_items",           :default => 0
    t.integer  "number_buckets",         :default => 0
    t.string   "calling_code"
    t.string   "name"
    t.integer  "setup_completion",       :default => 25
    t.string   "time_zone",              :default => "America/Chicago"
    t.string   "salt"
    t.string   "object_type",            :default => "user"
    t.string   "local_key"
    t.integer  "medium_id"
    t.string   "membership",             :default => "none"
    t.integer  "number_buckets_allowed"
    t.datetime "last_activity",          :default => '2016-02-01 16:10:36'
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["id"], :name => "index_users_on_id"
  add_index "users", ["phone"], :name => "index_users_on_phone"

  create_table "waitlists", :force => true do |t|
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
