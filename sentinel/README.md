# Sentinel Cookbook

Perform actions when things change.


## Configuration block

```ruby
"sentinel" => {
    "files" => [
        {
            "path" => "/some/path/to/file",
            "commands" => [
                "command to run",
            ],
            "notifies" => [
                [:restart, "service[NAME]", :delayed],
            ],
        },
    ],
}
```


## Attributes

* __files__ - Array - An array of hashes with the following keys:

    * __path__ - String - the source path you want to monitor
    * __notifies__ - Array - A list of tuples that will be used in the notifies block to have chef do something when the file at `path` changes.
    * __commands__ - Array - __NOT IMPLEMENTED AS OF 10-28-2020__ - A list of string commands that will be run when the file at `path` changes. This can be implemented in the cookbook by creating execute resources and then adding them to the `notifies` block that will get attached to the `remote_file` resource. I didn't implement it because I don't have a need for it yet but I wanted to get the structure in place.


## Platform

Ubuntu 18.04, nothing else has been tested

