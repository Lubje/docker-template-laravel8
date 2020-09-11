# Docker Template for Laravel 8

An easy to use docker shell for your new Laravel 8 application.

Includes MySQL, Redis, Nginx and PHP services using Docker Compose.


## Powered by

- [Docker](https://www.docker.com) with use of [Docker Compose](https://docs.docker.com/compose)
- [Docker Hub NGINX image](https://hub.docker.com/_/nginx)
- [Docker Hub MySQL image](https://hub.docker.com/_/mysql)
- [Docker Hub Redis image](https://hub.docker.com/_/redis)
- [General purpose PHP images by TheCodingMachine](https://github.com/thecodingmachine/docker-images-php)
- [HTML5 Boilerplate: Nginx Server Configs](https://github.com/h5bp/server-configs-nginx)
- [Laravel](https://laravel.com)
- [Laravel Jetstream](https://jetstream.laravel.com)
- [Inertia](https://inertiajs.com)
- [Livewire](https://laravel-livewire.com)
- [Tailwind CSS](https://tailwindcss.com)


## Installation

1. Clone this repository into your project folder:

   `git clone git@github.com:Lubje/docker-template-laravel8.git my-new-project`

1. Move in to your new project folder:

    `cd my-new-project`

1. Copy the .env.example file:

    `cp .env.example .env`

1. Open the .env file and change the values to your liking.

    The PROJECT_NAME will be used to name your Docker services and images.

1. Temporarily create the public folder that will be mounted through the volumes in the docker-compose.yml file:

    `mkdir -p src/public/`

1. Create the external network, so we can connect to MySQL, Redis and NGINX using the external ports set in the root .env file:

    `docker network create external`

1. Build, create, start and attach the containers for the services:

    `docker-compose up -d`

1. Enter the bash shell of your PHP container:

    `docker exec -it {PROJECT-NAME}-php bash`

1. Install Laravel from the bash shell of your PHP container:

    `composer create-project --prefer-dist laravel/laravel .`

1. Edit the Redis and MySQL variables in your src/.env file to match the following:

    ```
    DB_CONNECTION=mysql
    DB_HOST=mysql
    DB_PORT=3306
    DB_DATABASE={PROJECT_NAME}
    DB_USERNAME=user
    DB_PASSWORD=password
    
    BROADCAST_DRIVER=redis
    CACHE_DRIVER=redis
    QUEUE_CONNECTION=redis
    SESSION_DRIVER=redis
    SESSION_LIFETIME=120
    
    REDIS_HOST=redis
    REDIS_PASSWORD=null
    REDIS_PORT=6379
    ```

   Make sure that you replace "{PROJECT_NAME}" with the value that you set earlier in the root .env file.

1. Run the initial migrations from the bash shell of your PHP container:

    `php artisan migrate`

1. Use the NGINX_PORT you set in the root .env file to access your newly created app, by navigating to `http://localhost:{NGINX_EXTERNAL_PORT}`.


## Install scaffolding through Jetstream (optional)
 
 
### Option 1: Livewire + Tailwind CSS


### Option 2: Inertia + Tailwind CSS

