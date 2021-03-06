#Конфик мультистейджа. Должен быть в начале.
#Стейдж нельзя называть 'stage', поэтому зовем его 'staging'
set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

#Приложение
set :application, "new.chebit.ru"

#Репозиторий
set :scm, :git
set :repository,  "git@github.com:BrandyMint/#{application}.git"
set :deploy_via, :remote_cache
#set :git_enable_submodules, 1
set :scm_verbose, true
#Используем локальные ключи для приватных репозиториев на github
#В ~/.ssh/config на локальной машине должен быть прописан ForwardAgent yes
#https://help.github.com/articles/using-ssh-agent-forwarding
ssh_options[:forward_agent] = true

#Учетные данные на сервере
set :user,      'wwwchebit'
set :deploy_to,  defer { "/home/#{user}/#{application}" }
set :use_sudo,   false

#Все остальное
set :keep_releases, 3
set :shared_children, fetch(:shared_children) + %w(public/uploads)

set :rbenv_ruby_version, "1.9.3-p392"
set :bundle_flags, "--deployment --quiet --binstubs"

before 'deploy:restart', 'deploy:migrate'
after 'deploy:restart', "deploy:cleanup"
after 'deploy:finalize_update', 'chebit:symlink_configs'

#RVM, Bundler
load 'deploy/assets'
require "bundler/capistrano"
require "capistrano-rbenv"
require "holepicker/capistrano"
require "recipes0/database_yml"
require "recipes0/db/pg"
require "recipes0/init_d/unicorn"
require "recipes0/nginx"

namespace :chebit do
   task :symlink_configs, :except => { :no_release => true } do
      run "ln -nfs #{shared_path}/config/settings.yml #{release_path}/config/settings.yml" 
   end
end


