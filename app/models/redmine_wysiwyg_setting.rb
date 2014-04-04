class RedmineWysiwygSetting
  def self.setting
    Setting[:plugin_redmine_wysiwyg] || {}
  end

  def self.default
    ["1", true].include?(setting[:default])
  end

  def self.toolbar
    buttons = setting[:toolbar] || RedmineWysiwyg::DEFAULT_TOOLBAR
    if buttons.is_a?(String)
      bars = []
      bar = []
      buttons.split(",").each {|item|
        if item == "/"
          bars.push(bar, item)
          bar = []
        else
          bar.push(item)
        end
      }
      buttons = bar.size > 0 ? bars.push(bar) : bars
    end
    buttons
  end
end
