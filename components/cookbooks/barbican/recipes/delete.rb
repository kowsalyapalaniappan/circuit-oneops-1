require "fog/openstack"

require File.expand_path('../../libraries/barbican_utils.rb', __FILE__)

# get the necessary information from the node
service = BarbicanUtils.get_service_info(node)

secrets = BarbicanUtils.get_secrets(node)

secrets.each do |secret|
  Chef::Log.info "#{secret[:secret_name]}: #{secret[:content]}"
  barbican_secret 'Delete Barbican Secret' do
    openstack_auth_url service[:openstack_auth_url]
    openstack_username service[:openstack_username]
    openstack_api_key service[:openstack_api_key]
    openstack_project_name service[:openstack_project_name]
    openstack_tenant service[:openstack_tenant]
    Chef::Log.info("#{secret[:secret_name]}")
    secret_name secret[:secret_name]

    action :delete_secret do
      Chef::Log.info new_resource.result
      return result
    end
  end
end


barbican_container 'Delete barbican container' do
  openstack_auth_url service[:openstack_auth_url]
  openstack_username service[:openstack_username]
  openstack_api_key service[:openstack_api_key]
  openstack_project_name service[:openstack_project_name]
  openstack_tenant service[:openstack_tenant]
  cert_container_name node[:cert_container_name]

  action :delete_container do
    Chef::Log.info new_resource.result
    return result
  end

end



