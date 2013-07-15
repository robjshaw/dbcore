coldfusion / railo - db prototype engine - dbcore
======

### Why I built it
I was over building a object.cfc and feel the orm/framework tech comes with too much overhead to build slick prototype.
You should be able to add a column then ultize it straight away.  But the end game is more client side js less server side cf.

### Why use it?

* Cut dev time down significantly with a dynamic model
* Promotes a good MVC structure
* Promotes a consistant DB naming convention and structure.
* Allows me to prototype very very quickly with twitter bootstrap over the top.

### What my roadmap is

* ajax security layer - js with a secure layer of less than 300 lines of cf
* join table awesomeness
* utility layer

To Get you just do this

```
stArgs = structNew();
stArgs.profileid = url.profileid;
person = dbcore.get(type='profile', stArguments=stArgs);
```

or this

```
stArgs = structNew();
stArgs.emailaddress = qget.email;
stArgs.querylimitBy = 140;
stArgs.want = 'firstname,lastname';
p = dbcore.get(type='profile', stArguments=stArgs);
```

You could then update straight away

```
stArgs = structNew();
stArgs.emailaddress = qget.email;
stArgs.profileid = p.profileid;
dbcore.update(type='profile', stArguments=stArgs);
```

Creating is similar

```
stArgs = structNew();
stArgs.emailaddress = qget.email;
stArgs.firstname = qget.firstname;
stArgs.lastname = qget.lastname;

p = dbcore.create(type='profile', stArguments=stArgs);
```
Of course delete would be

```
stArgs = structNew();
stArgs.profileid = url.profileid;
dbcore.delete(type='profile',stArguments=stArgs);
```

There are a couple of utility functions such as getTitle which is useful to get the title from an ID in a join table.

TBD

