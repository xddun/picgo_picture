FROM nvidia/cuda:10.2-cudnn7-devel-centos7
COPY deps /deps
RUN rm -rf /etc/yum.repos.d/* && \
    cp /deps/CentOS-Base.repo /etc/yum.repos.d/ && \
    yum clean all && yum makecache fast
RUN yum install wget opencv vim -y
RUN wget http://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/conda.sh && \
    bash /tmp/conda.sh -b && rm /tmp/conda.sh && \ 
    cp -f /deps/.condarc /root/ 
	
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
RUN source ~/.bashrc && source /root/miniconda3/bin/activate && conda activate base \
    && conda create -n py38 python=3.8.12 -y \
    && source ~/.bashrc && source /root/miniconda3/bin/activate && conda activate py38 \
	&& pip install -i https://pypi.tuna.tsinghua.edu.cn/simple pip -U && pip install pip -U && pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple \
	&& pip install fastapi uvicorn python-multipart \
	&& pip install -r /deps/requirements.txt \
	&& python --version \
	&& conda install -y pytorch==1.8.0 torchvision==0.9.0 torchaudio==0.8.0 cudatoolkit=10.2 -c pytorch

WORKDIR /root/
COPY testfastapi.py .
ENTRYPOINT   ["/root/miniconda3/envs/py38/bin/python", "testfastapi.py"]