FROM ruby:2.2

# see update.sh for why all "apt-get install"s have to stay as one long line
RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*

# see http://guides.rubyonrails.org/command_line.html#rails-dbconsole
RUN apt-get update && apt-get install -y mysql-client postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV RAILS_VERSION 4.2.5.1

RUN gem install rails --version "$RAILS_VERSION"



#nginx
ENV NGINX_VERSION 1.9.11-1~jessie
RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
    && echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y ca-certificates nginx=${NGINX_VERSION} gettext-base \
    && rm -rf /var/lib/apt/lists/*
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log




#zsh
ENV ZSH_DEP_PACKAGE  "software-properties-common build-essential"
RUN apt-get update && apt-get install -y $ZSH_DEP_PACKAGE
RUN apt-get install -y zsh git
RUN git clone git://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh \
    && chsh -s /bin/zsh

#vim plugin
RUN apt-get install -y vim
RUN mkdir -p ~/.vim/autoload ~/.vim/bundle && curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
RUN git clone https://github.com/atyenoria/vim-pathogen.git ~/.vim.tmp && \
    ln -sf ~/.vim.tmp/autoload/pathogen.vim ~/.vim/autoload/pathogen.vim && \
    git clone https://github.com/atyenoria/nerdcommenter.git ~/.vim/bundle/nerdcommenter && \
    git clone https://github.com/atyenoria/delimitMate.git ~/.vim/bundle/delimitMate && \
    git clone https://github.com/atyenoria/PDV--phpDocumentor-for-Vim.git ~/.vim/bundle/phpDocumentor && \
    git clone https://github.com/atyenoria/vim-colorschemes.git ~/.vim/bundle/colorschemes && \
    git clone https://github.com/atyenoria/vim-misc.git ~/.vim/bundle/vim-misc && \
    git clone https://github.com/atyenoria/vim-colorscheme-switcher.git ~/.vim/bundle/colorscheme-switcher
ADD .vimrc /root/.vimrc


# Surpress Upstart errors/warning
# RUN dpkg-divert --local --rename --add /sbin/initctl
# RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
# ENV DEBIAN_FRONTEND noninteractive


# Install software requirements
ENV EXT_PACKAGES "wget curl lsof sudo supervisor dnsutils jq"
RUN apt-get update && \
    apt-get -y install $EXT_PACKAGES && \
    apt-get autoremove -y && \
    apt-get clean && \
    apt-get autoclean && \
    echo -n > /var/lib/apt/extended_states && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*


#clean up
RUN apt-get remove --purge -y software-properties-common && \
    apt-get autoremove -y && \
    apt-get clean && \
    apt-get autoclean && \
    echo -n > /var/lib/apt/extended_states && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*

RUN ln -sf /usr/share/zoneinfo/Japan /etc/localtime


RUN gem install foreman unicorn

# Rails App directory
WORKDIR /app

# Add default unicorn config

# Add default foreman config
ADD Procfile /app/Procfile
ADD unicorn.rb /app/unicorn.rb

ADD zshrc /root/.zshrc

ENV RAILS_ENV production


ADD nginx.conf /etc/nginx/nginx.conf





ADD start.sh /start.sh
ADD .bundle_config /usr/local/bundle/config

RUN mkdir -p /app
