COOKBOOKS_PATH ||= "/opt/oneops/inductor/circuit-oneops-1/components/cookbooks"


require File.expand_path('../../../../../../libraries/data_access/lbaas/loadbalancer_dao', __FILE__)
require File.expand_path('../../../../../../libraries/data_access/lbaas/listener_dao', __FILE__)
require File.expand_path('../../../../../../libraries/data_access/lbaas/pool_dao', __FILE__)
require File.expand_path('../../../../../../libraries/data_access/lbaas/member_dao', __FILE__)
require File.expand_path('../../../../../../libraries/data_access/lbaas/health_monitor_dao', __FILE__)
require File.expand_path('../../../../../../libraries/requests/lbaas/loadbalancer_request', __FILE__)
require File.expand_path('../../../../../../libraries/requests/lbaas/listener_request', __FILE__)
require File.expand_path('../../../../../../libraries/requests/lbaas/pool_request', __FILE__)
require File.expand_path('../../../../../../libraries/requests/lbaas/member_request', __FILE__)
require File.expand_path('../../../../../../libraries/requests/lbaas/health_monitor_request', __FILE__)
require File.expand_path('../../../../../../libraries/models/tenant_model', __FILE__)
require File.expand_path('../../../../../../libraries/loadbalancer_manager', __FILE__)
require File.expand_path('../../../../../../libraries/network_manager', __FILE__)
require File.expand_path('../../../../../../libraries/utils', __FILE__)


describe 'octavia SLB' do
  before(:each) do
    @spec_utils = Octavia_spec_utils.new($node)
  end

  it 'should exist' do
    service_lb_attributes = @spec_utils.get_service_metadata()
    tenant = TenantModel.new(service_lb_attributes[:endpoint],service_lb_attributes[:tenant],
                             service_lb_attributes[:username],service_lb_attributes[:password])

    loadbalancer_request = LoadbalancerRequest.new(tenant)
    @loadbalancer_dao = LoadbalancerDao.new(loadbalancer_request)
    lb_name = @spec_utils.build_n_return_lb_name
    lb_id = @loadbalancer_dao.get_loadbalancer_id(lb_name)
    #loadbalancer = @loadbalancer_dao.get_loadbalancer(lb_id)
    lb_manager = LoadbalancerManager.new(tenant)
    loadbalancer=lb_manager.get_loadbalancer(lb_id)
    expect(loadbalancer).not_to be_nil
    expect(loadbalancer.label.name).to eq(@spec_utils.build_n_return_lb_name)
  end

  it 'should have correct number of listeners' do
    listeners = @spec_utils.build_listener_from_wo()
    lb_details = @spec_utils.get_loadbalancer_details()
    expect(lb_details.listeners.count).to eq(listeners.count)
  end


  it 'should have right frontend and backend ports on listeners' do

    listeners_users_input = @spec_utils.build_listener_from_wo()
    lb_details = @spec_utils.get_loadbalancer_details()
    flag= false
    lb_details.listeners.each do |listener|
      flag= false
      listeners_users_input.each do | l|
        if((listener.protocol_port.to_s) == (l.vport)) && ((listener.pool.members[0].protocol_port.to_s) == (l.iport))
          flag = true
          break
        end
      end
      expect(flag).to eq(true)
    end
  end

  it 'should have right frontend and backend protocols on listeners' do

    listeners = @spec_utils.build_listener_from_wo()

    lb_details = @spec_utils.get_loadbalancer_details()


    if listeners.count == 1
      if (listeners[0].vprotocol == "TERMINATED_HTTPS" || listeners[0].vprotocol == 'HTTPS') && listeners[0].vprotocol == "http"
        expect(lb_details.listeners[0].protocol).to eq("TERMINATED_HTTPS")
        expect(lb_details.listeners[0].pool.members[0].protocol).to eq(listeners[0].iprotocol)
      end
    end
  end

  it 'should have right number of members' do


    service_lb_attributes = @spec_utils.get_service_metadata()
    tenant = TenantModel.new(service_lb_attributes[:endpoint],service_lb_attributes[:tenant],
                             service_lb_attributes[:username],service_lb_attributes[:password])
    subnet_id = select_provider_network_to_use(tenant, service_lb_attributes[:enabled_networks])
    lb_details = @spec_utils.get_loadbalancer_details()
    members = @spec_utils.initialize_members(subnet_id, 8080)
    expect(lb_details.listeners[0].pool.members.count).to eq(members.count)


  end

  it 'ip of backend members should match with compute ip in the workorder' do

    lb_details = @spec_utils.get_loadbalancer_details()
    compute_list = @spec_utils.get_compute_list_from_wo()
    compute_list.each do |compute|
      new_ip_address = compute["ciAttributes"]["private_ip"]
      if compute["ciAttributes"].has_key?("private_ipv6") && !compute["ciAttributes"]["private_ipv6"].nil? && !compute["ciAttributes"]["private_ipv6"].empty?
        new_ip_address = compute["ciAttributes"]["private_ipv6"]
        Chef::Log.info("ipv6 address: #{new_ip_address}")
      end
      expect(@spec_utils.is_member_exist(lb_details.listeners[0].pool.id, new_ip_address)).to be(true)
    end

  end


  it 'should have lb algorithm selected by the user' do

    lb_details = @spec_utils.get_loadbalancer_details()
    lb_attributes = @spec_utils.get_lb_attributes()
    expect(lb_details.listeners[0].pool.lb_algorithm).to eq(@spec_utils.validate_lb_algorithm(lb_attributes[:lbmethod]))
  end


  it 'should have connection limit entered by the user' do

    lb_details = @spec_utils.get_loadbalancer_details()
    lb_attributes = @spec_utils.get_lb_attributes()
    expect(lb_details.listeners[0].connection_limit.to_s).to eq(lb_attributes[:connection_limit])
  end

  it 'should have session stickiness and persistent type selected by the user' do
    lb_details = @spec_utils.get_loadbalancer_details()
    lb_attributes = @spec_utils.get_lb_attributes()
    stickiness = lb_attributes[:stickiness]
    persistence_type = lb_attributes[:persistence_type]
    session_persistence = lb_details.listeners[0].pool.session_persistence
    if stickiness
      flag= false
      if persistence_type == "SOURCE_IP"
        if session_persistence["type"] =~ /source/
          flag = true
        end
      elsif session_persistence["type"] == "HTTP_COOKIE" || session_persistence["type"] == "APP_COOKIE"
        if session_persistence["type"] =~ /cookie/
          flag = true
        end
        expect(flag).to be(true)
      end
    else
      expect(lb_details.listeners[0].pool.session_persistence).to be_nil

    end
  end

  it 'should have healthmonitor configured by the user' do

    service_lb_attributes = @spec_utils.get_service_metadata()
    tenant = TenantModel.new(service_lb_attributes[:endpoint],service_lb_attributes[:tenant], service_lb_attributes[:username],service_lb_attributes[:password])
    lb_name = @spec_utils.build_n_return_lb_name()
    lb_attributes = @spec_utils.get_lb_attributes()
    lb_details = @spec_utils.get_loadbalancer_details()
    listeners_users_input = @spec_utils.build_listener_from_wo()
    subnet_id = select_provider_network_to_use(tenant, service_lb_attributes[:enabled_networks])
    hm= nil
    members= nil

    lb_details.listeners.each do |listener|
      flag= false
      listeners_users_input.each do | l|
        hm = @spec_utils.initialize_health_monitor(l.iprotocol,lb_attributes[:ecv_map], lb_name, l.iport)
        members = @spec_utils.initialize_members(subnet_id, l.iport)
      end
    end
    expect(lb_details.listeners[0].pool.health_monitor).not_to be_nil
    expect(lb_details.listeners[0].pool.health_monitor.type).to eq(hm.type)
    expect(lb_details.listeners[0].pool.health_monitor.http_method).to eq(hm.http_method)
    expect(lb_details.listeners[0].pool.health_monitor.url_path).to eq(hm.url_path)
    expect(lb_details.listeners[0].pool.members[0].protocol_port.to_s).to eq(members[0].protocol_port)
  end
end