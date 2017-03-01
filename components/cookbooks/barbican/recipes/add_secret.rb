


# create the dynamic address group and addresses for all the computes
secret_firewall 'Add Barbican Secret' do
  openstack_auth_url service[:url_endpoint]
  openstack_username service[:username]
  openstack_api_key service[:password]
  openstack_project_name service[:tenant]
  openstack_tenant service[:tenant]
  secret_name secrets[:name]+"_certificate"
  secret_content secrets[:cert]
  action :add
end