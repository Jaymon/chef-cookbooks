# Diff Cookbook

Apply diff patches

## Attributes

`node["diff"]["patch"]` -- a list of patches

    node["diff"]["patch"] = [
      {
        "file" => "/path/to/file/to/patch",
        "diff" => "/path/to/diff/patch",
        "checksum" => "32 char md5 hash of 'file'"
      }
    ]

## Platform

Ubuntu 12.04, nothing else has been tested

