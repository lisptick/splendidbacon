class Ability
  include CanCan::Ability

  def initialize(user)
   can :create_project, User do |the_user, organization|
      #Except in demo mode
      # a user can create a project in an organization if he is an admin or he is the organization creator
      (the_user.demo? and !Organization.real.include? organization) or
      	the_user.admin? or organization.users[1] == the_user
    end

    can :update, Project do |project|
      #Except in demo mode
      # a user can edit a project if he is an admin or he's the project creator or he participates to the project
      (user.demo? and !Organization.real.include? project.organization) or
        user.admin? or project.organization.users[1] == user or
        user.projects.include? project
    end

    can :destroy, Project do |project|
      !Organization.real.include? project.organization or
        user.admin? or project.organization.users[1] == user or
        user.projects.include? project
    end

    can :create_organization, User do |the_user|
        the_user.admin? or Rails.application.config.user_can_create_organization
    end

    can :update, Organization do |organization|
      (user.demo? and !Organization.real.include? organization)
      user.admin? or organization.users[1] == user
    end

    can :destroy, Organization do |organization|
      (user.demo? and !Organization.real.include? organization)
      user.admin? or organization.users[1] == user
    end
  end
end
