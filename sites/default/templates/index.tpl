<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta content="width=device-width, initial-scale=1.0" name="viewport" />
    <link href="https://fonts.googleapis.com/css?family=Raleway:500,700|Source+Serif+Pro:400,700|Source+Code+Pro:400,600" rel="stylesheet" type="text/css" />
    <link href="{{ asset "/css/style.css" }}" rel="stylesheet" />
    <link href="{{ asset "/css/syntax.css" }}" rel="stylesheet">
    <title>
      {{ if .IsHome }}
        {{ setting "page/head/title" }}
      {{ else }}
        {{ if .Title }}
          {{ .Title }} {{ if setting "page/head/title" }} &middot; {{ setting "page/head/title" }} {{ end }}
        {{ else }}
          {{ setting "page/head/title" }}
        {{ end }}
      {{ end }}
    </title>
    <link rel="apple-touch-icon-precomposed" sizes="144x144" href="{{ asset "/apple-touch-icon-precomposed.png" }}">
    <link rel="shortcut icon" href="{{ asset "/favicon.ico"}}">

    <!-- Code highlighting -->
    <link rel="stylesheet" href="//menteslibres.net/static/highlightjs/styles/default.css?v0000">
    <script src="//menteslibres.net/static/highlightjs/highlight.pack.js?v0000"></script>
    <script>hljs.initHighlightingOnLoad();</script>

    <script src="{{asset "js/main.js"}}"></script>

    <meta name="go-import" content="upper.io/db git https://github.com/upper/db">
    <meta name="go-import" content="upper.io/builder git https://github.com/upper/builder">

    <meta name="go-import" content="upper.io/queue git https://github.com/upper/queue">
    <meta name="go-import" content="upper.io/ground git https://github.com/upper/ground">
    <meta name="go-import" content="upper.io/bridge git https://github.com/upper/bridge">
    <meta name="go-import" content="upper.io/db-misc git https://github.com/upper/db-misc">
    <meta name="go-import" content="upper.io/cache git https://github.com/upper/cache">
    <meta name="go-import" content="upper.io/patterns git https://github.com/upper/patterns">
    <meta name="go-import" content="upper.io/i git https://github.com/upper/i">
    <meta name="go-import" content="upper.io/bond git https://github.com/upper/bond">
  </head>

  <body>
    <header class="main-header">
      <nav class="nav--main">
        <div class="nav--sections">
          <a class="nav__trigger nav__trigger--sections" href="/db"><span>upper.io.</span>/db</a>
          {{ if .BreadCrumb }}
            <ul class="breadcrumb">
              {{ range .BreadCrumb }}
                <li><a href="{{ asset .link }}">{{ .text }}</a></li>
              {{ end }}
            </ul>
          {{ end }}
        </div>
        <div class="nav--adapters">
          <span class="nav__trigger--adapters" id="adapters-menu-trigger">adapters</span>
          <ul id="adapters-menu">
            <li><a href="/db/postgresql">PostgreSQL</a></li>
            <li><a href="/db/mysql">MySQL</a></li>
            <li><a href="/db/sqlite">SQLite</a></li>
            <li><a href="/db/ql">QL</a></li>
            <li><a href="/db/mongo">MongoDB</a></li>
          </ul>
        </div>
      </nav>
      {{ if eq .CurrentPage.URL "/db" }}
        <div class="hero">
          <div class="container">
            <img class="hero__background" src="{{ asset "/images/city.svg" }}" />
            <div class="hero__info">
              <img class="hero__gopher" src="{{ asset "/images/gopher.svg" }}" />
              <h1 class="hero__title">
                <a href="/">
                  <img src="{{ asset "/images/logo.svg" }}" />
                  <span>upper.io/db</span>
                </a>
              </h1>
              <p class="hero__description">A Package for
              <strong>Go</strong>which provides a common interface for interacting with different data sources*</p>
            </div>
            <div class="github">
              <a class="github__icon" target="_blank" href="https://github.com/upper/db">Check the project on github</a>
            </div>
          </div>
        </div>
      {{ end }}
    </header>
    <main>
      <nav class="sections__nav">
        <div class="nav__trigger--sections__nav" id="sections-menu-trigger">Index</div>
        <div class="sections__nav__block" id="sections-menu">
          <h2 class="sections__nav__title">
            {{ range .GetTitlesFromLevel 0 }}
              <a href="{{ .url }}">{{ .text }}</a>
            {{ end }}
          </h2>
          <ul>
          {{ range .GetTitlesFromLevel 1 }}
            <li><a href="{{ .url }}">{{ .text }}</a></li>
          {{ end }}
          </ul>
        </div>
      </nav>

      <article>
        <div class="container">
          {{ if eq .CurrentPage.URL "/db" }}
            <p class="pressly text-center hidden-extra-small">This project is proudly sponsored by
            <a href="https://www.pressly.com" target="_blank"><img class="vertical-middle logo-pressly" src="{{ asset "images/pressly.png" }}" /></a></p>
            <div class="features grid-3">
              <div class="feature">
                <h2 class="feature__title">Is upper.io/db an ORM?</h2>
                <p class="feature__description">
                  Yes, a very basic one, but it&#226;&#8364;&#8482;s not tyrannical* it just abstracts the most common operations you may need when working with database management systems and lets you focus on designing the complex tasks.
                </p>
                <img class="feature__icon" src="{{ asset "images/figure-01.svg" }}" />
              </div>
              <div class="feature">
                <h2 class="feature__title">What's the idea behind it?</h2>
                <p class="feature__description">
                  The main concept behind upper.io/db centers around subsets of items from a collection, which is a set of items that have properties. These properties may be fixed (SQL tables) or flexible (NoSQL collections). Once you have a collection reference (db.Collection) you can use the Find() method on it to delimit the subset.
                </p>
                <img class="feature__icon" src="{{ asset "images/figure-02.svg" }}" />
              </div>
              <div class="feature">
                <h2 class="feature__title">A quick usage example</h2>
                <p class="feature__description">
                  This is a syntax example in which col is a value that satisfies db.Collection, person is an array of an user-defined struct and res satisfies db.Result:
                </p>
                <img class="feature__icon" src="{{ asset "images/figure-03.svg" }}" />
              </div>
            </div>
          {{ end }}
          <section id="get-started">

            {{ if .Content }}

              {{ .ContentHeader }}

              {{ .Content }}

              {{ .ContentFooter }}

            {{ else }}

              {{ if .CurrentPage }}
                <h1>{{ .CurrentPage.text }}</h1>
              {{ end }}

              <ul>
                {{ range .SideMenu }}
                  <li>
                    <a href="{{ asset .link }}">{{ .text }}</a>
                  </li>
                {{ end }}
              </ul>

            {{end}}

            {{ if setting "page/body/copyright" }}
              <p>{{ setting "page/body/copyright" | htmltext }}</p>
            {{ end }}

          </section>
        </div>
      </article>
    </main>
    <script src="js/app.js"></script>
    {{ if setting "page/body/scripts/footer" }}
      <script type="text/javascript">
        {{ setting "page/body/scripts/footer" | jstext }}
      </script>
    {{ end }}
  </body>
</html>
