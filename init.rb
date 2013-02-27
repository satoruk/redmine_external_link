
require 'external_link_plugin'

Rails.configuration.to_prepare do
  RedCloth3.send(:include, ExternalLinkPlugin::Patches::RedCloth3Patch)
  Redmine::WikiFormatting::Textile::Formatter.send(:include, ExternalLinkPlugin::Patches::WikiFormatting::Textile::FormatterPatch)
end

Redmine::Plugin.register :external_link do
  name 'Redmine External Link plugin'
  author 'satoruk'
  description 'This is to customize external link plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/satoruk/redmine_external_link'
  author_url 'https://github.com/satoruk'
  requires_redmine :version_or_higher => '2.2.0'

  settings :default => {
    'target' => '_blank',
    'one_cushion_link' => 'http://webutil.catlet.com/redirect/${URL}',
  }, :partial => 'settings/external_link'

end

