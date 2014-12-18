# whatupdave cribbed this from: https://github.com/mtrpcic/js-routes

desc "Generate a JavaScript file that contains your Rails routes"
namespace :js do
  task :routes, [:filename] => :environment do |t, args|
    filename = args[:filename].blank? ? "routes.js" : args[:filename]
    save_path = "#{Rails.root}/app/assets/javascripts/#{filename}"

    javascript = <<-EOS
// This is a generated file, to regen run:
// rake js:routes

var exports = module.exports = {};
    EOS

    routes.each do |route|
      javascript << generate_method(route[:name], route[:path]) + "\n"
    end

    File.open(save_path, "w") { |f| f.write(javascript) }
    puts "Routes saved to #{save_path}."
  end
end

def generate_method(name, path)
  compare = /:(.*?)(\/|$)/
  path.sub!(compare, "' + params.#{$1} + '#{$2}") while path =~ compare

  <<-EOS
exports.#{name}_path = function(options){
  if (options && options.data) {
    var op_params = []
    for(var key in options.data){
      op_params.push([key, options.data[key]].join('='));
    }
    var params = options.params;
    return '#{path}?' + op_params.join('&');
  } else if(options && options.params) {
    var params = options.params;
    return '#{path}'
  } else {
    var params = options;
    return '#{path}'
  }
}
EOS
end

ROUTES = [
  'notifications',
  'product_follow',
  'product_post',
  'product_unfollow',
  'product_update',
  'product_update_comment',
  'product_update_comments',
  'product_update_subscribe',
  'product_update_unsubscribe',
  'readraptor',
]

def routes
  Rails.application.reload_routes!
  Rails.application.routes.routes.map do |route|
    if ROUTES.include?(route.name)
      {name: route.name, path: route.path.spec.to_s.split("(")[0]}
    end

  end.compact
end