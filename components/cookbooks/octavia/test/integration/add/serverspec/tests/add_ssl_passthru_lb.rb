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

  it 'should have ecv check on tcp port ' do
    listeners_users_input = @spec_utils.build_listener_from_wo()
    lb_details = @spec_utils.get_loadbalancer_details()
    puts lb_details.listeners.inspect
    flag= false
    lb_details.listeners.each do |listener|
      flag= false
      listeners_users_input.each do | l|
        if((l.vprotocol) == listener.protocol) && (l.iprotocol == 'SSL_BRIDGE' || l.iprotocol == 'TCP')
          expect(listener.pool.members[0].protocol).not_to be_nil
          expect(listener.pool.members[0].protocol).to eq("TCP")

        end
      end

    end


  end
  end