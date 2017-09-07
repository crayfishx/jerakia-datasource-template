policy :default do

  lookup :main do
    datasource :example, {
      :files => [
        "/etc/example/#{scope[:environment]}.json",
        "/etc/example/global.json"
      ]
    }
  end

end
