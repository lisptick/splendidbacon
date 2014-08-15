class Project < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  attr_accessor :user

  STATES = {:ongoing => "Ongoing",
            :on_hold => "On Hold",
            :completed => "Completed"}

  cattr_accessor :STATES
  @@STATES = STATES

  has_many :participations, :dependent => :destroy
  has_many :users, :through => :participations

  belongs_to :organization

  has_many :statuses, :dependent => :destroy

  has_many :notifications, :dependent => :delete_all, as: :notifiable
  has_many :subscribers, :source => :user, :through => :notifications

  before_create :generate_api_token
  after_create :create_initial_status
  after_create :send_notification_emails

  validates_presence_of :start
  validates_presence_of :end
  validates_presence_of :name
  validates_date :end, :on_or_after => :start, :on_or_after_message => "cannot be before the start date."
  validates_presence_of :state
  validates_inclusion_of :state, :in => STATES.keys, :allow_blank => true

  scope :ongoing, where(:state => :ongoing)
  scope :current, where(:state => [:ongoing, :on_hold])
  scope :completed, where(:state => :completed)
  scope :for_users, lambda { |users| includes(:participations).where("participations.user_id" => users) }
  scope :real, where("name NOT LIKE ?", "Agi Project").where("name NOT LIKE ?", "Cash Cow").where("name NOT LIKE ?", "Doomed")
  scope :on_time, where("projects.end > ?", 2.weeks.ago)
  scope :late, where("projects.end < ?", 2.weeks.ago)

  def last_activity
    status = self.statuses.select(:created_at).first
    status.nil? ? self.start.to_time_in_current_zone : status.created_at
  end

  def regenerate_api_token
    self.generate_api_token
    self.save
  end

  def guest_access?
    guest_token.present?
  end

  def authenticate_guest_access(token)
    guest_access? && guest_token == token
  end

  def enable_guest_access
    self.guest_token = SecureRandom.hex(16)
    self.save!
  end

  def disable_guest_access
    self.guest_token = nil
    self.save!
  end

  def human_start
    self.start.present? ? self.start.strftime("%d %B %Y") : Date.today.strftime("%d %B %Y")
  end

  def human_start=(string)
    self.start = Kronic.parse(string)
  end

  def human_end
    self.end.present? ? self.end.strftime("%d %B %Y") : Date.today.strftime("%d %B %Y")
  end

  def human_end=(string)
    self.end = Kronic.parse(string)
  end

  def state
    super.try(:to_sym)
  end

  def state_name
    STATES[state]
  end

  def as_json(opts={})
    opts = opts.is_a?(Hash) ? opts : {}
    opts[:include] = { :users => { :only => [:id, :email, :name] } }
    opts[:except] = [ :guest_token, :active, :api_token, :organization_id ]
    hash = super(opts)
    hash["project"]["url"] = url
    hash
  end

  def url
    project_url({ :host => Rails.application.config.action_mailer.default_url_options[:host],
                  :protocol => Rails.application.config.action_mailer.default_url_options[:protocol],
                  :id => id })
  end

  def to_param
    "#{self.id}-#{self.name.parameterize}"
  end

  protected

  def generate_api_token
    self.api_token = SecureRandom.hex 32
  end

  def create_initial_status
    self.statuses.create(:user => @user, :text => "Project created", :source => "Comment")
  end

  def send_notification_emails
    project = self
    organization = self.organization
    user = self.user
    emails = organization.subscribers.map(&:email).delete_if { |e| e == self.user.email }
    if emails.any?
      emails.each do |email|
        NotificationMailer.new_project(email, project.name, project.description, project.id.to_i, project.organization.name, project.organization.id.to_i, user.name).deliver
      end
    end
  end
end
