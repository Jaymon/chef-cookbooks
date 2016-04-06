# Locations Cookbook

place files and folders in the right spot


## Attributes

### users

the users key should contain a dictionary of locations that should be created, each key under the users is a description of the file being created, then that dict could contain the following keys:


#### src (optional)

The source file to use, if you don't have a source file, you can also set `content` which will be used as the source content for the destination file.
If you don't specify a `src` path or a `content` string, then it is assumed `dest` is a directory and it will just create the full path defined in `dest`.


#### dest (required)

The final resting place of the src file/dir or content.


#### mode (optional)

The linux mode specified like: `0755`

| user  | group | world |
| ----- |:-----:| ----- |
| r w x | r w x | r w x |
| 4 2 1 | 4 2 1 | 4 2 1 |


#### content (optional)

If you don't have an actual source file, you can set content to have dest file contain `content`.


## Example

This is what the configuration looks like

    "locations" => {
      "users" => {
        username => {
          "bash_profile" => {
            # move source file to dest file
            "src" => ::File.join("some", "base", "dir", "bash.sh"),
            "dest" => ::File.join("", "home", username, ".bash_aliases"),
            "mode" => "0644"
          },
          "all_dir_copy" => {
            # move all the contents of src directory to dest directory
            "src" => ::File.join("some", "dir"),
            "dest" => ::File.join("some", "destination"),
            "mode" => "0755"
          },
          "cache_dir" => {
            # create a folder owned by username at /var/cache
            "dest" => ::File.join("", "var", "cache"),
            "mode" => "0644"
          },
          "username_file" => {
            # create a file at /tmp/username with content
            "dest" => ::File.join(::Dir.tmpdir, "username"),
            "content" => username,
            "mode" => "0644"
          },
        },
      }
    },

## Platform

Ubuntu 14.04, nothing else has been tested

