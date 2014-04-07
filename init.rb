require 'redmine'
require 'redmine_wysiwyg'
require 'redcloth'

Rails.application.config.to_prepare do
  RedmineWysiwyg.apply_patch
end

Redmine::Plugin.register :redmine_wysiwyg do
  name 'redmine_wysiwyg'
  author 'Systango'
  description 'This is a CKEditor plugin for Redmine'
  version '1.0.0'
  requires_redmine :version_or_higher => '2.2.4'

  settings(:partial => 'settings/ckeditor')

  wiki_format_provider 'CKEditor', RedmineWysiwyg::WikiFormatting::Formatter,
    RedmineWysiwyg::WikiFormatting::Helper
end
