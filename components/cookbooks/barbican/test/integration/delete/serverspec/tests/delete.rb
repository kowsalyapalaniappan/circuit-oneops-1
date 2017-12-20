COOKBOOKS_PATH ||= "/opt/oneops/inductor/circuit-oneops-1/components/cookbooks"




describe 'barbican secrets' do
  before(:each) do
    @spec_utils = Barbican_spec_utils.new($node)
  end

  context 'babrican secret' do
    it 'all secret should not exist' do
      secret_list = @spec_utils.get_secrets_wo()
      secret_manager = @spec_utils.get_service_info("secret")

      secret_list.each do |secret|
        puts secret[:secret_name]
        secret_ref = secret_manager.get_secret(secret[:secret_name])
        puts secret_ref
        expect(secret_ref).to be(false)
      end
    end
  end

  context 'babrican container' do
    it 'container should not exist' do
      secrets = @spec_utils.get_secrets_wo()
      secret_manager = @spec_utils.get_service_info("secret")

      container_name = @spec_utils.get_container_name()
      acl_manager = @spec_utils.get_service_info("acl")
      con_ref=secret_manager.get_container(container_name)
      expect(con_ref).to be(false)
      end
    end


  end