class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :token_authenticatable, :authentication_keys => [:login]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :name

  attr_accessible :login

  validates_presence_of :username
  validates :username,
    :uniqueness => {
      :case_sensitive => false
    }

  has_many :memberships, :dependent => :destroy
  has_many :organizations, :through => :memberships

  has_many :participations, :dependent => :destroy
  has_many :projects, :through => :participations

  has_many :broadcast_reads, :dependent => :delete_all
  has_many :broadcasts, :through => :broadcast_reads

  has_many :notifications, :dependent => :delete_all
  has_many :subscriptions, :source => :project, :through => :notifications

  scope :real, where("email NOT LIKE ?", "%@demoaccount.com")
  scope :demo, where("email LIKE ?", "%@demoaccount.com")

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def gravatar_url(size = 64)
    "https://secure.gravatar.com/avatar/#{Digest::MD5.hexdigest(self.email)}?s=#{size.to_i}&d=#{CGI::escape("http://i.imgur.com/ASEqU.png")}"
  end

  def demo?
    !!self.email.match(/@demoaccount.com\z/i)
  end

  def create_demo_data
    users = ["Fred Astair", "Rick Rack", "Nemo Relic", "David Handsome"]

    o1=Organization.create!(:name => "Big Company")
    Membership.create!(:organization_id => o1.id, :user_id => self.id)

    o2=Organization.create!(:name => "Freelancing")
    Membership.create!(:organization_id => o2.id, :user_id => self.id)

    u = []
    users.each do |user|
      pass = SecureRandom.hex(8)
      u += [User.create!(:name => user, :username =>user.downcase.gsub(/\s+/, "."), :email => SecureRandom.hex(8) + "@demoaccount.com", :password => pass, :password_confirmation => pass)]
      Membership.create!(:organization_id => o1.id, :user_id => u.last.id)
    end

    p=Project.create!(:name => "Agi Project", :start => Date.today, :end => 38.days.from_now, :state => :ongoing, :organization_id => o1.id)
    Participation.create!(:user_id => u[0].id, :project_id => p.id)
    Participation.create!(:user_id => u[1].id, :project_id => p.id)
    Status.create!(:text => "Customer asked for the Layout", :link => nil, :source => "Comment", :user_id => u[1].id, :project_id => p.id)
    Status.create!(:text => "Ok, Delivering it during today", :link => nil, :source => "Comment", :user_id => u[0].id, :project_id => p.id)
    p=Project.create!(:name => "Doomed", :start => 8.days.ago, :end => 124.days.from_now, :state => :on_hold, :organization_id => o1.id)
    Participation.create!(:user_id => u[0].id, :project_id => p.id)
    Participation.create!(:user_id => u[1].id, :project_id => p.id)
    Participation.create!(:user_id => u[2].id, :project_id => p.id)
    Participation.create!(:user_id => u[3].id, :project_id => p.id)
    Status.create!(:text => "Dont need to spell out the dependency", :link => "http://github.com/rails/rails/commit/b227a9a94838aebb8fa6b9b6f69f100d7e516a0c", :source => "Github", :user_id => u[3].id, :project_id => p.id)
    Status.create!(:text => "Ok, David that's enough", :link => nil, :source => "Comment", :user_id => u[2].id, :project_id => p.id)
    Status.create!(:text => "Come on this project is doomed!", :link => nil, :source => "Comment", :user_id => u[3].id, :project_id => p.id)
    p=Project.create!(:name => "Cash Cow", :start => 120.days.ago, :end => 7.months.from_now, :state => :ongoing, :organization_id => o1.id)
    Participation.create!(:user_id => u[1].id, :project_id => p.id)
    Participation.create!(:user_id => u[2].id, :project_id => p.id)
    Participation.create!(:user_id => u[3].id, :project_id => p.id)
    Status.create!(:text => "Project is going smooth!", :link => nil, :source => "Comment", :user_id => u[2].id, :project_id => p.id)
    Status.create!(:text => "No need for parenthesis here", :link => "http://github.com/rails/rails/commit/67df21f8954073ddc7f3409ec618c953f97cb412", :source => "Github", :user_id => u[1].id, :project_id => p.id)
    Status.create!(:text => "There's some pizza in the kitchen", :link => nil, :source => "Comment", :user_id => u[1].id, :project_id => p.id)
    Status.create!(:text => "Too bad I'm not at the office", :link => nil, :source => "Comment", :user_id => u[3].id, :project_id => p.id)
    p=Project.create!(:name => "Portal Project", :start => 3.months.from_now, :end => 7.months.from_now, :state => :ongoing, :organization_id => o2.id)
    Participation.create!(:user_id => self.id, :project_id => p.id)
    Status.create!(:text => "Remember to use jQuery this time", :link => nil, :source => "Comment", :user_id => self.id, :project_id => p.id)
    p=Project.create!(:name => "Personal Homepage", :start => 4.days.ago, :end => 2.weeks.from_now, :state => :completed, :organization_id => o2.id)
    Status.create!(:text => "Add task foo:install (where foo is plugin) as a shortcutinstall:migrations and foo:install:assets", :link => "http://github.com/rails/rails/commit/43215de208a6feabdbc5f4ec29551beef4f89885", :source => "Github", :user_id => self.id, :project_id => p.id)
    Status.create!(:text => "Comment internal railties tasks.", :link => "http://github.com/rails/rails/commit/c7aea81a39e130bfddd26537dea5f3626e2a009e", :source => "Github", :user_id => self.id, :project_id => p.id)
    Status.create!(:text => "Update documentation for new tasks", :link => "http://github.com/rails/rails/commit/a2c52f100446ab328cbde0e505216a99c602bc57", :source => "Github", :user_id => self.id, :project_id => p.id)
    Participation.create!(:user_id => self.id, :project_id => p.id)
    p=Project.create!(:name => "Garage Project", :start => 2.days.from_now, :end => 14.days.from_now, :state => :ongoing, :organization_id => o2.id)
    Participation.create!(:user_id => self.id, :project_id => p.id)
    Status.create!(:text => "Get the tires out of garage", :link => nil, :source => "Comment", :user_id => self.id, :project_id => p.id)
  end
end
