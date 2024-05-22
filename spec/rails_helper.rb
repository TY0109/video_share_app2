# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
require 'vcr'

# spec/support配下のファイルを読み込めるようにコメントアウトを外す
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  Bullet.enable = true
  Bullet.raise = true
  Bullet.unused_eager_loading_enable = false

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    Rails.application.config.action_mailer.default_url_options = { host: 'localhost:3000' }
  end

  config.before(:each) do
    Rails.cache.clear
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.around(:each) do |example|
    Bullet.profile do
      example.run
    end
  end

  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  
  # deviseのヘルパーメソッドをrequest, systemテストで使用できるようにする
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system

  # Factory_botのメソッドを使用する際に、クラス名の指定を省略できるようにする
  # 例) user = FactoryBot.create(:user) →  user = create(:user)
  config.include FactoryBot::Syntax::Methods

  # ヘルパーメソッドを使用できるようにする
  # ※ vimeoへのアップとvimeoからの削除メソッドをヘルパーメソッドとして切り出している。
  config.include Helpers
  
  # VCRを使用する場合はコメントアウト解除
  # cf https://github.com/bo-oz/vimeo_me2/blob/master/spec/spec_helper.rb
  # VCR.configure do |config|
  #   config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  #   config.hook_into :webmock
  #   config.ignore_localhost = false
  # end
end
