# Copyright 2012, Dell 
# 
# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at 
# 
#  http://www.apache.org/licenses/LICENSE-2.0 
# 
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and 
# limitations under the License. 
# 

class PostgresqlService < ServiceObject

  def initialize(thelogger)
    @bc_name = "postgresql"
    @logger = thelogger
  end

  def self.allow_multiple_proposals?
    true
  end

  def create_proposal
    @logger.debug("postgresql create_proposal: entering")
    base = super

    nodes = NodeObject.all
    nodes.delete_if { |n| n.nil? or n.admin? }
    if nodes.size >= 1
      base["deployment"]["postgresql"]["elements"] = {
        "postgresql-server" => [ nodes.first[:fqdn] ]
      }
    end

    @logger.debug("postgresql create_proposal: exiting")
    base
  end

  def apply_role_pre_chef_call(old_role, role, all_nodes)
    @logger.debug("postgresql apply_role_pre_chef_call: entering #{all_nodes.inspect}")
    return if all_nodes.empty?

    # Make sure the bind hosts are in the admin network
    all_nodes.each do |n|
      node = NodeObject.find_node_by_name n

      admin_address = node.get_network_by_type("admin")["address"]
      node.crowbar[:postgresql] = {} if node.crowbar[:postgresql].nil?
      node.crowbar[:postgresql][:api_bind_host] = admin_address

      node.save
    end

    role.default_attributes["postgresql"]["server_debian_password"] = random_password if role.default_attributes["postgresql"]["server_debian_password"].nil?
    role.default_attributes["postgresql"]["server_root_password"] = random_password if role.default_attributes["postgresql"]["server_root_password"].nil?
    role.default_attributes["postgresql"]["server_repl_password"] = random_password if role.default_attributes["postgresql"]["server_repl_password"].nil?
    role.default_attributes["postgresql"]["db_maker_password"] = random_password if role.default_attributes["postgresql"]["db_maker_password"].nil?
    role.save

    #identify server node
    server_nodes = role.override_attributes["postgresql"]["elements"]["postgresql-server"]
    @logger.debug("postgresql postgresql-server elements: #{server_nodes.inspect}")
    if server_nodes.size == 1
      server_name = server_nodes.first
      @logger.debug("postgresql found single server node: #{server_name}")
      # set postgresql-server attribute for any postgresql-client role nodes
      cnodes = role.override_attributes["postgresql"]["elements"]["postgresql-client"]
      @logger.debug("postgresql postgresql-client elements: #{cnodes.inspect}")
      unless cnodes.nil? or cnodes.empty?
        cnodes.each do |n|
          node = NodeObject.find_node_by_name n
          node.crowbar["postgresql-server"] = server_name
          @logger.debug("postgresql assign node[:postgresql-server] for #{n}")
          node.save
        end
      end
    end

    @logger.debug("postgresql apply_role_pre_chef_call: leaving")
  end

end

