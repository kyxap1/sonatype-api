## Shell CLI for Nexus Sonatype 2.xx API

### DEPENDENCIES

```ShellSession
apt-get install httpie jq
```

## FEATURES

### NOTE

hat every constructors call resets global $QUERY variable
to parent context, means API resource reusage (and shell piping)
is not possible after querying different url

### FILTERS OVERRIDE

it's a handy substitution-based feature to test filter's string via
commandline or using script as a pipe

#### TODO

- read from stdin when used as pipe
- global query-related vars should be ignored when using filter in commandline

#### DESC

- sets JQ value to cmd args if they were passed to script
- if not, then assign JQ to FILTER value.
- in case of absence of foregoing FILTER value, sets jq filtering pattern to default '.' value.


```ShellSession
printf -v JQ "${@:-%s}" "${FILTER[@]}"
http ${QUERY} | jq "${JQ[@]:-'.'}"
```

## USAGE SAMPLES

### search::main

query releases repository with $ROLE (suitable service name), extracted from actual $HOSTNAME

```ShellSession
search "r==releases q==${ROLE}"
```
  e.g.

```ShellSession
HOSTNAME=order-srv666
ROLE=${HOSTNAME%-*}                          # ROLE=order
NODEID=${HOSTNAME#${HOSTNAME/[[:digit:]]*}}  # NODEID=666
HYPHEN=${HOSTNAME#${ROLE}-}                  # HYPHEN=-srv
TYPE=${HYPHEN%${NODEID}}                     # TYPE=srv
```

### search::filter

filter input by extension and version, then print coordinates

```ShellSession
FILTER='.data[] | select(.artifactHits[].artifactLinks[] .extension == "'${PACKAGING}'" and .version == "'${VERSION:?}'") | .groupId, .artifactId'
```

filter input by excplicited extensions list and up-layer .repositoryId presence

```ShellSession
FILTER='.data[] | select(.artifactHits[].artifactLinks[] .extension == "ear" or .extension == "war" and "..|.repositoryId" ) | keys'
```

filter input by excluded extension, .version presence on current layer and up-layer .repositoryId presence

```ShellSession
FILTER='.data[] | select(.artifactHits[].artifactLinks[] .extension != "jar" and .version and "..|.repositoryId" )' | keys, .version'
```

### resolve::main

resolve repository path for artifact with specified coordinates

```ShellSession
resolve "r==${REPOSITORY} g==${GROUPID} a==${ARTIFACTID} v==${VERSION} p==${PACKAGING}"
```

#### resolve::filter

filter input and returns .repositoryPath to use in redirect::main constructor

```ShellSession
FILTER='.data.repositoryPath'
```

### redirect::main

#### TODO

handle with redirect::main VERSION metas: LATEST | RELEASE | 1.0-SNAPSHOT

