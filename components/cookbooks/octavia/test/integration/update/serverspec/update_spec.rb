CIRCUIT_PATH="/opt/oneops/inductor/circuit-oneops-1"
COOKBOOKS_PATH="#{CIRCUIT_PATH}/components/cookbooks"

require "#{CIRCUIT_PATH}/components/spec_helper.rb"
require "#{COOKBOOKS_PATH}/octavia/test/integration/octavia_spec_utils.rb"

#run all the test cases under add test for update action.
require "#{COOKBOOKS_PATH}/octavia/test/integration/add/serverspec/tests/add_basic_lb.rb"