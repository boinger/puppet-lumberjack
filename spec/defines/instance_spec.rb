require 'spec_helper'

describe 'lumberjack::instance', :type => 'define' do

  let(:title) { 'foo' }
  let(:facts) { { :operatingsystem => 'CentOS' } }
  let(:pre_condition) { 'class {"lumberjack":; }' }

  context "Setup a instance with the service" do

    let :params do {
      :ssl_ca_file    => 'puppet:///path/to/ca.crt',
      :hosts          => ['localhost'],
      :port           => 1234,
      :files          => [ '/var/log/file1', '/var/log/file2' ],
      :fields         => { 'field1' => 'value1', 'field2' => 'value2' },
      :provider       => "init.d"
    } end

    it { should contain_file('/etc/init.d/lumberjack-foo') }
    it { should contain_file('/etc/lumberjack/foo') }
    it { should contain_file('/etc/lumberjack/foo/ca.crt') }

  end

  context "Setup a instance without a service" do

    let :params do {
      :ssl_ca_file    => 'puppet:///path/to/ca.crt',
      :provider       => "none"
    } end

    it { should_not contain_file('/etc/init.d/lumberjack-foo') }
    it { should contain_file('/etc/lumberjack/foo') }
    it { should contain_file('/etc/lumberjack/foo/ca.crt') }

  end

end
