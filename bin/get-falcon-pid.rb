#!/usr/bin/env ruby
#==============================================================================
# Copyright (C) 2021-present Alces Flight Ltd.
#
# This file is part of FlightSchedulerController.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# FlightSchedulerController is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with FlightSchedulerController. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on FlightSchedulerController, please visit:
# https://github.com/openflighthpc/flight-scheduler-controller
#==============================================================================

# Return the PID of the falcon supervisor process associated with the IPC
# given in ARGV[0].

require "pathname"
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile",
  Pathname.new(__FILE__).realpath)

bundle_binstub = File.expand_path("../bundle", __FILE__)

if File.file?(bundle_binstub)
  if File.read(bundle_binstub, 300) =~ /This file was generated by Bundler/
    load(bundle_binstub)
  else
    abort("Your `bin/bundle` was not generated by Bundler, so this binstub cannot run.
Replace `bin/bundle` by running `bundle binstubs bundler --force`, then run this command again.")
  end
end

require "rubygems"
require "bundler/setup"

require 'async'
require 'async/io/stream'
require 'async/io/unix_endpoint'
require 'json'

if ARGV.empty?
  STDERR.puts "usage get-pid.rb PATH_TO_IPC_SOCKET"
  exit 1
end

Async do
  endpoint = Async::IO::Endpoint.unix(ARGV[0])
  endpoint.connect do |socket|
    stream = Async::IO::Stream.new(socket)
    stream.puts({please: 'metrics'}.to_json, separator: "\0")
    response = JSON.parse(stream.gets("\0"), symbolize_names: true)
    puts response.keys.first
  end
rescue
  exit 2
end
