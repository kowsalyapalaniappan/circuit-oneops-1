module BarbicanUtils

  def get_service_info(node)
    service_hash = {}

    cloud_name = node[:workorder][:cloud][:ciName]
    Chef::Log.info("Cloud Name: #{cloud_name}")

    # get the service information
    if node[:workorder][:services].has_key?('key-management')
      Chef::Log.info("Key Management Service is: #{node[:workorder][:services]['key-management']}")
      barbican_attributes = node[:workorder][:services]['key-management'][cloud_name][:ciAttributes]
      service_hash[:openstack_auth_url] = barbican_attributes[:endpoint]
      service_hash[:openstack_username] = barbican_attributes[:username]
      service_hash[:openstack_api_key] = barbican_attributes[:password]
      service_hash[:openstack_tenant] = barbican_attributes[:tenant]
      service_hash[:openstack_project_name] = barbican_attributes[:tenant]

    end
    service_hash
  end

  def get_secrets(node)
    secret_hash = {}
    secrets = []
    # get the certificate information information
    certificate_attributes = node[:workorder][:rfcCi][:ciAttributes]
    ciName = node[:workorder][:rfcCi][:ciName]
    Chef::Log.info("certificate attribute:")
    Chef::Log.info(certificate_attributes.inspect)
    secret_hash[:content] = node[:workorder][:rfcCi][:ciAttributes][:cert]
    secret_hash[:secret_name] = ciName +"_certificate"
    secret_hash[:secret_ref] = ""
    secrets.push(secret_hash)

    secret_hash[:content] = node[:workorder][:rfcCi][:ciAttributes][:cacertkey]
    secret_hash[:secret_name] = ciName+"_intermediate"

    secrets.push(secret_hash)


    secret_hash[:content] = node[:workorder][:rfcCi][:ciAttributes][:key]
    secret_hash[:secret_name] = ciName+"_privatekey"

    secrets.push(secret_hash)

    secret_hash[:content] = node[:workorder][:rfcCi][:ciAttributes][:passphrase]
    secret_hash[:secret_name] = ciName+"_privatekey_passphrase"

    secrets.push(secret_hash)

    secrets
  end

  module_function :get_service_info, :get_secrets

end