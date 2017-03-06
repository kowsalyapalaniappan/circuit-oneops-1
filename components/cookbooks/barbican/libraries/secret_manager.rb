require '/usr/local/share/gems/gems/fog-openstack-0.1.19/lib/fog/openstack.rb'

class SecretManager
  def initialize(endpoint, username, password, tenantname)
    fail ArgumentError, 'tenant is nil' if tenantname.nil?

    @connection_params = {
        openstack_auth_url:     "#{endpoint}",
        openstack_username:     "#{username}",
        openstack_api_key:      "#{password}",
        openstack_project_name: "#{tenantname}",
        openstack_tenant:       "#{tenantname}"
    }

  end

  def create(secret)
    fail ArgumentError, 'secret is nil' if secret.nil?
    key_manager = Fog::KeyManager::OpenStack.new(@connection_params)
    Chef::Log.info secret.inspect
    if get_secret(@secret.name) == false #check whether the secret with same name exist before creating new
      new_secret = key_manager.secrets.create payload_content_type: @secret.payload_content_type,
                                              name: @secret.name,
                                              payload: @secret.payload_content,
                                              algorithm: @secret.algorithm,
                                              mode: @secret.mode,
                                              bit_length: @secret.bit_len


      Chef::Log.info("connection params:")
      Chef::Log.info(connection_params.inspect)
      # options = loadbalancer.serialize_optional_parameters
      # Make fog call to create secrets
      if !new_secret.secret_ref.nil?
        puts new_secret.secret_ref
        return new_secret.secret_ref
      else
        return false
      end
    else
      raise "Cannot create secret, Secret #{@secret.name} already exist ."
    end
  end

  def get_secret(secret_name)
    key_manager = Fog::KeyManager::OpenStack.new(@connection_params)
    secrets_list = key_manager.secrets.list_secrets()
    if !secrets_list.nil?
      secrets_list.each do |secret|
        if secret.name == secret_name
          return secret.secret_ref
        end
      end
    else
      return false
    end
  end

  def get_secrets_list()
    key_manager = Fog::KeyManager::OpenStack.new(@connection_params)
=begin
    #secrets_list = key_manager.secrets.list_secrets()
    if !secrets_list.nil?
      puts secrets_list
      return secrets_list
    else
      return FALSE
    end
=end
  end

  def delete(secret_ref)
    fail ArgumentError, 'secret_ref is nil' if secret_ref.nil? || secret_ref.empty?
    begin
      key_manager = Fog::KeyManager::OpenStack.new(@connection_params)
      secret_obj = key_manager.secrets.get secret_ref
      if !secret_obj.nil?
        puts secret_obj.inspect
        delete_Result = secret_obj.destroy
        if !delete_Result.nil?
          if delete_Result
            puts "Succesfully deleted the secret"
            return true
          else
            puts "Failed to delete the secret"
            return false
          end
        end
      else
        puts "Cannot find the secret" + secret_ref
      end
    rescue Exception => e
      puts e.inspect
    end
  end

  def create_container(container_name, type, certificate, private_key, intermediates, passphrase)
    fail ArgumentError, 'container_name is nil' if container_name.nil? || container_name.empty?
    fail ArgumentError, 'certificate is nil' if certificate.nil? || certificate.empty?
    fail ArgumentError, 'private_key is nil' if private_key.nil? || private_key.empty?
    fail ArgumentError, 'intermediates is nil' if intermediates.nil? || intermediates.empty?
    fail ArgumentError, 'passphrase is nil' if passphrase.nil? || passphrase.empty?

    begin
      cert = { "name" => "certificate", "secret_ref" => certificate }
      private_key_hash = { "name" => "private_key", "secret_ref" => private_key}
      inter_hash = {"name" => "intermediates", "secret_ref" => intermediates}
      secret_refs = []
      secret_refs.push(cert)
      secret_refs.push(private_key_hash)
      secret_refs.push(inter_hash)
      if get_container(container_name) == false
        key_manager = Fog::KeyManager::OpenStack.new(@connection_params)
        container_obj = key_manager.containers.create name: container_name,
                                                      type: type,
                                                      secret_refs: secret_refs
        #Make fog call to create container
        if !container_obj.nil?
          puts container_obj.inspect
          return container_obj
        else
          return False
        end
      else
        raise "Cannot create container, container with name #{container_name} already exists."
      end
    rescue Exception => e
      puts e.inspect

    end


  end

  def delete_container(secret_ref)
    begin
      key_manager = Fog::KeyManager::OpenStack.new(@connection_params)
      container_obj = key_manager.containers.get secret_ref
      if !container_obj.nil?
        puts container_obj.inspect
        delete_Result = container_obj.destroy
        if !delete_Result.nil?
          if delete_Result
            puts "Succesfully deleted the container"
            return true
          else
            puts "Failed to delete the container"
            return false
          end
        end
      else
        puts "Cannot find the ref #{secret_ref}"
      end
    rescue Exception => e
      puts e.inspect
    end
  end

  def get_container(container_name)
    key_manager = Fog::KeyManager::OpenStack.new(@connection_params)
    container_list = key_manager.containers.list_secrets()
    if !container_list.nil?
      container_list.each do |container|
        if container.name == container_name
          return container.secret_ref
        end
      end
    else
      return false
    end
  end
end
