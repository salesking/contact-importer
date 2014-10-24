I18n.backend.class.send(:include, I18n::Backend::Fallbacks)
I18n.default_locale = DEFAULT_LANG = :de

I18n.fallbacks.map(de: :en, pl: :en)

DEFAULT_TIME_ZONE = 'Europe/Berlin'