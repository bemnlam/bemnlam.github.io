---
title: "Creating a User With Limited Privileges in Postgres"
date: 2020-04-16T20:01:15+08:00
draft: false
description: This post showing how to create a user with limited privileges in PostgreSQL.
tags: ["postgres"]
thumbnail: https://images.pexels.com/photos/4033708/pexels-photo-4033708.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=420&w=1000
---

This post showing how to create a user with limited privileges in PostgreSQL.

## Situation
I created a web app. It reads data from a PostgreSQL database. I want to create a user with read-only privilege and connect to the database.

### Code 
Let say the user you want to create is `webapp_user`:

``` sql
CREATE USER webapp_user WITH ENCRYPTED PASSWORD 'secure_passw0rd';
```

Grant the right to all public tables:

``` sql
GRANT SELECT ON ALL TABLES IN SCHEMA public TO webapp_user;
```

Connect the database using `webapp_user` in the web app.

## I want more power...
Now my web app is not read-only anymore. Users can create/delete some entries in the tables too.

### Code

``` sql
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO webapp_user;
```

Looks simple and cool! But why I got the **`permission denied for sequence XXX_id_seq to YYY`** error while inserting new records to the tables?

If your table has an *auto-increment* field then you need some extra privileges: the privileges to use the sequence-related functions (e.g. `currval` and `nextval`)

``` sql
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public to webapp_user;
```

Example of an *auto-increment* field: the id of the table

### Extra
What if I just want to apply the privilege(s) to a special table?

```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON special_table TO webapp_user;
```

---
Reference:
- [Grant Privileges on Table](https://www.techonthenet.com/postgresql/grant_revoke.php)
- [ERROR: permission denied for sequence cities_id_seq using Postgres](https://stackoverflow.com/q/9325017)

---

*(this blog post also available on [dev.to](https://dev.to/bemnlam/creating-a-user-with-limited-privileges-in-postgres-5ee7/edit))*