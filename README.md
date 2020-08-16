# umx package
This is a Docker container for R 4.0.2 with RStudio, [Intel Math Kernel Library (MKL)](https://software.intel.com/en-us/mkl?cid=sem43700010399172562&intel_term=%2Bintel%20%2Bmkl&gclid=Cj0KCQjwzcbWBRDmARIsAM6uChXqzD4ACUJqCiu3zRJKA9rkC31XOhm9lIkEYiwBITMR_8hJbIAExF8aAn_LEALw_wcB&gclsrc=aw.ds), and `umx` package pre-installed. 

`umx` is a package designed to make [structural equation modeling](https://en.wikipedia.org/wiki/Structural_equation_modeling) easier, from building, to modifying and reporting.
`umx` includes high-level functions for complex models such as multi-group twin models, as well as graphical model output.

[Find out more about umx](https://github.com/tbates/umx).

## Docker Commands
### Pull umx image from dockerhub
```sudo docker pull diffpsych/umx```

### Run the umx container in detatched mode 
Map a host folder to the container so the container can access files on host and write out results. This is important since the --rm flag is there to tell the Docker Daemon to clean up the container and remove the file system after the container exits. Make sure you run the container as a non-root user.

`sudo docker run -d --rm -v $(pwd):/home/rstudio/data -e USERID=$UID -p 8787:8787 -e PASSWORD=<password> diffpsych/umx`

Username to login to RStudio is `rstudio` and the password is whatever you set when you ran container.

[More details about permissions on rocker wiki](https://github.com/rocker-org/rocker/wiki/Sharing-files-with-host-machine#linux)

### See list of all running containers
```sudo docker ps```

### Kill running container
```sudo docker kill <container ID>```

## R Code

### Shows how many cores you are using, and runs a test script so user can check CPU usage
`umx::umx_check_parallel()`

### Set number of cores you want `umx` to use
`umx::umx_set_cores()` #if empty, shows number of available cores

### Benchmark MKL
`benchmarkme::benchmark_std(runs=1)`