# Encoding: utf-8
module ActiveRecordHelper

  # Methods
  def attr_to_alnum(attribute)
    attribute.gsub('&', 'y').gsub(/[^[:alnum:]áéíóúñÁÉÍÓÚÑ\s]/,'').gsub('Ñ','ñ').gsub(/[Áá]/,'a').gsub(/[Éé]/,'e').gsub(/[Íí]/,'i').gsub(/[Óó]/,'o').gsub(/[Úú]/,'u').downcase
  end

  def attr_to_alpha(attribute)
    attr_to_alnum(attribute).gsub(/\d/,'')
  end

  def attr_or_nil(attribute)
    attribute.blank? ? nil : attribute 
  end
end