certificate_payload = node.workorder.payLoad.DependsOn.select { |d| d[:ciClassName] =~ /Certificate/ }
config_items_changed = nil
certificate_payload.each do |cert|
  config_items_changed = cert[:ciBaseAttributes]
end
if !config_items_changed.empty? # old_config is empty if there no configuration change in certificate component
  include_recipe "barbican::delete"
  include_recipe "barbican::add"
end