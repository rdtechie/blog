---
title: Enabling hidden posts in Ghost Blog instances
type: blog
date: 2016-06-04T05:34:23+00:00
---

There might be several scenarios under which you need to make sure that certain published posts are hidden on your [Ghost Blog][1] landing page. Out-of-the-box this is not yet supported, but luckily there is an easy way to implement this restriction.

For the purpose of this example, we will not show posts that are tagged a certain way. Let&#8217;s start with the fundamentals, though. Ghost relies on a templating framework called [Handlebars][2]. While it is extensible, it lacks certain capabilities by default.

One of the things that we need to check for when rendering the landing page is whether a post has a specific tag or not. There are two ways of going around that &#8211; either with a `{{has}}` helper, that is built into Ghost (as pointed out in the [Ghost i18n Slack channel][3]), or via a custom conditional helper. Looking at [this community wiki on StackOverflow][4], we get a nice solution for the problem:

```js
Handlebars.registerHelper('ifCond', function (v1, operator, v2, options) {
  switch (operator) {
    case '==':
      return (v1 == v2) ? options.fn(this) : options.inverse(this);
    case '===':
      return (v1 === v2) ? options.fn(this) : options.inverse(this);
    case '<':
      return (v1 < v2) ? options.fn(this) : options.inverse(this);
    case '<=':
      return (v1 <= v2) ? options.fn(this) : options.inverse(this);
    case '>':
      return (v1 > v2) ? options.fn(this) : options.inverse(this);
    case '>=':
      return (v1 >= v2) ? options.fn(this) : options.inverse(this);
    case '&&':
      return (v1 && v2) ? options.fn(this) : options.inverse(this);
    case '||':
      return (v1 || v2) ? options.fn(this) : options.inverse(this);
    default:
      return options.inverse(this);
  }
});
```

In your blog instance root folder, create a new file &#8211; **helpers.js**. This is where we will include our first custom Handlebars helper (and any other helpers, if you will need them later on).

Ghost uses a custom flavor of Handlebars, [express-hbs][5]. For that, in **helpers.js**, we need to include a custom declaration header:

```js
var hbs = require('express-hbs');
```

Now we can formalize the original `ifCond` helper within our helper:

```js
module.exports = function() {  
    hbs.registerHelper('ifCond', function (v1, operator, v2, options) {

    switch (operator) {
        case '==':
            return (v1 == v2) ? options.fn(this) : options.inverse(this);
        case '===':
            return (v1 === v2) ? options.fn(this) : options.inverse(this);
        case '<':
            return (v1 < v2) ? options.fn(this) : options.inverse(this);
        case '<=':
            return (v1 <= v2) ? options.fn(this) : options.inverse(this); 
        case '>':
            return (v1 > v2) ? options.fn(this) : options.inverse(this);
        case '>=':
            return (v1 >= v2) ? options.fn(this) : options.inverse(this);
        case '&&':
            return (v1 && v2) ? options.fn(this) : options.inverse(this);
        case '||':
            return (v1 || v2) ? options.fn(this) : options.inverse(this);
        default:
            return options.inverse(this);
    }
});
```

To be able to use the helper, ensure that you require it in `config.js`:

```js
require('./helpers')();
```

Let's dig through the infrastructure where the post previews for the landing page are handled. Specifically, let&#8217;s dig through `content/themes/casper/partials/loop.hbs`. That is, if you are using the default theme (casper). If you are using a custom theme, you will need to navigate to the right partial view.

Leverage `ifCond` within the iterator to verify whether a post contains the signal flag that you are using to determine whether a post should be displayed on the landing page or not:

```js
{{!-- This is the post loop - each post will be output using this markup --}}
{{#foreach posts}}
{{#ifCond tags.0.slug '==' "translation"}}
    <article class="{{post_class}}">
        <header class="post-header">
            <h2 class="post-title"><a href="{{url}}">{{title}}</a></h2>
        </header>
        <section class="post-excerpt">
            <p>{{excerpt words="26"}} <a class="read-more" href="{{url}}">&raquo;</a></p>
        </section>
        <footer class="post-meta">
            {{#if author.image}}<img class="author-thumb" src="{{author.image}}" alt="{{author.name}}" nopin="nopin" />{{/if}}
            {{author}}
            {{tags prefix=" on "}}
            <time class="post-date" datetime="{{date format="YYYY-MM-DD"}}">{{date format="DD MMMM YYYY"}}</time>
        </footer>
    </article>
{{/ifCond}}
{{/foreach}}
```

That is it! Because Handlebars supports array references (notice `tags.0.slug`), we can simply perform one check instead of creating a custom property in the post rendering code.

Of course, that can be a way to do that for cases where, unlike me, you are not assuming that the tag will also be the first tag within the slug. For that, you will need to modify `renderPost` in `core/server/controllers/frontend/index.js` to carry the aforementioned property:

```js
response.post.isTranslation = (response.post.tags[0].slug.toLowerCase() == "translation");
```

In this case, the property is not there in the stock model, but given the flexibility of JavaScript, we can just add it within one line. The Boolean value can later be used to determine whether to show the post or not.

 [1]: https://ghost.org/
 [2]: https://handlebarsjs.com/
 [3]: https://ghost.slack.com/archives/i18n/p1465059118000496
 [4]: http://stackoverflow.com/a/16315366/303696
 [5]: https://github.com/barc/express-hbs