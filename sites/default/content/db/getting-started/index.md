# upper.io/db

![upper.io/db package](/db/res/general.png)

The `upper.io/db` package for [Go][2] provides a *common interface* for
interacting with different data sources using *adapters* that wrap mature
database drivers.

```go
import(
  "upper.io/db"             // main package
  "upper.io/db/postgresql"  // adapter for PostgreSQL
)
```

`db` supports the [MySQL][13], [PostgreSQL][14], [SQLite][15] and [QL][16]
databases and provides partial support for [MongoDB][17].

## Introduction

### What's the idea behind `upper.io/db`?

`db` centers around the concept of sets. A collection (or table) represents a
set that contains data elements (or rows); `db` provides tools to work with
said elements.

![Database](/db/res/database.png)

In the following example we fill the `people` slice with all the elements from
the "people" collection whose "name" field (or column) equals the value "Max".

```go
var people []Person

col, err = sess.Collection("people")
...

res = col.Find(db.Cond{"name": "Max"})
err = res.All(&people)
...
```

If we only wanted one result, we could have used `res.One()` instead:

```go
var person Person

col, err = sess.Collection("people")
...

res = col.Find(db.Cond{"name": "Max"})
err = res.All(&person)
...
```

In the above example, we used `sess.Collection()` to get a collection reference
and then we used the `Find()` method on the said reference to filter out the
results we want; this creates a result set res which we can use to map results
into an slice (with `All()`) or into a single struct (with `One()`).

The result res points to all the rows from the "people" table that match
whatever conditions were passed to `db.Collection.Find()`. This result set is
not only useful for getting and mapping data from permanent storage, but to
update or delete the whole subset as well.

```go
res = col.Find(db.Cond{"name": "Jhon"})
err = res.Update(db.M{"name": "John"})
...
```

![Collections](/db/res/collection.png)

A result cannot be used to add an item to the collection, because a result set
only defines a subset of rows that already exists. If you wanted to add a row
to the collection you can use the `Append()` method on the collection.

```go
person = Person{
  Name:     "Harper",
  LastName: "Lee",
}
nid, err = col.Append(person)
...
```

If the table supports automatic indexes, then the `nid` returned by `Append()`
would be set to the value of the newly added index. The nid is actually an
`interface{}` type, so you'll probably have to cast it if you want to use it.

```go
rid, err = col.Append(person)
...
id, _ = nid.(int64)
```

The simple CRUD operations depicted above may come in handy for getting and
saving data from different databases, but what if you wanted to use advanced
queries on SQL databases? Then you can use the SQL builder db uses:

```go
bob = sess.Builder()
...

q = bob.Select("a.name").From("accounts a").
  Join("profile p").On("a.profile_id = p.id")

var accounts []Account
err = q.Iterator().All(&accounts)
...
```

Please note that SQL builder is only supported on SQL databases.

If you think the SQL builder methods are not flexible enough you can also use
raw SQL:

```go
bob = sess.Builder()
...

q = bob.Query("SELECT * FROM accounts WHERE id = ?", 5)

var account Account
err = q.Iterator().One(&account)
```

As you can see `db` offers you a range of tools that are designed to make
working with databases less tedious and more productive.

## Installation

The `upper.io/db` package depends on the [Go compiler and tools][4] and it's
compatible with Go 1.1 and above.

Use `go get` to download `db`:

```sh
go get -v -u upper.io/db
```

## Database adapters

The `db` package provides basic functions and interfaces but in order to
actually communicate with a database you'll also need a **database adapter**.

![Adapters](/db/res/adapters.png)

Make sure to tead the instructions from the specific adapter you'd like to use:

* [MySQL](/db/mysql/)
* [MongoDB](/db/mongo)
* [PostgreSQL](/db/postgresql)
* [QL](/db/ql)
* [SQLite](/db/sqlite/)

## Mapping tables to structs

Mapping a table to a struct is easy, you only have to add the db tag next to an
**exported field** definition and provide options if you need them:

```go
type Person struct {
  ID       uint64 `db:"id,omitempty"` // use `omitempty` to let auto increment set the value.
  Name     string `db:"name"`
  LastName string `db:"last_name"`
}
```

You can mix `db` tags with other tags, such as those used for JSON mapping:

```go
type Person struct {
  ID        uint64 `db:"id,omitempty" json:"id"`
  Name      string `db:"name" json:"name"`
  ...
  Password  string `db:"password,omitempty" json:"-"`
}
```

If you don't provide explicit mappings, `db` will try to use the field name
(case-sensitive), if you don't want that to happen you can set `-` as the name:

```go
type Person struct {
  ...
  Token    string `db:"-"` // ignore this field completely.
}
```

## Setting up a database session

Import the both the `upper.io/db` and the adapter packages into your
application:

```go
import (
  "upper.io/db"
  "upper.io/db/postgresql" // example adapter package
)
```

Make sure to read the adapter page for specific installation instructions.

All adapters include a `ConnectionURL` function that you can use to create a
DSN:

```go
var settings = postgresql.ConnectionURL{
  User:     "john",
  Password: "p4ss",
  Address:  db.Host("localhost"),
  Database: "myprojectdb",
}
```

Create a database session with the `db.Open()` function:

```go
sess, err = db.Open(postgresql.Adapter, settings)
...
```

The `sess` variable is a database session, you can use any `db.Database`
methods on it, such as `Collection()`, that will give you a collection
reference.

```go
usersCol, err = sess.Collection("users")
...
```

Or `C()` that does the same as `Collection()` but panics if the collection does
not exists:

```go
res = sess.C("users").Find()
...
```

Once you're done with the collection, you can use `Close()` to close it:

```go
err = sess.Close()
...
```

## Basic CRUD usage

We can use the database session `sess` to get a collection referece and insert
a value into it:

```go
person := Person{
  Name:     "Hedy",
  LastName: "Lamarr",
}

peopleCol, err = sess.Collection("people")
...

id, err = peopleCol.Append(person)
...
```

If you're absolutely sure the collection exists and you don't fear a panic in
case it doesn't, you could also use the `C()` method and chain `db.Collection`
methods to it:

```go
id, err = sess.C("people").Append(person)
...
```

## The Find() method

You can use `Find()` on a collection reference to get a result set from that
collection.

```go
res = sess.C("people").Find()
```

`Find()` accepts conditions that you can describe with the `db.Cond{}` map:

```go
res = sess.C("people").Find(db.Cond{
  "id": 25,
})
```

### The db.Cond map

`db.Cond{}` is a map with `string` keys and `interface{}` values, the keys
represent columns and the values represent, well, values. By default
`db.Cond{}` expresses an equality between columns and values:

```go
cond = db.Cond{
  "id": 36, // id equals 36
}
```

But you can also add special operators next to the column:

```go
cond = db.Cond{
  "id >": 36, // id greater than 36
}
```

Besides basic operators, you can also use special operators that may only work
on certain databases, such as `LIKE`:

```go
cond = db.Cond{
  "name LIKE": "Pete%", // SQL: name LIKE 'Pete%'
}
```

You can define `db.Cond{}` with more than one key-value pair and that means
than you want both conditions to be met:

```go
// name = 'John' AND "last_name" = 'Smi%'
cond = db.Cond{
  "name": "John",
  "last_name LIKE": "Smi%",
}
```

### Narrowing result sets

Once you have a basic understanding of result sets, you can start using
conditions, limits and offsets to reduce the amount of items returned in a
query.

Use the [db.Cond][21] type to define conditions for `db.Collection.Find()`.

```go
type db.Cond map[string]interface{}
```

```go
// SELECT * FROM users WHERE user_id = 1
res = col.Find(db.Cond{"user_id": 1})
```

If you want to add multiple conditions just provide more keys to the
[db.Cond][21] map:

```go
// SELECT * FROM users where user_id = 1
//  AND email = "ser@example.org"
res = col.Find(db.Cond{
  "user_id": 1,
  "email": "user@example.org",
})
```

provided conditions will be grouped under an *AND* conjunction, by default.

If you want to use the *OR* disjunction instead try the [db.Or][23] function.

The following code:

```go
// SELECT * FROM users WHERE
// email = "user@example.org"
// OR email = "user@example.com"
res = col.Find(db.Or(
  db.Cond{
    "email": "user@example.org",
  },
  db.Cond{
    "email": "user@example.com",
  }
))
```

uses *OR* disjunction instead of *AND*.

Complex *AND* filters can be delimited by the [db.And][22] function.

This example:

```go
res = col.Find(db.And(
  db.Or(
    db.Cond{
      "first_name": "Jhon",
    },
    db.Cond{
      "first_name": "John",
    },
  ),
  db.Or(
    db.Cond{
      "last_name": "Smith",
    },
    db.Cond{
      "last_name": "Smiht",
    },
  ),
))
```

means `(first_name = "Jhon" OR first_name = "John") AND (last_name = "Smith" OR
last_name = "Smiht")`.

### Result sets are chainable

The `col.Find()` instruction returns a [db.Result][20] interface, and some
methods of [db.Result][20] return the same interface, so they can be chained:

This example:

```go
res = col.Find().Skip(10).Limit(8).Sort("-name")
```

skips ten items, counts up to eight items and sorts the results by name
(descendent).

If you want to know how many items does the set hold, use the
`db.Result.Count()` method:

```go
c, err := res.Count()
```

this method will ignore `Offset` and `Limit` settings, so the returned result
is the total size of the result set.

### Dealing with `NULL` values

The `database/sql` package provides some special types
([NullBool](http://golang.org/pkg/database/sql/#NullBool),
[NullFloat64](http://golang.org/pkg/database/sql/#NullBool),
[NullInt64](http://golang.org/pkg/database/sql/#NullInt64) and
[NullString](http://golang.org/pkg/database/sql/#NullString)) that can be used
to represent values than may be `NULL` at some point.

The `postgresql`, `mysql`, `sqlite` and `ql` adapters support those special
types and they work as expected:

```go
type TestType struct {
  ...
  salary sql.NullInt64
  ...
}
```

### Marshaler and Unmarshaler interfaces

The `upper.io/db` package provides two special interfaces that can be used to
transform data before saving it into the database and to revert the
transformation when the data is retrieved.

The [db.Marshaler][27] interface is defined as:

```go
type Marshaler interface {
  MarshalDB() (interface{}, error)
}
```

The `MarshalDB()` function should be used to transform the type's current value
into a format that the database can accept and save.

For instance, if you'd like to save a `time.Time` data as an unix timestamp
(integer) instead of saving it as an string representation of the date, you
should implement `MarshalDB()`.

The [db.Unmarshaler][28] interface is defined as:

```go
type Unmarshaler interface {
  UnmarshalDB(interface{}) error
}
```

If you'd like to transform the stored UNIX timestamp into a `time.Time` value,
you should implement `UnmarshalDB()`.

The `UnmarshalDB()` function should be used to transform a value that was
retrieved from the database into a Go type.

The following example defines a timeType struct that can handle dates using the
native `time.Time` type. These dates are actually stored as integers (UNIX
timestamp). The `MarshalDB()` and `UnmarshalDB()` functions work as opposite
transformations.

```go
// Struct for testing marshalling.
type timeType struct {
  // Time is handled internally as time.Time but saved
  // as an (integer) unix timestamp.
  value time.Time
}

// time.Time -> unix timestamp
func (u timeType) MarshalDB() (interface{}, error) {
  return u.value.Unix(), nil
}

// Note that we're using *timeType and no timeType.
// unix timestamp -> time.Time
func (u *timeType) UnmarshalDB(v interface{}) error {
  var i int

  switch t := v.(type) {
  case string:
    i, _ = strconv.Atoi(t)
  default:
    return db.ErrUnsupportedValue
  }

  t := time.Unix(int64(i), 0)
  *u = timeType{t}

  return nil
}

// struct with a *timeType property.
type birthday struct {
  ...
  BornUT *timeType `db:"born_ut"`
  ...
}
```

**Note:** Currently, marshaling and unmarshaling are only available on the
`postgresql`, `mysql`, `sqlite` and `ql` adapters.

## Operations on databases

There are many more things you can do with a [db.Database][18] struct besides
getting a collection.

For example, you could get a list of all collections within the database:

```go
all, err = sess.Collections()
for _, name := range all {
  fmt.Printf("Got collection %s.\n", name)
}
```

If you need to switch databases, you can use the `db.Database.Use()` method

```go
err = sess.Use("another_database")
```

## Transactions

You can use the `db.Database.Transaction()` function to start a transaction (if
the database adapter supports such feature). `db.Database.Transaction()`
returns a clone of the session (type [db.Tx][29]) with two added functions:
`db.Tx.Commit()` and `db.Tx.Rollback()` that you can use to save the
transaction or to abort it.

```go
var tx db.Tx
if tx, err = sess.Transaction(); err != nil {
  log.Fatal(err)
}

var artist db.Collection
if artist, err = tx.Collection("artist"); err != nil {
  log.Fatal(err)
}

if _, err = artist.Append(item); err != nil {
  log.Fatal(err)
}

if err = tx.Commit(); err != nil {
  log.Fatal(err)
}
```

## Tips and tricks

### Logging

You can force `upper.io/db` to print SQL statements and errors to standard
output by using the `UPPERIO_DB_DEBUG` environment variable:

```console
UPPERIO_DB_DEBUG=1 ./go-program
```

You can also use this environment variable when running tests.

```console
cd $GOPATH/src/upper.io/db/sqlite
UPPERIO_DB_DEBUG=1 go test
...
2014/06/22 05:15:20
  SQL: SELECT "tbl_name" FROM "sqlite_master" WHERE ("type" = 'table')

2014/06/22 05:15:20
  SQL: SELECT "tbl_name" FROM "sqlite_master" WHERE ("type" = ? AND "tbl_name" = ?)
  ARG: [table artist]
...
```

### Working with the underlying driver

Many situations will require you to use methods that are specific to the
underlying driver, for example, if you're in the need of using the
[mgo.Session.Ping](http://godoc.org/labix.org/v2/mgo#Session.Ping) method, you
can retrieve the underlying `*mgo.Session` as an `interface{}`, cast it with
the appropriate type and use the `mgo.Session.Ping()` method on it, like this:

```go
drv = sess.Driver().(*mgo.Session)
err = drv.Ping()
```

This is another example using `db.Database.Driver()` with a SQL adapter:

```go
drv = sess.Driver().(*sql.DB)
rows, err = drv.Query("SELECT name FROM users WHERE age=?", age)
```


## License

The MIT license:

> Copyright (c) 2013-2015 The upper.io/db authors.
>
> Permission is hereby granted, free of charge, to any person obtaining
> a copy of this software and associated documentation files (the
> "Software"), to deal in the Software without restriction, including
> without limitation the rights to use, copy, modify, merge, publish,
> distribute, sublicense, and/or sell copies of the Software, and to
> permit persons to whom the Software is furnished to do so, subject to
> the following conditions:
>
> The above copyright notice and this permission notice shall be
> included in all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
> LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
> OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
> WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[1]: https://upper.io
[2]: http://golang.org
[3]: http://git-scm.com/
[4]: http://golang.org/doc/install
[5]: http://golang.org/doc/go1.1
[6]: http://godoc.org/upper.io/db
[7]: https://github.com/upper/db
[8]: https://github.com/upper/db/issues
[9]: https://github.com/upper/site
[10]: https://github.com/upper/db-docs/issues
[11]: https://help.github.com/articles/fork-a-repo
[12]: https://help.github.com/articles/fork-a-repo#pull-requests
[13]: http://www.mysql.com/
[14]: http://www.postgresql.org/
[15]: http://www.sqlite.org/
[16]: https://github.com/cznic/ql
[17]: http://www.mongodb.org/
[18]: http://godoc.org/upper.io/db#Database
[19]: http://godoc.org/upper.io/db#Collection
[20]: http://godoc.org/upper.io/db#Result
[21]: http://godoc.org/upper.io/db#Cond
[22]: http://godoc.org/upper.io/db#And
[23]: http://godoc.org/upper.io/db#Or
[24]: http://godoc.org/upper.io/db#Constrainer
[25]: http://godoc.org/upper.io/db#Raw
[26]: http://godoc.org/upper.io/db#ConnectionURL
[27]: http://godoc.org/upper.io/db#Marshaler
[28]: http://godoc.org/upper.io/db#Unmarshaler
[29]: http://godoc.org/upper.io/db#Tx
[30]: http://godoc.org/upper.io/db#IDSetter
[31]: http://godoc.org/upper.io/db#Int64IDSetter
[32]: http://godoc.org/upper.io/db#Uint64IDSetter
[33]: https://godoc.org/upper.io/builder/meta
