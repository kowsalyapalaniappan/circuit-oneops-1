CIRCUIT_PATH="/opt/oneops/inductor/circuit-oneops-1"
COOKBOOKS_PATH="#{CIRCUIT_PATH}/components/cookbooks"
BARBICAN_PATH="#{COOKBOOKS_PATH}/barbican"

require File.expand_path("#{BARBICAN_PATH}/libraries/secret_manager", __FILE__)
require File.expand_path("#{BARBICAN_PATH}/libraries/acl_manager", __FILE__)


class Barbican_spec_utils
  def initialize(node)
    @node=node
  end

def get_service_info(manager_class)
  service_hash = {}

  cloud_name = @node[:workorder][:cloud][:ciName]
  # get the service information
  if @node[:workorder][:services].has_key?('keymanagement')
    barbican_attributes = @node[:workorder][:services][:keymanagement][cloud_name][:ciAttributes]
    service_hash[:openstack_auth_url] = barbican_attributes[:endpoint]
    service_hash[:openstack_username] = barbican_attributes[:username]
    service_hash[:openstack_api_key] = barbican_attributes[:password]
    service_hash[:openstack_tenant] = barbican_attributes[:tenant]
    service_hash[:openstack_project_name] = barbican_attributes[:tenant]

  end
  service_hash
  if manager_class == "acl"
    return ACLManager.new(service_hash[:openstack_auth_url], service_hash[:openstack_username], service_hash[:openstack_api_key], service_hash[:openstack_tenant] )
  elsif manager_class == "secret"
    return SecretManager.new(service_hash[:openstack_auth_url], service_hash[:openstack_username], service_hash[:openstack_api_key], service_hash[:openstack_tenant] )
  end
end

  def get_secrets_wo()
    secrets = []
    # get the certificate information information

    certificate_payload = @node.workorder.payLoad.DependsOn.select { |d| d[:ciClassName] =~ /Certificate/ }
    certificate_payload.each do |cert|
      cacert_key = cert[:ciAttributes][:cacertkey]
      cert_content = cert[:ciAttributes][:cert]
      cert_key = cert[:ciAttributes][:key]
      cert_passphrase = cert[:ciAttributes][:passphrase]
      ciID = cert[:ciId].to_s

      Chef::Log.info("cacert_key:")
      Chef::Log.info(cacert_key)

      Chef::Log.info("CERT_CONTENT:")
      Chef::Log.info(cert_content)

      Chef::Log.info("CERT_KEY:")
      Chef::Log.info(cert_key)

      Chef::Log.info("PASSPHRASE:")
      Chef::Log.info(cert_passphrase)

      Chef::Log.info("ciID:")
      Chef::Log.info(ciID)

      cert_hash = {}
      if !cert_content.nil? && !cert_content.empty?
        cert_hash[:content] = cert_content
        cert_hash[:secret_name] = ciID + "_certificate"
        secrets.push(cert_hash)
      else
        raise "configuration error: certificate content is empty"
      end

      chain_hash = {}
      if !cacert_key.nil? && !cacert_key.empty?
        chain_hash[:content] = cacert_key
        chain_hash[:secret_name] = ciID + "_intermediates"
        secrets.push(chain_hash)
      else
        raise "configuration error: intermediate certificate chain is empty"
      end


      key_hash = {}
      if !cert_key.nil? && !cert_key.empty?
        key_hash[:content] = cert_key
        key_hash[:secret_name] = ciID +"_privatekey"
        secrets.push(key_hash)
      else
        raise "configuration error: private key is empty"
      end

      passphrase_hash = {}
      if !cert_passphrase.nil? && !cert_passphrase.empty?
        passphrase_hash[:content] = cert_passphrase
        passphrase_hash[:secret_name] = ciID + "_privatekey_passphrase"
        secrets.push(passphrase_hash)
      end

      @node.set["secrets_hash"] =  secrets
      @node.set["cert_container_name"] = ciID + "_tls_cert_container"

    end
    secrets

  end

def replace_acl(name, userlist, type)

  acl_manager =   get_service_info( "acl")
  secret_manager = get_service_info("secret")
  if type == "secret"
    secret_ref = secret_manager.get_secret(name)
    if secret_ref != false
      acl_manager.replace_secret_acl(secret_ref.split('/').last, userlist)
    end
  elsif type == "container"
    container_ref = secret_manager.get_container(name)
    if container_ref != false
      acl_manager.replace_container_acl(container_ref.split('/').last, userlist)
    end
  end
end

def add_secret(secret_name, secret_content,payload_content_type,algorithm, mode, bit_length)

  begin
    raise Exception.new("secret_name  is required") if secret_name.nil?
    raise Exception.new("secret content is required") if secret_content.nil?

    secret_manager = get_service_info("secret")

    @secret = {
        "name" =>             "#{secret_name}",
        "payload" =>  "#{secret_content}",
        "payload_content_type" =>     "#{payload_content_type}",
        "algorithm" =>        "#{algorithm}",
        "mode" =>             "#{mode}",
        "bit_len" =>        "#{bit_length}"
    }
    return (secret_manager.create(@secret))

  rescue => ex
    Chef::Log.error(ex.inspect)
    actual_err = "An error of type #{ex.class} happened, message is #{ex.message}"
    msg = "Exception creating new secret through Barbican API , " + actual_err
    puts "***FAULT:FATAL=#{msg}"
    e = Exception.new(msg)
    raise e
  end
end

def delete_secret(secret_name)
  begin
    raise Exception.new("secret_name  is required") if secret_name.nil?

    secret_manager = get_service_info("secret")
    secret_ref = secret_manager.get_secret(secret_name)

    if secret_ref != false
      return secret_manager.delete(secret_ref.split('/').last)
    end

  rescue => ex
    Chef::Log.error(ex.inspect)
    actual_err = "An error of type #{ex.class} happened, message is #{ex.message}"
    msg = "Exception deleting secret #{secret_name} through Barbican API , " + actual_err
    puts "***FAULT:FATAL=#{msg}"
    e = Exception.new(msg)
    raise e
  end
end


def create_container (cert_name,intermediates_name,private_key_name,private_key_passphrase_name, container_name, container_type)
  raise Exception.new("cert_ref  is required") if cert_name.nil?
  raise Exception.new("private_key_ref  is required") if private_key_name.nil?
  raise Exception.new("intermediates_ref  is required") if intermediates_name.nil?
  raise Exception.new("container_name is required") if container_name.nil?
  raise Exception.new("type is required") if container_type.nil?

  secret_manager = get_service_info("secret")

  secret_manager.create_container(container_name, container_type,
                                  cert_name, private_key_name,
                                  intermediates_name, private_key_passphrase_name)

rescue => ex
  Chef::Log.error(ex.inspect)
  actual_err = "An error of type #{ex.class} happened, message is #{ex.message}"
  msg = "Exception creating new certificate container through Barbican API , " + actual_err
  puts "***FAULT:FATAL=#{msg}"
  e = Exception.new(msg)
  raise e
end

def delete_container(container_name)
  begin
    raise Exception.new("container_name  is required") if container_name.nil?
    secret_manager = get_service_info("secret")
    container_ref = secret_manager.get_container(container_name)
    if container_ref != false && !container_ref.nil?
      return secret_manager.delete_container(container_ref.split('/').last)
    else
      Chef::Log.warn("container_ref for #{container_name} is empty")
    end
  rescue => ex
    Chef::Log.error(ex.inspect)
    actual_err = "An error of type #{ex.class} happened, message is #{ex.message}"
    msg = "Exception deleting certificate container through Barbican API , " + actual_err
    puts "***FAULT:FATAL=#{msg}"
    e = Exception.new(msg)
    raise e
  end
end

  def get_container_name()
    @node["cert_container_name"]
  end
end