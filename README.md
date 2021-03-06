# kernels-service

Launch Jupyter kernels over HTTP. Provides only the kernels and kernelspecs APIs of IPython/Jupyter.

### Direct launch

kernels.py starts a tornado web server that launches a single kernel and provides the ability to launch more.

Here we set the base path of the IPython API to start at `/minipython/`:


```console
$ python kernels.py --base-path=minipython
[I 150110 14:23:45 kernelmanager:85] Kernel started: 69f7a0bf-7900-49be-bcab-05acece7d2d5
[I 150110 14:23:45 singlekernel:98] Serving at http://127.0.0.1:8888/minipython/api/kernels/69f7a0bf-7900-49be-bcab-05acece7d2d5
[I 150110 14:23:58 web:1811] 200 GET /minipython/api/kernels/69f7a0bf-7900-49be-bcab-05acece7d2d5 (127.0.0.1) 29.48ms
```

A Docker image is available for launching directly:

```
$ docker run -it -p 8888:8888 rgbkrk/single-jupyter-kernel
```

Several environment variables are available for configuration:

Environment Variable | Description
---------------------|----------------------------------------------------------------------------------------------------------
`KERNEL_NAME`        | The name of the initial kernel (language type) to use, defaults to system python (could be 'ir' for the R Kernel)

Derivative images of `rgbkrk/kernels` that install kernels like IJulia or the IRKernel need only define these in their Dockerfiles. :warning: Depending on your usage, you may want to include a non-root user in the Docker image that runs the service itself. :warning:

Options for base path and port are provided via command line arguments (like the tmpnb demo image). If used directly, they must be done with `sh -c` explicitly:

```console
$ docker run -it -p 8888:8888 rgbkrk/single-jupyter-kernel sh -c "/srv/singlekernel.py --base-path=/krn/"
[I 150110 20:19:42 kernelmanager:85] Kernel started: 0a9f36b3-4faa-4405-bb8e-64405c7c093a
[I 150110 20:19:42 singlekernel:98] Serving at http://127.0.0.1:8888/krn/api/kernels/0a9f36b3-4faa-4405-bb8e-64405c7c093a
[I 150110 20:19:51 web:1811] 200 GET /krn/api/kernels/0a9f36b3-4faa-4405-bb8e-64405c7c093a (192.168.59.3) 0.82ms
```

Otherwise you get that awkward kernel restart that occurs when IPython and Docker's pseudo-exec collide:

```console
$ docker run -it -p 8888:8888 rgbkrk/single-jupyter-kernel /srv/singlekernel.py --base-path=/krn/
[I 150110 20:22:02 kernelmanager:85] Kernel started: 9030f86f-aff4-4203-b354-d233fcff7c05
[I 150110 20:22:02 singlekernel:98] Serving at http://127.0.0.1:8888/krn/api/kernels/9030f86f-aff4-4203-b354-d233fcff7c05
[I 150110 20:22:05 restarter:103] KernelRestarter: restarting kernel (1/5)
...
```

### Connecting to the kernel over JavaScript

This is terribly hacky, there must be a better way. I'm directly using one notebook to get access to the kernel running *somewhere* else.

```JavaScript
// Hokey creation of a kernel object
var k = new IPython.Kernel("", "", IPython.notebook);

// This kernel can be located anywhere
k.ws_url = 'ws://127.0.0.1:8888'

// Using the full path provided on launch
k.kernel_url = "/krn/api/kernels/5b7ad625-4484-403a-a7c3-8b16394b2ae7"
k.kernel_id = "5b7ad625-4484-403a-a7c3-8b16394b2ae7"

k.start_channels()

// TODO: Wait for the websocket connection to finalize
k.execute('import os; os.mkdir("touchdown")');
```

In reality, I want to be able to use the kernel *without* a notebook.

The reason is that events are propagated to a notebook model in the JavaScript.
