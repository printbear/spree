Spree::Core::Engine.draw_routes

# yes, terrible, terrible hack. but it guarantees that no extension
# has appended to spree's routes that we are clobbering
if !defined?(ROUTEHACK)
  Spree::Core::Engine.routes.append do
    get '/*id', :to => 'taxons#show', :as => :nested_taxons
  end
  class ROUTEHACK; end;
end
