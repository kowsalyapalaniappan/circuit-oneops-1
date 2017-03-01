require "fog/openstack"

require File.expand_path('../../libraries/barbican_utils.rb', __FILE__)

# get the necessary information from the node
service = BarbicanUtils.get_service_info(node)

secrets = BarbicanUtils.get_secrets(node)

Chef::Log.info("url:#{service[:openstack_auth_url]}")
secrets.each do |secret|
  Chef::Log.info "#{secret[:secret_name]}: #{secret[:content]}"
  barbican_secret 'Add Barbican Secret' do
    openstack_auth_url service[:openstack_auth_url]
    openstack_username service[:openstack_username]
    openstack_api_key service[:openstack_api_key]
    openstack_project_name service[:openstack_project_name]
    openstack_tenant service[:openstack_tenant]
    Chef::Log.info("#{secret[:secret_name]}")
    secret_name secret[:secret_name]
    secret_content secret[:content]
    payload_content_type "text/plain"
    algorithm "aes"
    bit_length 256
    mode "cbc"

    action :add_secret do
      Chef::Log.info new_resource.secret_ref
      secret[:secret_ref] = new_resource.secret_ref
    end
  end
  node.set["secret_reference"] = secrets
end

barbican_secret 'Add barbican container' do

end
