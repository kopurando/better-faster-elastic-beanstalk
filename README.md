better-faster-elastic-beanstalk
===============================

This collection of hooks for AWS Elastic Beanstalk node.js containers was designed to dramatically reduce deployment times, avoid unnecessary rebuilding of node_modules, install any version of node.js, install global NPM modules and more.

This project demonstrates several tweaks to the standard node.js Elastic Beanstalk configuration that significantly reduce deployment times by avoiding unnecessary rebuilds of node_modules. 

## Main features

 1. Install ANY node.js version as per your env.config (including
    the most recent ones that are not yet supported by AWS EB)  — control your node.js version to avoid surprises with sudden AWS updates or compatibility issues
 2. Avoid rebuilding existing node modules, including in-app
    node_modules dir  — dramatically speeds up deployment
 3. Install node.js globally (and any desired module as well), if your use-case requires so.

Please see the original discussion on StackOverflow to grasp the concept:
http://stackoverflow.com/questions/21200251/avoid-rebuilding-node-modules-in-elastic-beanstalk

__NOTE__: this respo is way ahead of the StackOverflow thread, and heavily customised for my own use-case. It still works as a charm though and saves a lot of time on each deployment. Feel free to look around, be inspired and find solutions for your problems in my code, but it is essential to fork this repo and  adapt it for your own needs.

## Usage

Put `.ebextensions/example_env.config` into your project `.ebextensions` dir and read through the file to get a grasp of its mechanics.  example_env.config from this repo does following:
- installs bunch of packages (such as ImageMagick, git, tmux, mosh etc.); 
- fills option settings with default values (I strongly recommend NOT to put any passwords here, even in a private repo, and instead set them via instances profiles jsons, see docs here http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/create_deploy_nodejs.container.html);
- fetches all *.sh hooks from this _public_ repo. You can (and should) replace them with your own hooks from your private repos of course;
- sets up simple PhantomJS proxy via nginx config modification;
- injects z.sh (for admin comfort);
- sets up logging io.server...

... and much much more. We used these hooks in our production and it worked bulletproof (unless github went down :). Chances are, you won't need 90% of functionality we developed, so please refer to the original SO thread for more ideas and less sophisticated config for generic use-cases:

http://stackoverflow.com/questions/21200251/avoid-rebuilding-node-modules-in-elastic-beanstalk

## Principle of action

We use `.ebextensions/example_env.config` to replace default AWS deploy & config hooks with customized ones (all *.sh files, see detais below). Also, in a default EB container setup some env variables are missing (`$HOME` for example) and `node-gyp` sometimes fails during rebuild because of it (took me 2 hours of googling and reinstalling libxmljs to resolve this). 

Below are the files to be included along with your build. You can inject them via env.config as inline code or via `source: URL` (as in this `example_env.config` from this repo)

**`env.vars`** (desired node version & arch are included here and in `env.config, see below)

**`40install_node.sh`** (fetch and ungzip desired node.js version, make global symlinks, update global npm version)

**`50npm.sh`** (creates /var/node_modules, symlinks it to app dir and runs npm install. You can install any module globally from here, they will land in /root/.npm) 

*you can add more *.sh hooks for your needs*, see `55phantomjs_restart.sh` and `46update_geolitecity.sh` for examples

**`env.config`** (note node version here too, and to be safe, put desired node version in env config in AWS console as well. I'm not certain which of these settings will take precedence.)

There you have it: on t1.micro instance deployment now takes 20-30 secs instead of 10-15 minutes! If you deploy 10 times a day, this tweak will save you 3 (three) weeks in a year.
Hope it helps and special thanks  to AWS EB staff for my lost weekend :)



##todo
- remove (rename) and rebuild node_modules in case NodeJS or npm version gets changed 
