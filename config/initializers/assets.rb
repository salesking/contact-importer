# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'
Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'bower_components')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
# Add Webfonts from bower libs to the Asset Pipeline

Rails.application.config.assets.precompile += %w( bootstrap/dist/fonts/glyphicons-halflings-regular.eot
                                                  bootstrap/dist/fonts/glyphicons-halflings-regular.woff
                                                  bootstrap/dist/fonts/glyphicons-halflings-regular.ttf
                                                  font-awesome/fonts/FontAwesome.otf
                                                  font-awesome/fonts/fontawesome-webfont.eot
                                                  font-awesome/fonts/fontawesome-webfont.svg
                                                  font-awesome/fonts/fontawesome-webfont.ttf
                                                  font-awesome/fonts/fontawesome-webfont.woff
)

# Prevent digest generation for Webfonts  ... wtf sprockets !!
# could also use regex
NonStupidDigestAssets.whitelist = %w( bootstrap/dist/fonts/glyphicons-halflings-regular.eot
                                      bootstrap/dist/fonts/glyphicons-halflings-regular.woff
                                      bootstrap/dist/fonts/glyphicons-halflings-regular.ttf
                                      font-awesome/fonts/FontAwesome.otf
                                      font-awesome/fonts/fontawesome-webfont.eot
                                      font-awesome/fonts/fontawesome-webfont.svg
                                      font-awesome/fonts/fontawesome-webfont.ttf
                                      font-awesome/fonts/fontawesome-webfont.woff
                                      logo.svg)