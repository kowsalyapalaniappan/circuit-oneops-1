COOKBOOKS_PATH ||= "/opt/oneops/inductor/circuit-oneops-1/components/cookbooks"

describe 'barbican secrets' do
  before(:each) do
    @spec_utils = Barbican_spec_utils.new($node)
  end

  context 'babrican secret' do
    it 'all secret should exist' do
      secret_list = @spec_utils.get_secrets_wo()
      secret_manager = @spec_utils.get_service_info("secret")

      secret_list.each do |secret|
        puts secret[:secret_name]
        secret_ref = secret_manager.get_secret(secret[:secret_name])
        puts secret_ref
        expect(secret_ref).not_to be_nil
      end
    end


    it 'acl should be set for every secret' do
      secret_list = @spec_utils.get_secrets_wo()
      acl_manager = @spec_utils.get_service_info("acl")
      secret_manager = @spec_utils.get_service_info("secret")
      user_list = Array.new
      user_list.push("neutron")
      user_list.push("octavia")
      user_list.push("admin")

      secret_list.each do |secret|
        secret_ref = secret_manager.get_secret(secret[:secret_name])
        acl_ref = acl_manager.get_secret_acl(secret_ref.split('/').last)
        response= acl_ref.body
        value= response["read"]
        uuid_list_1 =  value["users"]
        uuid_list_2 = acl_manager.get_uuid_list(user_list)
        expect(uuid_list_1).to match_array(uuid_list_2)
      end
    end

    context 'babrican container' do
      it 'container should exist' do
        secrets = @spec_utils.get_secrets_wo()
        secret_manager = @spec_utils.get_service_info("secret")

        container_name = @spec_utils.get_container_name()
        acl_manager = @spec_utils.get_service_info("acl")
        con_ref=secret_manager.get_container(container_name)
        expect(con_ref).not_to be_nil
      end

      it 'acl should be set for container' do
        secrets = @spec_utils.get_secrets_wo()
        acl_manager = @spec_utils.get_service_info("acl")
        secret_manager = @spec_utils.get_service_info("secret")
        user_list = Array.new
        user_list.push("neutron")
        user_list.push("octavia")
        user_list.push("admin")
        container_name = @spec_utils.get_container_name()
        con_ref=secret_manager.get_container(container_name)
        acl_ref = acl_manager.get_container_acl(con_ref)
        response= acl_ref.body
        value= response["read"]
        uuid_list_1 =  value["users"]
        uuid_list_2 = acl_manager.get_uuid_list(user_list)
        expect(uuid_list_1).to match_array(uuid_list_2)
      end
    end
  end
end