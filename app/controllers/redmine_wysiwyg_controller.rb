require 'html2textile'
require 'sgml-parser'
require 'redcloth'

class RedmineWysiwygController < ApplicationController
  def wysiwygtotextiletohtml 
    @text = RedCloth.new(params[:textile]).to_html if params[:textile]
    render :partial => 'convert'
  end

  def wysiwygtohtmltotextile 
    htmlparser = HTMLToTextileParser.new
    htmlparser.feed(params[:html])
    @text = htmlparser.to_textile
    render :json => { status: l(:status_ok), text: (@text || "") }
  end
end
