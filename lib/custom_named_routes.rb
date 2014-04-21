module CustomNamedRoutes
  def self.included(base)
    public_instance_methods.map do |url_route|
      path_route = url_route.to_s.sub(/url$/, 'path')
      if !method_defined?(path_route)
        define_method path_route do |record, options = {}|
          send url_route, record, options.merge(:only_path => true)
        end
      end
      if base < ApplicationController
        puts url_route.inspect
        base.helper_method url_route, path_route
      end
    end
  end
end
