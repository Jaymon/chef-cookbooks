# https://docs.chef.io/libraries.html
# https://blog.chef.io/2014/03/12/writing-libraries-in-chef-cookbooks/

module PythonHelper
  class PythonHelper

    # returns the recipes and packages that should be installed
    #
    # basically, we allow custom recipes that can be run transparently so needed
    # packages and stuff can be installed as needed, this takes a package_name and
    # then figures out what recipes and packages should be installed (eg, if you
    # passed in requirements.txt that had `psycopg2` in it, this would return 
    # `package_psycopg2` in the recipes and `requirements.txt` in the packages
    #
    # @param [string] name: the recipe name
    # @param [hash] node: the root chef node
    # @param [string] package_name: the package name that was requested that will
    #   be used to populate the return arrays
    # @returns [array]: a length 2 array with recipe_names at index 0 and package_names at 1
    def self.get_recipes_packages(name, node, package_name)
      recipe_names = []
      package_names = []

      # if we have a requirements.txt file then parse it and see if any of the defined
      # packages has a matching recipe
      if ::File.exist?(package_name)
        ::File.read(package_name).each_line do |line|
          # get rid of comments and sorrounding whitespace
          line = line.sub(/(?:^|\s+)#.*$/, "").strip()
          if !line.empty?
            recipe_name = self.get_recipe(name, node, line)
            if !recipe_name.empty?
              recipe_names << [recipe_name, line]
            end
          end
        end

        # we want to install the packages that have custom recipes first, then we will run the file
        package_names << package_name

      else
        recipe_name = self.get_recipe(name, node, package_name)
        if recipe_name.empty?
          package_names << package_name
        else
          recipe_names << [recipe_name, package_name]
        end

      end

      return [recipe_names, package_names]

    end

    # given a package_name return the internal recipe if it exists, "" otherwise
    def self.get_recipe(name, node, package_name)
      # get the actual package name from things like foo==N.N.N
      recipe_name = "package_#{package_name.downcase.match('^[a-z][a-z0-9_-]*')}"
      # via: https://discourse.chef.io/t/getting-cookbookversion-at-runtime/5250/3
      # https://discourse.chef.io/t/getting-cookbookversion-at-runtime/5250/2
      if node.run_context.cookbook_collection[name].recipe_filenames_by_name.has_key?(recipe_name)
        return recipe_name
      end

      return ""

    end

  end
end


# http://stackoverflow.com/questions/20835697/how-to-require-my-library-in-chef-ruby-block
::Chef::Recipe.send(:include, PythonHelper)

