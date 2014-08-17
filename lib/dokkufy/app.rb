module Dokkufy
  class App

    attr_accessor :hostname, :username, :repo, :app_name

    def initialize args
      if args.length == 2
        self.repo        = args.first
        self.username    = args.first.split("@").first
        self.hostname    = args.first.split("@").last.split(":").first
        self.app_name    = args.first.split("@").last.split(":").last
      elsif args.length == 3
        self.hostname    = args[0]
        self.username    = args[1]
        self.app_name    = args[2]
        self.repo        = "#{username}@#{hostname}:#{app_name}"
      else
        raise ArgumentError("Invalid number of arguments")
      end
    end

    def dokkufy
      git = Dokkufy::Git.new
      if git.app_exists?(app_name)
        puts "Sorry, an app named #{app_name} already exists in your .dokkurc file"
      else
        git.add_app(repo)
        puts "You can now push your app using `git push #{app_name} master`"
      end
    end

  end
end
