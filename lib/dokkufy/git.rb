module Dokkufy
  class Git

    def dokku_remote_present?
      !dokku_remote.nil?
    end

    def dokku_remote
      @dokku_remote ||= current_remote
    end

    def add_app(repo)
      @app_name = repo.strip.split(':').last
      @dokku_remote = repo
      add_git_remote
      add_dokkufile_remote
    end

    def clear
      apps = dokku_apps

      if dokku_apps.count > 0 || File.exists?('.dokkurc')
        puts 'Removing git remotes...'
        apps.each do |app|
          `git remote remove #{get_app_name(app)}`
        end

        puts 'Removing .dokkurc file...'
        `rm .dokkurc`
      else
        puts "Sorry, there are no apps for me to clear"
      end
    end

    def current_app
      current_remote.split(':').last
    end

    def current_app=(app)
      @current_app = app
      set_current_app
    end

    def app_list
      puts 'This is a list of current dokku apps for this application'
      puts '* = current app'
      puts
      puts dokku_apps.map { |app| app =~ /^\*/ ? "*#{app.split(':').last}" : app.split(':').last }
    end

    def remove_app(app_name)
      if app_exists?(app_name)
        puts "Removing dokku app: #{app_name}"

        modified_app_list = dokku_apps.select { |app| !(app =~ /^\*?.*:#{Regexp.quote(app_name)}$/) }
        self.dokku_apps = modified_app_list

        puts 'Removing git remote'
        `git remote remove #{app_name}`
      else
        puts "Sorry, there is no app named #{app_name} in your .dokkurc file"
      end
    end

    def app_exists?(app_name)
      dokku_apps.select { |app| app.split(':').last == app_name }.count > 0
    rescue
      false
    end

    def get_app_name(app)
      app.split(':').last
    rescue
      ''
    end

    def current_remote
      if dokku_apps.count == 1
        dokku_apps.first.gsub(/^\*?/, '')
      elsif dokku_apps.count > 1
        app = dokku_apps.select { |app| app =~ /^\*/ }.first
        app[1..-1] if app
      else
        nil
      end
    rescue
      nil
    end

    private

    def add_git_remote
      puts 'Adding remote to git...'
      `git remote add #{@app_name} #{@dokku_remote}`
    end

    def add_dokkufile_remote
      if dokku_apps.select { |app| app.strip =~ /Regexp.quote(@dokku_remote)/ }.empty?
        self.dokku_apps = dokku_apps << "#{@dokku_remote}"
      else
        puts 'That remote already exists'
      end

      @current_app = @app_name
      set_current_app
    end

    def dokku_apps
      @dokku_apps ||= File.open(".dokkurc").map do |line|
        line.strip
      end
    rescue
      []
    end

    def dokku_apps=(apps)
      @dokku_apps = apps
      File.open('.dokkurc', 'w') do |f|
        apps.each { |app| f.write(app + "\n") }
      end
    end

    def set_current_app
      puts "Writing .dokkurc"
      updated_apps = dokku_apps.map do |app|
        demoted = app.gsub(/^\*/, '')
        demoted.split(':').last == @current_app ? '*' + demoted : demoted
      end
      self.dokku_apps = updated_apps
    end

  end
end
