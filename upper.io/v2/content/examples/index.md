# Examples and Patterns

This is the perfect page to go after reading the [getting started][1] page.

## Mapping structs to tables

### Typical mapping


```go
type User struct {
  ID         uint64 `db:"id,omitempty"` // `omitempty` skips ID when zero
  FirstName  string `db:"first_name"`
  LastName   string `db:"last_name"`
}
```

Using the `omitempty` option on the "id" tag skips the field when it has the
zero value, that prevents the database from thinking that "0" is an ID.

### Embedded struct

```go
type Auth struct {
  Email string          `db:"email"`
  PasswordHash string   `db:"password_hash,omitempty"`
}

type User struct {
  ID         uint64 `db:"id,omitempty"`
  FirstName  string `db:"first_name"`
  LastName   string `db:"last_name"`
  Auth              `db:",inline"` // `inline` embeds Auth
}
```

Using the `inline` option tells `db` to descend into the struct when looking
for column matches.

## Connecting to a database

### Using the ConnectionURL function from the adapter

```go
import (
  "upper.io/db.v2"
  "upper.io/db.v2/postgresql"
)


var settings = postgresql.ConnectionURL{
  Address:    db.Host("localhost"), // Server IP or hostname.
  Database:   "peanuts",
  User:       "c.brown",
  Password:   "sn00py",
}

sess, err := db.Open(postgresql.Adapter, settings)
...

sess.Close()
```

### Using a DSN string

```go
import (
  "upper.io/db.v2"
  "upper.io/db.v2/postgresql"
)

var dsn string = "postgres://c.brown:sn00py@localhost/peanuts"

settings, err := postgresql.ParseURL(dsn)
...

sess, err := db.Open(postgresql.Adapter, settings)
...

sess.Close()
```

## Getting a collection

### Using Collection()

```go
accountsCol, err := sess.Collection("accounts")
...
res = accountsCol.Find(...)
...

```

`Collection()` returns an error if the collection does not exist and allows the
program to recover.

### Using C()

```go
res = sess.C("accounts").Find(...)
...

```

`C()` is better for chaining and it also has a internal cache that prevents the
collection for being looked up constantly, but it panics if the collection does
not exist.

## Creating a result set

Use the `Find()` method on a collection to create a result set:


```go
col, err = sess.C("accounts")
...

// all the elements on "accounts"
res = col.Find()

// the elements on "accounts" with "id" equal to 11
res = col.Find(db.Cond{"id": 11})
```

## Conditions

The `db.Cond{}` map can be used to express simple conditions:

```go
// the elements on "accounts" with "id" equal to 5, probably just one
res = col.Find(db.Cond{"id": 5})

// the elements on "people" with "age" greater than 21
ageCond = db.Cond{
  "age": 21,
}
res = col.Find(ageCond)

// the elements on "people" with name not equal to "Joanna"
res = col.Find(db.Cond{"name !=": "Joanna"})
```

`db.Cond{}` can also be used to express conditions that require special
escaping or custom operators:


```go
// SQL: "id" IN (1, 2, 3, 4)
res = col.Find(db.Cond{"id": []int{1, 2, 3, 4}})

// SQL: "id" NOT IN (1, 2, 3, 4)
res = col.Find(db.Cond{"id NOT IN": []int{1, 2, 3, 4}})

// SQL: "last_name" IS NULL
res = col.Find(db.Cond{"last_name IS": nil})

// SQL: "last_name" IS NOT NULL
res = col.Find(db.Cond{"last_name IS NOT": nil})

// SQL: "last_name" LIKE "Smi%"
res = col.Find(db.Cond{"last_name LIKE": "Smi%"})
```

When using SQL adapters, conditions can also be expressed in string-arguments
form, use a SQL string as first argument, the list of arguments follows. The
`?` symbol represents a placeholder for an argument that must be properly
escaped.

```go
// These two lines are equivalent.
res = col.Find("id = ?", 5)
res = col.Find("id", 5) // equality by default

// These two as well.
res = col.Find("id > ?", 5)
res = col.Find("id >", 5)

// The placeholder can be omitted when we only have one argument at the end
// of the statement.
res = col.Find("id IN ?", []int{1, 2, 3, 4})
res = col.Find("id IN", []int{1, 2, 3, 4})

// We can't omit placeholders if the argument is not at the end or when we
// expect more than one argument.
res = col.Find("id = ?::integer", "23")

// You can express complex statements as well.
var pattern string = ...
res = col.Find("MATCH(name) AGAINST(? IN BOOLEAN MODE)", pattern)
```

## Counting elements on the set

Use the `Count()` method on a result set to count the number of elements on it:

```go
var cond db.Cond = ...
res = col.Find(cond)

total, err := res.Count()
...
```

## Adding an element to the set

Use a mapped struct to create a new element:

```go
account := Account{
  ID uint64 `db:"id,omitempty"`
  ...
}
nid, err = col.Append(account)
...
```

You can also use a map:

```go
nid, err = col.Append(map[string]interface{}{
  "name":      "Elizabeth",
  "last_name": "Smith",
  ...,
})
...
```

## Mapping result sets to Go values

### Mapping all results at once

If you're dealing with a relatively small number of items, you may want to dump
them all at once, use the `All()` method on a result set to do so:

```go
// A result set can be mapped into an slice of structs
var accounts []Account
err = res.All(&accounts)

// Or into a map
var accounts map[string]interface{}
err = res.All(&accounts)
```

You can use `Limit()` and `Skip()` to adjust the number of results to be
passed:

```
// LIMIT 5 OFFSET 2
err = res.Limit(5).Skip(2).All(&accounts)
```

And `Sort()` to define ordering:

```
err = res.Limit(5).Skip(2).Sort("name").All(&accounts)
```

There is no need to `Close()` the result set when using `All()`.

### Mapping one result

If you expect or need only one element from the result set use `One()`:

```go
var account Account
err = res.One(&account)
```

All the other options for `All()` work with `One()`:

```
err = res.Skip(2).Sort("-name").One(&account)
```

There is no need to `Close()` the result set when using `One()`.

### Mapping results one by one, for large result sets

If your result set is too large for being just dumped into an slice without
killing the system you can also use `Next()` on a result set to process one
result at a time:

```go
var account Account
for err := res.Next(&account); err != nil {
  ...
}
res.Close()
```

All the other options for `All()` work with `Next()`:

```go
var account Account
for err := res.Sort("-name").Next(&account) {
  ...
}
res.Close()
```

When using `Next()` you are the only one that knows when to stop, so you'll
have to `Close()` the result set after finishing using it.

## Updating a result set

If you have a mapped element, you can change it and make the modification
permanent by using the `Update()` method:

```go
var account Account
res = col.Find("id", 5)

err = col.One(account)
...

// Modify the struct
account.Name = "New name"
...

err = res.Update(account)
...
```

`Update()` affects all elements that match the conditions given to `Find()`,
whether it is one element or many.

If you only want to update a column and nothing else, you can also use a map:

```go
res = col.Find("id", 5)

err = res.Update(map[string]interface{}{
  "last_login": time.Now(),
})
...
```

## Deleting a result set

Use `Remove()` on a result set to remove all the elements that match the
conditions given to `Find()`.

```go
res = col.Find("id IN", []int{1, 2, 3, 4})
err = res.Remove()
...
```

## Transactions

Request a transaction session with the `Transaction()` method on a normal
database session:

```go
tx, err := sess.Transaction()
...
```

Use `tx` as you would normally use `sess`:

```go
_, err = tx.C("accounts").Append(...)
...

res = tx.C("accounts").Find(...)

err = res.Update(...)
...

```

The difference from `sess` is that at the end you'll have to either commit or
roll back the operations:

```go
err = tx.Commit() // or tx.Rollback()
...
```

There is no need to `Close()` the transaction, after commiting or rolling back
the transaction gets closed and it's no longer valid.

## The SQL builder

`db` comes with a very powerful query builder, use `Builder()` on a database
session to get a reference to it:

```go
b := sess.Builder()

q := b.SelectAllFrom("accounts")

var accounts []Account
err = q.All(&accounts)
...
```

Using the query builder you can express complex queries for SQL databases:

```go
q = b.Select("id", "name").From("accounts").
  Where("last_name = ?", "Smith").
  OrderBy("name").Limit(10)
```

Even joins are supported:

```go
q = b.Select("a.name").From("accounts AS a").
  Join("profiles AS p").
  On("p.account_id = a.id")

q = b.Select("name").From("accounts").
  Join("owners").
  Using("employee_id")
```

Sometimes the builder won't be able to represent complex queries, if this
happens it may be more effective to use plain SQL:

```go
rows, err = b.Query(`SELECT * FROM accounts WHERE id = ?`, 5)
...
row, err = b.QueryRow(`SELECT * FROM accounts WHERE id = ? LIMIT ?`, 5, 1)
...
res, err = b.Exec(`DELETE FROM accounts WHERE id = ?`, 5)
...
```

Mapping results from raw queries is also really easy:

```go
rows, err = b.Query(`SELECT * FROM accounts WHERE last_name = ?`, "Smith")
...
var accounts []Account
iter := sqlbuilder.NewIterator(rows)
iter.All(&accounts)
...
```

See [builder examples][2] to learn how to master the query builder.

## Add or request an example

It would be awesome if you want to fix an error or add a new example, please
refer to the [contributions][3] to learn how to do so.

[1]: /db.v2/getting-started
[2]: /builder/examples
[3]: /db.v2/contribute
