Vagrant.configure(2) do |config|
  org = "travishook6"

  config.vm.box     = "cloudspace_default_12.042"
  config.vm.box_url = "https://s3.amazonaws.com/vagrant.cloudspace.com/cloudspace_ubuntu_12.042_ruby_2.box"

  config.ssh.private_key_path = [File.join(ENV['HOME'], '.ssh', 'cs_vagrant.pem'), File.join(ENV['HOME'], '.ssh', 'id_rsa')]

  config.ssh.forward_agent = true

  config.vm.network "private_network", ip: "33.33.33.71"

  config.vm.synced_folder ".", "/srv/#{org}", type: "nfs"
  
  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "2048", "--name", "#{org}","--cpus", "2"]
    # v.gui = true
  end
  
  config.vm.provision :chef_solo do |chef|

    chef.node_name = "#{org}_vagrant_#{ENV['USER']}"

    chef.cookbooks_path = "cookbooks"
    chef.add_recipe "ubuntu"
    chef.add_recipe "git"
    chef.add_recipe "postgresql::server"
    chef.add_recipe "postfix"
    chef.add_recipe "nodejs"
    chef.add_recipe "bundler"
    chef.add_recipe "librarian-chef"


    chef.json = {
      :postgresql => {
        :password => {
          :postgres => ''
        },
        :pg_hba => [
          {
            :comment => '# User For Rails Development', 
            :type => 'host',
            :db => 'all',
            :user => 'all',
            :addr => "localhost",
            :method => 'trust'
          }
        ]
      }, :postfix => {
        :mydomain => '#{org}.com'
      },
      :nodejs => {
        :install_method => 'source'
      },
      :bundler => { :app_path => "/srv/#{org}" },
      :librarian_chef => { :app_path => "/srv/#{org}" }
    }

  end
end
