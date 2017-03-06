def whyrun_supported?
  true
end


action :create_container do
  begin
    converge_by("Add secret certificate container through barbican API") do
      raise Exception.new("openstack_auth_url is required") if @new_resource.openstack_auth_url.nil?
      raise Exception.new("openstack_username is required") if @new_resource.openstack_username.nil?
      raise Exception.new("openstack_api_key  is required") if @new_resource.openstack_api_key.nil?
      raise Exception.new("tenant name is required") if @new_resource.openstack_tenant.nil?
      raise Exception.new("cert_ref  is required") if @new_resource.cert_ref.nil?
      raise Exception.new("private_key_ref  is required") if @new_resource.private_key_ref.nil?
      raise Exception.new("intermediates_ref  is required") if @new_resource.intermediates_ref.nil?
      raise Exception.new("private_key_passphrase_ref is required") if @new_resource.private_key_passphrase_ref.nil?
      raise Exception.new("container_name is required") if @new_resource.container_name.nil?
      raise Exception.new("type is required") if @new_resource.type.nil?

      secret_manager = SecretManager.new(@new_resource.openstack_auth_url, @new_resource.openstack_username, @new_resource.openstack_api_key, @new_resource.openstack_tenant )

      @new_resource.secret_ref = secret_manager.create_container(@new_resource.container_name, @new_resource.type,
                                                                 @new_resource.cert_ref, @new_resource.private_key_ref,
                                                                 @new_resource.intermediates, @new_resource.passphrase)

    end

    @new_resource.updated_by_last_action(true)
  rescue => ex
    Chef::Log.error(ex.inspect)
    actual_err = "An error of type #{ex.class} happened, message is #{ex.message}"
    msg = "Exception creating new certificate container through Barbican API , " + actual_err
    puts "***FAULT:FATAL=#{msg}"
    e = Exception.new(msg)
    raise e
  end
end

action delete_container do
  begin
    converge_by("Delete secret certificate container through barbican API") do
      raise Exception.new("openstack_auth_url is required") if @new_resource.openstack_auth_url.nil?
      raise Exception.new("openstack_username is required") if @new_resource.openstack_username.nil?
      raise Exception.new("openstack_api_key  is required") if @new_resource.openstack_api_key.nil?
      raise Exception.new("tenant name is required") if @new_resource.openstack_tenant.nil?
      raise Exception.new("container_name  is required") if @new_resource.container_name.nil?


      secret_manager = SecretManager.new(@new_resource.openstack_auth_url, @new_resource.openstack_username, @new_resource.openstack_api_key, @new_resource.openstack_tenant )
      container_ref = secret_manager.get_container(@new_resource.container_name)
      @new_resource.result = secret_manager.delete_container(container_ref)

    end
    @new_resource.updated_by_last_action(true)

  rescue => ex
    Chef::Log.error(ex.inspect)
    actual_err = "An error of type #{ex.class} happened, message is #{ex.message}"
    msg = "Exception deleting certificate container through Barbican API , " + actual_err
    puts "***FAULT:FATAL=#{msg}"
    e = Exception.new(msg)
    raise e
  end

end