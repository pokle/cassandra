Generate Dockerfile
===================

Generate Dockerfile and all additional files per cassandra version in own directory. Calling the build.sh script will build the image with cassandra version tag. Files from templates directory will be used to to replace certain variables. src directory will directly copied into the new version directory.

###Generate Directory:

Generate directory 2.1 with Dockerfile and build.sh script:

```bash
./generate.py -v 2.1
```

###Generate Directory and build image:

```bash
./generate.py -v 2.1 -b
```

###List versions

```bash
./generate.py -l
```

###Help

```bash
./generate.py -h
```
