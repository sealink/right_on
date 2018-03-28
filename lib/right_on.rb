module RightOn
  require 'active_record'

  require 'rails'
  require 'right_on/railtie'
  require 'right_on/rights_manager'

  def self.rights_yaml(file_path = nil)
    if file_path
      @rights_yaml = file_path
    else
      @rights_yaml
    end
  end
end
