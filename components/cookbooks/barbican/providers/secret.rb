def whyrun_supported?
  true
end

action :add_secret do
  begin
    converge_by("Add secrets through barbican API") do
      raise Exception.new("openstack_auth_url is required") if @new_resource.openstack_auth_url.nil?
      raise Exception.new("openstack_username is required") if @new_resource.openstack_username.nil?
      raise Exception.new("openstack_api_key  is required") if @new_resource.openstack_api_key.nil?
      raise Exception.new("tenant name is required") if @new_resource.openstack_tenant.nil?
      raise Exception.new("secret_name  is required") if @new_resource.secret_name.nil?
      raise Exception.new("secret content is required") if @new_resource.secret_content.nil?
      raise Exception.new("openstack_api_key hash is required") if @new_resource.openstack_api_key.nil?

      secret_manager = SecretManager.new(@new_resource.openstack_auth_url, @new_resource.openstack_username, @new_resource.openstack_api_key, @new_resource.openstack_tenant )

      @secret = {
          name:             "#{@new_resource.secret_name}",
          payload_content:  "#{@new_resource.secret_content}",
          content_type:     "#{@new_resource.payload_content_type}",
          algorithm:        "#{@new_resource.algorithm}",
          mode:             "#{@new_resource.mode}",
          bit_len:          "#{@new_resource.bit_length}"
      }
      Chef::Log.info("secret:")
      Chef::Log.info(@secret.inspect)
      Chef::Log.info(secret_manager.inspect)
      @new_resource.secret_ref = secret_manager.create(@secret)

    end

    @new_resource.updated_by_last_action(true)
  rescue => ex
    Chef::Log.error(ex.inspect)
    actual_err = "An error of type #{ex.class} happened, message is #{ex.message}"
    msg = "Exception creating new secret through Barbican API , " + actual_err
    puts "***FAULT:FATAL=#{msg}"
    e = Exception.new(msg)
    raise e
  end
end


action :delete_secret do
  begin
    converge_by("Add secrets through barbican API") do
      raise Exception.new("openstack_auth_url is required") if @new_resource.openstack_auth_url.nil?
      raise Exception.new("openstack_username is required") if @new_resource.openstack_username.nil?
      raise Exception.new("openstack_api_key  is required") if @new_resource.openstack_api_key.nil?
      raise Exception.new("tenant name is required") if @new_resource.openstack_tenant.nil?
      raise Exception.new("secret_name  is required") if @new_resource.secret_name.nil?
      raise Exception.new("secret content is required") if @new_resource.secret_content.nil?
      raise Exception.new("openstack_api_key hash is required") if @new_resource.openstack_api_key.nil?

      secret_manager = SecretManager.new(@new_resource.openstack_auth_url, @new_resource.openstack_username, @new_resource.openstack_api_key, @new_resource.openstack_tenant )

      @secret = {
          name:             "#{@new_resource.secret_name}",
          payload_content:  "#{@new_resource.secret_content}",
          content_type:     "#{@new_resource.payload_content_type}",
          algorithm:        "#{@new_resource.algorithm}",
          mode:             "#{@new_resource.mode}",
          bit_len:          "#{@new_resource.bit_length}"
      }
      Chef::Log.info("secret:")
      Chef::Log.info(@secret.inspect)
      Chef::Log.info(secret_manager.inspect)
      @new_resource.secret_ref = secret_manager.delete(@secret)

    end

    @new_resource.updated_by_last_action(true)
  rescue => ex
    Chef::Log.error(ex.inspect)
    actual_err = "An error of type #{ex.class} happened, message is #{ex.message}"
    msg = "Exception deleting secret #{@new_resource.secret_name} through Barbican API , " + actual_err
    puts "***FAULT:FATAL=#{msg}"
    e = Exception.new(msg)
    raise e
  end
end
