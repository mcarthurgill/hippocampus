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

ActiveRecord::Schema.define(:version => 20140708233324) do

  create_table "bucket_item_pairs", :force => true do |t|
    t.integer  "bucket_id"
    t.integer  "item_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "buckets", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "bucket_type"
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

  create_table "items", :force => true do |t|
    t.text     "message",       :limit => 255
    t.integer  "person_id"
    t.integer  "user_id"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.string   "item_type"
    t.date     "reminder_date"
    t.string   "status",                       :default => "outstanding"
    t.string   "input_method"
    t.integer  "bucket_id"
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
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "item_id"
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
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "country_code"
  end

end
