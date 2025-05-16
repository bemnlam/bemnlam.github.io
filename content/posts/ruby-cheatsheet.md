---
title: "Ruby Cheatsheet"
summary: I don't need ↑↑↓↓←→←→BA but I need this when writing Ruby scripts.
date: 2020-09-15T08:40:48+08:00
draft: false
categories: ["Dev"]
tags: ["cheatsheet", "ruby"]
cover_image: https://static.dribbble.com/users/79571/screenshots/2232375/ruby.png
thumbnail: https://static.dribbble.com/users/79571/screenshots/2232375/ruby.png
---

This post contains many useful snippets for me when writing **Ruby** scripts. I will keep updating this note in the future.


## 🏷 About File

### Absolute Path

`__dir__` returns the current path.

```ruby
File.join(__dir__, file_name_no_path )
```

### Read / Write a file

Read the content of `file_name` to `buffer`

```ruby
buffer = File.read( file_name )
```

Write `content` to `file_name`. File will be created when it does not exist.

```ruby
File.open( file_name , "w") { |f| f.write( content ) }
```

## 🏷 About String

### String template

To create a multiline string template:

```bash
template = <<-EOCONTENT
Your
Multiline
Text
Content
EOCONTENT
```

### String Interpolation 

```ruby
str = "This is a string with #{variable_name}."
```

### Trim a String
```ruby
"    Hello James ".strip  #=> "Hello James"
```

### Null Or Empty

```ruby
str.nil? ? "null" : "not_null"
str.empty? ? "empty" : "not_empty"
```

### Titlecase / UPPERCASE / lowercase / Capitalize

All returns a new copy. Examples from [this answer in StackOverflow](https://stackoverflow.com/a/1020571/13742790).

```ruby
"hello James".titleize    #=> "Hello James"
"hello James".upcase      #=> "HELLO JAMES"
"hello James".downcase    #=> "hello james"
"hello James".capitalize  #=> "Hello james"
```

Note: **Alter the original string** by adding `!` right after the method.

```ruby
"hello James".downcase!
```

## 🏷 About Input

### Console Input

Ask a question and wait for user input:

```ruby
print "Your question: "
user_input = gets
```

(you may need to `strip` the `user_input` to ger rid of a tailing newline.)

## 🏷 About Regex

Test a ruby regex: https://rubular.com/

### Named regex capturing group

Steps:

1. Prepare the regex: `^(\w+)(Query|Command)$`.
2. Add `?<named_group>` at the beginning **inside** that capturing group.
3. Do the regex `match()`
4. Retrieve the named group: `[:named_group]`

```ruby
## name: SomeStuffQuery ; result: SomeStuff
result = /^(?<named_group>\w+)(Query|Command)$/.match(name)[:named_group]
```

If your regex is valid, you should be able to see the captured group and related content:

![image-20200915091031591](/img/image-20200915091031591.png)

## 🏷 About Bundler and Gemfile

[Bundler](https://bundler.io/) helps you to manage gem denendencies in your project.

### Install bundler

```zsh
gem install bundler
bundler -v
```

### Setup and restore dependencies

Create a `Gemfile`:

```gemfile
source 'https://rubygems.org'
gem 'dotenv', '~> 2.7', '>= 2.7.5'
gem "mustache", "~> 1.0"
```

#### Globally

```bash
bundle # may requires sudo
```

#### Locally 

To install gems at a relative path e.g. at the `lib` folder:
```bash
bundle install --path=./lib
```

a `.bundle` folder will be generated, together with your `Gemfile.lock`.

### Check the info of a installed gem

```bash
❯ bundle info ruby_http_client
  * ruby_http_client (3.5.1)
        Summary: A simple REST client
        Homepage: http://github.com/sendgrid/ruby-http-client
        Path: ~/git/my-folder/lib/ruby/2.6.0/gems/ruby_http_client-3.5.1
```

---

_(cover image from [this dribble](https://dribbble.com/shots/2232375-Ruby))_