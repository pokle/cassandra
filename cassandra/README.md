Cassandra Docker Images
========================
You can find all neccessary files to build a certain docker image for a cassandra version in the directory with the version name.

##Generate Dockerfile in version directory for given version

The file *generate* generates a Dockerfile and all additional files per cassandra version in its own directory. Calling the build.sh script in this directory will build the image with cassandra version tag. Files from templates directory will be used to replace certain variables. src directory will directly be copied into the new version directory.
New versions can be added in file *generator* in the dictionary 'version_to_package' by adding a <version_name: package_name> pair, e.g. "2.1": "dsc21". 

###Install python requirements

```bash
pip install -r requirements.txt
```

###Examples:

####Generate Directory:

Generate directory 2.1 with Dockerfile and build.sh script:

```bash
./generate -v 2.1
```

####Generate Directory and build image:

```bash
./generate -v 2.1 -b
```

####List versions

```bash
./generate -l
```

####Help

```bash
./generate -h
```

