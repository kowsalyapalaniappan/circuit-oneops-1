module BarbicanUtils

  def get_service_info(node)
    service_hash = {}

    cloud_name = node[:workorder][:cloud][:ciName]
    Chef::Log.info("Cloud Name: #{cloud_name}")
    # get the service information
    if node[:workorder][:services].has_key?('keymanagement')
      Chef::Log.info("Key Management Service is: #{node[:workorder][:services][:keymanagement]}")
      barbican_attributes = node[:workorder][:services][:keymanagement][cloud_name][:ciAttributes]
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
    secret_hash[:content] = node[:workorder][:rfcCi][:ciAttributes][:cert]
    secret_hash[:secret_name] = ciName +"_certificate"
    secret_hash[:secret_ref] = ""
    Chef::Log.info("secret name: #{secret_hash[:secret_name]}, secret_content: #{secret_hash[:content]}")
    secrets.push(secret_hash)

    secret_hash[:content] = node[:workorder][:rfcCi][:ciAttributes][:cacertkey]
    secret_hash[:secret_name] = ciName+"_intermediate"
    Chef::Log.info("secret name: #{secret_hash[:secret_name]}, secret_content: #{secret_hash[:content]}")

    secrets.push(secret_hash)


    secret_hash[:content] = node[:workorder][:rfcCi][:ciAttributes][:key]
    secret_hash[:secret_name] = ciName+"_privatekey"
    Chef::Log.info("secret name: #{secret_hash[:secret_name]}, secret_content: #{secret_hash[:content]}")

    secrets.push(secret_hash)

    secret_hash[:content] = node[:workorder][:rfcCi][:ciAttributes][:passphrase]
    secret_hash[:secret_name] = ciName+"_privatekey_passphrase"
    Chef::Log.info("secret name: #{secret_hash[:secret_name]}, secret_content: #{secret_hash[:content]}")

    secrets.push(secret_hash)
    node.set["secrets_hash"] =  secrets
    node.set["cert_container_name"] = ciName + "cert_container_name"
    secrets
  end

  module_function :get_service_info, :get_secrets

end