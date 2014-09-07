xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Project Dashboard"
    xml.description "A Dashboard of Gandi projects"
    xml.link projects_url

    for status in @statuses
      xml.item do
        xml.title "Project post"
        xml.description status.text
        xml.pubDate status.created_at.to_s(:rfc822)
      end
    end
  end
end
