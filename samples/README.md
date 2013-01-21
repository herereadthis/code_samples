Update 2013-01-21 Patch
=======================

Hi, I've created a patch to accomplish the goals of this test.
1. All JS has been converted or created to be using RequireJS

2. On the homepage, we have a link to load the conditions of aneurysms, which is set by a new module, router.js
    * The link is created as /#/slug/ which will become /#/aneurysm/
    * A the bottom of the page, there's a link to return to the homepage

3. The Aneurysm page is created using the template, condition.hbs.

4. The view for the Aneurysm page lists all the treatments, as a descriptions list.

Extra Add-Ons
-------------

* Styling is done in LESS, and is minified when compiled.

* Markup in templates will generate semantically-outlined HTML5

Remarks
-------

This project was fun and interesting, but I found that the best part of it was the challenge. The goals that were set are typical of a Backbone project - and essentially any webapp project - so it presented situations that one would encounter commonly, though not all at once. The challenge, I found, was making sure that what was required for each module was in place in order to be using AMD patterns.

To solve this problem, I had to break down the project in granular steps, instead of trying to tackle it all at once.

First, I created the model, view, and router, and then re-wrote them as modules. (I assume going forward, I'll be jumping straight into the latter step.) Second, I created the templates as a very basic output with little html or template logic. Third, after confirming that everything was working, I applied stylesheets to improved templates.

Were I to revisit this project, my first goal would be to make the views be presentable on a mobile device. The stylesheets are all written using EM values, so there is a bit of a head start. Once it is presentable, I would like to look into creating scripts to add user interactivity, such as swiping from treatment to treatment, or collapsible options.



WiserTogether Backbone Test
===========================

This is a skeleton app based on backbone.js designed for you to demonstrate your
skills in writing Javascript-based features and templates. The application is
structured so that it will deliver a static set of information about a health
condition. Follow the instructions below to complete the test and submit your 
work.

Setting Up
==========
If you have cloned this repository, then you are pretty much good to go. Open the
index.html file in your favorite development browser and you should see a screen
that says "Test Application" and "Welcome to the WiserTogether test Backbone
Application". If you see this, then everything is working properly as it stands.

The Test
========
This is a simple test. A model has been created in the apps/test/models.js file
called ``TestApp.Models.Condition``. This model has ``fetch`` and ``save`` methods
on it. When fetching, it will deliver the content outlined in the data structure.
The data structure is a JSON object describing treatments for the "Aneurysm" 
condition (a health condition having to do with the heart).

Your goal is to accomplish the following:

1. Convert the existing namespaced Javascript to [javascript modules](https://github.com/amdjs/amdjs-api/wiki/AMD)
   using the async script loader of your choice. We have included [require.js](http://requirejs.org/docs/start.html) 
   and [the requirejs handlebars plugin](https://github.com/SlexAxton/require-handlebars-plugin) 
   in the repository for your convenience, but feel free to use an alternate 
   async loader if you prefer.
2. Create a link on the first page of the app that brings the user to the 
    Aneurysm page
    * This page should be bookmarkable with a hash-based URL (``#/slug/``)
    * The browser Back button should work to move between this page and the
    main page
3. Create a Template to render the Aneurysm content
    * Be sure this Template utilizes data supplied by the Condition model
4. Create a View to render the Aneurysm content
    * The View needs to fetch data from the Condition model
    * The View needs to render the Template you have created

Once you have a working link and Aneurysm page displaying, do one more thing:

**Do something interesting to make your demo a little bit better.**

Submitting Your Results
=======================
Submit your results by emailing us a patchset created via the git format-patch
command.

Email your patchset to: tech-jobs@wisertogether.com
