FROM pytorch/pytorch:2.2.0-cuda12.1-cudnn8-devel

RUN apt update && apt install -y git unzip syncthing curl wget supervisor ca-certificates tmux sudo 


# Install Cloudflared
RUN wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
RUN dpkg -i cloudflared-linux-amd64.deb


# Configure Supervisor
RUN mkdir -p /etc/supervisor/conf.d
COPY supervisord.conf /etc/supervisor/supervisord.conf

RUN useradd -m user && echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN mkdir -p -m777  /workspace/kohya_ss/ /assets /output
USER user


WORKDIR /workspace/kohya_ss/

RUN git clone https://github.com/kohya-ss/sd-scripts --depth=1

RUN cd sd-scripts && pip install -r requirements.txt 
RUN pip install tensorflow==2.10.1
USER root

USER user

# Expose necessary ports
EXPOSE 8384 22000 21027/udp 3000

# Start Supervisor
CMD ["/usr/bin/supervisord"]