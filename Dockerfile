FROM ipython/scipystack

ADD singlekernel.py /srv/

EXPOSE 8888

# The exec form causes kernels to restart unless invoked with sh -c
CMD ["sh", "-c", "/srv/singlekernel.py"]
