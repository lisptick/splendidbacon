ThinkingSphinx::Index.define :project, :with => :active_record do
  # fields
  indexes :name
  indexes description
  indexes statuses.text :as => :statuses
  has organization_id, state
end

