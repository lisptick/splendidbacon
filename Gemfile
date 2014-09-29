source "https://rubygems.org"

gem "rails", "3.2.9"

gem "devise", "~> 2.1.2"
gem "net-ldap"
gem "foreman", "~> 0.51.0"
gem "haml", "~> 3.1.6"
gem "haml-rails"
gem "jquery-rails"
gem "kaminari", "~> 0.14.1"
gem "kronic", "~> 1.1.3"
gem "nokogiri", "~> 1.5.5"
gem "rake"
gem "RedCloth", "~> 4.2.9"
gem "simple_form", "~> 1.2.2"
gem "validates_timeliness", "~> 3.0.14"
gem "yajl-ruby"
gem "thin", "~> 1.5.0"
gem "cancan"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem "sass-rails", "~> 3.2.5"
  gem "coffee-rails", "~> 3.2.2"
  gem "uglifier"
  gem "font-awesome-sass-rails"
end

group :development do
  gem "sqlite3"
end

group :production do
  gem "pg"
  gem 'mysql2',          '0.3.12b5', :platform => :ruby
  gem 'jdbc-mysql',      '5.1.28',   :platform => :jruby
  gem 'thinking-sphinx', '~> 3.1.1'
  gem 'yaml_db'

end

group :test, :development do
  gem "rspec-rails"
  gem "steak"
  gem "akephalos"
  gem "awesome_print", :require => "ap"
  gem "ffaker"
end

group :test do
  gem "factory_girl_rails"
  gem "capybara"
  gem "launchy"
  gem "autotest"
  gem "database_cleaner"
end
