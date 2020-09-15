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

1. Clone this repository into your projects folder:

   `git clone git@github.com:Lubje/docker-template-laravel8.git my-new-project`

1. Enter your newly created project folder and copy the .env file:

    `cd my-new-project`

    `cp .env.example .env`

    Open the .env file and change the values to your liking.

    The PROJECT_NAME will be used to name your Docker services, Docker images and the database.
    
    For the rest of the examples we will assume the PROJECT_NAME has a value of "my-new-project".

1. Temporarily create the public folder that will be mounted through the volumes in the docker-compose.yml file:

    `mkdir -p src/public`

1. Create the external network, so we can connect to MySQL, Redis and NGINX using the external ports set in the root .env file:

    `docker network create external`

1. Build, create, start and attach the containers for the services:

    `docker-compose up -d`

1. Remove the earlier created temporary public folder:

    `rm -rf src/public`
    
    The public folder will be recreated during the Laravel installation in the next step. 

1. Enter the bash shell of your PHP container and install Laravel:

    `docker exec -it my-new-project-php bash`

    `composer create-project --prefer-dist laravel/laravel .`

1. Edit the Redis and MySQL variables in the newly created src/.env file to match the following:

    ```
    DB_CONNECTION=mysql
    DB_HOST=mysql
    DB_PORT=3306
    DB_DATABASE=my-new-project
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
   
   Make sure you set DB_DATABASE to the same value that PROJECT_NAME has in the root .env file.

1. Exit the bash shell and restart the services:

    `exit`

    `docker-compose restart`
 
1.  [ OPTIONAL ] Install scaffolding through Jetstream:

    `docker exec -it my-new-project-php composer require laravel/jetstream`
 
    Install either the Livewire or the Inertia variant (add the --teams flag at the end of the Livewire or Inertia installation command to enable the teams functionality):
    
    1. Livewire + Tailwind CSS:

        `docker exec -it my-new-project-php php artisan jetstream:install livewire`
        
        Publish the views:
        
        `docker exec -it my-new-project-php php artisan vendor:publish --tag=jetstream-views`

    1. Inertia + Tailwind CSS:

        `docker exec -it my-new-project-php php artisan jetstream:install inertia`

    Compile the assets:
    
        `docker exec -it my-new-project-php npm install`
    
        `docker exec -it my-new-project-php npm run dev`

1. Run the migrations:

    `docker exec -it my-new-project-php php artisan migrate`

1. Visit your running app by navigating to `http://localhost:{NGINX_EXTERNAL_PORT}`.

