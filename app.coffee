#--------------------------------------------------------
# Requirements
#--------------------------------------------------------

express     = require 'express'
poet        = require './poet'
markdown    = require("node-markdown").Markdown
fs          = require 'fs'
path        = require 'path'
jade        = require 'jade'
frontmatter = require 'front-matter'


#--------------------------------------------------------
# Express config
#--------------------------------------------------------

app = express()

app.set 'views', path.join(__dirname, "views")
app.set 'view engine', 'jade'
app.use express.static(__dirname + '/public')
app.locals.pretty = true
app.locals.basedir = path.join(__dirname, 'views')

app.listen 3000, ->
  console.log "App running at http://localhost:3000"


#--------------------------------------------------------
# Poet Config
#--------------------------------------------------------

poet = poet app,
  posts: "./content/posts/"
  postsPerPage: 5
  metaFormat: "json"
  routes: 
    '/blog/:post': 'blog/post'

poet.init()


#--------------------------------------------------------
# Routes
#--------------------------------------------------------

# Blog Homepage
app.get '/blog', (req, res)->
  res.render "blog/index"

# Markdown examples - Try '/markdown', '/markdown/one', 'markdown/two'
app.get '/markdown/:page?', (req, res)->
  page = req.params.page || "index"
  filePath = path.join __dirname, "content/markdown/#{page}.md"
  fs.readFile filePath, 'utf-8', (err, data) ->
    if err
      res.status(404).send('Not Found 404')
    else
      res.render "templates/markdown-template",
        meta: frontmatter(data).attributes
        markdownContent: markdown(frontmatter(data).body)

# Pages - using yaml frontmatter
app.get '/:page?', (req, res)->
  page = req.params.page || "index"
  filePath = path.join __dirname, "views/pages/#{page}.jade"
  fs.readFile filePath, 'utf8', (err, data) ->
    if err
      res.status(404).send('Not Found 404')
    else
      res.render "pages/#{page}",
        meta: frontmatter(data).attributes
