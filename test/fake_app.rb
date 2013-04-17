require 'active_record'
require 'action_controller/railtie'

# database
if ENV['TRAVIS'].present?
  ActiveRecord::Base.configurations = {'test' => {:adapter => 'postgresql', :database => 'supercharged_test', :username => "postgres"}}
else
  ActiveRecord::Base.configurations = {'test' => {:adapter => 'sqlite3', :database => ':memory:'}}
end
ActiveRecord::Base.establish_connection('test')

# config
app = Class.new(Rails::Application)
app.config.secret_token = "3b7cd727ee24e8444053437c36cc66c4"
app.config.session_store :cookie_store, :key => "_fakeapp_session"
app.config.active_support.deprecation = :log
app.initialize!

#migrations
ActiveRecord::Base.silence do
  ActiveRecord::Migration.verbose = false
  ActiveRecord::Schema.define :version => 0 do

    create_table "charges_state_transitions", :force => true do |t|
      t.integer  "charges_id"
      t.string   "charges_type"
      t.string   "event"
      t.string   "from"
      t.string   "to"
      t.datetime "created_at"
    end

    add_index "charges_state_transitions", ["charges_id"], :name => "index_charges_state_transitions_on_charges_id"

    create_table "charges", :force => true do |t|
      t.integer  "amount",                                     :null => false
      t.integer  "user_id",                                    :null => false
      t.string   "external_transaction_id"
      t.text     "params"
      t.string   "state",                   :default => "new", :null => false
      t.datetime "created_at",                                 :null => false
      t.datetime "updated_at",                                 :null => false
      t.integer  "user_transaction_id"
      t.string   "error"
      t.integer  "approved_by"
      t.text     "reject_reason"
      t.decimal  "real_amount"
    end

    add_index "charges", ["approved_by"], :name => "index_charges_on_approved_by"
    add_index "charges", ["state"], :name => "index_charges_on_state"
    add_index "charges", ["user_id"], :name => "index_charges_on_user_id"

  end
end

# helpers
Object.const_set(:ApplicationHelper, Module.new)
