CIRCUIT_PATH="/opt/oneops/inductor/circuit-oneops-1"
COOKBOOKS_PATH="#{CIRCUIT_PATH}/components/cookbooks"

require "#{CIRCUIT_PATH}/components/spec_helper.rb"
require "#{COOKBOOKS_PATH}/barbican/test/integration/barbican_spec_utils.rb"


require "#{COOKBOOKS_PATH}/barbican/test/integration/tests/add.rb"

