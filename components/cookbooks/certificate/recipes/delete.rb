#if key-managment service barbican is present in the workload , invoke the barbican::add recipe here
if node[:workorder][:services].has_key?("keymanagement")
  include_recipe "barbican::delete"
end
