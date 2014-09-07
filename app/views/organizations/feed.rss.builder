xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Project Dashboard"
    xml.description "A Dashboard of Gandi projects"
    xml.link projects_url

    for project in @projects
      xml.item do
        xml.title project.name
        xml.description project.description
        xml.link project_url(project)
        xml.guid project_url(project)
      end
    end
  end
end
