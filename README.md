Right On
========

[![Build Status](https://travis-ci.org/sealink/right_on.png?branch=master)](https://travis-ci.org/sealink/right_on)
[![Coverage Status](https://coveralls.io/repos/sealink/right_on/badge.png)](https://coveralls.io/r/sealink/right_on)
[![Dependency Status](https://gemnasium.com/sealink/right_on.png?travis)](https://gemnasium.com/sealink/right_on)
[![Code Climate](https://codeclimate.com/github/sealink/right_on.png)](https://codeclimate.com/github/sealink/right_on)


# DESCRIPTION

Gives rails applications a way to manage rights/roles

If you have a class User, then you can use it like so:

```ruby
class User < ActiveRecord::Base
  include RightOn::RoleModel
end
```

This will create a many-to-many relationship with roles

Roles are sets of rights. Generally people will have multiple roles
e.g. A senior bank teller might have the following roles:
* Senior Bank Teller
* Bank Teller
* Bank Employee

The Role class also has a many-to-many relationship with rights

So a bank employee might have access to the building during regular hours
e.g. has a right 'transactions/add' giving him access to the add method of the transactions controller

Wheras the senior bank teller might be the only one with the 'tellers/create'
Thus he is the only one who can create new tellers.

There are a few types of rights:
* Rights giving access to an entire controller (tellers)
* Rights giving access to a single action within a controller (e.g. tellers/show)
* Rights giving access to multiple actions within a controller (e.g. tellers/read_only or tellers/read_write)
* Rights giving access to particular objects, e.g. a right gives you access to contact clients with a type "High Value Clients"
* Rights giving custom access. To have affect you need to use the has_right? Helper in you views

RightOn comes with controller methods to verify if the user has rights. Simply add the following in your app to controllers
you want to enforce rights:

```ruby
include RightOn::ActionControllerExtensions

before_filter :verify_rights
```

This will enforce that you have a right matching the controllers right
You must have a method "current_user" which is the user model that you've made as the RoleModel

# INSTALLATION

Add to your Gemfile:
gem 'right_on'
