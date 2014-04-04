RedmineApp::Application.routes.draw do
    match "redmine_wysiwyg/wysiwygtotextiletohtml", :via => [:post, :put]
    match "redmine_wysiwyg/wysiwygtohtmltotextile", :via => [:post, :put]
end
