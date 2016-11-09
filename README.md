# semversort
SemVer Sort / Versions sorting

It project doesn't validate schema, it's more or less similar to the PHP function [`version_sort`](http://php.net/version_sort) algorithm.
Also, it supports sorting patches like `1.2.3-patch.4` but native [SemVer](https://github.com/npm/node-semver) doesn't.

If you use only valid Semantic versions, you may use [SemVer](https://github.com/npm/node-semver) app written on NodeJS.

## Versions
- 0.1.0

## Download latest version
```shell
$ curl -Ls https://raw.github.com/rikby/semversort/master/download | bash
```

It will create file `/usr/local/bin/semversort`.

## Using examples
```shell
$ semversort 1.0 1.0-rc 1.0-patch 1.0-alpha
```
```shell
$ semversort $(git tag)
```
```shell
$ echo 1.0 1.0-rc 1.0-patch 1.0-alpha | semversort
```
