#
# Author:: Stephen Lauck (<stephen.lauck@gmail.com>)
# Copyright:: Copyright (c) 2013 
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# original knife plugin code borrowed heavily from https://github.com/opscode/knife-openstack
# thanks Matt Ray

require 'octokit'

class Chef
  class Knife
    module GithubBase

      def self.included(includer)
        includer.class_eval do

          deps do
            require 'chef/json_compat'
            require 'chef/knife'
            require 'readline'
            Chef::Knife.load_deps
          end

          option :github_token,
            :short => "-T TOKEN",
            :long => "--github-token OAUTH_TOKEN",
            :description => "Your Github OAuth Token",
            :proc => Proc.new { |token| Chef::Config[:knife][:github_token] = token }
        end
      end


      # client = Octokit::Client.new(:login => username, :password => pass)

      # client.create_repo(cookbook, { :organization => "#{org}"} )
     
      Octokit.configure do |c|
        c.api_endpoint = Chef::Config[:knife][:github_api]
        c.web_endpoint = Chef::Config[:knife][:github_web]
      end

      def connection
        Chef::Log.debug("github_token #{Chef::Config[:knife][:github_token]}")

        @connection ||= begin
          connection = Octokit::Client.new(
            :access_token => Chef::Config[:knife][:github_token]
          )
        rescue Excon::Errors::Unauthorized => e
          ui.fatal("Connection failure, please check your Github OAuth Token.")
          exit 1
        rescue Excon::Errors::SocketError => e
          ui.fatal("Connection failure, please check your Github api URL.")
          exit 1
        end
      end

      def locate_config_value(key)
        key = key.to_sym
        Chef::Config[:knife][key] || config[key]
      end

      def msg_pair(label, value, color=:cyan)
        if value && !value.to_s.empty?
          puts "#{ui.color(label, color)}: #{value}"
        end
      end

    end
  end
end

