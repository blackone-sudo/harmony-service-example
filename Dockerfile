FROM continuumio/miniconda3:4.7.12

WORKDIR "/home"

# Install the app dependencies into the base conda environment so we
# don't need to activate a conda environment when running.
COPY environment.yml .
RUN conda env update --file environment.yml -n base

# This is below the preceding layer to prevent Docker from rebuilding the 
# previous layer (forcing a conda reload of dependencies) whenever the
# status of a local service library changes
ARG service_lib_dir=NO_SUCH_DIR

# Install a local harmony-service-lib-py if we have one
COPY deps ./deps/
RUN if [ -d deps/${service_lib_dir} ]; then echo "OK"; pip install deps/${service_lib_dir}; fi
# Else install from PiPy - this is done separately to allow caching of primary deps above
RUN if [ ! -d deps/${service_lib_dir} ]; then pip install harmony-service-lib; fi

# Copy the app. This step is last so that Docker can cache layers for the steps above
COPY . .

ENTRYPOINT ["python", "-m", "harmony_gdal"]
