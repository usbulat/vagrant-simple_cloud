cd test

bundle exec vagrant up --provider=simple_cloud
bundle exec vagrant up
bundle exec vagrant provision
bundle exec vagrant rebuild
bundle exec vagrant halt
bundle exec vagrant destroy

cd ..
