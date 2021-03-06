require 'i18n'

module Jekyll
  class TranslateTag < Liquid::Tag
    def initialize(tag_name, token, *args)
      super
      params = token.to_s.strip.split(',')
      @token = eval(params[0].strip)
      @locale = params[1].to_s.strip
      @locale = nil if @locale == '' || @locale == 'editable:true'
      @editable = params[1] || params[2]
      @editable = @editable && @editable.to_s.strip == 'editable:true'
    end

    def render(context)
      site = context.registers[:site]
      load_translations(site.source, site.config['i18n_dir'])
      locale = context[@locale] || @locale || site.active_lang || site.default_lang || 'en'
      I18n.available_locales = site.languages || [site.default_lang || 'en']
      
      text = I18n.t(@token, locale: locale)
      if @editable
        return "<span data-live-edit-i18n-key=\"#{@token}\" data-live-edit-i18n-locale=\"#{locale}\">#{text}</span>"
      else
        return text
      end
    end

    private
      def load_translations(path, i18n_dir=nil)
        unless I18n::backend.instance_variable_get(:@translations)
          # Load from all submodules too!
          locales_directories = [i18n_dir || '_locales'].flatten
          locales_directories.each do |locale_dir|
            I18n.backend.load_translations Dir[File.join(path, "#{locale_dir}/*.yml")]
          end
        end
      end
  end
end

Liquid::Template.register_tag('t', Jekyll::TranslateTag)
